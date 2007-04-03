From: Jan Rekorajski <baggins@sith.mimuw.edu.pl>
Subject: Re: RFC - NFS startup order
Date: Tue, 3 Apr 2007 10:45:23 +0200
Message-ID: <20070403084523.GA32339@sith.mimuw.edu.pl>
References: <17937.44243.21793.371809@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYedr-0000ie-74
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 01:45:27 -0700
Received: from sith.mimuw.edu.pl ([193.0.96.4] ident=postfix)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HYeds-0007aW-Bp
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 01:45:29 -0700
In-Reply-To: <17937.44243.21793.371809@notabene.brown>
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

On Tue, 03 Apr 2007, Neil Brown wrote:

> 3.1.  SERVER STARTUP
> 
> 
>    A/  mount -t nfsd /proc/fs/nfsd
>       This filesystem needs to be mount before most daemons,
>       particularly exportfs, mountd, svcgssd, idmapd.
>       It could be mounted once, or the script that starts each daemon
>       could test if it is mounted and mount it if not.

mount -t rpc_pipefs /var/lib/nfs/rpc_pipefs
This filesystem must be mounted before svcgssd and idmapd daemons.

> 
>    B/ svcgssd ; idmapd
>        These supply services to nfsd and so should be started before
>        rpc.nfsd.  Where they come between mounting the nfsd filesystem
>        and starting the nfsd server is not important.
>        idmapd is only need for NFSv4 support.

[...]
> 
> 3.2.  CLIENT STARTUP
> 
>    A/ sm-notify
>       This should be run shortly after boot and before any NFS
>       filesystems are mounted with remote-locking support -
>       filesystems can be mounted with "-o nolock" before sm-notify.
>       This is appropriate for '/', '/usr', and '/var'.

Same here.

>    B/ gssd ; idmapd
>       (I need some guidance here).

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
