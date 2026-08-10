Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A38B3E7141
	for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2026 14:19:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786371544; cv=none; b=TSw1QJJ3vDfxHXx4661HKSj2GVCISUAlE2qrk8MiWzkrmYK4oY55nJS4MvzioNu6LmSao2IK7Lg2HiBxowhkPjPO65pn/wwko+eR3AbogjcVefanD9DWA6WOk/1/fBjbjuqcGC9L71IT3TySb/SwKvWxXzuRRwLMwDwcETMMe48=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786371544; c=relaxed/simple;
	bh=eiv3NvjFSVzc2SfXAtkt60GYsDHQPYfnn2L8FOK0iuU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=tP6nk4f1+eoyQBJRQl9nYCDEYp8f/npWUoh6/tu8nUp46ObK67Aob6FDT06YEuHM46d1XgD1AnHxQIAJXTfcJe5CQKJSGnMfW2lW2iGl2LJV80sm7fg+ztdCNAr4PrxU/LC11SfA7wulB8BgMXGTGd0r0S4yub1FYsYxcb6CJeE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=eykiJ5Ar; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="eykiJ5Ar"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 72BBD1F00A3D;
	Mon, 10 Aug 2026 14:19:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786371543;
	bh=lLPFh0QFsQmQs9Qsipv0erGicXvkShOVnPYQcTWkMKA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=eykiJ5Ard/l73A74j0uirdgLTfxuDjuZqtQUnJIZXcvtWh29w0EYxHeYuzoy/Evwu
	 Kj4yTzPeaxyZl62NwAVgS/ub/90xEIqaIMYxlpmid9LFuEfgIdd1eJH0NZwu8e9gZ3
	 naBA6Czk0LMtjbG9Y3lXjdijfyNLeLp7O4xFRQqhcm1ABGOctQeNrXLa4qgy09m2nZ
	 XmmKCfCLX7W4xFe/H2i3iaG4WRCkMoF/7bILZ1CEB4sQXs9GduS/X1ARE2HrAw4B8d
	 +gta5s7bNYKvtXzObp5wZNMdc419nD5WP+Px3sgv2uRMUHN6vHrW+01a+YmL9cVTAu
	 wdYSuFW23W2JA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 2/2] NFSD: Move version-specific ACCESS maps into per-version code
Date: Mon, 10 Aug 2026 10:19:00 -0400
Message-ID: <20260810141900.33846-2-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260810141900.33846-1-cel@kernel.org>
References: <20260810141900.33846-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd_access() owns three static tables that map on-the-wire ACCESS
bits to NFSD_MAY flags, and every NFS version shares them. That puts
protocol-version specifics in the version-agnostic VFS layer. The
NFSv4.2 extended-attribute bits are wedged into the NFSv3 tables
under CONFIG_NFSD_V4.

Give each version its own tables in its proc code and pass the
matching set into nfsd_access() as a new argument.

Splitting the tables also stops the NFSv2-ACL and NFSv3 ACCESS paths
from answering for the NFSv4.2 extended-attribute bits. Both use the
NFSv4-augmented table whenever CONFIG_NFSD_V4 is set, so an NFSv3
request that sets an xattr bit has it echoed back in the reply even
though those bits are undefined for v3.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs2acl.c  | 46 ++++++++++++++++++++++++++-
 fs/nfsd/nfs3proc.c | 41 +++++++++++++++++++++++-
 fs/nfsd/nfs4proc.c | 42 +++++++++++++++++++++++--
 fs/nfsd/vfs.c      | 78 ++++++++++------------------------------------
 fs/nfsd/vfs.h      | 15 ++++++++-
 5 files changed, 155 insertions(+), 67 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index aba69dd278a1..33610deda3b0 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -16,6 +16,48 @@
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
+/*
+ * These maps are identical to the NFSv3 maps (nfs3proc.c). This enables
+ * the behavior of the two versions to diverge if needed.
+ */
+static const struct nfsd_access_map nfsd2_regaccess[] = {
+	{ NFS3_ACCESS_READ,	NFSD_MAY_READ				},
+	{ NFS3_ACCESS_EXECUTE,	NFSD_MAY_EXEC				},
+	{ NFS3_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_TRUNC		},
+	{ NFS3_ACCESS_EXTEND,	NFSD_MAY_WRITE				},
+	{ 0,			0					}
+};
+
+static const struct nfsd_access_map nfsd2_diraccess[] = {
+	{ NFS3_ACCESS_READ,	NFSD_MAY_READ				},
+	{ NFS3_ACCESS_LOOKUP,	NFSD_MAY_EXEC				},
+	{ NFS3_ACCESS_MODIFY,	NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC },
+	{ NFS3_ACCESS_EXTEND,	NFSD_MAY_EXEC|NFSD_MAY_WRITE		},
+	{ NFS3_ACCESS_DELETE,	NFSD_MAY_REMOVE				},
+	{ 0,			0					}
+};
+
+/*
+ * Some clients - Solaris 2.6 at least, make an access call to the NFS
+ * server to check for access for things like /dev/null (which really,
+ * NFSD doesn't care about).  So NFSD provides simple access checking
+ * for those objects, looking mainly at mode bits, ignoring read-only
+ * filesystem checks.
+ */
+static const struct nfsd_access_map nfsd2_otheraccess[] = {
+	{ NFS3_ACCESS_READ,	NFSD_MAY_READ				},
+	{ NFS3_ACCESS_EXECUTE,	NFSD_MAY_EXEC				},
+	{ NFS3_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
+	{ NFS3_ACCESS_EXTEND,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
+	{ 0,			0					}
+};
+
+static const struct nfsd_access_maps nfsd2_access_maps = {
+	.regular	= nfsd2_regaccess,
+	.directory	= nfsd2_diraccess,
+	.other		= nfsd2_otheraccess,
+};
+
 /*
  * NULL call.
  */
@@ -181,7 +223,9 @@ static __be32 nfsacld_proc_access(struct svc_rqst *rqstp)
 
 	fh_copy(&resp->fh, &argp->fh);
 	resp->access = argp->access;
-	resp->status = nfsd_access(rqstp, &resp->fh, &resp->access, NULL);
+
+	resp->status = nfsd_access(rqstp, &resp->fh, &nfsd2_access_maps,
+				   &resp->access, NULL);
 	if (resp->status != nfs_ok)
 		goto out;
 	resp->status = fh_getattr(&resp->fh, &resp->stat);
diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 19ab0a713d82..17bbe5d13f18 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -49,6 +49,44 @@ static bool nfsd3_time_in_range(const struct iattr *iap)
 	return true;
 }
 
+static const struct nfsd_access_map nfsd3_regaccess[] = {
+	{ NFS3_ACCESS_READ,	NFSD_MAY_READ				},
+	{ NFS3_ACCESS_EXECUTE,	NFSD_MAY_EXEC				},
+	{ NFS3_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_TRUNC		},
+	{ NFS3_ACCESS_EXTEND,	NFSD_MAY_WRITE				},
+	{ 0,			0					}
+};
+
+static const struct nfsd_access_map nfsd3_diraccess[] = {
+	{ NFS3_ACCESS_READ,	NFSD_MAY_READ				},
+	{ NFS3_ACCESS_LOOKUP,	NFSD_MAY_EXEC				},
+	{ NFS3_ACCESS_MODIFY,	NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC },
+	{ NFS3_ACCESS_EXTEND,	NFSD_MAY_EXEC|NFSD_MAY_WRITE		},
+	{ NFS3_ACCESS_DELETE,	NFSD_MAY_REMOVE				},
+	{ 0,			0					}
+};
+
+/*
+ * Some clients - Solaris 2.6 at least, make an access call to the NFS
+ * server to check for access for things like /dev/null (which really,
+ * NFSD doesn't care about).  So NFSD provides simple access checking
+ * for those objects, looking mainly at mode bits, ignoring read-only
+ * filesystem checks.
+ */
+static const struct nfsd_access_map nfsd3_otheraccess[] = {
+	{ NFS3_ACCESS_READ,	NFSD_MAY_READ				},
+	{ NFS3_ACCESS_EXECUTE,	NFSD_MAY_EXEC				},
+	{ NFS3_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
+	{ NFS3_ACCESS_EXTEND,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
+	{ 0,			0					}
+};
+
+static const struct nfsd_access_maps nfsd3_access_maps = {
+	.regular	= nfsd3_regaccess,
+	.directory	= nfsd3_diraccess,
+	.other		= nfsd3_otheraccess,
+};
+
 static int nfsd3_iocb_flags(enum nfs3_stable_how how)
 {
 	switch (how) {
@@ -186,7 +224,8 @@ nfsd3_proc_access(struct svc_rqst *rqstp)
 
 	fh_copy(&resp->fh, &argp->fh);
 	resp->access = argp->access;
-	resp->status = nfsd_access(rqstp, &resp->fh, &resp->access, NULL);
+	resp->status = nfsd_access(rqstp, &resp->fh, &nfsd3_access_maps,
+				   &resp->access, NULL);
 	resp->status = nfsd3_map_status(resp->status);
 	return rpc_success;
 }
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a2bea8947ef5..54593f4667f8 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -72,6 +72,43 @@ MODULE_PARM_DESC(nfsd4_ssc_umount_timeout,
 
 #define NFSDDBG_FACILITY		NFSDDBG_PROC
 
+static const struct nfsd_access_map nfsd4_regaccess[] = {
+	{ NFS4_ACCESS_READ,	NFSD_MAY_READ				},
+	{ NFS4_ACCESS_EXECUTE,	NFSD_MAY_EXEC				},
+	{ NFS4_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_TRUNC		},
+	{ NFS4_ACCESS_EXTEND,	NFSD_MAY_WRITE				},
+	{ NFS4_ACCESS_XAREAD,	NFSD_MAY_READ				},
+	{ NFS4_ACCESS_XAWRITE,	NFSD_MAY_WRITE				},
+	{ NFS4_ACCESS_XALIST,	NFSD_MAY_READ				},
+	{ 0,			0					}
+};
+
+static const struct nfsd_access_map nfsd4_diraccess[] = {
+	{ NFS4_ACCESS_READ,	NFSD_MAY_READ				},
+	{ NFS4_ACCESS_LOOKUP,	NFSD_MAY_EXEC				},
+	{ NFS4_ACCESS_MODIFY,	NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC },
+	{ NFS4_ACCESS_EXTEND,	NFSD_MAY_EXEC|NFSD_MAY_WRITE		},
+	{ NFS4_ACCESS_DELETE,	NFSD_MAY_REMOVE				},
+	{ NFS4_ACCESS_XAREAD,	NFSD_MAY_READ				},
+	{ NFS4_ACCESS_XAWRITE,	NFSD_MAY_WRITE				},
+	{ NFS4_ACCESS_XALIST,	NFSD_MAY_READ				},
+	{ 0,			0					}
+};
+
+static const struct nfsd_access_map nfsd4_otheraccess[] = {
+	{ NFS4_ACCESS_READ,	NFSD_MAY_READ				},
+	{ NFS4_ACCESS_EXECUTE,	NFSD_MAY_EXEC				},
+	{ NFS4_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
+	{ NFS4_ACCESS_EXTEND,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
+	{ 0,			0					}
+};
+
+static const struct nfsd_access_maps nfsd4_access_maps = {
+	.regular	= nfsd4_regaccess,
+	.directory	= nfsd4_diraccess,
+	.other		= nfsd4_otheraccess,
+};
+
 static int nfsd4_iocb_flags(enum stable_how4 how)
 {
 	switch (how) {
@@ -851,10 +888,9 @@ nfsd4_access(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 
 	if (access->ac_req_access & ~access_full)
 		return nfserr_inval;
-
 	access->ac_resp_access = access->ac_req_access;
-	return nfsd_access(rqstp, &cstate->current_fh, &access->ac_resp_access,
-			   &access->ac_supported);
+	return nfsd_access(rqstp, &cstate->current_fh, &nfsd4_access_maps,
+			   &access->ac_resp_access, &access->ac_supported);
 }
 
 static __be32
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 807e09521e0c..6d865f4f9ba3 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -782,64 +782,21 @@ __be32 nfsd4_vfs_fallocate(struct svc_rqst *rqstp, struct svc_fh *fhp,
 }
 #endif /* defined(CONFIG_NFSD_V4) */
 
-/*
- * Check server access rights to a file system object
+/**
+ * nfsd_access - Check caller's access rights to a file system object
+ * @rqstp: RPC transaction context
+ * @fhp: target NFS filehandle
+ * @maps: tables mapping on-the-wire access bits to NFSD_MAY flags
+ * @access: requested access bits on entry, permitted bits on return
+ * @supported: optional output of the access bits the server supports
+ *
+ * Return: nfs_ok on success, otherwise an nfserr status code
  */
-struct accessmap {
-	u32		access;
-	int		how;
-};
-static struct accessmap	nfs3_regaccess[] = {
-    {	NFS3_ACCESS_READ,	NFSD_MAY_READ			},
-    {	NFS3_ACCESS_EXECUTE,	NFSD_MAY_EXEC			},
-    {	NFS3_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_TRUNC	},
-    {	NFS3_ACCESS_EXTEND,	NFSD_MAY_WRITE			},
-
-#ifdef CONFIG_NFSD_V4
-    {	NFS4_ACCESS_XAREAD,	NFSD_MAY_READ			},
-    {	NFS4_ACCESS_XAWRITE,	NFSD_MAY_WRITE			},
-    {	NFS4_ACCESS_XALIST,	NFSD_MAY_READ			},
-#endif
-
-    {	0,			0				}
-};
-
-static struct accessmap	nfs3_diraccess[] = {
-    {	NFS3_ACCESS_READ,	NFSD_MAY_READ			},
-    {	NFS3_ACCESS_LOOKUP,	NFSD_MAY_EXEC			},
-    {	NFS3_ACCESS_MODIFY,	NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC},
-    {	NFS3_ACCESS_EXTEND,	NFSD_MAY_EXEC|NFSD_MAY_WRITE	},
-    {	NFS3_ACCESS_DELETE,	NFSD_MAY_REMOVE			},
-
-#ifdef CONFIG_NFSD_V4
-    {	NFS4_ACCESS_XAREAD,	NFSD_MAY_READ			},
-    {	NFS4_ACCESS_XAWRITE,	NFSD_MAY_WRITE			},
-    {	NFS4_ACCESS_XALIST,	NFSD_MAY_READ			},
-#endif
-
-    {	0,			0				}
-};
-
-static struct accessmap	nfs3_anyaccess[] = {
-	/* Some clients - Solaris 2.6 at least, make an access call
-	 * to the server to check for access for things like /dev/null
-	 * (which really, the server doesn't care about).  So
-	 * We provide simple access checking for them, looking
-	 * mainly at mode bits, and we make sure to ignore read-only
-	 * filesystem checks
-	 */
-    {	NFS3_ACCESS_READ,	NFSD_MAY_READ			},
-    {	NFS3_ACCESS_EXECUTE,	NFSD_MAY_EXEC			},
-    {	NFS3_ACCESS_MODIFY,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
-    {	NFS3_ACCESS_EXTEND,	NFSD_MAY_WRITE|NFSD_MAY_LOCAL_ACCESS	},
-
-    {	0,			0				}
-};
-
-__be32
-nfsd_access(struct svc_rqst *rqstp, struct svc_fh *fhp, u32 *access, u32 *supported)
+__be32 nfsd_access(struct svc_rqst *rqstp, struct svc_fh *fhp,
+		   const struct nfsd_access_maps *maps,
+		   u32 *access, u32 *supported)
 {
-	struct accessmap	*map;
+	const struct nfsd_access_map *map;
 	struct svc_export	*export;
 	struct dentry		*dentry;
 	u32			query, result = 0, sresult = 0;
@@ -853,12 +810,11 @@ nfsd_access(struct svc_rqst *rqstp, struct svc_fh *fhp, u32 *access, u32 *suppor
 	dentry = fhp->fh_dentry;
 
 	if (d_is_reg(dentry))
-		map = nfs3_regaccess;
+		map = maps->regular;
 	else if (d_is_dir(dentry))
-		map = nfs3_diraccess;
+		map = maps->directory;
 	else
-		map = nfs3_anyaccess;
-
+		map = maps->other;
 
 	query = *access;
 	for  (; map->access; map++) {
@@ -868,7 +824,7 @@ nfsd_access(struct svc_rqst *rqstp, struct svc_fh *fhp, u32 *access, u32 *suppor
 			sresult |= map->access;
 
 			err2 = nfsd_permission(&rqstp->rq_cred, export,
-					       dentry, map->how);
+					       dentry, map->may);
 			switch (err2) {
 			case nfs_ok:
 				result |= map->access;
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index aa7679d4c54a..3aa4522ca0a4 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -37,6 +37,17 @@
 #define NFSD_MAY_CREATE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE)
 #define NFSD_MAY_REMOVE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC)
 
+struct nfsd_access_map {
+	u32		access;
+	int		may;
+};
+
+struct nfsd_access_maps {
+	const struct nfsd_access_map	*regular;
+	const struct nfsd_access_map	*directory;
+	const struct nfsd_access_map	*other;
+};
+
 struct nfsd_file;
 
 /*
@@ -100,7 +111,9 @@ __be32		nfsd_create_locked(struct svc_rqst *, struct svc_fh *,
 __be32		nfsd_create(struct svc_rqst *, struct svc_fh *,
 				char *name, int len, struct nfsd_attrs *attrs,
 				int type, dev_t rdev, struct svc_fh *res);
-__be32		nfsd_access(struct svc_rqst *, struct svc_fh *, u32 *, u32 *);
+__be32		nfsd_access(struct svc_rqst *rqstp, struct svc_fh *fhp,
+				const struct nfsd_access_maps *maps,
+				u32 *access, u32 *supported);
 __be32		nfsd_create_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				struct svc_fh *resfhp, struct nfsd_attrs *iap);
 __be32		nfsd_commit(struct svc_rqst *rqst, struct svc_fh *fhp,
-- 
2.54.0

