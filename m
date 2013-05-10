Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52934 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757355Ab3EJBBj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 May 2013 21:01:39 -0400
Date: Thu, 9 May 2013 21:01:32 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 16/17] NFSD: Server implementation of MAC Labeling
Message-ID: <20130510010132.GA7222@fieldses.org>
References: <1367515151-31015-1-git-send-email-SteveD@redhat.com>
 <1367515151-31015-17-git-send-email-SteveD@redhat.com>
 <20130509015033.GI23747@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130509015033.GI23747@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 08, 2013 at 09:50:33PM -0400, bfields wrote:
> This also doesn't handle the unsupported case correctly.
> 
> Applying the following fix to my tree.

And, one more change: I can't see why we need struct nfs4_label, given
that the only fields we're actually using are data and length.

One assumption I'm making here is that a zero-length security label is
the same as no security label; correct me if that's wrong.

After this, note that the only patch shared between client and server is
one patch that adds protocol constants.

A temporary branch with my current version of the server patches is
available from

	git://linux-nfs.org/~bfields/linux-topics.git for-3.11-incoming

--b.

commit 1b2b52707bb41229f7fdad0d13c2ae69b142e6dc
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed May 8 21:38:00 2013 -0400

    nfsd4: fix handling of unsupported SEC_LABEL
    
    Copy the logic in the ACL case to ensure that we just turn off the
    bitmap in the getattr case instead of erroring out, and to ensure that
    we get the supported_attributes attribute right.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d96f598..96f07cb 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1989,27 +1989,19 @@ nfsd4_encode_aclname(struct svc_rqst *rqstp, struct nfs4_ace *ace,
 
 #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
 static inline __be32
-nfsd4_encode_security_label(struct svc_rqst *rqstp, struct dentry *dentry, __be32 **pp, int *buflen)
+nfsd4_encode_security_label(struct svc_rqst *rqstp, void *context, int len, __be32 **pp, int *buflen)
 {
-	void *context;
-	int host_err;
-	__be32 err = nfserr_resource;
-	u32 len;
 	__be32 *p = *pp;
 
-	host_err = security_inode_getsecctx(dentry->d_inode, &context, &len);
-	if (host_err)
-		return nfserrno(host_err);
-
 	if (*buflen < ((XDR_QUADLEN(len) << 2) + 4 + 4 + 4))
-		goto out;
+		return nfserr_resource;
 
 	/*
 	 * For now we use a 0 here to indicate the null translation; in
 	 * the future we may place a call to translation code here.
 	 */
 	if ((*buflen -= 8) < 0)
-		goto out;
+		return nfserr_resource;
 
 	WRITE32(0); /* lfs */
 	WRITE32(0); /* pi */
@@ -2017,10 +2009,7 @@ nfsd4_encode_security_label(struct svc_rqst *rqstp, struct dentry *dentry, __be3
 	*buflen -= (XDR_QUADLEN(len) << 2) + 4;
 
 	*pp = p;
-	err = 0;
-out:
-	security_release_secctx(context, len);
-	return err;
+	return 0;
 }
 #else
 static inline __be32
@@ -2087,6 +2076,9 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 	int err;
 	int aclsupport = 0;
 	struct nfs4_acl *acl = NULL;
+	void *context = NULL;
+	int contextlen;
+	bool contextsupport = false;
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
 	u32 minorversion = resp->cstate.minorversion;
 	struct path path = {
@@ -2140,6 +2132,21 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 		}
 	}
 
+#ifdef CONFIG_NFSD_V4_SECURITY_LABEL
+	if ((bmval[2] & FATTR4_WORD2_SECURITY_LABEL) ||
+			bmval[0] & FATTR4_WORD0_SUPPORTED_ATTRS) {
+		err = security_inode_getsecctx(dentry->d_inode,
+						&context, &contextlen);
+		contextsupport = (err = 0);
+		if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
+			if (err == -EOPNOTSUPP)
+				bmval2 &= ~FATTR4_WORD2_SECURITY_LABEL;
+			else if (err)
+				goto out_nfserr;
+		}
+	}
+#endif /* CONFIG_NFSD_V4_SECURITY_LABEL */
+
 	if (bmval2) {
 		if ((buflen -= 16) < 0)
 			goto out_resource;
@@ -2168,6 +2175,8 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 
 		if (!aclsupport)
 			word0 &= ~FATTR4_WORD0_ACL;
+		if (!contextsupport)
+			word2 &= ~FATTR4_WORD2_SECURITY_LABEL;
 		if (!word2) {
 			if ((buflen -= 12) < 0)
 				goto out_resource;
@@ -2476,8 +2485,8 @@ out_acl:
 		WRITE64(stat.ino);
 	}
 	if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
-		status = nfsd4_encode_security_label(rqstp, dentry,
-				&p, &buflen);
+		status = nfsd4_encode_security_label(rqstp, context,
+				contextlen, &p, &buflen);
 		if (status)
 			goto out;
 	}
@@ -2493,6 +2502,8 @@ out_acl:
 	status = nfs_ok;
 
 out:
+	if (context)
+		security_release_secctx(context, contextlen);
 	kfree(acl);
 	if (fhp == &tempfh)
 		fh_put(&tempfh);
