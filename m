From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Different NFSSVC_MAXBLKSIZE for udp and tcp clients?
Date: Wed, 26 Nov 2003 06:20:53 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113020AC79F@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AP0XO-0002mZ-00
	for <nfs@lists.sourceforge.net>; Wed, 26 Nov 2003 06:21:02 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AP0XO-0002Ug-9u
	for nfs@lists.sourceforge.net; Wed, 26 Nov 2003 06:21:02 -0800
To: "James Pearson" <james-p@moving-picture.com>,
        "Greg Banks" <gnb@melbourne.sgi.com>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

here's a vote for leaving these values variable rather than
fixed on the server side.  48KB maximum for UDP is great on
a clean network, but some folks would probably prefer setting
it to 8KB to ensure clients on more realistically congested
networks retain reasonable UDP performance.

is there any evidence to show that a 4MB TCP maximum will
have benefits over something smaller, like say 1MB ?  as
the per-op costs go down when you add more data, the per-byte
costs will become the major part of the overhead for such
operations.  there's probably a sweet spot where the sum
of both per-op and per-byte costs reach a minimum.  as
far as i can tell that value is around 16KB in the current
Linux client implementations.


> -----Original Message-----
> From: James Pearson [mailto:james-p@moving-picture.com]=20
> Sent: Wednesday, November 26, 2003 5:44 AM
> To: Greg Banks; Trond Myklebust
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] Different NFSSVC_MAXBLKSIZE for udp and=20
> tcp clients?
>=20
>=20
> Greg Banks wrote:
> >=20
> > James Pearson wrote:
> > >
> > > Is it possible to force a different maximum [rw]size on the server
> > > depending on whether the client uses udp or tcp?
> >=20
> > If someone writes the code, e.g. some new export options?
>=20
> Do you know if this would be possible with 2.4 kernels?
>=20
> If it is possible, and someone could give me some pointers, I=20
> won't mind
> giving it a a go ...
>=20
> James Pearson
>=20
>=20
> -------------------------------------------------------
> This SF.net email is sponsored by: SF.net Giveback Program.
> Does SourceForge.net help you be more productive?  Does it
> help you create better code?  SHARE THE LOVE, and help us help
> YOU!  Click Here: http://sourceforge.net/donate/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
