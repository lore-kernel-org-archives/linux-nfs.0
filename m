From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: RE: NFS and tinygrams
Date: Thu, 21 Oct 2004 15:21:49 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098397308.3601.320.camel@tesuji.nac.uci.edu>
References: <EXCHG2003XZZTHfyQge000010c5@EXCHG2003.microtech-ks.com>
	 <1098396197.3601.309.camel@tesuji.nac.uci.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-5UKjtJVan1jiiv5F8ycQ"
Cc: Dan Stromberg <strombrg@dcs.nac.uci.edu>,
        "'Lever, Charles'" <Charles.Lever@netapp.com>,
        "'Linux NFS Mailing List'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKlJj-0005I4-Jk
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 15:21:55 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CKlJi-0002e0-HM
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 15:21:55 -0700
To: Roger Heflin <rheflin@atipa.com>
In-Reply-To: <1098396197.3601.309.camel@tesuji.nac.uci.edu>
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


--=-5UKjtJVan1jiiv5F8ycQ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


I suspect tracepath is either lying, or I'm misinterpreting its output,
because if I fire up an iperf pair from esmf04d to esmft2, I -do- see
some jumbo frames.

I'll try the remounting when I can.

Thanks folks.

On Thu, 2004-10-21 at 15:03, Dan Stromberg wrote:
> That sounds worth trying, but should I be seeing:
>=20
> [root@esmft2 etc]# tracepath esmf04d
>  1:  esmft2 (192.168.2.102)                               asymm 65 =20
> 0.260ms pmtu 1492
>  1:  esmf04d (192.168.2.12)                                 0.294ms
> reached
>      Resume: pmtu 1492 hops 1 back 1=20
>=20
> ?
>=20
> Thanks!
>=20
> On Thu, 2004-10-21 at 14:22, Roger Heflin wrote:
> > From what I have seen you need to umount and remount to get it to
> > use the jumbos.   It appears to me (someone correct me if this is=20
> > wrong) that the MTU is set on a per connection basis when the
> > connection is initially established, and does not appear to change
> > once established, at least not in the upward direction.
> >=20
> >                        Roger=20
> >=20
> > -----Original Message-----
> > From: nfs-admin@lists.sourceforge.net
> > [mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Dan Stromberg
> > Sent: Thursday, October 21, 2004 3:52 PM
> > To: Lever, Charles
> > Cc: Dan Stromberg; Linux NFS Mailing List
> > Subject: RE: [NFS] NFS and tinygrams
> >=20
> >=20
> > Yes, you're right.  I was on the wrong server - rxvt lied to me.=20
> > hostname did not.
> >=20
> > Upon doing a similar check on the Right server, it's become clear that =
while
> > our Redhat 9 host is doing jumbo frames, our RHEL 3 host is not.
> >=20
> > I've set the MTU to 9000 on the RHEL 3 host.  Is there something else I=
 need
> > to do to set jumbo frames on RHEL 3?  (The AIX 5.1 host this RHEL 3 hos=
t is
> > talking to, is doing jumbo frames fine with the Redhat 9 host, so I ass=
ume
> > the AIX 5.1 host is configured fine in this regard...)
> >=20
> > Thanks!
> >=20
> > > > Here are our packet lengths with counts, over 10000 packets:
> > > >=20
> > > >   count packet length =20
> > > >       3 70
> > > >       1 74
> > > >       2 82
> > > >       3 98
> > > >     164 182
> > > >     180 186
> > > >    8827 190
> > > >      76 202
> > > >     407 286
> > > >      52 4266
> > > >       1 7418
> > > >     284 8362
> > > >=20
> > > > Does this look normal for a network with jumbo frames enabled=20
> > > > transferring lots of mostly-large files?
> > >=20
> > > you are confusing the network transport with the upper layer protocol=
.
> > > in addition i think you are looking at UDP traffic, not TCP.
> > >=20
> > > note that 4266 =3D 170 + 4096, and that 8362 =3D 170 + 8192.  170 is =
the=20
> > > size of the IP, UDP, RPC, and NFS headers, and the rest is the data=20
> > > payload (multiple of the client's page size, 4096).  anything smaller=
=20
> > > than 300 is likely to be an NFS metadata op (GETATTR, LOOKUP, and the=
=20
> > > like).  that one 7000-odd byte packet is probably a READDIR.
> > >=20
> > > if you want an analysis of the efficiency of the NFS client, use=20
> > > "nfsstat -c" to decide whether your client is generating mostly=20
> > > metadata ops, or whether these are really small reads and writes.
> > >=20
> > > > On Thu, 2004-10-21 at 12:15, Dan Stromberg wrote:
> > > > > On Thu, 2004-10-21 at 11:56, Lever, Charles wrote:
> > > > > > > A tinygram is a small packet.
> > > > > > >=20
> > > > > > > Many of the NFS packets I'm seeing are small - say about 200=20
> > > > > > > or 300 bytes.  Then from time to time, there's a 7k packet,=20
> > > > > > > like I'd like to see more of.
> > > > > >=20
> > > > > > do you know what's in the small packets?  200 to 300 bytes are=20
> > > > > > typical of most NFS operations (not READ or WRITE).  maybe your=
=20
> > > > > > application is causing the client to generate lots of NFS
> > > > requests,
> > > > > > but only a few of them are WRITEs.
> > > > >=20
> > > > > This is the NFS portion of a 190 byte packet, that appears to be=20
> > > > > fairly representative, taken from tethereal:
> > > > >=20
> > > > > Network File System
> > > > >     Program Version: 3
> > > > >     V3 Procedure: READ (6)
> > > > >     file
> > > > >         length: 36
> > > > >         hash: 0x3305e54e
> > > > >         type: unknown
> > > > >         data: 01000006007900411A00000000000000
> > > > >               001B8C1A000000000000000000057E72
> > > > >               00000000
> > > > >     offset: 1484812288
> > > > >     count: 8192
> > > > >=20
> > > > > Most of the files in this filesystem are large (data from
> > > > simulation
> > > > > runs in netcdf format), but there certainly are some small ones.
> > > > >=20
> > > > > Right now, our application is rsync.  But that may change later.
> > > > >=20
> > > > > > > Someone just told me that netapp servers can do intent-based=20
> > > > > > > NFS.  Do you concur?
> > > > > >=20
> > > > > > i've never heard of "intent-based NFS."  can you explain
> > > > what this
> > > > > > means?
> > > > >=20
> > > > > I believe it means that you bundle a bunch of operations
> > > > together into
> > > > > one large packet, and the execution of later operations is
> > > > contingent
> > > > > on the success of earlier operations (or perhaps more
> > > > generally, the
> > > > > exit status of earlier operations - not sure).
> > > > >=20
> > > > > Lustre, I'm told, uses an intent-based protocol to speed up its=20
> > > > > operations.
> > > > >=20
> > > > > The FC2 nfs implementation (kernel 2.6.8-1) has a structure named=
=20
> > > > > "intent", which -might- only be used in NFS v4.
> > > > >=20
> > > > > There's some discussion of the data structure for intent-based NF=
S
> > > > > here:
> > > > >=20
> > > > > http://seclists.org/lists/linux-kernel/2003/May/6040.html
> > > > >=20
> > > > > Unfortunately, our AIX 5.1 machine does not support NFS v4. =20
> > > > > Anyone know if AIX 5.3 does?  I'll ask on an AIX mailing list too=
...
> > > > >=20
> > > > > >=20
> > > > > >=20
> > > > > > > On Thu, 2004-10-21 at 10:47, Lever, Charles wrote:
> > > > > > > > what's a "tinygram" ?
> > > > > > > >=20
> > > > > > > > do you mean the NFS write requests aren't all "wsize"=20
> > > > bytes?  or
> > > > > > > > do
> > > > > > > > you mean the TCP layer is segmenting into small IP packets?=
=20
> > > > > > >  these are
> > > > > > > > two separate layers, and do not interact.
> > > > > > > >=20
> > > > > > > > > -----Original Message-----
> > > > > > > > > From: Dan Stromberg [mailto:strombrg@dcs.nac.uci.edu]
> > > > > > > > > Sent: Thursday, October 21, 2004 1:05 PM
> > > > > > > > > To: Linux NFS Mailing List
> > > > > > > > > Cc: Dan Stromberg
> > > > > > > > > Subject: [NFS] NFS and tinygrams
> > > > > > > > >=20
> > > > > > > > >=20
> > > > > > > > >=20
> > > > > > > > > We have a series of test transfers going, where we are=20
> > > > > > > > > shuttling data from GFS->NFS V3 over UDP->NFS V3 over
> > > > > > > > > TCP->Lustre.
> > > > > > > > >=20
> > > > > > > > > On the NFS V3 over TCP link, we're seeing a lot of
> > > > tinygrams,
> > > > > > > > > despite having 8K NFS block sizes turned on, and
> > > > jumbo packets
> > > > > > > > > enabled (9000 byte MTU).
> > > > > > > > >=20
> > > > > > > > > The GFS machine runs Redhat 9, the first NFS server
> > > > also runs
> > > > > > > > > Redhat 9. The machine copying from NFS to NFS is
> > > > running AIX
> > > > > > > > > 5.1.  The machine copying NFS to Lustre is running RHEL 3=
.
> > > > > > > > >=20
> > > > > > > > > I didn't check on the packet sizes of the other legs of=20
> > > > > > > > > the transfer.
> > > > > > > > >=20
> > > > > > > > > I've verified that we do have jumbo packets being
> > > > used some of
> > > > > > > > > the time, on that AIX 5.1 -> RHEL 3 hop.  However,
> > > > we're still
> > > > > > > > > getting a pretty large percentage of tinygrams.
> > > > > > > > >=20
> > > > > > > > > Is there any way of cutting down on the tinygrams, to mor=
e=20
> > > > > > > > > effectively utilize our large MTU?  Is there
> > > > perhaps any sort
> > > > > > > > > of "intent based" packetizing in standard
> > > > implementations of
> > > > > > > > > NFS on Redhat 9, AIX 5.1, and/or RHEL 3?
> > > > > > > > >=20
> > > > > > > > > (Yes, we could short circuit the AIX 5.1 part of
> > > > the transfer,
> > > > > > > > > and that Would make things faster, but it Wouldn't
> > > > test what
> > > > > > > > > we need to test!)
> > > > > > > > >=20
> > > > > > > > > Thanks!
> > > > > > > > >=20
> > > > > > > > > --
> > > > > > > > > Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>
> > > > > > > > >=20
> > > > > > > > >=20
> > > > > > > > >=20
> > > > > > > > >=20
> > > > > > > > > -------------------------------------------------------
> > > > > > > > > This SF.net email is sponsored by: IT Product Guide on=20
> > > > > > > > > ITManagersJournal Use IT products in your business? Tell=20
> > > > > > > > > us what you think of them. Give us Your Opinions, Get Fre=
e=20
> > > > > > > > > ThinkGeek Gift Certificates! Click to find out more=20
> > > > > > > > > http://productguide.itmanagersjournal.com/guid>=20
> > > > > > > > > epromo.tmpl
> > > > > > > > >=20
> > > > > > > > > _______________________________________________
> > > > > > > > >=20
> > > > > > > > > NFS maillist  -  NFS@lists.sourceforge.net=20
> > > > > > > > > https://lists.sourceforge.net/lists/listinfo/n> fs
> > > > > > > > >=20
> > > > > > > --
> > > > > > > Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>
> > > > > > >=20
> > > > > > >=20
> > > > --
> > > > Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>
> > > >=20
> > > >=20
> > > >=20
> > --
> > Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>
--=20
Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>


--=-5UKjtJVan1jiiv5F8ycQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBeDZ8o0feVm00f/8RAs7HAKChbfeuEjWoWhU75R6e16icRtjSMwCeNqpv
qCnEaOyVMILf/Ku3enznbR4=
=P8Sc
-----END PGP SIGNATURE-----

--=-5UKjtJVan1jiiv5F8ycQ--



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
