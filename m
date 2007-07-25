From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NFS: have string-based mount options default to "intr" mounts
Date: Wed, 25 Jul 2007 14:56:14 -0400
Message-ID: <20070725145614.e17ca721.jlayton@redhat.com>
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

The current string-based mount options default to "nointr" mounts. This
is consistent with the current behavior of the struct-based mount
options for NFSv2/3, but inconsistent with v4.

I've just sent a nfs-utils patch to make the default be "intr" for all
NFS flavors. This patch makes the default the same when using
string-based mount options.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b2a851c..55f9b8b 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1122,7 +1122,9 @@ static int nfs_validate_mount_data(struct nfs_mount_data **options,
 		char *c;
 		int status;
 		struct nfs_parsed_mount_data args = {
-			.flags		= (NFS_MOUNT_VER3 | NFS_MOUNT_TCP),
+			.flags		= (NFS_MOUNT_INTR |
+					   NFS_MOUNT_VER3 |
+					   NFS_MOUNT_TCP),
 			.rsize		= NFS_MAX_FILE_IO_SIZE,
 			.wsize		= NFS_MAX_FILE_IO_SIZE,
 			.timeo		= 600,
@@ -1608,6 +1610,7 @@ static int nfs4_validate_mount_data(struct nfs4_mount_data **options,
 	default: {
 		unsigned int len;
 		struct nfs_parsed_mount_data args = {
+			.flags		= NFS4_MOUNT_INTR,
 			.rsize		= NFS_MAX_FILE_IO_SIZE,
 			.wsize		= NFS_MAX_FILE_IO_SIZE,
 			.timeo		= 600,
