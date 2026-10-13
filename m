Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 776A5360EC5
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 12:49:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791895784; cv=none; b=SFCJUERZ4F0mex3UvT2URcsvNFa8HV8Nj4xN+4jxoQ2s7IcGOXZxOKlt7mc6jT4CoPJHzCVJ+4jtfmxJzadarsIYROB+4hLjG8R1/gcV0o6VlfDKZiZv5h0IEjs7uFYnjMZKIQ4lKpE973rmFZlUzVkM7w9USlY+T0dvdzF0Nxc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791895784; c=relaxed/simple;
	bh=XyowkGRrVwuSfK58s7lOXgiIkOZma/Hu7GL8yYbTdQ4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=FjkYJYD5WKzVOC8mLKptcXdwqvSEZPyk2eSYmyPcNFcSn3QQID+VpiQJ3QWvg0FjCAnVMQRtMdDmqQDZKYjjoW3aQV7vC4QALmzdxT28PAp6VY4xWJCvJAm56gdEC2tGpljTgrON2HrZ8y5LPoxVi+5ioTdqZizCj8UzJ806d/s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ioOTCmJH; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ioOTCmJH"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D3A971F00893;
	Tue, 13 Oct 2026 12:49:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791895781;
	bh=LebER95L3Nbv5HMs2UdaEMQbmwKnJjHAGkN1mqHE5r4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ioOTCmJHeer6Ed3kCM7HmQOYN0rqfA9TWEkub7RgCSUgzbLRj0sMf5eaNicLlrjUl
	 ymnCLSZh1aue76eKkMC8bvjbBDUrssyJ8HQOVfGnmBzOaoR8so1Si7m2eHQIY1fNlG
	 IIgodmjpaHQ1PF/fpAKY8Ukp4A5pDHDogvxDpF0/fGWJTXvkwmvRw0HSEgZ7UL+Lfh
	 6+OQ+7RMKng8kaS4w3qhMbKBwz+q9NpfVfMIvjEk0WRq3vCnVxkV3/Wi5CnyKBk4on
	 7NI9RZb1IS5546I8K7YK2EVQS36TnOSuU6b2rL6kn9U5IlN+g5RgYuLZwwmsZCP9pi
	 1pWZhhbdovJ2A==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v3 19/34] NFSD: Use xdrgen XDR functions for the NFSv3 REMOVE procedure
Date: Tue, 13 Oct 2026 08:49:33 -0400
Message-ID: <20261013124933.316765-10-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20261013124933.316765-1-cel@kernel.org>
References: <20261013124933.316765-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Replace the NFSPROC3_REMOVE entry in the nfsd_procedures3 array
with an entry that dispatches the xdrgen-generated
nfs_svc_decode_REMOVE3args and nfs_svc_encode_REMOVE3res. A
wrapper structure bridges the generated xdrgen argument type and
the legacy svc_fh representation the NFSD VFS layer still uses;
the result uses the generated REMOVE3res type directly.

Filename validity is now checked by nfsd3_proc_remove() so that a
proper NFS3ERR status code can be returned to the client rather
than GARBAGE_ARGS.

The pc_argzero field is now set to zero for the NFSv3 REMOVE
procedure. The xdrgen decoders are trusted to initialize all
arguments in the argp->xdrgen field, making the early defensive
memset unnecessary. The remaining argp fields are cleared as
needed.

Because nfsd3_proc_remove() now assembles the WCC data, that work
moves out of the XDR result encoder, and the reference to the
file handle can be released directly by nfsd3_proc_remove(). A
separate ->pc_release callback is thus no longer needed. This
makes it straightforward to confirm that the file handle is
properly released during every error flow.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3proc.c | 72 ++++++++++++++++++++++++++++++++--------------
 1 file changed, 51 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index d878391e63f8..540e4a6a42e0 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -163,6 +163,13 @@ struct MKNOD3res_wrapper {
 
 static_assert(offsetof(struct MKNOD3res_wrapper, xdrgen) == 0);
 
+struct REMOVE3args_wrapper {
+	struct REMOVE3args	xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct REMOVE3args_wrapper, xdrgen) == 0);
+
 static int nfsd3_ftype3_to_mode(ftype3 ftype)
 {
 	switch (ftype) {
@@ -1252,20 +1259,42 @@ static __be32 nfsd3_proc_mknod(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
-/*
- * Remove file/fifo/socket etc.
+/**
+ * nfsd3_proc_remove - REMOVE: Remove a file
+ * @rqstp: RPC transaction context
+ *
+ * Return:
+ *   %rpc_success:		RPC executed successfully
+ *
+ * RPC synopsis:
+ *   REMOVE3res NFSPROC3_REMOVE(REMOVE3args) = 12;
  */
-static __be32
-nfsd3_proc_remove(struct svc_rqst *rqstp)
+static __be32 nfsd3_proc_remove(struct svc_rqst *rqstp)
 {
-	struct nfsd3_diropargs *argp = rqstp->rq_argp;
-	struct nfsd3_attrstat *resp = rqstp->rq_resp;
+	struct REMOVE3args_wrapper *argp = rqstp->rq_argp;
+	struct diropargs3 *object = &argp->xdrgen.object;
+	struct REMOVE3res *resp = rqstp->rq_resp;
+	struct svc_fh *fhp = &argp->fh;
 
-	/* Unlink. -S_IFDIR means file must not be a directory */
-	fh_copy(&resp->fh, &argp->fh);
-	resp->status = nfsd_unlink(rqstp, &resp->fh, -S_IFDIR,
-				   argp->name, argp->len);
-	resp->status = nfsd3_map_status(resp->status);
+	nfsd3_fh3_to_svc_fh(fhp, &object->dir);
+	resp->status = nfsd3_check_filename(object->name.data,
+					    object->name.len);
+	if (resp->status != nfs_ok)
+		goto out;
+
+	resp->status = nfsd_unlink(rqstp, fhp, -S_IFDIR,
+				   (char *)object->name.data,
+				   object->name.len);
+
+out:
+	if (resp->status == nfs_ok) {
+		nfsd3_fill_wcc_data(rqstp, &resp->u.resok.dir_wcc, fhp);
+	} else {
+		resp->status = nfsd3_map_status(resp->status);
+		nfsd3_fill_wcc_data(rqstp, &resp->u.resfail.dir_wcc, fhp);
+	}
+
+	fh_put(fhp);
 	return rpc_success;
 }
 
@@ -1712,16 +1741,15 @@ static const struct svc_procedure nfsd_procedures3[22] = {
 		.pc_name	= "MKNOD",
 	},
 	[NFSPROC3_REMOVE] = {
-		.pc_func = nfsd3_proc_remove,
-		.pc_decode = nfs3svc_decode_diropargs,
-		.pc_encode = nfs3svc_encode_wccstatres,
-		.pc_release = nfs3svc_release_fhandle,
-		.pc_argsize = sizeof(struct nfsd3_diropargs),
-		.pc_argzero = sizeof(struct nfsd3_diropargs),
-		.pc_ressize = sizeof(struct nfsd3_wccstatres),
-		.pc_cachetype = RC_REPLBUFF,
-		.pc_xdrressize = ST+WC,
-		.pc_name = "REMOVE",
+		.pc_func	= nfsd3_proc_remove,
+		.pc_decode	= nfs_svc_decode_REMOVE3args,
+		.pc_encode	= nfs_svc_encode_REMOVE3res,
+		.pc_argsize	= sizeof(struct REMOVE3args_wrapper),
+		.pc_argzero	= 0,
+		.pc_ressize	= sizeof(struct REMOVE3res),
+		.pc_cachetype	= RC_REPLBUFF,
+		.pc_xdrressize	= NFS3_REMOVE3res_sz,
+		.pc_name	= "REMOVE",
 	},
 	[NFSPROC3_RMDIR] = {
 		.pc_func = nfsd3_proc_rmdir,
@@ -1852,6 +1880,8 @@ union nfsd3_xdrstore {
 	struct SYMLINK3res_wrapper	symlinkres;
 	struct MKNOD3args_wrapper	mknodargs;
 	struct MKNOD3res_wrapper	mknodres;
+	struct REMOVE3args_wrapper	removeargs;
+	struct REMOVE3res		removeres;
 	struct nfsd3_renameargs		renameargs;
 	struct nfsd3_linkargs		linkargs;
 	struct nfsd3_readdirargs	readdirargs;
-- 
2.55.0

