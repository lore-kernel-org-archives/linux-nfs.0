Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33135 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750927AbaAWSxG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Jan 2014 13:53:06 -0500
Date: Thu, 23 Jan 2014 13:53:05 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, sandeen@redhat.com
Subject: [PATCH] nfsd4: decrease nfsd4_encode_fattr stack usage
Message-ID: <20140123185304.GA28223@fieldses.org>
References: <20140109213335.GA21559@fieldses.org>
 <20140109191934.5a66c3d8@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140109191934.5a66c3d8@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

A struct svc_fh is 320 bytes on x86_64, it'd be better not to have these
on the stack.

kmalloc'ing them probably isn't ideal either, but this is the simplest
thing to do.  If it turns out to be a problem in the readdir case then
we could add a svc_fh to nfsd4_readdir and pass that in.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

On Thu, Jan 09, 2014 at 07:19:34PM -0500, Jeff Layton wrote:
> On Thu, 9 Jan 2014 16:33:35 -0500
> >     nfsd: fix encode_entryplus_baggage stack usage
...
> I think this is probably the best solution...
> 
> Acked-by: Jeff Layton <jlayton@redhat.com>

Thanks.  While we're at it, here's the v4 case.

--b.

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 8198ecf..63f2395 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2058,7 +2058,7 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 	u32 bmval1 = bmval[1];
 	u32 bmval2 = bmval[2];
 	struct kstat stat;
-	struct svc_fh tempfh;
+	struct svc_fh *tempfh = NULL;
 	struct kstatfs statfs;
 	int buflen = count << 2;
 	__be32 *attrlenp;
@@ -2105,11 +2105,15 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 			goto out_nfserr;
 	}
 	if ((bmval0 & (FATTR4_WORD0_FILEHANDLE | FATTR4_WORD0_FSID)) && !fhp) {
-		fh_init(&tempfh, NFS4_FHSIZE);
-		status = fh_compose(&tempfh, exp, dentry, NULL);
+		tempfh = kmalloc(sizeof(struct svc_fh), GFP_KERNEL);
+		status = nfserr_jukebox;
+		if (!tempfh)
+			goto out;
+		fh_init(tempfh, NFS4_FHSIZE);
+		status = fh_compose(tempfh, exp, dentry, NULL);
 		if (status)
 			goto out;
-		fhp = &tempfh;
+		fhp = tempfh;
 	}
 	if (bmval0 & (FATTR4_WORD0_ACL | FATTR4_WORD0_ACLSUPPORT
 			| FATTR4_WORD0_SUPPORTED_ATTRS)) {
@@ -2495,8 +2499,8 @@ out:
 		security_release_secctx(context, contextlen);
 #endif /* CONFIG_NFSD_V4_SECURITY_LABEL */
 	kfree(acl);
-	if (fhp == &tempfh)
-		fh_put(&tempfh);
+	if (tempfh)
+		fh_put(tempfh);
 	return status;
 out_nfserr:
 	status = nfserrno(err);
-- 
1.7.9.5

