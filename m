From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH 0/18] export operations rewrite
Date: Sun, 01 Apr 2007 16:03:25 +0100
Message-ID: <1175439805.3122.332.camel@pmac.infradead.org>
References: <20070317010946.GA24947@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HY1ab-0002o2-Iw
	for nfs@lists.sourceforge.net; Sun, 01 Apr 2007 08:03:29 -0700
Received: from canuck.infradead.org ([209.217.80.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HY1ac-0005NB-Ok
	for nfs@lists.sourceforge.net; Sun, 01 Apr 2007 08:03:32 -0700
In-Reply-To: <20070317010946.GA24947@infradead.org>
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

On Sat, 2007-03-17 at 01:09 +0000, Christoph Hellwig wrote:
> This touches all nfs exporting filesystems, and I've done testing
> on all of the filesystems I have here locally (xfs, ext2, ext3,
> reiserfs, jfs) 

modprobe mtdram ; mount -tjffs2 mtd0 /mnt

:)

-- 
dwmw2


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
