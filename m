From: Neil Brown <neilb@suse.de>
Subject: Re: RFC - NFS startup order
Date: Wed, 4 Apr 2007 13:00:36 +1000
Message-ID: <17939.5332.757746.617356@notabene.brown>
References: <17937.44243.21793.371809@notabene.brown>
	<20070403084523.GA32339@sith.mimuw.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jan Rekorajski <baggins@sith.mimuw.edu.pl>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYvjk-0002b6-J7
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 20:00:50 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HYvjm-0005uC-JY
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 20:00:42 -0700
In-Reply-To: message from Jan Rekorajski on Tuesday April 3
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

On Tuesday April 3, baggins@sith.mimuw.edu.pl wrote:
> On Tue, 03 Apr 2007, Neil Brown wrote:
> 
> > 3.1.  SERVER STARTUP
> > 
> > 
> >    A/  mount -t nfsd /proc/fs/nfsd
> >       This filesystem needs to be mount before most daemons,
> >       particularly exportfs, mountd, svcgssd, idmapd.
> >       It could be mounted once, or the script that starts each daemon
> >       could test if it is mounted and mount it if not.
> 
> mount -t rpc_pipefs /var/lib/nfs/rpc_pipefs
> This filesystem must be mounted before svcgssd and idmapd daemons.
> 

Is rpc_pipefs really needed for svcgssd?  or just for 'gssd' and
'idmapd'.

I gather that a SIGHUP to idmapd will cause it to open the serve
channels after they have been made available.  It is also sufficient
to SIGHUP idmapd after mounting rpc_pipefs if rpc_pipefs is mounted
later for some reason?

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
