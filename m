From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: nfs unlink perf !
Date: Tue, 13 Aug 2002 09:20:32 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E50D1E6@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eePX-0004Se-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 09:20:47 -0700
To: =?iso-8859-1?Q?=27Brasseur_Val=E9ry=27?=
	 <Valery.Brasseur@atosorigin.com>
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

hi brasseur-

> I check nfsstat, and see a bunch of retrans...
> but now when then following your suggestion I 've try to put :
>    tcp + rsize/wsize=3D32768 and :
>  * take the same time
>  * hang on D state under moderate load so I need to reboot=20
> very frequently.

if "nfsstat -c" shows lots of retransmissions and you are using
NFS over UDP, follow these instructions to increase the transport
socket buffer size:

1.	Become root on your client
2.	cd into /proc/sys/net/core
3.	echo 262143 > rmem_max
4.	echo 262143 > wmem_max
5.	echo 262143 > rmem_default
6.	echo 262143 > wmem_default
7.	Remount your NFS file systems on the client

if that doesn't clear your problem, then you probably have a faulty
network -- swap your cabling, look for NIC errors on your client
and filer, check the statistics on your switch, and be sure duplex
and autonegotiation are correctly set.  you can ask your NetApp SE
for help diagnosing network problems on the filer if you need it.

also try testing from other clients on other networks, if you can.

> my previous setup was :
>  * nfs v3, rsize/wsize=3D8192, udp
>=20
> my client (DL360) and server  (F880) are connected through a =
dedicated
> switch each with 100FD network link to the switch.
>=20
> any ideas ?

if the above suggestions don't help, get a packet trace.  you can use
"tcpdump" on your client, or you can try "pktt" on the filer.
("pktt list" on the filer's console should tell you what you need to
know).  pktt produces a trace file in tcpdump format, so you can use
tcpdump on your clients to look at the dump.

send me the dump if you'd like help.

> > -----Original Message-----
> > From: Lever, Charles [mailto:Charles.Lever@netapp.com]
> > Sent: Monday, August 12, 2002 5:48 PM
> > To: 'Brasseur Val=E9ry'; nfs@lists.sourceforge.net
> > Subject: RE: [NFS] nfs unlink perf !
> >=20
> >=20
> > link RPCs can be very large (much larger than wsize, for instance).
> > if you use UDP and your network drops lots of packets, large link
> > requests will probably require several retransmissions to complete.
> >=20
> > enlarge your transport socket buffer size on the client (see FAQ)
> > and/or try NFS over TCP.  also examine your network to see if it
> > is clean, and is working optimally.  if your client is attached
> > via a more slow link than your server, that can be the source of
> > bursty packet loss.
> >=20
> > > -----Original Message-----
> > > From: Brasseur Val=E9ry [mailto:Valery.Brasseur@atosorigin.com]
> > > Sent: Monday, August 12, 2002 8:09 AM
> > > To: nfs@lists.sourceforge.net
> > > Subject: [NFS] nfs unlink perf !
> > >=20
> > >=20
> > > I am testing an application which to a lot of link/unlink
> > >=20
> > > server is a NetApp filer, client is linux 2.4.19+nfs patches.
> > >=20
> > > under load it seems that the unlink call is very long when=20
> > > all over calls
> > > response time seems to be OK.
> > > is there any problems with the unlink code ?
> > >=20
> > > thanks
> > >=20
> > >=20
> > >=20
> > > -------------------------------------------------------
> > > This sf.net email is sponsored by:ThinkGeek
> > > Welcome to geek heaven.
> > > http://thinkgeek.com/sf
> > > _______________________________________________
> > > NFS maillist  -  NFS@lists.sourceforge.net
> > > https://lists.sourceforge.net/lists/listinfo/nfs
> > >=20
> >=20
>=20


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
