From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: REPOST patch 08/38: CLIENT: change fsid in 'struct nfs_fattr'
Date: Wed, 14 Aug 2002 16:39:55 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208141639310.1834-100000@vanguard.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f4vt-0003zk-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 13:39:57 -0700
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


In NFSv4, an fsid is a 64-bit major number together with a 64-bit
minor number.  In previous versions, an fsid is a single number.
This patch changes 'struct nfs_fattr' accordingly.

--- old/include/linux/nfs_xdr.h	Sun Aug 11 20:27:40 2002
+++ new/include/linux/nfs_xdr.h	Sun Aug 11 20:28:56 2002
@@ -22,13 +22,20 @@ struct nfs_fattr {
 		} nfs3;
 	} du;
 	__u32			rdev;
-	__u64			fsid;
+	union {
+		__u64		nfs3;		/* also nfs2 */
+		struct {
+			__u64	major;
+			__u64	minor;
+		} nfs4;
+	} fsid_u;
 	__u64			fileid;
 	__u64			atime;
 	__u64			mtime;
 	__u64			ctime;
 	unsigned long		timestamp;
 };
+#define fsid			fsid_u.nfs3

 #define NFS_ATTR_WCC		0x0001		/* pre-op WCC data    */
 #define NFS_ATTR_FATTR		0x0002		/* post-op attributes */



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
