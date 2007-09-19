From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 00/18] export operations rewrite
Date: Wed, 19 Sep 2007 18:30:09 +0200
Message-ID: <20070919163009.GA18952@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: akpm@osdl.org
To: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IY2RL-0003TJ-HP
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 09:30:15 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1IY2RM-0005c1-VN
	for nfs@lists.sourceforge.net; Wed, 19 Sep 2007 09:30:20 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This patchset is a medium scale rewrite of the export operations
interface.  The goal is to make the interface less complex, and
easier to understand from the filesystem side, aswell as preparing
generic support for exporting of 64bit inode numbers.

This touches all nfs exporting filesystems, and I've done testing
on all of the filesystems I have here locally (xfs, ext2, ext3, reiserfs,   
jfs)

Unlike the last posting this series is against -mm (2.6.23-rc6-mm1
specificly), so the first patch has been dropped as it's in git-xfs
already, and the XFS conversion has gotten some major context changes
due to the changes in git-xfs.  Except for those and some typo fixes
in the documentation patch it's identical to the previous one.

This series is sent for inclusion into -mm.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
