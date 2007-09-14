From: hch@lst.de
Subject: [PATCH 00/19] export operations rewrite
Date: Fri, 14 Sep 2007 13:47:46 +0200
Message-ID: <20070914114746.GA28282@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IW9eI-0007zh-PO
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 04:47:50 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1IW9eL-0002qz-5M
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 04:47:55 -0700
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

Compared to the last version I've fixed the white space issues that
checkpatch.pl complained about.

Note that this patch series is against mainline.  There will be some
xfs changes landing in -mm soon that revamp lots of the code touched
here.  They should hopefully include the first path in the series so
it can be simply dropped, but the xfs conversion will need some smaller
updates.  I will send this update as soon as the xfs tree updates get
pulled into -mm.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
