From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: patch 28/38: SERVER: expand filehandle to 128 bytes
Date: Tue, 13 Aug 2002 19:08:22 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208131908030.25942-100000@rastan.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ekm0-0005kF-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 16:08:24 -0700
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


Expand filehandle to 128 bytes.

--- old/include/linux/nfsd/nfsfh.h	Tue Jul 30 22:43:19 2002
+++ new/include/linux/nfsd/nfsfh.h	Mon Jul 29 11:50:09 2002
@@ -96,7 +96,7 @@ struct knfsd_fh {
 					 */
 	union {
 		struct nfs_fhbase_old	fh_old;
-		__u32			fh_pad[NFS3_FHSIZE/4];
+		__u32			fh_pad[NFS4_FHSIZE/4];
 		struct nfs_fhbase_new	fh_new;
 	} fh_base;
 };



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
