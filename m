From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS and tinygrams
Date: Thu, 21 Oct 2004 11:56:50 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07E75@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Linux NFS Mailing List" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKi7N-0004IJ-By
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 11:56:57 -0700
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CKi7M-0002rz-Pd
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 11:56:57 -0700
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

> A tinygram is a small packet.
>=20
> Many of the NFS packets I'm seeing are small - say about 200=20
> or 300 bytes.  Then from time to time, there's a 7k packet,=20
> like I'd like to see more of.

do you know what's in the small packets?  200 to 300 bytes are typical
of most NFS operations (not READ or WRITE).  maybe your application is
causing the client to generate lots of NFS requests, but only a few of
them are WRITEs.

> Someone just told me that netapp servers can do intent-based=20
> NFS.  Do you concur?

i've never heard of "intent-based NFS."  can you explain what this
means?



> On Thu, 2004-10-21 at 10:47, Lever, Charles wrote:
> > what's a "tinygram" ?
> >=20
> > do you mean the NFS write requests aren't all "wsize" bytes?  or do=20
> > you mean the TCP layer is segmenting into small IP packets?=20
>  these are=20
> > two separate layers, and do not interact.
> >=20
> > > -----Original Message-----
> > > From: Dan Stromberg [mailto:strombrg@dcs.nac.uci.edu]
> > > Sent: Thursday, October 21, 2004 1:05 PM
> > > To: Linux NFS Mailing List
> > > Cc: Dan Stromberg
> > > Subject: [NFS] NFS and tinygrams
> > >=20
> > >=20
> > >=20
> > > We have a series of test transfers going, where we are
> > > shuttling data from GFS->NFS V3 over UDP->NFS V3 over TCP->Lustre.
> > >=20
> > > On the NFS V3 over TCP link, we're seeing a lot of tinygrams,
> > > despite having 8K NFS block sizes turned on, and jumbo=20
> > > packets enabled (9000 byte MTU).
> > >=20
> > > The GFS machine runs Redhat 9, the first NFS server also runs
> > > Redhat 9.=20
> > > The machine copying from NFS to NFS is running AIX 5.1.  The=20
> > > machine copying NFS to Lustre is running RHEL 3.
> > >=20
> > > I didn't check on the packet sizes of the other legs of the=20
> > > transfer.
> > >=20
> > > I've verified that we do have jumbo packets being used some
> > > of the time, on that AIX 5.1 -> RHEL 3 hop.  However, we're=20
> > > still getting a pretty large percentage of tinygrams.
> > >=20
> > > Is there any way of cutting down on the tinygrams, to more
> > > effectively utilize our large MTU?  Is there perhaps any sort=20
> > > of "intent based" packetizing in standard implementations of=20
> > > NFS on Redhat 9, AIX 5.1, and/or RHEL 3?
> > >=20
> > > (Yes, we could short circuit the AIX 5.1 part of the
> > > transfer, and that Would make things faster, but it Wouldn't=20
> > > test what we need to test!)
> > >=20
> > > Thanks!
> > >=20
> > > --
> > > Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>
> > >=20
> > >=20
> > >=20
> > >=20
> > > -------------------------------------------------------
> > > This SF.net email is sponsored by: IT Product Guide on
> > > ITManagersJournal Use IT products in your business? Tell us=20
> > > what you think of them. Give us Your Opinions, Get Free=20
> > > ThinkGeek Gift Certificates! Click to find out more=20
> > > http://productguide.itmanagersjournal.com/guid> epromo.tmpl
> > >=20
> > > _______________________________________________
> > >=20
> > > NFS maillist  -  NFS@lists.sourceforge.net
> > > https://lists.sourceforge.net/lists/listinfo/n> fs
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
