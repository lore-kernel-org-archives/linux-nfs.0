From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: nfsd random drop
Date: Thu, 1 Apr 2004 07:19:30 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435DE49@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B93yl-0007Dp-0G
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 07:19:39 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B93yk-0006Cv-Ms
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 07:19:38 -0800
To: "Olaf Kirch" <okir@suse.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

quick comment --

i think a shorter wait in the client before attempting to
reconnect would improve the likelihood that your completed
but unreplied operations would still be in the server's
replay cache.

that might be a good additional change (if you haven't
suggested that already).

> -----Original Message-----
> From: Olaf Kirch [mailto:okir@suse.de]=20
> Sent: Thursday, April 01, 2004 5:24 AM
> To: Neil Brown
> Cc: nfs@lists.sourceforge.net
> Subject: [NFS] nfsd random drop
>=20
>=20
> Hi,
>=20
> I hate to bore you all with the same old stuff, but I'm still fighting
> problems caused by nfsd's dropping active connections.
>=20
> The most recent episode in this saga is a problem with the Linux
> client.
>=20
> Consider a network with a single Linux 2.4 based home server, a few
> hundred clients, all using TCP. In Linux 2.4, nfsd starts dropping
> connections when it reaches a limit of (nrthreads + 3) * 10 open
> connections. With 4 threads, this means 70 connections, and=20
> with 8 threads
> this means 110 connections max. Both of which is totally=20
> inadequate for
> this network. To get out of the congestion zone, we would need to bump
> the number of threads to about 20, which is just silly.
>=20
> The very same network has been served well with just 4 threads all
> the time while using UDP.
>=20
> With the 2.6 kernel, things get even worse as the formula was=20
> changed to
> (nrthreads + 3) * 5, so you'll max out at 35 (4 threads) and 55 (with
> 8 threads), respectively. To serve 200 mounts via TCP simultaneously,
> you'd need close to 40 nfsd threads.
>=20
> In theory, all clients should be able to cope gracefully with=20
> such drops,
> but even the Linux client runs into a couple of SNAFUs with these.
>=20
> One: with a 50% probability, nfsd decides to drop the=20
> _newest_ connection,
> which is the one it just accepted.  When the Linux client sees a fresh
> connection go down before it was able to send anything across, it
> backs off for 15 to 60 seconds, hanging the NFS mount (with 2.6.5-pre,
> it's always 60 seconds). Which is kind of annoying the KDE users here,
> because KDE applications like to scribble to the home directory all
> the time, and their entire session freezes when NFS hangs.
>=20
> Second: People have reported that files vanished and/or rename/remove
> operations failed.
>=20
> I also think this is due to the TCP disconnects. What I think
> is happening here is this:
>=20
>  -      user X: unlink("blafoo")=20
>  -      kernel: sends NFS call to server REMOVE "blafoo"=20
>  -      nfsd thread A receives request, removes file blafoo.=20
> waits for=20
> 	some file system i/o to sync the change to disk=20
>  -      a new tcp connection comes in. Another nfsd thread B decides=20
> 	it needs to nuke some connections, selects user X's connection=20
>  -      nfsd thread A decides it should send the response now,
> 	but finds the socket is gone. Drops the reply.
>  -      client kernel: reconnect to NFS server
>  -	server drops connection
>  -	client waits for a while, reconnects again,
> 	resends REMOVE "blafoo"=20
>  -      NFS server: sorry, ENOENT: there's no such file "blafoo"=20
>=20
> Normally, the NFS server's replay cache should protect from this sort
> of behavior, but the long timeouts before the client can reconnect
> effectively mean the cached reply has been forgotten by the time the
> retransmitted call arrives.
>=20
> This is not a theoretical case; users here have reported that
> files vanish mysteriously several times a day.
>=20
> Three: people reported lots of messages in their syslog saying
> "nfs_rename: target foo/bar busy, d_count=3D2". This is a variation
> of the above. nfs_rename finds that someone still has foo/bar
> open and decides it needs to do a sillyrename. The rename
> fails with the spurious ENOENT error described above, causing
> the entire rename operation to fail
>=20
> Four: Some buggy clients can't deal with it, but I think I mentioned
> that already.  Prime offender is zOS; when a fresh connection=20
> is killed,
> it simply propagates the error to the application, hard mount=20
> or not. I
> know it's broken, but that doesn't mean we can't be gentler and make
> these clients work more smoothly with Linux.
>=20
> I propose to add the following two patches to the server and=20
> client. They
> increase the connection limit, stop dropping the neweset socket, and
> add some printk's to alert the admin of the contention.
>=20
> As an alternative to hardcoding a formula based on the number=20
> of threads,
> I could also make the max number of connections a sysctl.
>=20
> Comments,
> Olaf
> --=20
> Olaf Kirch     |  The Hardware Gods hate me.
> okir@suse.de   |
> ---------------+=20
>=20


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
