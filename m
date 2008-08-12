From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: permit unauthenticated stat of export root
Date: Tue, 12 Aug 2008 11:43:15 -0400
Message-ID: <20080812154315.GA26256@fieldses.org>
References: <20080807181148.GK18904@fieldses.org> <489B3DAC.5060004@redhat.com> <20080807191656.GL18904@fieldses.org> <489B4F81.8000204@redhat.com> <20080807204154.GR18904@fieldses.org> <48A0AEDC.3080308@redhat.com> <1218490711.12593.16.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:51932 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751636AbYHLPnV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2008 11:43:21 -0400
In-Reply-To: <1218490711.12593.16.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 11, 2008 at 05:38:31PM -0400, Trond Myklebust wrote:
> On Mon, 2008-08-11 at 17:27 -0400, Peter Staubach wrote:
> > A better description of the set of operations which should be
> > allowed and which ones are not should include a discussion on
> > the contents of the response to the FSINFO request.  If the
> > server returns attributes in the FSINFO response, then it does
> > not need to allow unauthenticated GETATTR requests.  If it does
> > not return attributes in the FSINFO response, then it must allow
> > unauthenticated GETATTR requests because this is required in
> > order to allow clients to successfully mount file systems using
> > strong authentication.
> 
> Well... That's true for NFSv3, but if your server also supports
> NFSv2-with-RPCSEC_GSS, then it also has to support the NFSv2 FSSTAT
> +GETATTR under AUTH_SYS.
> 
> In any case, this is an issue of efficiency rather than security.
> Whether you allow FSINFO w/ post-op attributes but no GETATTR, or you
> allow FSINFO w/o post-op attributes and allow GETATTR on the mountpoint
> is entirely equivalent from the security viewpoint: the amount of
> information available using weak security is the same.

That makes sense, thanks.  (And thanks to Peter for the testing!)

So for now I'd like to just do the easy thing and add the v3 getattr to
the list of operations that don't require gss on the export root.

Still todo:

	- Test behavior with automount
	- Consider adding attributes to the return from fsinfo,
	  pathconf, and fsstat.
	- Look at client code to figure out why it's still requiring a
	  krb5 cred on mount.

But I don't know when I'll get to these, so if someone else is
interested, please go ahead and let us know what you find out....

--b.

commit ca80290ebda9009aedc4bd93ede5d397cb1853dc
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Thu Aug 7 13:00:20 2008 -0400

    nfsd: permit unauthenticated stat of export root
    
    RFC 2623 section 2.3.2 permits the server to bypass gss authentication
    checks for certain operations that a client may perform when mounting.
    In the case of a client that doesn't have some form of credentials
    available to it on boot, this allows it to perform the mount unattended.
    (Presumably real file access won't be needed until a user with
    credentials logs in.)
    
    Being slightly more lenient allows lots of old clients to access
    krb5-only exports, with the only loss being a small amount of
    information leaked about the root directory of the export.
    
    This affects only v2 and v3; v4 still requires authentication for all
    access.
    
    Thanks to Peter Staubach testing against a Solaris client, which
    suggesting addition of v3 getattr, to the list, and to Trond for noting
    that doing so exposes no additional information.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Cc: Peter Staubach <staubach@redhat.com>
    Cc: Trond Myklebust <trond.myklebust@fys.uio.no>

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 4d617ea..9dbd2eb 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -63,7 +63,8 @@ nfsd3_proc_getattr(struct svc_rqst *rqstp, struct nfsd_fhandle  *argp,
 		SVCFH_fmt(&argp->fh));
 
 	fh_copy(&resp->fh, &argp->fh);
-	nfserr = fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_NOP);
+	nfserr = fh_verify(rqstp, &resp->fh, 0,
+			NFSD_MAY_NOP | NFSD_MAY_BYPASS_GSS_ON_ROOT);
 	if (nfserr)
 		RETURN_STATUS(nfserr);
 
@@ -530,7 +531,7 @@ nfsd3_proc_fsstat(struct svc_rqst * rqstp, struct nfsd_fhandle    *argp,
 	dprintk("nfsd: FSSTAT(3)   %s\n",
 				SVCFH_fmt(&argp->fh));
 
-	nfserr = nfsd_statfs(rqstp, &argp->fh, &resp->stats);
+	nfserr = nfsd_statfs(rqstp, &argp->fh, &resp->stats, 0);
 	fh_put(&argp->fh);
 	RETURN_STATUS(nfserr);
 }
@@ -558,7 +559,8 @@ nfsd3_proc_fsinfo(struct svc_rqst * rqstp, struct nfsd_fhandle    *argp,
 	resp->f_maxfilesize = ~(u32) 0;
 	resp->f_properties = NFS3_FSF_DEFAULT;
 
-	nfserr = fh_verify(rqstp, &argp->fh, 0, NFSD_MAY_NOP);
+	nfserr = fh_verify(rqstp, &argp->fh, 0,
+			NFSD_MAY_NOP | NFSD_MAY_BYPASS_GSS_ON_ROOT);
 
 	/* Check special features of the file system. May request
 	 * different read/write sizes for file systems known to have
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index f45451e..7c6847e 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -302,17 +302,27 @@ fh_verify(struct svc_rqst *rqstp, struct svc_fh *fhp, int type, int access)
 	if (error)
 		goto out;
 
-	if (!(access & NFSD_MAY_LOCK)) {
-		/*
-		 * pseudoflavor restrictions are not enforced on NLM,
-		 * which clients virtually always use auth_sys for,
-		 * even while using RPCSEC_GSS for NFS.
-		 */
-		error = check_nfsd_access(exp, rqstp);
-		if (error)
-			goto out;
-	}
+	/*
+	 * pseudoflavor restrictions are not enforced on NLM,
+	 * which clients virtually always use auth_sys for,
+	 * even while using RPCSEC_GSS for NFS.
+	 */
+	if (access & NFSD_MAY_LOCK)
+		goto skip_pseudoflavor_check;
+	/*
+	 * Clients may expect to be able to use auth_sys during mount,
+	 * even if they use gss for everything else; see section 2.3.2
+	 * of rfc 2623.
+	 */
+	if (access & NFSD_MAY_BYPASS_GSS_ON_ROOT
+			&& exp->ex_path.dentry == dentry)
+		goto skip_pseudoflavor_check;
+
+	error = check_nfsd_access(exp, rqstp);
+	if (error)
+		goto out;
 
+skip_pseudoflavor_check:
 	/* Finally, check access permissions. */
 	error = nfsd_permission(rqstp, exp, dentry, access);
 
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 0766f95..5cffeca 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -65,7 +65,8 @@ nfsd_proc_getattr(struct svc_rqst *rqstp, struct nfsd_fhandle  *argp,
 	dprintk("nfsd: GETATTR  %s\n", SVCFH_fmt(&argp->fh));
 
 	fh_copy(&resp->fh, &argp->fh);
-	nfserr = fh_verify(rqstp, &resp->fh, 0, NFSD_MAY_NOP);
+	nfserr = fh_verify(rqstp, &resp->fh, 0,
+			NFSD_MAY_NOP | NFSD_MAY_BYPASS_GSS_ON_ROOT);
 	return nfsd_return_attrs(nfserr, resp);
 }
 
@@ -521,7 +522,8 @@ nfsd_proc_statfs(struct svc_rqst * rqstp, struct nfsd_fhandle   *argp,
 
 	dprintk("nfsd: STATFS   %s\n", SVCFH_fmt(&argp->fh));
 
-	nfserr = nfsd_statfs(rqstp, &argp->fh, &resp->stats);
+	nfserr = nfsd_statfs(rqstp, &argp->fh, &resp->stats,
+			NFSD_MAY_BYPASS_GSS_ON_ROOT);
 	fh_put(&argp->fh);
 	return nfserr;
 }
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 0f4481e..f51bdf6 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1872,9 +1872,9 @@ out:
  * N.B. After this call fhp needs an fh_put
  */
 __be32
-nfsd_statfs(struct svc_rqst *rqstp, struct svc_fh *fhp, struct kstatfs *stat)
+nfsd_statfs(struct svc_rqst *rqstp, struct svc_fh *fhp, struct kstatfs *stat, int access)
 {
-	__be32 err = fh_verify(rqstp, fhp, 0, NFSD_MAY_NOP);
+	__be32 err = fh_verify(rqstp, fhp, 0, NFSD_MAY_NOP | access);
 	if (!err && vfs_statfs(fhp->fh_dentry,stat))
 		err = nfserr_io;
 	return err;
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index a2861d9..47bea82 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -39,6 +39,7 @@
 #define NFSD_MAY_LOCK		32
 #define NFSD_MAY_OWNER_OVERRIDE	64
 #define NFSD_MAY_LOCAL_ACCESS	128 /* IRIX doing local access check on device special file*/
+#define NFSD_MAY_BYPASS_GSS_ON_ROOT 256
 
 #define NFSD_MAY_CREATE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE)
 #define NFSD_MAY_REMOVE		(NFSD_MAY_EXEC|NFSD_MAY_WRITE|NFSD_MAY_TRUNC)
@@ -126,7 +127,7 @@ int		nfsd_truncate(struct svc_rqst *, struct svc_fh *,
 __be32		nfsd_readdir(struct svc_rqst *, struct svc_fh *,
 			     loff_t *, struct readdir_cd *, filldir_t);
 __be32		nfsd_statfs(struct svc_rqst *, struct svc_fh *,
-				struct kstatfs *);
+				struct kstatfs *, int access);
 
 int		nfsd_notify_change(struct inode *, struct iattr *);
 __be32		nfsd_permission(struct svc_rqst *, struct svc_export *,
