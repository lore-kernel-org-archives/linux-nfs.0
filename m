From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: REPOST patch 19/38: CLIENT: lease time in 'struct nfs_fsinfo'
Date: Wed, 14 Aug 2002 16:45:48 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208141645300.1834-100000@vanguard.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from berzerk.gpcc.itd.umich.edu ([141.211.2.162])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17f51b-0005gE-00
	for <nfs@lists.sourceforge.net>; Wed, 14 Aug 2002 13:45:51 -0700
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


A trivial loose end: add a 'lease_time' field to 'struct nfs_fsinfo'.

--- old/include/linux/nfs_xdr.h	Sun Aug 11 22:19:39 2002
+++ new/include/linux/nfs_xdr.h	Sun Aug 11 22:24:08 2002
@@ -66,6 +66,7 @@ struct nfs_fsinfo {
 	__u64			afiles;	/* # of files available to user */
 	__u32			linkmax;/* max # of hard links */
 	__u32			namelen;/* max name length */
+	__u32			lease_time; /* in seconds */
 };

 /* Arguments to the read call.



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
