From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: RE: nfs unlink perf !
Date: Tue, 13 Aug 2002 18:52:57 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8D7D56C6ED3DD411998D009027DC685E0874E226@srv-grp-s1.segin.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from hermes8.atos-group.com ([160.92.18.57] helo=hermes8.segin.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eeuZ-00033G-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 09:52:51 -0700
To: "'Lever, Charles'" <Charles.Lever@netapp.com>
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

> -----Original Message-----
> From: Lever, Charles [mailto:Charles.Lever@netapp.com]
> Sent: Tuesday, August 13, 2002 6:21 PM
> To: 'Brasseur Val=E9ry'
> Cc: nfs@lists.sourceforge.net
> Subject: RE: [NFS] nfs unlink perf !
>=20
>=20
> hi brasseur-
>=20
> > I check nfsstat, and see a bunch of retrans...
> > but now when then following your suggestion I 've try to put :
> >    tcp + rsize/wsize=3D32768 and :
> >  * take the same time
> >  * hang on D state under moderate load so I need to reboot=20
> > very frequently.
>=20
> if "nfsstat -c" shows lots of retransmissions and you are using
> NFS over UDP, follow these instructions to increase the transport
> socket buffer size:
>=20
> 1.	Become root on your client
> 2.	cd into /proc/sys/net/core
> 3.	echo 262143 > rmem_max
> 4.	echo 262143 > wmem_max
> 5.	echo 262143 > rmem_default
> 6.	echo 262143 > wmem_default
> 7.	Remount your NFS file systems on the client
>=20

already done that ! it's my default config !

> if that doesn't clear your problem, then you probably have a faulty
> network -- swap your cabling, look for NIC errors on your client
> and filer, check the statistics on your switch, and be sure duplex
> and autonegotiation are correctly set.  you can ask your NetApp SE
> for help diagnosing network problems on the filer if you need it.

no errors are reported by NICs nor switch ! full-duplex is force=20
on all devices (client,filer,switches ...)

>=20
> also try testing from other clients on other networks, if you can.
>=20
> > my previous setup was :
> >  * nfs v3, rsize/wsize=3D8192, udp
> >=20
> > my client (DL360) and server  (F880) are connected through=20
> a dedicated
> > switch each with 100FD network link to the switch.
> >=20
> > any ideas ?
>=20
> if the above suggestions don't help, get a packet trace.  you can use
> "tcpdump" on your client, or you can try "pktt" on the filer.
> ("pktt list" on the filer's console should tell you what you need to
> know).  pktt produces a trace file in tcpdump format, so you can use
> tcpdump on your clients to look at the dump.
>=20
> send me the dump if you'd like help.
>=20
> > > -----Original Message-----
> > > From: Lever, Charles [mailto:Charles.Lever@netapp.com]
> > > Sent: Monday, August 12, 2002 5:48 PM
> > > To: 'Brasseur Val=E9ry'; nfs@lists.sourceforge.net
> > > Subject: RE: [NFS] nfs unlink perf !
> > >=20
> > >=20
> > > link RPCs can be very large (much larger than wsize, for=20
> instance).
> > > if you use UDP and your network drops lots of packets, large link
> > > requests will probably require several retransmissions to=20
> complete.
> > >=20
> > > enlarge your transport socket buffer size on the client (see FAQ)
> > > and/or try NFS over TCP.  also examine your network to see if it
> > > is clean, and is working optimally.  if your client is attached
> > > via a more slow link than your server, that can be the source of
> > > bursty packet loss.
> > >=20
> > > > -----Original Message-----
> > > > From: Brasseur Val=E9ry [mailto:Valery.Brasseur@atosorigin.com]
> > > > Sent: Monday, August 12, 2002 8:09 AM
> > > > To: nfs@lists.sourceforge.net
> > > > Subject: [NFS] nfs unlink perf !
> > > >=20
> > > >=20
> > > > I am testing an application which to a lot of link/unlink
> > > >=20
> > > > server is a NetApp filer, client is linux 2.4.19+nfs patches.
> > > >=20
> > > > under load it seems that the unlink call is very long when=20
> > > > all over calls
> > > > response time seems to be OK.
> > > > is there any problems with the unlink code ?
> > > >=20
> > > > thanks
> > > >=20
> > > >=20
> > > >=20
> > > > -------------------------------------------------------
> > > > This sf.net email is sponsored by:ThinkGeek
> > > > Welcome to geek heaven.
> > > > http://thinkgeek.com/sf
> > > > _______________________________________________
> > > > NFS maillist  -  NFS@lists.sourceforge.net
> > > > https://lists.sourceforge.net/lists/listinfo/nfs
> > > >=20
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
