From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS and tinygrams
Date: Thu, 21 Oct 2004 12:57:02 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07E77@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Linux NFS Mailing List" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKj3d-00025z-7n
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 12:57:09 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CKj3c-0002Os-LI
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 12:57:09 -0700
To: "Dan Stromberg" <strombrg@dcs.nac.uci.edu>
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

> On Thu, 2004-10-21 at 11:56, Lever, Charles wrote:
> This is the NFS portion of a 190 byte packet, that appears to=20
> be fairly representative, taken from tethereal:
>=20
> Network File System
>     Program Version: 3
>     V3 Procedure: READ (6)
>     file
>         length: 36
>         hash: 0x3305e54e
>         type: unknown
>         data: 01000006007900411A00000000000000
>               001B8C1A000000000000000000057E72
>               00000000
>     offset: 1484812288
>     count: 8192
>=20
> Most of the files in this filesystem are large (data from=20
> simulation runs in netcdf format), but there certainly are=20
> some small ones.

a READ request is small.  the reply, however, is large.  likewise, a
WRITE request is large, but the reply is small.  requests like GETATTR,
ACCESS, LOOKUP, CREATE, REMOVE are all small requests.

so take a look at "nfsstat -c" on your client to understand what
requests are going over the wire.  if you see few WRITEs but lots of
GETATTRs and LOOKUPs, that can explain why you are seeing small packets
on the wire.

> > > Someone just told me that netapp servers can do intent-based
> > > NFS.  Do you concur?
> >=20
> > i've never heard of "intent-based NFS."  can you explain what this=20
> > means?
>=20
> I believe it means that you bundle a bunch of operations=20
> together into one large packet, and the execution of later=20
> operations is contingent on the success of earlier operations=20
> (or perhaps more generally, the exit status of earlier=20
> operations - not sure).

you've managed to conflate a number of features.  what you are referring
to here is known as compound RPCs, and is a feature of NFSv4.

this has nothing to do with how much data TCP puts in a single segment.
that is determined more by the client's network stack -- the use (or
lack of use) of TCP_CORK and the Nagle algorithm.

if you are seeing small datagrams, then this is probably UDP we're
talking about.  TCP tries to pack as many bytes into each segment as it
can.

> Lustre, I'm told, uses an intent-based protocol to speed up=20
> its operations.

now here, you're talking about the statefulness of the upper layer file
system protocol.  NFSv4 uses OPEN and CLOSE to communicate to the server
the access intentions of the application.  when the Linux VFS layer
invokes a file system's lookup method, it can now tell the file system
whether the lookup is for a DNLC refresh or because some application is
trying to open a file.

> The FC2 nfs implementation (kernel 2.6.8-1) has a structure=20
> named "intent", which -might- only be used in NFS v4.

there are a few NFSv3 areas where this can be used (exclusive create
being one).

> Unfortunately, our AIX 5.1 machine does not support NFS v4. =20
> Anyone know if AIX 5.3 does?  I'll ask on an AIX mailing list too...

yes, AIX 5.3 supports NFSv4.

> > > On Thu, 2004-10-21 at 10:47, Lever, Charles wrote:
> > > > what's a "tinygram" ?
> > > >=20
> > > > do you mean the NFS write requests aren't all "wsize"=20
> bytes?  or=20
> > > > do
> > > > you mean the TCP layer is segmenting into small IP packets?=20
> > >  these are
> > > > two separate layers, and do not interact.
> > > >=20
> > > > > -----Original Message-----
> > > > > From: Dan Stromberg [mailto:strombrg@dcs.nac.uci.edu]
> > > > > Sent: Thursday, October 21, 2004 1:05 PM
> > > > > To: Linux NFS Mailing List
> > > > > Cc: Dan Stromberg
> > > > > Subject: [NFS] NFS and tinygrams
> > > > >=20
> > > > >=20
> > > > >=20
> > > > > We have a series of test transfers going, where we=20
> are shuttling=20
> > > > > data from GFS->NFS V3 over UDP->NFS V3 over TCP->Lustre.
> > > > >=20
> > > > > On the NFS V3 over TCP link, we're seeing a lot of tinygrams,=20
> > > > > despite having 8K NFS block sizes turned on, and=20
> jumbo packets=20
> > > > > enabled (9000 byte MTU).
> > > > >=20
> > > > > The GFS machine runs Redhat 9, the first NFS server also runs=20
> > > > > Redhat 9. The machine copying from NFS to NFS is running AIX=20
> > > > > 5.1.  The machine copying NFS to Lustre is running RHEL 3.
> > > > >=20
> > > > > I didn't check on the packet sizes of the other legs of the
> > > > > transfer.
> > > > >=20
> > > > > I've verified that we do have jumbo packets being=20
> used some of=20
> > > > > the time, on that AIX 5.1 -> RHEL 3 hop.  However,=20
> we're still=20
> > > > > getting a pretty large percentage of tinygrams.
> > > > >=20
> > > > > Is there any way of cutting down on the tinygrams, to more=20
> > > > > effectively utilize our large MTU?  Is there perhaps=20
> any sort of=20
> > > > > "intent based" packetizing in standard=20
> implementations of NFS on=20
> > > > > Redhat 9, AIX 5.1, and/or RHEL 3?
> > > > >=20
> > > > > (Yes, we could short circuit the AIX 5.1 part of the=20
> transfer,=20
> > > > > and that Would make things faster, but it Wouldn't=20
> test what we=20
> > > > > need to test!)
> > > > >=20
> > > > > Thanks!
> > > > >=20
> > > > > --
> > > > > Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>
> > > > >=20
> > > > >=20
> > > > >=20
> > > > >=20
> > > > > -------------------------------------------------------
> > > > > This SF.net email is sponsored by: IT Product Guide on=20
> > > > > ITManagersJournal Use IT products in your business?=20
> Tell us what=20
> > > > > you think of them. Give us Your Opinions, Get Free ThinkGeek=20
> > > > > Gift Certificates! Click to find out more=20
> > > > > http://productguide.itmanagersjournal.com/guid> epromo.tmpl
> > > > >=20
> > > > > _______________________________________________
> > > > >=20
> > > > > NFS maillist  -  NFS@lists.sourceforge.net=20
> > > > > https://lists.sourceforge.net/lists/listinfo/n> fs
> > > > >=20
> > > --
> > > Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>
> > >=20
> > >=20
> --=20
> Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>
>=20
>=20


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
