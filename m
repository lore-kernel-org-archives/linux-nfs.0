From: "Jeremy Kusnetz" <JKusnetz@nrtc.org>
Subject: RE: RE: Chrooted BIND broke on NFS server between kernel 2.4.21 and 2.4.22
Date: Mon, 15 Dec 2003 09:41:47 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F7F4B5EA9EBD414D8A0091E80389450569D3D4@exchange.nrtc.coop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AVtv0-0004Vy-Q8
	for nfs@lists.sourceforge.net; Mon, 15 Dec 2003 06:41:54 -0800
Received: from outmail.nrtc.org ([204.145.144.17] helo=exchange.nrtc.coop)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AVtv0-0004kI-Co
	for nfs@lists.sourceforge.net; Mon, 15 Dec 2003 06:41:54 -0800
To: <bernd-schubert@web.de>,
	<nfs@lists.sourceforge.net>
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

Thanks, that did the trick!

On a higher level, should this be part of the How-to's trouble shooting =
guide?

> -----Original Message-----
> From: bernd-schubert@web.de [mailto:bernd-schubert@web.de]
> Sent: Sunday, December 14, 2003 9:46 AM
> To: Jeremy Kusnetz; nfs@lists.sourceforge.net
> Subject: Re: [NFS] RE: Chrooted BIND broke on NFS server=20
> between kernel
> 2.4.21 and 2.4.22
>=20
>=20
> >         if (!(exp->ex_flags & NFSEXP_NOSUBTREECHECK)) {
>=20
> So giving 'no_subtree_check' as export option (man exports)=20
> should work as=20
> well, shouldn't it? Due to the problems already described on=20
> this list, I=20
> recently set this option to all rw-exported filesystems.
>=20
> Cheers,
> 	Bernd
>=20


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
