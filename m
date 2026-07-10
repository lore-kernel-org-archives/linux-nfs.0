Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8CE81390222
	for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2026 20:47:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783716438; cv=none; b=josIivEqjRpYyeFSj3M23BMPzthIQ6gK/5ztg35Stw7E8FWpf4uq5Vz0BMR51na1RL1LdGEN/DDV5/IPtKTra/ouX9jZ0YQd6jTYPfuw4sntU79y894IvLvSDF7Rq64AcNtwm72cE97+3yhTYQrOjY45dhwPkbTFT4kX8n1LrMU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783716438; c=relaxed/simple;
	bh=ZviibdmDvmAiWuH62dMdDb6cJH3UtPtjL990x9wrRzQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ERQZjU429wIk8oVpXSCVHHHcLbiCAq7RQEUFoy5+o70SoND3gvvojmZIOnhcknZW6Mw5CNv/VCDR7svSPREbXaJs9+7FAMggve9rKUlCN1vy7QwoHwdLH/vb2HwhBlmc1Q2oqxfcTe/MEJvvDySYkbzXwB+vOISb5y2b7zKx274=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Z9FCBuHE; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Z9FCBuHE"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0BD531F00A3A;
	Fri, 10 Jul 2026 20:47:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783716437;
	bh=GyEocahv6HYwqdYH54wYbqEf6G+d/guGy5fmQmfOOM8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Z9FCBuHEAsJwfs6mfV5aadDcsxD4sbkrVUoaQ71LHRaC4Vkpxh2RY6gZvWGc6+RmS
	 lE1dovwAId43zJgDU+sy+tI4ZBhvtxnoeSSqjvYGyefrQsMwrWzjs6Cz9HoNfFEdBz
	 RDFm+DYqjNOPHP6vKeDMjQphgeu/FI6xxYLg/4fE0csHYeQROu/EnwJqi3m0961iqT
	 stBSzkOVsVR/sCFfWiQi0CXiA52UG4XXaqHK+Q47+JbcpzQPcbQgsWUGmF8p7mJZcz
	 X8aCsiyZKgEfTiFpa11nju8nBQCYCULsX1++U/hgj0/EjtPEEMwEm8QavbReJUsyrE
	 wWDTcE5ZYv13w==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH 2/2] NFS: Decrement refcounts if allocating nfs_free_stateid_data fails
Date: Fri, 10 Jul 2026 16:47:15 -0400
Message-ID: <20260710204715.621189-2-anna@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260710204715.621189-1-anna@kernel.org>
References: <20260710204715.621189-1-anna@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Anna Schumaker <anna.schumaker@hammerspace.com>

I noticed that we were immediately exiting this function if the
allocation fails, leaving the client and server object refcounts bumped.
Fix this by creating a common exit point to clean up dangling
references.

Fixes: 576acc259146 ("nfs4: take a reference on the nfs_client when running FREE_STATEID")
Signed-off-by: Anna Schumaker <anna.schumaker@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 20 +++++++++++++-------
 1 file changed, 13 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3ad5ef52a2e8..5709c6fea85b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -10403,21 +10403,22 @@ static int nfs41_free_stateid(struct nfs_server *server,
 	struct nfs_free_stateid_data *data;
 	struct rpc_task *task;
 	struct nfs_client *clp = server->nfs_client;
+	int ret = -EIO;
 
 	if (!refcount_inc_not_zero(&clp->cl_count))
-		return -EIO;
-	if (!nfs_sb_active(server->super)) {
-		nfs_put_client(clp);
-		return -EIO;
-	}
+		return ret;
+	if (!nfs_sb_active(server->super))
+		goto out_put_clp;
 
 	nfs4_state_protect(clp, NFS_SP4_MACH_CRED_STATEID,
 		&task_setup.rpc_client, &msg);
 
 	dprintk("NFS call  free_stateid %p\n", stateid);
 	data = kmalloc_obj(*data);
-	if (!data)
-		return -ENOMEM;
+	if (!data) {
+		ret = -ENOMEM;
+		goto out_put_server;
+	}
 	data->server = server;
 	nfs4_stateid_copy(&data->args.stateid, stateid);
 
@@ -10433,6 +10434,11 @@ static int nfs41_free_stateid(struct nfs_server *server,
 	rpc_put_task(task);
 	stateid->type = NFS4_FREED_STATEID_TYPE;
 	return 0;
+out_put_server:
+	nfs_sb_deactive(server->super);
+out_put_clp:
+	nfs_put_client(clp);
+	return ret;
 }
 
 static void
-- 
2.55.0

