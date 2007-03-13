From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs-utils inode cache patch
Date: Tue, 13 Mar 2007 10:47:14 -0400
Message-ID: <20070313144714.GF23604@fieldses.org>
References: <20070309180921.57ae908c.simon.peter@gmx.de>
	<17910.9971.125407.778285@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Simon Peter <simon.peter@gmx.de>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HR8HZ-0005aK-Tk
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 07:47:22 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HR8HY-00076d-Dv
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 07:47:23 -0700
In-Reply-To: <17910.9971.125407.778285@notabene.brown>
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

On Tue, Mar 13, 2007 at 03:22:11PM +1100, Neil Brown wrote:
> While reflecting I remembered that I like the fact that unused
> information eventually disappeared from the kernel (where memory
> cannot be pages out).  This information won't any more.
> 
> But that probably isn't a big cost.

The cost of the export structure itself should be very small.  I would
have guessed that the it's the mounts that are the bigger problem.  But
I think additional work is needed to allow us to keep only currently
used filesystems mounted.

And in any case if Olaf is right then it may not be the cost of keeping
those filesystems mounted so much as the time required to mount them all
at once on startup.  So that might be the problem to work on first.

But I wonder how much memory it takes to keep a few thousand mounts?
And in addition to the memory, are there any bits of VFS code that don't
scale well to lots of mounts?

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
