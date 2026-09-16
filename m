Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 695D7559CB7
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 16:29:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789576152; cv=none; b=d/SQOzVxr51TElO+rdBuzZgEeLgxXrlQBzPqTJF9O5XX2KBybJ/yfZtoVo9ckBsgsNXCjZXIwQ6csSFRnxjDNK2HkpLfXTWujvYoLdkX9Q7XxAza2QBMl0/DT6Vs3HtdEf9rC5r0fmABoa0V0tpyEh8MS7wZg4SGX/dxOfVqZSQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789576152; c=relaxed/simple;
	bh=9YKkjjs188jFUKJiD0WoSHxzCwPcB2ATUiC5fisJHI0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=TaPn61pDahHd9WRwhnpX5hfdIaijyTN8Jb6Z0a52trZxfryrXEluPphTbx/NtyULCLGmScTsRBGX+MqtEjfmfGeypMN26YOgD3p07zqPs1ScllVlkkTd6J35fZ1qe4zVxw1avn2im208D+qxftQ2tPHoysI//Zcf/yUL73O5OUY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iT8u5Wb2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iT8u5Wb2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 37A8D1F00898;
	Wed, 16 Sep 2026 16:29:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789576149;
	bh=di4pxWosqIkwKYQtaO+FfDcYGN/IFNtg8orCKsVrDVI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=iT8u5Wb2w8aTCe0bwQ7N5JfFCCzXfLxs4Uls/ZW44k6qDSpCIZ/f43TFWL2ckcAZ/
	 3qbWGoqAzdzuXcVbuwUKjyAI6n5JQFBx3XzAe3m8jdcIiQYcXUc9bhzAewRO3/x/Sm
	 a5+JvBDgHd0lAriDPXjuLZ6gsqqye+Ifhl2Vx6A4szRQV8mUxBsbfSIbaYPSyb7xkh
	 BPan1wpb+ZitpARO9R0RDqaJW463dtsHxWADrTGpWHAdjcjmDUZu2JIzXXnCtWgfZB
	 Ho0pQZIjg3S0FofjOCP9ss87QSaKdsa0aBEzWRLrgsslRY5x7gVZ9Bxuj750fenWqi
	 1DLt4SbOy6/zQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 10/27] NFSD: Use xdrgen XDR functions for the NFSv2 LOOKUP procedure
Date: Wed, 16 Sep 2026 12:28:41 -0400
Message-ID: <20260916162859.2051-13-cel@kernel.org>
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

Replace the NFSPROC_LOOKUP entry in the nfsd_procedures2 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_diropargs and nfs_svc_encode_diropres. Wrapper
structures bridge the generated xdrgen types and the legacy
svc_fh and kstat representations the NFSD VFS layer still uses.

The pc_argzero field is now set to zero for the NFSv2 LOOKUP
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

This refactor replaces the use of svcxdr_encode_fattr(), so the
references to the directory and object file handles can be
released directly by nfsd_proc_lookup(). A separate ->pc_release
callback is thus no longer needed. This makes it straightforward
to confirm that the file handles are properly released during
every error flow.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsproc.c | 95 ++++++++++++++++++++++++++++++++---------------
 1 file changed, 65 insertions(+), 30 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index c0f8c6988925..ce52939b3ae7 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -48,6 +48,21 @@ struct sattrargs_wrapper {
 
 static_assert(offsetof(struct sattrargs_wrapper, xdrgen) == 0);
 
+struct diropargs_wrapper {
+	struct diropargs	xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct diropargs_wrapper, xdrgen) == 0);
+
+struct diropres_wrapper {
+	struct diropres		xdrgen;
+	struct svc_fh		fh;
+	struct kstat		stat;
+};
+
+static_assert(offsetof(struct diropres_wrapper, xdrgen) == 0);
+
 static __be32 nfsd_map_status(__be32 status)
 {
 	switch (status) {
@@ -81,6 +96,12 @@ nfsd_fhandle_to_svc_fh(struct svc_fh *fhp, const fhandle *fhandle)
 	memcpy(&fhp->fh_handle.fh_raw, fhandle, NFS_FHSIZE);
 }
 
+static __always_inline void
+nfsd_svc_fh_to_fhandle(fhandle *fhandle, const struct svc_fh *fhp)
+{
+	memcpy(fhandle, fhp->fh_handle.fh_raw, NFS_FHSIZE);
+}
+
 static __always_inline void
 nfsd_timespec64_to_timeval(struct timeval *dst,
 			   const struct timespec64 *src)
@@ -412,31 +433,46 @@ static __be32 nfsd_proc_root(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Look up a path name component
- * Note: the dentry in the resp->fh may be negative if the file
- * doesn't exist yet.
- * N.B. After this call resp->fh needs an fh_put
+/**
+ * nfsd_proc_lookup - LOOKUP: Look up file name
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   diropres NFSPROC_LOOKUP(diropargs) = 4;
  */
-static __be32
-nfsd_proc_lookup(struct svc_rqst *rqstp)
+static __be32 nfsd_proc_lookup(struct svc_rqst *rqstp)
 {
-	struct nfsd_diropargs *argp = rqstp->rq_argp;
-	struct nfsd_diropres *resp = rqstp->rq_resp;
+	struct diropargs_wrapper *argp = rqstp->rq_argp;
+	struct diropres_wrapper *resp = rqstp->rq_resp;
+	struct diropargs *what = &argp->xdrgen;
+	struct kstat *statp = &resp->stat;
+	struct svc_fh *dirfhp = &argp->fh;
+	struct svc_fh *fhp = &resp->fh;
 
-	dprintk("nfsd: LOOKUP   %s %.*s\n",
-		SVCFH_fmt(&argp->fh), argp->len, argp->name);
+	nfsd_fhandle_to_svc_fh(dirfhp, &what->dir);
 
-	fh_init(&resp->fh, NFS_FHSIZE);
-	resp->status = nfsd_lookup(rqstp, &argp->fh, argp->name, argp->len,
-				   &resp->fh);
-	fh_put(&argp->fh);
-	if (resp->status != nfs_ok)
+	fh_init(fhp, NFS_FHSIZE);
+	resp->xdrgen.status = nfsd_lookup(rqstp, dirfhp,
+					  (char *)what->name.data,
+					  what->name.len, fhp);
+	if (resp->xdrgen.status != nfs_ok)
 		goto out;
+	resp->xdrgen.status = fh_getattr(fhp, statp);
 
-	resp->status = fh_getattr(&resp->fh, &resp->stat);
 out:
-	resp->status = nfsd_map_status(resp->status);
+	if (resp->xdrgen.status == nfs_ok) {
+		nfsd_svc_fh_to_fhandle(&resp->xdrgen.u.diropok.file, fhp);
+		nfsd_stat_to_fattr(rqstp, &resp->xdrgen.u.diropok.attributes,
+				   statp, fhp);
+	} else {
+		resp->xdrgen.status = nfsd_map_status(resp->xdrgen.status);
+	}
+
+	fh_put(fhp);
+	fh_put(dirfhp);
 	return rpc_success;
 }
 
@@ -957,16 +993,15 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 		.pc_name	= "ROOT",
 	},
 	[NFSPROC_LOOKUP] = {
-		.pc_func = nfsd_proc_lookup,
-		.pc_decode = nfssvc_decode_diropargs,
-		.pc_encode = nfssvc_encode_diropres,
-		.pc_release = nfssvc_release_diropres,
-		.pc_argsize = sizeof(struct nfsd_diropargs),
-		.pc_argzero = sizeof(struct nfsd_diropargs),
-		.pc_ressize = sizeof(struct nfsd_diropres),
-		.pc_cachetype = RC_NOCACHE,
-		.pc_xdrressize = ST+FH+AT,
-		.pc_name = "LOOKUP",
+		.pc_func	= nfsd_proc_lookup,
+		.pc_decode	= nfs_svc_decode_diropargs,
+		.pc_encode	= nfs_svc_encode_diropres,
+		.pc_argsize	= sizeof(struct diropargs_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct diropres_wrapper),
+		.pc_cachetype	= RC_NOCACHE,
+		.pc_xdrressize	= NFS2_diropres_sz,
+		.pc_name	= "LOOKUP",
 	},
 	[NFSPROC_READLINK] = {
 		.pc_func = nfsd_proc_readlink,
@@ -1122,7 +1157,7 @@ static const struct svc_procedure nfsd_procedures2[18] = {
 union nfsd_xdrstore {
 	struct fhandle_wrapper		fhandle;
 	struct sattrargs_wrapper	sattrargs;
-	struct nfsd_diropargs	dirop;
+	struct diropargs_wrapper	diropargs;
 	struct nfsd_readargs	read;
 	struct nfsd_writeargs	write;
 	struct nfsd_createargs	create;
@@ -1131,7 +1166,7 @@ union nfsd_xdrstore {
 	struct nfsd_symlinkargs	symlink;
 	struct nfsd_readdirargs	readdir;
 	struct attrstat_wrapper		attrstat;
-	struct nfsd_diropres	diropres;
+	struct diropres_wrapper		diropres;
 	struct nfsd_readlinkres	readlinkres;
 	struct nfsd_readres	readres;
 	struct nfsd_readdirres	readdirres;
-- 
2.55.0

