From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 00/19] export operations rewrite
Date: Fri, 14 Sep 2007 12:43:55 -0400
Message-ID: <20070914164355.GD26622@fieldses.org>
References: <20070914114746.GA28282@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, Neil Brown <neilb@suse.de>,
	nfs@lists.sourceforge.net
To: hch@lst.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IWEGp-00081n-ST
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 09:43:55 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IWEGs-0002dn-CZ
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 09:44:00 -0700
In-Reply-To: <20070914114746.GA28282@lst.de>
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

On Fri, Sep 14, 2007 at 01:47:46PM +0200, hch@lst.de wrote:
> This patchset is a medium scale rewrite of the export operations
> interface.  The goal is to make the interface less complex, and
> easier to understand from the filesystem side, aswell as preparing
> generic support for exporting of 64bit inode numbers.
> 
> This touches all nfs exporting filesystems, and I've done testing
> on all of the filesystems I have here locally (xfs, ext2, ext3, reiserfs,
> jfs)
> 
> Compared to the last version I've fixed the white space issues that
> checkpatch.pl complained about.

OK, thanks again.  Everything I have now is in

	git://linux-nfs.org/~bfields/linux.git	for-mm

I'm hoping Neil can take a quick look as well (and make a response to
the comment on patch #1 along the way).

> Note that this patch series is against mainline.  There will be some
> xfs changes landing in -mm soon that revamp lots of the code touched
> here.  They should hopefully include the first path in the series so
> it can be simply dropped, but the xfs conversion will need some smaller
> updates.  I will send this update as soon as the xfs tree updates get
> pulled into -mm.

OK.  Let me know if you need me to do anything when that happens.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
