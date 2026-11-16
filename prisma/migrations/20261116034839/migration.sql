-- CreateEnum
CREATE TYPE "ProjectStatus" AS ENUM ('DRAFT', 'GENERATING', 'READY', 'BUILDING', 'TESTING', 'REVIEWING', 'FIXING', 'SYNCING', 'FAILED');

-- CreateEnum
CREATE TYPE "ArtifactType" AS ENUM ('REQUIREMENTS', 'ARCHITECTURE', 'DATABASE', 'API', 'PLAN', 'CODE', 'REVIEW', 'BUILD', 'TEST');

-- CreateEnum
CREATE TYPE "KnowledgeSourceKind" AS ENUM ('DOCUMENT', 'URL', 'GITHUB', 'PROJECT');

-- CreateEnum
CREATE TYPE "AgentStatus" AS ENUM ('DISCONNECTED', 'CONNECTED', 'BUSY', 'ERROR');

-- CreateEnum
CREATE TYPE "RunStatus" AS ENUM ('QUEUED', 'RUNNING', 'SUCCESS', 'FAILED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "RunOperation" AS ENUM ('GENERATE', 'BUILD', 'TEST', 'REVIEW', 'FIX', 'FILE_READ', 'FILE_WRITE', 'FILE_DELETE', 'TERMINAL', 'GIT_STATUS', 'GIT_DIFF', 'GIT_COMMIT', 'GIT_PUSH', 'GIT_PULL', 'GIT_CLONE', 'SYNC');

-- CreateEnum
CREATE TYPE "AgentJobStatus" AS ENUM ('QUEUED', 'RUNNING', 'SUCCESS', 'FAILED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "AgentJobType" AS ENUM ('FILE_READ', 'FILE_WRITE', 'FILE_DELETE', 'FILE_RENAME', 'TERMINAL', 'BUILD', 'TEST', 'GIT_STATUS', 'GIT_DIFF', 'GIT_COMMIT', 'GIT_PUSH', 'GIT_PULL', 'GIT_CLONE', 'WATCH');

-- CreateEnum
CREATE TYPE "AIProviderType" AS ENUM ('OPENROUTER', 'OPENAI', 'GEMINI', 'ANTHROPIC', 'CUSTOM');

-- CreateEnum
CREATE TYPE "ProjectVisibility" AS ENUM ('PRIVATE', 'PUBLIC');

-- CreateEnum
CREATE TYPE "GitProvider" AS ENUM ('GITHUB');

-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('USER', 'ADMIN');

-- CreateEnum
CREATE TYPE "GitSyncStatus" AS ENUM ('NOT_CONNECTED', 'CONNECTED', 'AHEAD', 'BEHIND', 'DIVERGED', 'CLEAN', 'DIRTY', 'ERROR');

-- CreateEnum
CREATE TYPE "ProjectRole" AS ENUM ('OWNER', 'ADMIN', 'DEVELOPER', 'REVIEWER', 'VIEWER');

-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "githubId" TEXT NOT NULL,
    "githubUsername" TEXT,
    "githubName" TEXT,
    "email" TEXT,
    "avatarUrl" TEXT,
    "role" "UserRole" NOT NULL DEFAULT 'USER',
    "isBlocked" BOOLEAN NOT NULL DEFAULT false,
    "githubAccessTokenEnc" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Session" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "tokenHash" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lastSeenAt" TIMESTAMP(3),

    CONSTRAINT "Session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Project" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "stack" TEXT,
    "status" "ProjectStatus" NOT NULL DEFAULT 'DRAFT',
    "visibility" "ProjectVisibility" NOT NULL DEFAULT 'PRIVATE',
    "gitProvider" "GitProvider",
    "githubOwner" TEXT,
    "githubRepository" TEXT,
    "githubBranch" TEXT NOT NULL DEFAULT 'main',
    "githubRepoId" TEXT,
    "localProjectId" TEXT,
    "localPath" TEXT,
    "localAgentId" TEXT,
    "gitSyncStatus" "GitSyncStatus" NOT NULL DEFAULT 'NOT_CONNECTED',
    "lastSyncedAt" TIMESTAMP(3),
    "settings" JSONB,

    CONSTRAINT "Project_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProjectMember" (
    "id" TEXT NOT NULL,
    "projectId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "role" "ProjectRole" NOT NULL DEFAULT 'VIEWER',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ProjectMember_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Artifact" (
    "id" TEXT NOT NULL,
    "projectId" TEXT NOT NULL,
    "type" "ArtifactType" NOT NULL,
    "name" TEXT NOT NULL,
    "content" JSONB NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Artifact_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "KnowledgeSource" (
    "id" TEXT NOT NULL,
    "projectId" TEXT NOT NULL,
    "kind" "KnowledgeSourceKind" NOT NULL,
    "embeddingProvider" "AIProviderType" NOT NULL,
    "embeddingModel" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "uri" TEXT NOT NULL,
    "lastIndexedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "KnowledgeSource_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "KnowledgeChunk" (
    "id" TEXT NOT NULL,
    "projectId" TEXT NOT NULL,
    "sourceId" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "embedding" JSONB,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "KnowledgeChunk_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ProjectRun" (
    "id" TEXT NOT NULL,
    "projectId" TEXT NOT NULL,
    "operation" "RunOperation" NOT NULL,
    "status" "RunStatus" NOT NULL DEFAULT 'QUEUED',
    "input" JSONB,
    "output" JSONB,
    "error" TEXT,
    "startedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "finishedAt" TIMESTAMP(3),

    CONSTRAINT "ProjectRun_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AIProvider" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "provider" "AIProviderType" NOT NULL,
    "label" TEXT NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "model" TEXT,
    "fallbackProvider" "AIProviderType",
    "fallbackModel" TEXT,
    "temperature" DOUBLE PRECISION,
    "maxTokens" INTEGER,
    "apiKeyEnc" TEXT,
    "baseUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AIProvider_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AIRequest" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "projectId" TEXT,
    "provider" "AIProviderType" NOT NULL,
    "model" TEXT,
    "task" TEXT NOT NULL,
    "inputTokens" INTEGER NOT NULL DEFAULT 0,
    "outputTokens" INTEGER NOT NULL DEFAULT 0,
    "totalTokens" INTEGER NOT NULL DEFAULT 0,
    "latencyMs" INTEGER,
    "estimatedCost" DECIMAL(18,8),
    "status" TEXT NOT NULL,
    "error" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AIRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LocalAgent" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "agentName" TEXT NOT NULL,
    "machineName" TEXT,
    "platform" TEXT,
    "architecture" TEXT,
    "version" TEXT,
    "status" "AgentStatus" NOT NULL DEFAULT 'DISCONNECTED',
    "tokenHash" TEXT,
    "pairedAt" TIMESTAMP(3),
    "connectedAt" TIMESTAMP(3),
    "lastSeenAt" TIMESTAMP(3),
    "capabilities" JSONB,
    "workspaceRoot" TEXT,

    CONSTRAINT "LocalAgent_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AgentJob" (
    "id" TEXT NOT NULL,
    "projectId" TEXT NOT NULL,
    "agentId" TEXT NOT NULL,
    "type" "AgentJobType" NOT NULL,
    "status" "AgentJobStatus" NOT NULL DEFAULT 'QUEUED',
    "input" JSONB,
    "output" JSONB,
    "error" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "startedAt" TIMESTAMP(3),
    "finishedAt" TIMESTAMP(3),

    CONSTRAINT "AgentJob_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GitRepository" (
    "id" TEXT NOT NULL,
    "projectId" TEXT NOT NULL,
    "provider" "GitProvider" NOT NULL DEFAULT 'GITHUB',
    "owner" TEXT NOT NULL,
    "repository" TEXT NOT NULL,
    "githubRepoId" TEXT,
    "defaultBranch" TEXT NOT NULL DEFAULT 'main',
    "connected" BOOLEAN NOT NULL DEFAULT true,
    "lastSyncAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "GitRepository_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" TEXT NOT NULL,
    "userId" TEXT,
    "action" TEXT NOT NULL,
    "entityType" TEXT,
    "entityId" TEXT,
    "metadata" JSONB,
    "ipHash" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Pairing" (
    "id" TEXT NOT NULL,
    "codeHash" TEXT NOT NULL,
    "userId" TEXT,
    "tokenHash" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Pairing_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RagGlobalSettings" (
    "id" TEXT NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "retrievalStrategy" TEXT NOT NULL DEFAULT 'hybrid',
    "enableGlobalKnowledge" BOOLEAN NOT NULL DEFAULT true,
    "enablePersonalKnowledge" BOOLEAN NOT NULL DEFAULT true,
    "enableProjectKnowledge" BOOLEAN NOT NULL DEFAULT true,
    "enableWorkspaceKnowledge" BOOLEAN NOT NULL DEFAULT true,
    "enableCitations" BOOLEAN NOT NULL DEFAULT true,
    "enableRagLogging" BOOLEAN NOT NULL DEFAULT true,
    "fallbackWithoutRag" BOOLEAN NOT NULL DEFAULT true,
    "enableRagEvaluation" BOOLEAN NOT NULL DEFAULT true,
    "embeddingProvider" TEXT NOT NULL DEFAULT 'OPENROUTER',
    "embeddingModel" TEXT NOT NULL DEFAULT 'openai/text-embedding-3-small',
    "embeddingDimensions" INTEGER NOT NULL DEFAULT 1536,
    "embeddingBatchSize" INTEGER NOT NULL DEFAULT 32,
    "embeddingRequestTimeoutMs" INTEGER NOT NULL DEFAULT 45000,
    "embeddingRetryCount" INTEGER NOT NULL DEFAULT 2,
    "retrievalStrategyTopK" INTEGER NOT NULL DEFAULT 20,
    "vectorSearchEnabled" BOOLEAN NOT NULL DEFAULT true,
    "keywordSearchEnabled" BOOLEAN NOT NULL DEFAULT true,
    "minSimilarity" DOUBLE PRECISION NOT NULL DEFAULT 0.65,
    "maxContextChunks" INTEGER NOT NULL DEFAULT 5,
    "maxContextTokens" INTEGER NOT NULL DEFAULT 8000,
    "enableMetadataFiltering" BOOLEAN NOT NULL DEFAULT true,
    "enableRrf" BOOLEAN NOT NULL DEFAULT true,
    "rrfK" INTEGER NOT NULL DEFAULT 60,
    "enableReranking" BOOLEAN NOT NULL DEFAULT false,
    "contextDeduplication" BOOLEAN NOT NULL DEFAULT true,
    "includeSourceMetadata" BOOLEAN NOT NULL DEFAULT true,
    "includeFilePath" BOOLEAN NOT NULL DEFAULT true,
    "includeLineNumbers" BOOLEAN NOT NULL DEFAULT true,
    "noResultBehavior" TEXT NOT NULL DEFAULT 'fallback',
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "updatedByUserId" TEXT,

    CONSTRAINT "RagGlobalSettings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "RagTaskProfile" (
    "id" TEXT NOT NULL,
    "task" TEXT NOT NULL,
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "retrievalStrategy" TEXT NOT NULL DEFAULT 'hybrid',
    "topK" INTEGER NOT NULL DEFAULT 20,
    "maxContextChunks" INTEGER NOT NULL DEFAULT 5,
    "minSimilarity" DOUBLE PRECISION NOT NULL DEFAULT 0.65,
    "maxContextTokens" INTEGER NOT NULL DEFAULT 8000,
    "enableReranking" BOOLEAN NOT NULL DEFAULT false,
    "enableCitations" BOOLEAN NOT NULL DEFAULT true,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "RagTaskProfile_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_githubId_key" ON "User"("githubId");

-- CreateIndex
CREATE INDEX "User_githubUsername_idx" ON "User"("githubUsername");

-- CreateIndex
CREATE INDEX "User_email_idx" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "Session_tokenHash_key" ON "Session"("tokenHash");

-- CreateIndex
CREATE INDEX "Session_userId_idx" ON "Session"("userId");

-- CreateIndex
CREATE INDEX "Session_expiresAt_idx" ON "Session"("expiresAt");

-- CreateIndex
CREATE INDEX "Project_userId_idx" ON "Project"("userId");

-- CreateIndex
CREATE INDEX "Project_userId_status_idx" ON "Project"("userId", "status");

-- CreateIndex
CREATE INDEX "Project_localAgentId_idx" ON "Project"("localAgentId");

-- CreateIndex
CREATE INDEX "Project_githubOwner_githubRepository_idx" ON "Project"("githubOwner", "githubRepository");

-- CreateIndex
CREATE INDEX "ProjectMember_userId_idx" ON "ProjectMember"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "ProjectMember_projectId_userId_key" ON "ProjectMember"("projectId", "userId");

-- CreateIndex
CREATE INDEX "Artifact_projectId_idx" ON "Artifact"("projectId");

-- CreateIndex
CREATE INDEX "Artifact_projectId_type_createdAt_idx" ON "Artifact"("projectId", "type", "createdAt");

-- CreateIndex
CREATE INDEX "KnowledgeSource_projectId_createdAt_idx" ON "KnowledgeSource"("projectId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "KnowledgeSource_projectId_uri_key" ON "KnowledgeSource"("projectId", "uri");

-- CreateIndex
CREATE INDEX "KnowledgeChunk_projectId_sourceId_idx" ON "KnowledgeChunk"("projectId", "sourceId");

-- CreateIndex
CREATE INDEX "ProjectRun_projectId_createdAt_idx" ON "ProjectRun"("projectId", "createdAt");

-- CreateIndex
CREATE INDEX "ProjectRun_status_idx" ON "ProjectRun"("status");

-- CreateIndex
CREATE INDEX "AIProvider_userId_enabled_idx" ON "AIProvider"("userId", "enabled");

-- CreateIndex
CREATE UNIQUE INDEX "AIProvider_userId_provider_key" ON "AIProvider"("userId", "provider");

-- CreateIndex
CREATE INDEX "AIRequest_userId_createdAt_idx" ON "AIRequest"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "AIRequest_projectId_createdAt_idx" ON "AIRequest"("projectId", "createdAt");

-- CreateIndex
CREATE INDEX "LocalAgent_userId_idx" ON "LocalAgent"("userId");

-- CreateIndex
CREATE INDEX "LocalAgent_userId_status_idx" ON "LocalAgent"("userId", "status");

-- CreateIndex
CREATE INDEX "AgentJob_projectId_createdAt_idx" ON "AgentJob"("projectId", "createdAt");

-- CreateIndex
CREATE INDEX "AgentJob_agentId_status_idx" ON "AgentJob"("agentId", "status");

-- CreateIndex
CREATE INDEX "GitRepository_projectId_idx" ON "GitRepository"("projectId");

-- CreateIndex
CREATE UNIQUE INDEX "GitRepository_projectId_owner_repository_key" ON "GitRepository"("projectId", "owner", "repository");

-- CreateIndex
CREATE INDEX "AuditLog_userId_createdAt_idx" ON "AuditLog"("userId", "createdAt");

-- CreateIndex
CREATE INDEX "AuditLog_entityType_entityId_createdAt_idx" ON "AuditLog"("entityType", "entityId", "createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "Pairing_codeHash_key" ON "Pairing"("codeHash");

-- CreateIndex
CREATE INDEX "Pairing_expiresAt_idx" ON "Pairing"("expiresAt");

-- CreateIndex
CREATE UNIQUE INDEX "RagTaskProfile_task_key" ON "RagTaskProfile"("task");

-- AddForeignKey
ALTER TABLE "Session" ADD CONSTRAINT "Session_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Project" ADD CONSTRAINT "Project_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Project" ADD CONSTRAINT "Project_localAgentId_fkey" FOREIGN KEY ("localAgentId") REFERENCES "LocalAgent"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProjectMember" ADD CONSTRAINT "ProjectMember_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProjectMember" ADD CONSTRAINT "ProjectMember_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Artifact" ADD CONSTRAINT "Artifact_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "KnowledgeSource" ADD CONSTRAINT "KnowledgeSource_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "KnowledgeChunk" ADD CONSTRAINT "KnowledgeChunk_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "KnowledgeChunk" ADD CONSTRAINT "KnowledgeChunk_sourceId_fkey" FOREIGN KEY ("sourceId") REFERENCES "KnowledgeSource"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProjectRun" ADD CONSTRAINT "ProjectRun_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AIProvider" ADD CONSTRAINT "AIProvider_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AIRequest" ADD CONSTRAINT "AIRequest_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AIRequest" ADD CONSTRAINT "AIRequest_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LocalAgent" ADD CONSTRAINT "LocalAgent_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AgentJob" ADD CONSTRAINT "AgentJob_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AgentJob" ADD CONSTRAINT "AgentJob_agentId_fkey" FOREIGN KEY ("agentId") REFERENCES "LocalAgent"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "GitRepository" ADD CONSTRAINT "GitRepository_projectId_fkey" FOREIGN KEY ("projectId") REFERENCES "Project"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Pairing" ADD CONSTRAINT "Pairing_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
