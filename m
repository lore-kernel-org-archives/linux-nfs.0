From: Marco.Schwarz@Freudenberg.de
Subject: AW: AW: URGENT: Problems with NFS-Root-Clients
Date: Wed, 28 Aug 2002 10:55:28 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <95AF67BA7F70D511829B0002A551737001C9C7@faw-e01.faw.freudenberg.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [153.95.95.71] (helo=itnts96.freudenberg.de)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17jydO-0001nk-00
	for <nfs@lists.sourceforge.net>; Wed, 28 Aug 2002 01:57:06 -0700
To: bogdan.costescu@iwr.uni-heidelberg.de
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

> -----Urspr=FCngliche Nachricht-----
> Von:	Bogdan Costescu [SMTP:bogdan.costescu@iwr.uni-heidelberg.de]
> Gesendet am:	Dienstag, 27. August 2002 18:11
> An:	Marco.Schwarz@freudenberg.de
> Cc:	nfs@lists.sourceforge.net
> Betreff:	Re: AW: [NFS] URGENT: Problems with NFS-Root-Clients
>=20
> On Tue, 27 Aug 2002 Marco.Schwarz@freudenberg.de wrote:
>=20
> > it is not working most of the time, but sometime it is, and some
> > days ago it was the other way ... working most of the time, just
> sometimes
> > problems).
>=20
> Hmm, maybe you should fix this first ! What do you mean by "not =
working":=20
> - sometimes it doesn't provide a link at boot time and you have to =
reboot=20
> and eventually it will get past the point and afterwards eveything =
works=20
> fine or
> - it boots fine and there are intermitent problems afterwards or
> - something else ?
	[Schwarz, Marco (FAW-Exchange)] =20
	Not Working: The client stops at the messages

NET4: Unix domain sockets 1.0/SMP for Linux NET4.0
ds: no socket drivers loaded !
Looking up port of RPC 100003/2 on 192.168.0.235
portmap: server 192.168.0.235 mot responding, timed out !
Root-NFS: Unable to get nfsd port number from server, using default
Looking up port of RPC 100005/1 on 192.168.0.235
portmap: server 192.168.0.235 mot responding, timed out !
Root-NFS: Unable to get mountd port number from server, using default
mount: server 192.168.0.235 not responding, timed out
Root-NFS: Server returned error -5 while mounting =
/netclients/192.168.0.87
VFS: Unable to mount root fs via NFS, trying floppy
VFS: Insert root floppy and press ENTER

	and simply refuses to boot ... This is not happening on all the
clients, one some it is a little better, on some its not working at all =
...
clients in a second adress range (153.95.240.x) seem not to be affected =
at
all, only clients with local adresses ...

> > Network cards are Intel EEPro100, but we have a lot more of these =
(also
> with
> > diskless clients, same configuration/kernel), and the problem is
> happening
> > in just this one location ...
>=20
> IIRC, there are different revisions of the cards, some of them having =

> some problems... so it's not sufficient to have another one working =
well !
	[Schwarz, Marco (FAW-Exchange)] =20
	I have about 30 cards here and 30 more in other places, so I think
it is save to rule out card problems, esp. since it is working when =
simply I
use my second adress range ... maybe its something with my =
configuration
which is wrong ...

> > Sending BOOTP requests . OK
> > IP-Config: Got BOOTP answer from 192.168.0.235, my adress is
> 192.168.0.87
> > IP-Config: Complete:
>=20
> Um, the link did work ! Can you try to ping it from the server ? That =

> should show if the link is down. Another (better) possibility would =
be to=20
> turn on debugging in the network driver (change in source and =
recompile or
>=20
> pass it on the kernel command line), but it depends on the driver =
that=20
> you're using. F.e. for Donald Becker's drivers you can use debug =
level 2=20
> or 3 to get media related information without getting too much=20
> uninteresting (for this problem) stuff
> Another unrelated suggestion: can you make sure that you're not =
running=20
> any kind of firewall (ipchains/iptables) on the server that could =
block=20
> the communication ?
	[Schwarz, Marco (FAW-Exchange)] =20
	There are no firewalls on this server ...

	Marco Schwarz

> --=20
> Bogdan Costescu
>=20
> IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
> Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
> Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
> E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De


-------------------------------------------------------
This sf.net email is sponsored by: Jabber - The world's fastest growing 
real-time communications platform! Don't just IM. Build it in! 
http://www.jabber.com/osdn/xim
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
