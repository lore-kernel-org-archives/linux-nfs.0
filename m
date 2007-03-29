From: Jan Rekorajski <baggins@sith.mimuw.edu.pl>
Subject: Re: RELEASE CANDIDATE - nfs-utils-1.1.0-rc1
Date: Thu, 29 Mar 2007 14:44:46 +0200
Message-ID: <20070329124446.GZ23295@sith.mimuw.edu.pl>
References: <17931.15549.578071.112573@notabene.brown>
	<20070329084433.GA1627@sith.mimuw.edu.pl>
	<17931.34669.47062.146703@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWtzh-0001vq-5A
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 05:44:45 -0700
Received: from sith.mimuw.edu.pl ([193.0.96.4] ident=postfix)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWtzg-0006aX-7S
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 05:44:47 -0700
In-Reply-To: <17931.34669.47062.146703@notabene.brown>
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

On Thu, 29 Mar 2007, Neil Brown wrote:

> On Thursday March 29, baggins@sith.mimuw.edu.pl wrote:
> > On Thu, 29 Mar 2007, Neil Brown wrote:
> > 
> > >  Run "statd" only when starting the NFS server.
> > >  "statd" should be run before starting the NFS server.
> > 
> > While you're at it, can you tell me what should be the order of starting
> > all NFS/NFS4 daemons? So far I got to this:
> > 
> > 1) statd
> > 2) mountd
> > 3) nfsd
> > 4) idmapd
> > 5) svcgssd
> > 6) gssd
> > 7) rquotad
> > 8) any NFS mounts
> > 
> > Is it correct?
> 
> Hmm... good question.
> 
> I think:
> 
>   - idmapd and gssd should be started before any nfs mount

That's quite obvious.

>   - idmapd and svcgssd should be started before nfsd

Here I must disagree, my experience shows that idmapd must be started (or
at least restarted) after mountd (or exportfs) is run.
I had no id mapping when I started idmapd before mountd/nfsd.

[...]

>  idmapd/svcgssd/gssd:
>    simply provide service to the kernel modules.   So they should
>    be running before the kernel wants them.

What's troubling me here is svcgssd - does it behave like idmapd and
requires mountd? My quick investigation in the source telss me it is so.

Jan
-- 
Jan Rekorajski            |  ALL SUSPECTS ARE GUILTY. PERIOD!
baggins<at>mimuw.edu.pl   |  OTHERWISE THEY WOULDN'T BE SUSPECTS, WOULD THEY?
BOFH, MANIAC              |                   -- TROOPS by Kevin Rubio

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
