From: "bc Wong" <bcwalrus@gmail.com>
Subject: [PATCH] nfs-utils: Handle authentication flavour order properly
Date: Thu, 6 Mar 2008 19:08:38 -0800
Message-ID: <f88853200803061908y497164bdpdff7b9109567d8c0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.189]:44362 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761526AbYCGDIj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Mar 2008 22:08:39 -0500
Received: by rn-out-0910.google.com with SMTP id v46so474486rnb.15
        for <linux-nfs@vger.kernel.org>; Thu, 06 Mar 2008 19:08:39 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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

Signed-off-by: bc Wong <bcwong-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>

Cheers,
bc

---

 utils/mount/nfsmount.c |   13 ++++++++-----
 utils/mountd/mountd.c  |    9 ++++++++-
 2 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 3d2ebb1..da5c428 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -734,7 +734,7 @@ nfsmount(const char *spec, const char *node, int flags,
 #if NFS_MOUNT_VERSION >= 4
                mountres3_ok *mountres;
                fhandle3 *fhandle;
-               int i, *flavor, yum = 0;
+               int i, n_flavors, *flavor, yum = 0;
                if (mntres.nfsv3.fhs_status != 0) {
                        nfs_error(_("%s: %s:%s failed, reason given by
server: %s"),
                                        progname, hostname, dirname,
@@ -743,13 +743,16 @@ nfsmount(const char *spec, const char *node, int flags,
                }
 #if NFS_MOUNT_VERSION >= 5
                mountres = &mntres.nfsv3.mountres3_u.mountinfo;
-               i = mountres->auth_flavors.auth_flavors_len;
-               if (i <= 0)
+               n_flavors = mountres->auth_flavors.auth_flavors_len;
+               if (n_flavors <= 0)
                        goto noauth_flavors;

                flavor = mountres->auth_flavors.auth_flavors_val;
-               while (--i >= 0) {
-                       /* If no flavour requested, use first simple
+               for (i = 0; i < n_flavors; ++i) {
+                       /*
+                        * Per RFC2623, section 2.7, we should prefer the
+                        * flavour listed first.
+                        * If no flavour requested, use the first simple
                         * flavour that is offered.
                         */
                        if (! (data.flags & NFS_MOUNT_SECFLAVOUR) &&
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 63d5ce1..b006dc6 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -342,7 +342,14 @@ mount_mnt_3_svc(struct svc_req *rqstp, dirpath
*path, mountres3 *res)
 #define AUTH_GSS_KRB5 390003
 #define AUTH_GSS_KRB5I 390004
 #define AUTH_GSS_KRB5P 390005
-       static int      flavors[] = { AUTH_NULL, AUTH_UNIX,
AUTH_GSS_KRB5, AUTH_GSS_KRB5I, AUTH_GSS_KRB5P};
+       /*
+        * We should advertise the preferred flavours first. (See RFC 2623
+        * section 2.7.) AUTH_UNIX is arbitrarily ranked over the GSS's.
+        * AUTH_NULL is dropped from the list to avoid backward compatibility
+        * issue with older Linux clients, who inspect the list in reversed
+        * order.
+        */
+       static int      flavors[] = { AUTH_UNIX, AUTH_GSS_KRB5,
AUTH_GSS_KRB5I, AUTH_GSS_KRB5P };
        struct nfs_fh_len *fh;

        xlog(D_CALL, "MNT3(%s) called", *path);
-- 
1.5.2.5
