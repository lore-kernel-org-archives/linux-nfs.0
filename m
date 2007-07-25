From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfs-utils: have mount.nfs default to "intr" mounts for v2
	and v3
Date: Wed, 25 Jul 2007 14:56:11 -0400
Message-ID: <20070725145611.946d0a96.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

Currently NFSv4 defaults to "intr" mounts, and NFSv2 and 3 default to
"nointr". The manpage, however, just says that the default is "nointr"
with no mention of NFSv4's actual default. We could just fix the doc,
but it seems like having "intr" as the default across the board would
make the most sense. The following patch does this and updates the nfs
manpage accordingly.

I'll also send a follow-on patch that brings the string-based mount
options into line with this default.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index e66daba..9f238ba 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -234,11 +234,12 @@ If an NFS file operation has a major timeout then report
 "server not responding" on the console and continue retrying indefinitely.
 This is the default.
 .TP 1.5i
-.I intr
+.I nointr
 If an NFS file operation has a major timeout and it is hard mounted,
-then allow signals to interupt the file operation and cause it to
-return EINTR to the calling program.  The default is to not
-allow file operations to be interrupted.
+then a signal will allow the operation to be interrupted and EINTR 
+returned to the calling program. This option disables this, causing
+signals to be ignored in this situation. The default is to allow file
+operations to be interrupted by signals.
 .TP 1.5i
 .I posix
 Mount the NFS filesystem using POSIX semantics.  This allows
diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
index 6949b50..09c5209 100644
--- a/utils/mount/nfsmount.c
+++ b/utils/mount/nfsmount.c
@@ -167,7 +167,7 @@ parse_options(char *old_opts, struct nfs_mount_data *data,
 	char cbuf[128];
 	int open_quote = 0;
 
-	data->flags = 0;
+	data->flags = NFS_MOUNT_INTR;
 	*bg = 0;
 
 	len = strlen(new_opts);
