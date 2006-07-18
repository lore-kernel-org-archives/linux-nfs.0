From: Neil Brown <neilb@suse.de>
Subject: Re: NFS export/mount problem ERR_ACCESS for exported mount
 point
Date: Wed, 19 Jul 2006 08:53:00 +1000
Message-ID: <17597.26188.641053.176665@cse.unsw.edu.au>
References: <44BB9F3D.14211.1695037@Ulrich.Windl.rkdvmks1.ngate.uni-regensburg.de>
	<17596.8411.211050.655554@cse.unsw.edu.au>
	<Pine.LNX.4.64.0607181716100.23497@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G3Lf6-0007df-0M
	for nfs@lists.sourceforge.net; Wed, 19 Jul 2006 16:41:04 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G3Lf3-0003P6-Uu
	for nfs@lists.sourceforge.net; Wed, 19 Jul 2006 16:41:04 -0700
To: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
In-Reply-To: message from Peter Åstrand on Tuesday July 18
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

On Tuesday July 18, astrand@cendio.se wrote:
> On Tue, 18 Jul 2006, Neil Brown wrote:
> 
> > The "user space" nfs server does have a --re-export option and it does
> > work to some extent, but there are plenty of scenarios where it would
> > perform very poorly or fail completely.
> 
> When you say "the user space nfs server", you mean Olaf Kirchs nfs-server 
> (http://freshmeat.net/projects/nfs-server/), right? Any particular reason 
> why you are recommending this one instead of UNFS3 
> (http://freshmeat.net/projects/unfs3/)?

I'm not recommending anything in particular.  I didn't even realise
there were two separate code bases.... I suspect they both come from
common code started by Mark Shand years and years ago...

It was more a general reference than a specific recommendation.

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
