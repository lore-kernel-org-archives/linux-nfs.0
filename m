From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: RFC - NFS startup order
Date: Tue, 3 Apr 2007 09:49:40 -0400
Message-ID: <4d569c330704030649n14c6d82bw633aafc390a0e09e@mail.gmail.com>
References: <17937.44243.21793.371809@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: "Neil Brown" <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYjOL-0001sv-EF
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 06:49:45 -0700
Received: from ug-out-1314.google.com ([66.249.92.175])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HYjON-0005c4-9a
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 06:49:47 -0700
Received: by ug-out-1314.google.com with SMTP id z38so305290ugc
	for <nfs@lists.sourceforge.net>; Tue, 03 Apr 2007 06:49:42 -0700 (PDT)
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

On 4/2/07, Neil Brown <neilb@suse.de> wrote:
>
>
> 3. DAEMON STARTUP ORDER
>
> This nfs-utils packages does not provide any scripts for starting
> various daemons as mast distributions replace them with their own, so

s/mast/most/

> any scripts we package would not get much testing.
> Instead, we explain the dependencies involved in startup so that
> scripts can be written to work correctly.
>
> 3.0   PREREQUISITES
>
>    Name service (host name lookup) should be working before any
>    NFS services are started.
>
>    "portmap" must be running before any NFS services (server or
>    client) are started.
>
>    Normally network interfaces should be configured first as well,
>    though this isn't critical for the NFS server (providing name
>    service is handled locally).
>
> 3.1.  SERVER STARTUP
>
>
>    A/  mount -t nfsd /proc/fs/nfsd
>       This filesystem needs to be mount before most daemons,
>       particularly exportfs, mountd, svcgssd, idmapd.
>       It could be mounted once, or the script that starts each daemon
>       could test if it is mounted and mount it if not.
>
>    B/ svcgssd ; idmapd
>        These supply services to nfsd and so should be started before
>        rpc.nfsd.  Where they come between mounting the nfsd filesystem
>        and starting the nfsd server is not important.
>        idmapd is only need for NFSv4 support.

s/need/needed/
Note that svcgssd is only needed if exporting NFS filesystems securely
(with Kerberos or SPKM3).

>    C/ exportfs -av ; rpc.mountd
>        If it important that exportfs be run before mountd so that

s/If it/It is/

>        mountd is working from current information (in
>        /var/lib/nfs/etab).
>        It is also important that both of these are run before
>        rpc.nfsd.
>        If not, any NFS requests that arrive before mountd is started
>        will get replied to with a 'Stale NFS File handle' error.
>
>    D/ rpc.statd --no-notify
>        It is best if statd is started before nfsd though this isn't
>        critical.  Certainly it should be at most a few seconds after
>        nfsd.
>        When nfsd starts it will start lockd. If lockd then receives a
>        lock request it will communicate with statd.  If statd is not
>        running lockd will retry, but it won't wait forever for a
>        reply.
>        Note that if statd is started before nfsd, the --no-notify
>        option must be used.  If notify requests are sent out before
>        nfsd start, clients may try to reclaim locks and, on finding
>        that lockd isn't running, they will give up and never reclaim
>        the lock.
>        rpc.statd is only needed for NFSv2 and NFSv3 support.
>
>    E/ rpc.nfsd
>        Starting nfsd will automatically start lockd.  The nfs server
>        will now be fully active and respond to any requests from
>        clients.
>
>    F/ sm-notify
>        This will notify any client which might have locks from before
>        a reboot to try to reclaim their locks.  This should start
>        immediately after rpc.nfsd is started so that clients have a
>        chance to reclaim locks within the 90 second grace period.
>        sm-notify is only needed for NFSv2 and NFSv3 support.
>
>
> 3.2.  CLIENT STARTUP
>
>    A/ sm-notify
>       This should be run shortly after boot and before any NFS
>       filesystems are mounted with remote-locking support -
>       filesystems can be mounted with "-o nolock" before sm-notify.
>       This is appropriate for '/', '/usr', and '/var'.
>
>    B/ gssd ; idmapd
>       (I need some guidance here).

idmapd should be started before mounting any NFSv4 filesystems.
gssd is only needed when filesystems are mounted securely (with
Kerberos or SPKM3).  It must be started before mounting any NFS
filesystems securely.

>    C/ statd should be run before any NFSv2 or NFSv3 filesystem is
>       mounted with remote locking (i.e. without -o nolock).
>       'mount' will try to use "/usr/sbin/start-statd" to start statd
>       if it is not already running, so there is no need to explicitly
>       start statd in boot-time scripts.
>
> 3.3.  SERVER/CLIENT INTERACTIONS
>
>    A/ sm-notify
>       Both the server and the client need sm-notify to be run.
>       It should be run after the NFS server is started, but before
>       and NFS filesystems are mounted with remote locking.
>
>    B/ rpc.statd
>       Both the server and the client need rpc.statd to be running.
>       Each should try to start when they need it.
>
>    C/ idmapd
>       (I need some guidance here).

Both the server and client need idmapd to be running.  If idmapd is
started (for the client) before starting nfsd (or is it mountd?), then
idmapd should be sent a HUP signal after starting nfsd (mountd?) to
signal that the server channels should be opened.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
