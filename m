From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: REPOST patch 09/38: CLIENT: new fields in 'struct nfs_mount_data'
Date: Wed, 14 Aug 2002 16:40:33 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208141639580.1834-100000@vanguard.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f4wW-00044N-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 13:40:36 -0700
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

--- old/include/linux/nfs.h	Sun Aug 11 18:11:53 2002
+++ new/include/linux/nfs.h	Sun Aug 11 20:29:44 2002
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
--- old/include/linux/nfs3.h	Thu Aug  1 16:16:30 2002
+++ new/include/linux/nfs3.h	Sun Aug 11 20:29:44 2002
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
--- old/include/linux/nfs_mount.h	Thu Aug  1 16:16:03 2002
+++ new/include/linux/nfs_mount.h	Sun Aug 11 20:29:44 2002
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
