From: NeilBrown <neilb@suse.de>
Subject: [PATCH 000 of 2] knfsd: Don't allow bad file handles to cause
	extX to go readonly
Date: Fri, 28 Jul 2006 10:31:20 +1000
Message-ID: <20060728102713.15132.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6GGx-0005VS-0x
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 17:32:11 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G6GGw-0000t7-4s
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 17:32:11 -0700
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Currently, and file handle with a bad inode number in it can cause
ext2 to go to readonly (as it looks like a corrupted filesystem)
and could allow remote access to ext3 special files like the journal.

These patches give ext2/3 their own get_dentry method which checks the
inode number early before other bits of the code can be freaked out by
it.

These are revised versions of earlier patches.  Rather than exporting
export_iget, we open code it and simplify it slightly.  This avoids
and extra module dependancy.

NeilBrown

To follow:
 [PATCH 001 of 2] knfsd: Have ext2 reject file handles with bad inode numbers early.
 [PATCH 002 of 2] knfsd: Make ext3 reject filehandles referring to invalid inode numbers

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
