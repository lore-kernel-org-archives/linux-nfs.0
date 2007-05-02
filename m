From: Neil Brown <neilb@suse.de>
Subject: Re: mountd randomly crash and panic the server
Date: Wed, 2 May 2007 21:29:06 +1000
Message-ID: <17976.30210.646676.127544@notabene.brown>
References: <461CFABE.9050301@barazer.net> <46234130.5020502@oxeva.fr>
	<17955.21572.383131.837268@notabene.brown>
	<4623830D.7040108@oxeva.fr>
	<17956.8604.672536.126674@notabene.brown>
	<46367FBC.6000007@oxeva.fr>
	<17974.33522.70308.585198@notabene.brown>
	<463853D5.1020106@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Gabriel Barazer <gabriel@oxeva.fr>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjD1U-0000Gq-50
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 04:29:28 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HjD1W-0001FR-40
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 04:29:30 -0700
In-Reply-To: message from Gabriel Barazer on Wednesday May 2
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

On Wednesday May 2, gabriel@oxeva.fr wrote:
> On 05/01/2007 1:59:46 +0200, Neil Brown <neilb@suse.de> wrote:
> > 
> >>   related kernel panics, which are, I suppose, not linked to the NFS 
> >> problem (I still mention it because unrelated but linked problems like 
> >> this sometimes happens)
> > 
> > CFQ panics ?  In cfq_dispatch_insert by any chance?
> > 
> > This patch from Jens Axboe might be what you need.
> > 
> 
> The problem is exactly related to this function : Is this bug related to 
> the NFS subsystem, or am I lucky and it appears you work on the CFQ 
> scheduler as well ? :) I can test this patch, but since this bug panic() 
> the kernel, I can't afford to hang the file server very often.

I don't normally work on the CFQ scheduler, but I do work on md/raid,
and the people who had reported this bug were all using md/raid, so I
looked into it.

The patch definitely fixes the problem.

> 
> For now I have changed the scheduler to deadline with the 
> /sys/block/<device>/queue/scheduler file. Is this patch already sent to 
> the upstream kernel sources ?

Yes, it is in 2.6.21.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
