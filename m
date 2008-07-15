From: Neil Brown <neilb@suse.de>
Subject: [PATCH] umount: fix problems when portmap doesn't listen on UDP.
Date: Tue, 15 Jul 2008 22:52:22 +1000
Message-ID: <18556.40326.764642.102066@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>,
	"Chuck Lever" <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:55115 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755330AbYGOMw2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2008 08:52:28 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Another patch that can be pulled from 
     git://neil.brown.name/nfs-utils for-steved

This and the next deal with problems with the new 'string based
option' code when portmap can only be contacted via TCP.

Some people seem to turn of string based options to avoid this
problem:
  https://bugs.launchpad.net/ubuntu/+bug/213444/comments/23

This can partly be avoided using mountproto=tcp, but that
  a/ shouldn't be needed (isn't with the old code)
  b/ doesn't help the unmount case.

This first patch make umount work better if mountproto=tcp was given
to mount.
The next patch gives mountproto=tcp to mount if it is needed.

NeilBrown



>From 863af3c54b574a588ac6d7bd05a1f250784159bd Mon Sep 17 00:00:00 2001
From: Neil Brown <neilb@suse.de>
Date: Tue, 15 Jul 2008 17:36:57 +1000

If portmap is not listening on UDP (as apparently happens with
MS-Windows-Server2003R2SP2), then nfs mounts have to be mounted
with -o mountproto=tcp to succeed.

In this case a umount will still try UDP and will fail to contact the
server.  It will still succeed with the local unmount (after a
timeout) but exits with a non-zero exit status.  This causes
/bin/mount to retry so we get a strange error about the filesystem
not being mounted.

So:
  get umount to use tcp if "mountproto=tcp" appears in mtab
  ignore any failure message from the server that would overwrite
     a success message from the local umount syscall.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 utils/mount/nfsumount.c |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 285273b..9e1855d 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -203,9 +203,15 @@ static int do_nfs_umount23(const char *spec, char *opts)
 		pmap->pm_vers = nfsvers_to_mnt(atoi(p+5));
 	if (opts && (p = strstr(opts, "mountvers=")) && isdigit(*(p+10)))
 		pmap->pm_vers = atoi(p+10);
-	if (opts && (hasmntopt(&mnt, "udp") || hasmntopt(&mnt, "proto=udp")))
+	if (opts && (hasmntopt(&mnt, "udp")
+		     || hasmntopt(&mnt, "proto=udp")
+		     || hasmntopt(&mnt, "mountproto=udp")
+		    ))
 		pmap->pm_prot = IPPROTO_UDP;
-	if (opts && (hasmntopt(&mnt, "tcp") || hasmntopt(&mnt, "proto=tcp")))
+	if (opts && (hasmntopt(&mnt, "tcp")
+		     || hasmntopt(&mnt, "proto=tcp")
+		     || hasmntopt(&mnt, "mountproto=tcp")
+		    ))
 		pmap->pm_prot = IPPROTO_TCP;
 
 	if (!nfs_gethostbyname(hostname, &mnt_server.saddr)) {
@@ -347,8 +353,13 @@ int nfsumount(int argc, char *argv[])
 	ret = 0;
 	if (mc) {
 		if (!lazy && strcmp(mc->m.mnt_type, "nfs4") != 0)
-			ret = do_nfs_umount23(mc->m.mnt_fsname, mc->m.mnt_opts);
-		ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir) ?: ret;
+			/* We ignore the error from do_nfs_umount23.
+			 * If the actual umount succeeds (in del_mtab),
+			 * we don't want to signal an error, as that
+			 * could cause /sbin/mount to retry!
+			 */
+			do_nfs_umount23(mc->m.mnt_fsname, mc->m.mnt_opts);
+		ret = del_mtab(mc->m.mnt_fsname, mc->m.mnt_dir);
 	} else if (*spec != '/') {
 		if (!lazy)
 			ret = do_nfs_umount23(spec, "tcp,v3");
-- 
1.5.6.2

