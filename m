From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: patch 09/38: CLIENT: change fsid in 'struct nfs_fattr'
Date: Tue, 13 Aug 2002 18:59:45 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208131859230.25942-100000@rastan.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from berzerk.gpcc.itd.umich.edu ([141.211.2.162])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ekdf-0001FB-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 15:59:47 -0700
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

--- old/include/linux/nfs_xdr.h	Mon Jul 29 22:59:17 2002
+++ new/include/linux/nfs_xdr.h	Mon Jul 29 23:12:45 2002
@@ -22,12 +22,19 @@ struct nfs_fattr {
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
