From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: patch 31/38: SERVER: allow type==0 in nfsd_unlink()
Date: Tue, 13 Aug 2002 19:09:49 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208131909190.25942-100000@rastan.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eknP-0008OZ-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 16:09:51 -0700
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


If nfsd_unlink() is called with @type equal to 0, then let it do the
right thing regardless of the type of the file being unlinked.  This
is needed for the NFSv4 REMOVE operation, which works for any type of
file, even directories.

--- old/fs/nfsd/vfs.c	Tue Jul 30 23:28:23 2002
+++ new/fs/nfsd/vfs.c	Tue Jul 30 23:59:38 2002
@@ -1329,6 +1329,9 @@ nfsd_unlink(struct svc_rqst *rqstp, stru
 		goto out;
 	}

+	if (!type)
+		type = rdentry->d_inode->i_mode & S_IFMT;
+
 	if (type != S_IFDIR) { /* It's UNLINK */
 #ifdef MSNFS
 		if ((fhp->fh_export->ex_flags & NFSEXP_MSNFS) &&



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
