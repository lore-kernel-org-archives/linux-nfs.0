Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 47BBF5293F4
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576143; cv=none; b=itEadLPklC5swfJHiw4v9BdwgConOcIiEtli4fh86JFl67FhZUfO5TLWaWJEoWPCPOirbw12ExijbNwt0ubIVARKdPQ3raCMXSLYzn0rYxG3sfrwuu9nOvBOkHmBV509HlUZwW/VEQFlf+dWFaMEYVRog/bVq/F3JdZjL4eR8oA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576143; c=relaxed/simple;
	bh=OA2Xcl8kBUiIXCfkCQmP3oHhnxjnoWgLLqWuMrZjfRY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=sj8vK+rSaNKNx5ZROCUADnR8h/G7yPp9NdeQUtIUt1tY7jBodD9cP1V6K8BLgDTZuaR7yd/FW1xcCDC/YlgdNJVtsvGrGyD1NB1xvkjHha156jJ71C4DcYXnZJBJGVxEXSIfp4FoVM6IcvWZQZVXkmhcYlxM1YaZvMxR+Sesp04=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VWc4ubJt; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VWc4ubJt"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A22071F00898;
	Wed, 16 Sep 2026 16:29:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576142;
	bh=KUeW+gxqqwDfqavKs1JkCs22os43RV+Q0bd868tWtis=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=VWc4ubJtcQKoio2S+uLEPWZbZCcFsUNqgiw++F9rJgFpbhfuUcGjuLQVc9ZPUiVoD
	 5jD/b792AMaxHl89MmNXnkQFiT/cIWgVXqvXK2rEgfNbdhC09Ar3iBgh/AzksIl5r8
	 95e0ZODAEOEiC8+R/Aj3n7Tk0i910Td7ReWSBfPWCydQVRkjA4jO9NyhSQspsVb3zr
	 EhLLd7g/hq6/D2xVB0l36JwmLx565w2zVBj/4bRlEfbm5KHH+TcudBLLILqWFV96Lk
	 eKuCSBFv4xz3+6kAne2jE8//R8cO2tkscDgKyN0tgwHFSNsN0/NQZQIBwvsy1lV1el
	 4gKw5BM9WI5tQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 1/2] NFSD: map fh_verify() status codes for NFS_ACLv2 replies
Date: Wed, 16 Sep 2026 12:28:31 -0400
Message-ID: <20260916162859.2051-3-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260916162859.2051-1-cel@kernel.org>
References: <20260916162859.2051-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The NFS_ACL v2 protocol shares its status code space with NFSv2,
which has no NFSERR_BADHANDLE and no NFSERR_NOFILEHANDLE. An
NFS_ACLv2 GETACL, SETACL, GETATTR, or ACCESS request that carries a
malformed or empty file handle gets a reply with status 10001 or
10020, values the client cannot interpret.

Commit 1459ad57673b ("nfsd: Move error code mapping to per-version
proc code.") removed the version check from fh_verify() that turned
those codes into NFSERR_STALE for any version 2 program. The NFSv2
procedures gained nfsd_map_status() in exchange, but the NFS_ACL v2
procedures did not, so the unmapped status reaches the encoder.

Add the same mapping to the NFS_ACL v2 procedures.

Fixes: 1459ad57673b ("nfsd: Move error code mapping to per-version proc code.")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs2acl.c | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 0a5c444fef99..0673e83b6666 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -59,6 +59,20 @@ static const struct nfsd_access_maps nfsd2_access_maps = {
 	.other		= nfsd2_otheraccess,
 };
 
+static __be32 nfsacld_map_status(__be32 status)
+{
+	switch (status) {
+	case nfserr_nofilehandle:
+	case nfserr_badhandle:
+		status = nfserr_stale;
+		break;
+	case nfserr_wrongsec:
+		status = nfserr_acces;
+		break;
+	}
+	return status;
+}
+
 /*
  * NULL call.
  */
@@ -123,6 +137,7 @@ static __be32 nfsacld_proc_getacl(struct svc_rqst *rqstp)
 
 	/* resp->acl_{access,default} are released in nfssvc_release_getacl. */
 out:
+	resp->status = nfsacld_map_status(resp->status);
 	return rpc_success;
 
 fail:
@@ -181,6 +196,7 @@ static __be32 nfsacld_proc_setacl(struct svc_rqst *rqstp)
 
 out:
 	/* argp->acl_{access,default} are released in nfsaclsvc_release_setacl. */
+	resp->status = nfsacld_map_status(resp->status);
 	return rpc_success;
 
 out_drop_lock:
@@ -207,6 +223,7 @@ static __be32 nfsacld_proc_getattr(struct svc_rqst *rqstp)
 		goto out;
 	resp->status = fh_getattr(&resp->fh, &resp->stat);
 out:
+	resp->status = nfsacld_map_status(resp->status);
 	return rpc_success;
 }
 
@@ -231,6 +248,7 @@ static __be32 nfsacld_proc_access(struct svc_rqst *rqstp)
 		goto out;
 	resp->status = fh_getattr(&resp->fh, &resp->stat);
 out:
+	resp->status = nfsacld_map_status(resp->status);
 	return rpc_success;
 }
 
-- 
2.55.0

