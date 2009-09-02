From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSD: Fix a bug in the NFSv4 'supported attrs' mandatory
	attribute
Date: Tue, 1 Sep 2009 20:58:45 -0400
Message-ID: <20090902005844.GB582@fieldses.org>
References: <1251746171.25048.1.camel@heimdal.trondhjem.org> <20090831220324.GC5718@fieldses.org> <1251757313.25048.12.camel@heimdal.trondhjem.org> <1251757790.25048.16.camel@heimdal.trondhjem.org> <20090831224901.GA7466@fieldses.org> <1251761165.25048.19.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37410 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755460AbZIBA6m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Sep 2009 20:58:42 -0400
In-Reply-To: <1251761165.25048.19.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 31, 2009 at 07:26:05PM -0400, Trond Myklebust wrote:
> Actually, if you read Dave and Carl's 2005 internet draft, you'll see
> that they recommend you bump the change attribute whenever fs_locations
> changes.
> IOW: clients would only be allowed to cache the fs_locations information
> while the change attribute remains constant.

Which works for pure referrals since the object itself doesn't really
have any other use for the change attribute.  OK, makes sense.

> > To me it would seem permissible, however, for a client to interpret a
> > GETATTR reply which turns off a requested FS_LOCATIONS bit as stating a
> > permanent lack of support for the attribute, rather than necessarily as
> > stating that the list of fs_locations is currently zero-length.  So why
> > not make it unambiguous and return a zero-length list?
> 
> That would work.

Eh, just one more check's slightly incorrect (well, anyway pynfs
complains we're returning the wrong error), so the following is what I'm
commiting--thanks.

--b.

commit a06b1261bdb580b35967d0e055d1ab131b332254
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Aug 31 15:16:11 2009 -0400

    NFSD: Fix a bug in the NFSv4 'supported attrs' mandatory attribute
    
    The fact that the filesystem doesn't currently list any alternate
    locations does _not_ imply that the fs_locations attribute should be
    marked as "unsupported".
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6fde431..bebc0c2 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -68,7 +68,6 @@ check_attr_support(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		   u32 *bmval, u32 *writable)
 {
 	struct dentry *dentry = cstate->current_fh.fh_dentry;
-	struct svc_export *exp = cstate->current_fh.fh_export;
 
 	/*
 	 * Check about attributes are supported by the NFSv4 server or not.
@@ -80,17 +79,13 @@ check_attr_support(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		return nfserr_attrnotsupp;
 
 	/*
-	 * Check FATTR4_WORD0_ACL & FATTR4_WORD0_FS_LOCATIONS can be supported
+	 * Check FATTR4_WORD0_ACL can be supported
 	 * in current environment or not.
 	 */
 	if (bmval[0] & FATTR4_WORD0_ACL) {
 		if (!IS_POSIXACL(dentry->d_inode))
 			return nfserr_attrnotsupp;
 	}
-	if (bmval[0] & FATTR4_WORD0_FS_LOCATIONS) {
-		if (exp->ex_fslocs.locations == NULL)
-			return nfserr_attrnotsupp;
-	}
 
 	/*
 	 * According to spec, read-only attributes return ERR_INVAL.
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index fdf632b..20c5e3d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1793,11 +1793,6 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 				goto out_nfserr;
 		}
 	}
-	if (bmval0 & FATTR4_WORD0_FS_LOCATIONS) {
-		if (exp->ex_fslocs.locations == NULL) {
-			bmval0 &= ~FATTR4_WORD0_FS_LOCATIONS;
-		}
-	}
 	if ((buflen -= 16) < 0)
 		goto out_resource;
 
@@ -1825,8 +1820,6 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 			goto out_resource;
 		if (!aclsupport)
 			word0 &= ~FATTR4_WORD0_ACL;
-		if (!exp->ex_fslocs.locations)
-			word0 &= ~FATTR4_WORD0_FS_LOCATIONS;
 		if (!word2) {
 			WRITE32(2);
 			WRITE32(word0);
