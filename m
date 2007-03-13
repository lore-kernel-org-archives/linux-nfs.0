From: Neil Brown <neilb@suse.de>
Subject: Re: nfs-utils inode cache patch
Date: Tue, 13 Mar 2007 15:22:11 +1100
Message-ID: <17910.9971.125407.778285@notabene.brown>
References: <20070309180921.57ae908c.simon.peter@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Simon Peter <simon.peter@gmx.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQyWf-00022c-8L
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 21:22:18 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HQyWg-00065h-TM
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 21:22:19 -0700
In-Reply-To: message from Simon Peter on Friday March 9
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

On Friday March 9, simon.peter@gmx.de wrote:
> Hi Neil,
> 
> okay, here's the patch making the kernel cache inode data of exported
> directories forever, thus avoiding unnecessary disk spin-ups when this
> data is looked for. It looks correct, works for me and both Bruce and
> you have been encouraging it. :) Would be great if that could go into
> nfs-utils.
> 
> Thanks,
> Simon

Hmmm...

> Content-Type: video/dv;
>  name="nfs-utils-1.0.12-cache.dif"

So it was a video/dv file was it?

Ok, I've applied it and added a big comment.

While reflecting I remembered that I like the fact that unused
information eventually disappeared from the kernel (where memory
cannot be pages out).  This information won't any more.

But that probably isn't a big cost.

http://neil.brown.name/git?p=nfs-utils;a=commitdiff;h=b1e1c8a05afdbbc3f217ef79c31c3b8ca302f9eb

Thanks,
NeilBrown


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
