Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:58258 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752055AbdEIJU5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 05:20:57 -0400
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 16/32] lockd: fix some weird indentation
Date: Tue,  9 May 2017 11:19:54 +0200
Message-Id: <20170509092010.30752-17-hch@lst.de>
In-Reply-To: <20170509092010.30752-1-hch@lst.de>
References: <20170509092010.30752-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove double indentation of a few struct rpc_version and
struct rpc_program instance.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/lockd/clntxdr.c | 22 +++++++++++-----------
 fs/lockd/mon.c     | 16 ++++++++--------
 2 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/fs/lockd/clntxdr.c b/fs/lockd/clntxdr.c
index cccf5c2ffadb..7bc54162f5bf 100644
--- a/fs/lockd/clntxdr.c
+++ b/fs/lockd/clntxdr.c
@@ -601,15 +601,15 @@ static const struct rpc_procinfo nlm_procedures[] = {
 };
 
 static const struct rpc_version	nlm_version1 = {
-		.number		= 1,
-		.nrprocs	= ARRAY_SIZE(nlm_procedures),
-		.procs		= nlm_procedures,
+	.number		= 1,
+	.nrprocs	= ARRAY_SIZE(nlm_procedures),
+	.procs		= nlm_procedures,
 };
 
 static const struct rpc_version	nlm_version3 = {
-		.number		= 3,
-		.nrprocs	= ARRAY_SIZE(nlm_procedures),
-		.procs		= nlm_procedures,
+	.number		= 3,
+	.nrprocs	= ARRAY_SIZE(nlm_procedures),
+	.procs		= nlm_procedures,
 };
 
 static const struct rpc_version	*nlm_versions[] = {
@@ -623,9 +623,9 @@ static const struct rpc_version	*nlm_versions[] = {
 static struct rpc_stat		nlm_rpc_stats;
 
 const struct rpc_program	nlm_program = {
-		.name		= "lockd",
-		.number		= NLM_PROGRAM,
-		.nrvers		= ARRAY_SIZE(nlm_versions),
-		.version	= nlm_versions,
-		.stats		= &nlm_rpc_stats,
+	.name		= "lockd",
+	.number		= NLM_PROGRAM,
+	.nrvers		= ARRAY_SIZE(nlm_versions),
+	.version	= nlm_versions,
+	.stats		= &nlm_rpc_stats,
 };
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 2c41de8db1f0..0eb55b4d75b6 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -553,9 +553,9 @@ static const struct rpc_procinfo nsm_procedures[] = {
 };
 
 static const struct rpc_version nsm_version1 = {
-		.number		= 1,
-		.nrprocs	= ARRAY_SIZE(nsm_procedures),
-		.procs		= nsm_procedures
+	.number		= 1,
+	.nrprocs	= ARRAY_SIZE(nsm_procedures),
+	.procs		= nsm_procedures
 };
 
 static const struct rpc_version *nsm_version[] = {
@@ -565,9 +565,9 @@ static const struct rpc_version *nsm_version[] = {
 static struct rpc_stat		nsm_stats;
 
 static const struct rpc_program nsm_program = {
-		.name		= "statd",
-		.number		= NSM_PROGRAM,
-		.nrvers		= ARRAY_SIZE(nsm_version),
-		.version	= nsm_version,
-		.stats		= &nsm_stats
+	.name		= "statd",
+	.number		= NSM_PROGRAM,
+	.nrvers		= ARRAY_SIZE(nsm_version),
+	.version	= nsm_version,
+	.stats		= &nsm_stats
 };
-- 
2.11.0

