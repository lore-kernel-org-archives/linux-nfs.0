From: Neil Brown <neilb@suse.de>
Subject: Re: rpc.statd  in /sbin or /usr/sbin ??
Date: Thu, 22 Mar 2007 16:12:23 +1100
Message-ID: <17922.4151.996812.925495@notabene.brown>
References: <17917.58341.502839.29524@notabene.brown>
	<200703190924.03153.olaf.kirch@oracle.com>
	<45FE8782.5020001@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HUFbB-0001Da-4f
	for nfs@lists.sourceforge.net; Wed, 21 Mar 2007 22:12:29 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HUFbC-0003cl-SJ
	for nfs@lists.sourceforge.net; Wed, 21 Mar 2007 22:12:31 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id BDB9F122EC
	for <nfs@lists.sourceforge.net>; Thu, 22 Mar 2007 06:12:27 +0100 (CET)
In-Reply-To: message from Steve Dickson on Monday March 19
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

On Monday March 19, SteveD@redhat.com wrote:
> 
> 
> Olaf Kirch wrote:
> > On Monday 19 March 2007 02:14, Neil Brown wrote:
> >>  The only reason I can see for putting statd in /sbin is if it were
> >>  needed for mounting /usr (in cases where /usr is accessed via NFS).
> > 
> > Can't speak for others, but this is the reason why Suse put it into /sbin too,
> > as long as they shipped it.
> I can only assuming this was the case as well... Red Hat has
> been putting both rpc.lockd and rpc.statd in /sbin
> since at least RH 7.1
> 

Ok.... so the only reason for moving to /sbin is a reason that I don't
think is a good one.  I think I won't move it in 'upstream'.

So people should really mount '/usr' (and '/var') with 'nolock' (which
should really be spelt 'locallocks' or similar).  But they probably
don't.

So how about this: In a similar way that we now try to start statd if
'nolock' is not set, we could set 'nolock' if we fail to start statd
(and it isn't already running).  What do people think of that?
I should probably add an rpc ping to check if statd is running rather
than just looking in /var/run/rpc.statd.pid, but the principle seems
sound.... 

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
