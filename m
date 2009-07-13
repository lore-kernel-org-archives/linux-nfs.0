Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38329 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752177AbZGMRlj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2009 13:41:39 -0400
Date: Mon, 13 Jul 2009 13:41:36 -0400
To: Tom Haynes <tdh@excfb.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Security negotiation
Message-ID: <20090713174136.GA20884@fieldses.org>
References: <4A578372.1020005@excfb.com> <D8976FEC-39F9-4FF4-8FCE-AB3D5B047DFB@oracle.com> <F2FB7FDE-00D9-4623-964D-3C632AD64C68@oracle.com> <4A57AADE.8080002@excfb.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4A57AADE.8080002@excfb.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jul 10, 2009 at 03:55:58PM -0500, Tom Haynes wrote:
> Chuck Lever wrote:
>>
>>>
>>> If mountd does not provide AUTH_SYS a mount request with no sec= will 
>>> fail.  Should it try the first one in the list instead?  What if the  
>>> first one is AUTH_NULL?
>>
>> In other words, I'm not sure what is the right behavior here.  What it  
>> does now is probably suboptimal.  I've browsed 2623 a bit, but it's  
>> not hitting me.
>>
>
> So we (OpenSolaris) changed our behavior inadvertently to do the
> list in order. Which means we are trying AUTH_NONE against
> a Linux server. (Bug is here:  
> http://bugs.opensolaris.org/bugdatabase/view_bug.do?bug_id=6834430)

Yeah, that was a linux mountd bug.  Fixed by the below.  And note the
rfc language it mentions:

	"For this reason, a NFS client SHOULD use the first flavor in the
	list that it supports, on the assumption that the best access is
	provided by the first flavor. NFS servers that support the
	ability to export file systems with multiple security flavors
	SHOULD either present the best accessing flavor first to the
	client, or leave the order under the control of the system
	administrator."

Of course we may still be stuck with buggy servers, so perhaps a careful
client will still want to handle auth_null at least specially....

--b.

commit 3c1bb23c0379864722e79d19f74c180edcf2c36e
Author: bc Wong <bcwong@cisco.com>
Date:   Tue Mar 18 09:30:44 2008 -0400

    There were 2 things wrong with auth flavour ordering:
    - Mountd used to advertise AUTH_NULL as the first flavour on
      the list, which means that it prefers AUTH_NULL to anything
      else (as per RFC 2623 section 2.7).
    - Mount.nfs used to scan the returned list in reverse order,
      and stopping at the first AUTH_NULL or AUTH_SYS encountered.
      If a server advertises (AUTH_SYS, AUTH_NULL), it will by
      default choose AUTH_NULL and have degraded access.
    
    I've fixed mount.nfs to scan from the beginning. For mountd,
    it does not advertise AUTH_NULL anymore. This is necessary
    to avoid backward compatibility issue. If AUTH_NULL appears
    in the list, either the new or the old client will choose
    that over AUTH_SYS.
    
    Tested the server/client combination against the previous
    versions, as well as Solaris and FreeBSD.
    
    Signed-off-by: bc Wong <bcwong@cisco.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index d1d43c6..ff0ff93 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -738,7 +738,7 @@ nfsmount(const char *spec, const char *node, int flags,
 #if NFS_MOUNT_VERSION >= 4
 		mountres3_ok *mountres;
 		fhandle3 *fhandle;
-		int i, *flavor, yum = 0;
+		int i,  n_flavors, *flavor, yum = 0;
 		if (mntres.nfsv3.fhs_status != 0) {
 			nfs_error(_("%s: %s:%s failed, reason given by server: %s"),
 					progname, hostname, dirname,
@@ -747,13 +747,16 @@ nfsmount(const char *spec, const char *node, int flags,
 		}
 #if NFS_MOUNT_VERSION >= 5
 		mountres = &mntres.nfsv3.mountres3_u.mountinfo;
-		i = mountres->auth_flavors.auth_flavors_len;
-		if (i <= 0)
+		n_flavors = mountres->auth_flavors.auth_flavors_len;
+		if (n_flavors <= 0)
 			goto noauth_flavors;
 
 		flavor = mountres->auth_flavors.auth_flavors_val;
-		while (--i >= 0) {
-			/* If no flavour requested, use first simple
+		for (i = 0; i < n_flavors; ++i) {
+			/*
+			 * Per RFC2623, section 2.7, we should prefer the
+			 * flavour listed first.
+			 * If no flavour requested, use the first simple
 			 * flavour that is offered.
 			 */
 			if (! (data.flags & NFS_MOUNT_SECFLAVOUR) &&
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 63d5ce1..8137f7f 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -342,7 +342,14 @@ mount_mnt_3_svc(struct svc_req *rqstp, dirpath *path, mountres3 *res)
 #define AUTH_GSS_KRB5 390003
 #define AUTH_GSS_KRB5I 390004
 #define AUTH_GSS_KRB5P 390005
-	static int	flavors[] = { AUTH_NULL, AUTH_UNIX, AUTH_GSS_KRB5, AUTH_GSS_KRB5I, AUTH_GSS_KRB5P};
+	static int	flavors[] = { AUTH_UNIX, AUTH_GSS_KRB5, AUTH_GSS_KRB5I, AUTH_GSS_KRB5P};
+	/*
+	 * We should advertise the preferred flavours first. (See RFC 2623
+	 * section 2.7.) AUTH_UNIX is arbitrarily ranked over the GSS's.
+	 * AUTH_NULL is dropped from the list to avoid backward compatibility
+	 * issue with older Linux clients, who inspect the list in reversed
+	 * order.
+	 */
 	struct nfs_fh_len *fh;
 
 	xlog(D_CALL, "MNT3(%s) called", *path);
