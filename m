From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: patch 10/38: CLIENT: new fields in 'struct nfs_mount_data'
Date: Tue, 13 Aug 2002 19:00:09 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208131859470.25942-100000@rastan.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from berzerk.gpcc.itd.umich.edu ([141.211.2.162])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eke4-0001nI-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 16:00:12 -0700
To: linux-kernel@vger.kernel.org, <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


This patch changes 'struct nfs_mount_data' to include some new fields
which will be passed down by the mount program:
  @mnt_path - In NFSv4, the client kernel obtains the mount path
              and is responsible for doing LOOKUP's component by
              component, starting with the root of the pseudo
              filesystem, until the filehandle of the mount point
              is obtained.  This is in contrast with previous
              versions, in which the mount program obtains the
              filehandle of the mount point from mountd.
  @ip_addr  - The mount program fills this in with the client's
              own IP address.  This is used to set the client's
              clientid (an identifier, unique to the client,
              which the client sends to the server), and also
              to send callback information to the server.

It also defines new mount flags NFS_MOUNT_VER4, NFS_MOUNT_STRICTLOCK.
The STRICTLOCK flag will be used in a subsequent patch which implements
byte-range file locking.

Finally, this patch increases the filehandle size to 128 bytes, but also
changes the definition of the 'root' field in 'struct nfs_mount_data'
so that it remains a 64-byte filehandle (to ensure binary compatibility
with pre-NFSv4 versions of the mount program).

--- old/include/linux/nfs.h	Mon Jul 29 15:53:27 2002
+++ new/include/linux/nfs.h	Mon Jul 29 23:18:38 2002
@@ -120,7 +120,11 @@ enum nfs_ftype {
 /*
  * This is the kernel NFS client file handle representation
  */
-#define NFS_MAXFHSIZE		64
+#ifdef CONFIG_NFS_V4
+# define NFS_MAXFHSIZE		128
+#else
+# define NFS_MAXFHSIZE		64
+#endif
 struct nfs_fh {
 	unsigned short		size;
 	unsigned char		data[NFS_MAXFHSIZE];
--- old/include/linux/nfs3.h	Wed Jul 24 16:03:30 2002
+++ new/include/linux/nfs3.h	Mon Jul 29 11:50:09 2002
@@ -28,6 +28,12 @@
 #define NFS3_ACCESS_EXTEND	0x0008
 #define NFS3_ACCESS_DELETE	0x0010
 #define NFS3_ACCESS_EXECUTE	0x0020
+#define NFS3_ACCESS_FULL	0x003f
+
+struct nfs3_fh {
+	unsigned short		size;
+	char			data[NFS3_FHSIZE];
+};

 /* Flags for create mode */
 enum nfs3_createmode {
--- old/include/linux/nfs_mount.h	Wed Jul 24 16:03:18 2002
+++ new/include/linux/nfs_mount.h	Mon Jul 29 11:50:09 2002
@@ -18,7 +18,7 @@
  * mount-to-kernel version compatibility.  Some of these aren't used yet
  * but here they are anyway.
  */
-#define NFS_MOUNT_VERSION	4
+#define NFS_MOUNT_VERSION	5

 struct nfs_mount_data {
 	int		version;		/* 1 */
@@ -37,7 +37,9 @@ struct nfs_mount_data {
 	char		hostname[256];		/* 1 */
 	int		namlen;			/* 2 */
 	unsigned int	bsize;			/* 3 */
-	struct nfs_fh	root;			/* 4 */
+	struct nfs3_fh	root;			/* 4 */
+	char		mnt_path[256];		/* 5 */
+	char		ip_addr[16];		/* 5 */
 };

 /* bits in the flags field */
@@ -53,6 +55,8 @@ struct nfs_mount_data {
 #define NFS_MOUNT_KERBEROS	0x0100	/* 3 */
 #define NFS_MOUNT_NONLM		0x0200	/* 3 */
 #define NFS_MOUNT_BROKEN_SUID	0x0400	/* 4 */
+#define NFS_MOUNT_VER4		0x0800	/* 5 */
+#define NFS_MOUNT_STRICTLOCK	0x1000	/* 5 */
 #define NFS_MOUNT_FLAGMASK	0xFFFF

 #endif



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
