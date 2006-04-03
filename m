From: NeilBrown <neilb@suse.de>
Subject: [PATCH 004 of 16] knfsd: nfsd4: fix acl xattr length return
Date: Mon, 3 Apr 2006 15:18:23 +1000
Message-ID: <1060403051823.1771@suse.de>
References: <20060403151452.1567.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751480AbWDCFUP@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


We should be using the length from the second vfs_getxattr, in case it
changed.  (Note: there's still a small race here; we could end up returning
-ENOMEM if the length increased between the first and second call.  I don't
know whether it's worth spending a lot of effort to fix that.)

This makes XFS ACLs usable on NFS exports, which they currently aren't,
since XFS appears to be returning a too-large value for vfs_getxattr() when
it's passed a NULL buffer.  So there's probably an XFS bug here too, though
since getxattr with a NULL buffer is usually used to decide how much memory
to allocate, it may be a fairly harmless bug in most cases.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/vfs.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2006-04-03 15:12:07.000000000 +1000
+++ ./fs/nfsd/vfs.c	2006-04-03 15:12:07.000000000 +1000
@@ -371,7 +371,6 @@ out_nfserr:
 static ssize_t nfsd_getxattr(struct dentry *dentry, char *key, void **buf)
 {
 	ssize_t buflen;
-	int error;
 
 	buflen = vfs_getxattr(dentry, key, NULL, 0);
 	if (buflen <= 0)
@@ -381,10 +380,7 @@ static ssize_t nfsd_getxattr(struct dent
 	if (!*buf)
 		return -ENOMEM;
 
-	error = vfs_getxattr(dentry, key, *buf, buflen);
-	if (error < 0)
-		return error;
-	return buflen;
+	return vfs_getxattr(dentry, key, *buf, buflen);
 }
 #endif
 
