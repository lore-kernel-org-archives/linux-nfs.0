From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: stale nfs file handle with exported loopback mounts
Date: Fri, 2 Nov 2007 15:42:25 -0400
Message-ID: <20071102194225.GH15595@fieldses.org>
References: <2062533683@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, NFS@lists.sourceforge.net,
	Andreas Gruenbacher <agruen@suse.de>
To: devzero@web.de
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <2062533683@web.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, Nov 02, 2007 at 08:37:12PM +0100, devzero@web.de wrote:
> so, you mean this is a problem of the client or some "fix it at the
> client end" ?
> 
> that would be bad, since it would mean i need to touch all our linux
> systems which want to access our next-generation :) cd-rom server.... 

No, it's definitely a server-side problem.  Oh, I see, I miswrote the
path; I meant fs/nfsd/nfs3acl.c, not fs/nfs/nfs3acl.c....

How about this?

--b.

>From 7fc982f90d404003329934ae3b786c5e4efb0c0a Mon Sep 17 00:00:00 2001
From: J. Bruce Fields <bfields@citi.umich.edu>
Date: Fri, 2 Nov 2007 15:36:08 -0400
Subject: [PATCH] knfsd: fix spurious EINVAL errors on first access of new filesystem

The v2/v3 acl code in nfsd is translating any return from fh_verify() to
nfserr_inval.  This is particularly unfortunate in the case of an
nfserr_dropit return, which is an internal error meant to indicate to
callers that this request has been deferred and should just be dropped
pending the results of an upcall to mountd.

Thanks to Roland <devzero@web.de> for bug report and data collection.

Cc: Roland <devzero@web.de>
Cc: Andreas Gruenbacher <agruen@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs2acl.c |    2 +-
 fs/nfsd/nfs3acl.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index bb3e188..d5fca59 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -41,7 +41,7 @@ static __be32 nfsacld_proc_getacl(struct svc_rqst * rqstp,
 
 	fh = fh_copy(&resp->fh, &argp->fh);
 	if ((nfserr = fh_verify(rqstp, &resp->fh, 0, MAY_NOP)))
-		RETURN_STATUS(nfserr_inval);
+		RETURN_STATUS(nfserr);
 
 	if (argp->mask & ~(NFS_ACL|NFS_ACLCNT|NFS_DFACL|NFS_DFACLCNT))
 		RETURN_STATUS(nfserr_inval);
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 3e3f2de..7cb39e7 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -40,7 +40,7 @@ static __be32 nfsd3_proc_getacl(struct svc_rqst * rqstp,
 		RETURN_STATUS(nfserr_inval);
 
 	if (argp->mask & ~(NFS_ACL|NFS_ACLCNT|NFS_DFACL|NFS_DFACLCNT))
-		RETURN_STATUS(nfserr_inval);
+		RETURN_STATUS(nfserr);
 	resp->mask = argp->mask;
 
 	if (resp->mask & (NFS_ACL|NFS_ACLCNT)) {
-- 
1.5.3.4.208.gc990


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
