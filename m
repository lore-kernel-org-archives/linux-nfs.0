From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: linux 2.4.20 oops
Date: Tue, 29 Apr 2003 09:56:22 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D55598@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19AYPL-0007KE-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 09:56:43 -0700
Received: from frejya.corp.netapp.com (frejya [10.10.20.91])
	by mx01.netapp.com (8.12.9/8.12.9/NTAP-1.4) with ESMTP id h3TGubFB006708
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 09:56:37 -0700 (PDT)
Received: from black.eng.netapp.com (black.eng.netapp.com [10.56.10.24])
	by frejya.corp.netapp.com (8.12.9/8.12.9/NTAP-1.4) with ESMTP id h3TGubln025308
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 09:56:37 -0700 (PDT)
To: "Trond Myklebust (E-mail)" <trond.myklebust@fys.uio.no>
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

the fix appears in 2.4.21-pre7, but was removed from
2.4.21-rc1.  trond?

> -----Original Message-----
> From: Danny Smith [mailto:dannys@cinesite.co.uk]
> Sent: Tuesday, April 29, 2003 12:44 PM
> To: Philippe Troin
> Cc: Brasseur Val=E9ry; nfs@lists.sourceforge.net
> Subject: Re: [NFS] linux 2.4.20 oops
>=20
>=20
>=20
> Philippe Troin wrote:
>=20
> >Danny Smith <dannys@cinesite.co.uk> writes:
> > =20
> >
> >>We used this patch from Ulrich Weigand
> >>(weigand@informatik.uni-erlangen.de), and haven't seen a problem
> >>since. See the archives for full details - basically seems to be an
> >>SMP race in rpc_delete_timer(). If you're not on an SMP system, =
it's
> >>probably NOT the right fix.
> >>   =20
> >>
> >
> >Has this been pushed to 2.4.21?
> > =20
> >
> Not AFAIK.
>  From the comments in the original post I saw, it looks like=20
> Trond did=20
> produce a similar patch, but I couldn't see anything when I=20
> was looking=20
> for a resolution to our problems. Perhaps it's worth waiting for more =

> confirmation that this is
> a) harmless in all cases, and
> b) fixes the problems being seen
> before trying to get this pushed up. I freely confess that I=20
> don't know=20
> enough of this code at this level to feel confident beyond "it works=20
> well for us".
>=20
> Danny
>=20
> --=20
> Danny Smith
> Senior Systems Administrator, Cinesite (Europe) Ltd
> 020 7973 4000 - x4055    /    dannys@cinesite.co.uk
>=20
>=20
>=20
>=20
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
