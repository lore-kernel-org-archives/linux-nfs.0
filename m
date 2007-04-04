From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: RFC - NFS startup order
Date: Wed, 4 Apr 2007 12:16:01 -0400
Message-ID: <4d569c330704040916m4fe927a9g947cfafd7affb319@mail.gmail.com>
References: <17937.44243.21793.371809@notabene.brown>
	<20070403084523.GA32339@sith.mimuw.edu.pl>
	<17939.5332.757746.617356@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Jan Rekorajski <baggins@sith.mimuw.edu.pl>
To: "Neil Brown" <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HZ89T-0006Uv-Cz
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 09:16:03 -0700
Received: from ug-out-1314.google.com ([66.249.92.173])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HZ89T-0008Bc-Mg
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 09:16:05 -0700
Received: by ug-out-1314.google.com with SMTP id z38so777865ugc
	for <nfs@lists.sourceforge.net>; Wed, 04 Apr 2007 09:16:03 -0700 (PDT)
In-Reply-To: <17939.5332.757746.617356@notabene.brown>
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

On 4/3/07, Neil Brown <neilb@suse.de> wrote:
> On Tuesday April 3, baggins@sith.mimuw.edu.pl wrote:
> > On Tue, 03 Apr 2007, Neil Brown wrote:
> >
> > > 3.1.  SERVER STARTUP
> > >
> > >
> > >    A/  mount -t nfsd /proc/fs/nfsd
> > >       This filesystem needs to be mount before most daemons,
> > >       particularly exportfs, mountd, svcgssd, idmapd.
> > >       It could be mounted once, or the script that starts each daemon
> > >       could test if it is mounted and mount it if not.
> >
> > mount -t rpc_pipefs /var/lib/nfs/rpc_pipefs
> > This filesystem must be mounted before svcgssd and idmapd daemons.
> >
>
> Is rpc_pipefs really needed for svcgssd?  or just for 'gssd' and
> 'idmapd'.

rpc_pipefs is not currently used in svcgssd.

> I gather that a SIGHUP to idmapd will cause it to open the serve
> channels after they have been made available.  It is also sufficient
> to SIGHUP idmapd after mounting rpc_pipefs if rpc_pipefs is mounted
> later for some reason?

The short answer is no.  The current sighup processing in idmapd only
attempts to open/reopen the server channels.  (Probably only because
the "normal" system starts the NFS client first, and then the NFS
server.)

It is possible to start two instances of idmapd -- one servicing only
the client, and one servicing only the server.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
