From: =?iso-8859-1?Q?Brasseur_Val=E9ry?= <Valery.Brasseur@atosorigin.com>
Subject: RE: nfs unlink perf !
Date: Tue, 13 Aug 2002 17:09:14 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8D7D56C6ED3DD411998D009027DC685E0874E223@srv-grp-s1.segin.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from hermes8.atos-group.com ([160.92.18.57] helo=hermes8.segin.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17edII-0001eY-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 08:09:14 -0700
To: "'Lever, Charles'" <Charles.Lever@netapp.com>,
	nfs@lists.sourceforge.net
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

I check nfsstat, and see a bunch of retrans...
but now when then following your suggestion I 've try to put :
   tcp + rsize/wsize=3D32768 and :
 * take the same time
 * hang on D state under moderate load so I need to reboot very =
frequently.

my previous setup was :
 * nfs v3, rsize/wsize=3D8192, udp

my client (DL360) and server  (F880) are connected through a dedicated
switch each with 100FD network link to the switch.

any ideas ?

> -----Original Message-----
> From: Lever, Charles [mailto:Charles.Lever@netapp.com]
> Sent: Monday, August 12, 2002 5:48 PM
> To: 'Brasseur Val=E9ry'; nfs@lists.sourceforge.net
> Subject: RE: [NFS] nfs unlink perf !
>=20
>=20
> link RPCs can be very large (much larger than wsize, for instance).
> if you use UDP and your network drops lots of packets, large link
> requests will probably require several retransmissions to complete.
>=20
> enlarge your transport socket buffer size on the client (see FAQ)
> and/or try NFS over TCP.  also examine your network to see if it
> is clean, and is working optimally.  if your client is attached
> via a more slow link than your server, that can be the source of
> bursty packet loss.
>=20
> > -----Original Message-----
> > From: Brasseur Val=E9ry [mailto:Valery.Brasseur@atosorigin.com]
> > Sent: Monday, August 12, 2002 8:09 AM
> > To: nfs@lists.sourceforge.net
> > Subject: [NFS] nfs unlink perf !
> >=20
> >=20
> > I am testing an application which to a lot of link/unlink
> >=20
> > server is a NetApp filer, client is linux 2.4.19+nfs patches.
> >=20
> > under load it seems that the unlink call is very long when=20
> > all over calls
> > response time seems to be OK.
> > is there any problems with the unlink code ?
> >=20
> > thanks
> >=20
> >=20
> >=20
> > -------------------------------------------------------
> > This sf.net email is sponsored by:ThinkGeek
> > Welcome to geek heaven.
> > http://thinkgeek.com/sf
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
> >=20
>=20


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
