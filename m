From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: RE: NFS and tinygrams
Date: Thu, 21 Oct 2004 13:52:18 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098391937.3601.304.camel@tesuji.nac.uci.edu>
References: <482A3FA0050D21419C269D13989C611302B07E78@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-7/TJqI26iXg/r1GvpZWb"
Cc: Dan Stromberg <strombrg@dcs.nac.uci.edu>,
        Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKjvD-0007t1-Ji
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 13:52:31 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CKjvC-0001Iv-Vj
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 13:52:31 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611302B07E78@lavender-fe.eng.netapp.com>
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


--=-7/TJqI26iXg/r1GvpZWb
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Yes, you're right.  I was on the wrong server - rxvt lied to me.=20
hostname did not.

Upon doing a similar check on the Right server, it's become clear that
while our Redhat 9 host is doing jumbo frames, our RHEL 3 host is not.

I've set the MTU to 9000 on the RHEL 3 host.  Is there something else I
need to do to set jumbo frames on RHEL 3?  (The AIX 5.1 host this RHEL 3
host is talking to, is doing jumbo frames fine with the Redhat 9 host,
so I assume the AIX 5.1 host is configured fine in this regard...)

Thanks!

> > Here are our packet lengths with counts, over 10000 packets:
> >=20
> >   count packet length =20
> >       3 70
> >       1 74
> >       2 82
> >       3 98
> >     164 182
> >     180 186
> >    8827 190
> >      76 202
> >     407 286
> >      52 4266
> >       1 7418
> >     284 8362
> >=20
> > Does this look normal for a network with jumbo frames enabled=20
> > transferring lots of mostly-large files?
>=20
> you are confusing the network transport with the upper layer protocol.
> in addition i think you are looking at UDP traffic, not TCP.
>=20
> note that 4266 =3D 170 + 4096, and that 8362 =3D 170 + 8192.  170 is the
> size of the IP, UDP, RPC, and NFS headers, and the rest is the data
> payload (multiple of the client's page size, 4096).  anything smaller
> than 300 is likely to be an NFS metadata op (GETATTR, LOOKUP, and the
> like).  that one 7000-odd byte packet is probably a READDIR.
>=20
> if you want an analysis of the efficiency of the NFS client, use
> "nfsstat -c" to decide whether your client is generating mostly metadata
> ops, or whether these are really small reads and writes.
>=20
> > On Thu, 2004-10-21 at 12:15, Dan Stromberg wrote:
> > > On Thu, 2004-10-21 at 11:56, Lever, Charles wrote:
> > > > > A tinygram is a small packet.
> > > > >=20
> > > > > Many of the NFS packets I'm seeing are small - say about 200
> > > > > or 300 bytes.  Then from time to time, there's a 7k packet,=20
> > > > > like I'd like to see more of.
> > > >=20
> > > > do you know what's in the small packets?  200 to 300 bytes are=20
> > > > typical of most NFS operations (not READ or WRITE).  maybe your=20
> > > > application is causing the client to generate lots of NFS=20
> > requests,=20
> > > > but only a few of them are WRITEs.
> > >=20
> > > This is the NFS portion of a 190 byte packet, that appears to be=20
> > > fairly representative, taken from tethereal:
> > >=20
> > > Network File System
> > >     Program Version: 3
> > >     V3 Procedure: READ (6)
> > >     file
> > >         length: 36
> > >         hash: 0x3305e54e
> > >         type: unknown
> > >         data: 01000006007900411A00000000000000
> > >               001B8C1A000000000000000000057E72
> > >               00000000
> > >     offset: 1484812288
> > >     count: 8192
> > >=20
> > > Most of the files in this filesystem are large (data from=20
> > simulation=20
> > > runs in netcdf format), but there certainly are some small ones.
> > >=20
> > > Right now, our application is rsync.  But that may change later.
> > >=20
> > > > > Someone just told me that netapp servers can do intent-based
> > > > > NFS.  Do you concur?
> > > >=20
> > > > i've never heard of "intent-based NFS."  can you explain=20
> > what this=20
> > > > means?
> > >=20
> > > I believe it means that you bundle a bunch of operations=20
> > together into=20
> > > one large packet, and the execution of later operations is=20
> > contingent=20
> > > on the success of earlier operations (or perhaps more=20
> > generally, the=20
> > > exit status of earlier operations - not sure).
> > >=20
> > > Lustre, I'm told, uses an intent-based protocol to speed up its=20
> > > operations.
> > >=20
> > > The FC2 nfs implementation (kernel 2.6.8-1) has a structure named=20
> > > "intent", which -might- only be used in NFS v4.
> > >=20
> > > There's some discussion of the data structure for intent-based NFS=20
> > > here:
> > >=20
> > > http://seclists.org/lists/linux-kernel/2003/May/6040.html
> > >=20
> > > Unfortunately, our AIX 5.1 machine does not support NFS v4.  Anyone=20
> > > know if AIX 5.3 does?  I'll ask on an AIX mailing list too...
> > >=20
> > > >=20
> > > >=20
> > > > > On Thu, 2004-10-21 at 10:47, Lever, Charles wrote:
> > > > > > what's a "tinygram" ?
> > > > > >=20
> > > > > > do you mean the NFS write requests aren't all "wsize"=20
> > bytes?  or=20
> > > > > > do
> > > > > > you mean the TCP layer is segmenting into small IP packets?=20
> > > > >  these are
> > > > > > two separate layers, and do not interact.
> > > > > >=20
> > > > > > > -----Original Message-----
> > > > > > > From: Dan Stromberg [mailto:strombrg@dcs.nac.uci.edu]
> > > > > > > Sent: Thursday, October 21, 2004 1:05 PM
> > > > > > > To: Linux NFS Mailing List
> > > > > > > Cc: Dan Stromberg
> > > > > > > Subject: [NFS] NFS and tinygrams
> > > > > > >=20
> > > > > > >=20
> > > > > > >=20
> > > > > > > We have a series of test transfers going, where we are=20
> > > > > > > shuttling data from GFS->NFS V3 over UDP->NFS V3 over=20
> > > > > > > TCP->Lustre.
> > > > > > >=20
> > > > > > > On the NFS V3 over TCP link, we're seeing a lot of=20
> > tinygrams,=20
> > > > > > > despite having 8K NFS block sizes turned on, and=20
> > jumbo packets=20
> > > > > > > enabled (9000 byte MTU).
> > > > > > >=20
> > > > > > > The GFS machine runs Redhat 9, the first NFS server=20
> > also runs=20
> > > > > > > Redhat 9. The machine copying from NFS to NFS is=20
> > running AIX=20
> > > > > > > 5.1.  The machine copying NFS to Lustre is running RHEL 3.
> > > > > > >=20
> > > > > > > I didn't check on the packet sizes of the other legs of the
> > > > > > > transfer.
> > > > > > >=20
> > > > > > > I've verified that we do have jumbo packets being=20
> > used some of=20
> > > > > > > the time, on that AIX 5.1 -> RHEL 3 hop.  However,=20
> > we're still=20
> > > > > > > getting a pretty large percentage of tinygrams.
> > > > > > >=20
> > > > > > > Is there any way of cutting down on the tinygrams, to more=20
> > > > > > > effectively utilize our large MTU?  Is there=20
> > perhaps any sort=20
> > > > > > > of "intent based" packetizing in standard=20
> > implementations of=20
> > > > > > > NFS on Redhat 9, AIX 5.1, and/or RHEL 3?
> > > > > > >=20
> > > > > > > (Yes, we could short circuit the AIX 5.1 part of=20
> > the transfer,=20
> > > > > > > and that Would make things faster, but it Wouldn't=20
> > test what=20
> > > > > > > we need to test!)
> > > > > > >=20
> > > > > > > Thanks!
> > > > > > >=20
> > > > > > > --
> > > > > > > Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>
> > > > > > >=20
> > > > > > >=20
> > > > > > >=20
> > > > > > >=20
> > > > > > > -------------------------------------------------------
> > > > > > > This SF.net email is sponsored by: IT Product Guide on=20
> > > > > > > ITManagersJournal Use IT products in your business? Tell us=20
> > > > > > > what you think of them. Give us Your Opinions, Get Free=20
> > > > > > > ThinkGeek Gift Certificates! Click to find out more=20
> > > > > > > http://productguide.itmanagersjournal.com/guid> epromo.tmpl
> > > > > > >=20
> > > > > > > _______________________________________________
> > > > > > >=20
> > > > > > > NFS maillist  -  NFS@lists.sourceforge.net=20
> > > > > > > https://lists.sourceforge.net/lists/listinfo/n> fs
> > > > > > >=20
> > > > > --
> > > > > Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>
> > > > >=20
> > > > >=20
> > --=20
> > Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>
> >=20
> >=20
> >=20
--=20
Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>


--=-7/TJqI26iXg/r1GvpZWb
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBeCGBo0feVm00f/8RAhQEAJ0TfkNR/r3iC50mF+UImR+FNwg2RACZAXww
rOLapLoBs1kIN5tfrUs7kD0=
=vPhq
-----END PGP SIGNATURE-----

--=-7/TJqI26iXg/r1GvpZWb--



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
