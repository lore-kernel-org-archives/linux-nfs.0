From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: linux 2.4.20 oops
Date: Tue, 29 Apr 2003 10:31:26 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D5559E@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "Marcelo Tosatti" <marcelo@conectiva.com.br>,
   "NFS maillist" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19AYxA-0002eJ-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 10:31:40 -0700
To: <trond.myklebust@fys.uio.no>
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

ok, it looks like i was stupid and didn't apply the rc1 patch
to my rc1 tree.  my copy of the rc1 pre-patch has the right
stuff in it.

sorry to be a bug.

> -----Original Message-----
> From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
> Sent: Tuesday, April 29, 2003 1:22 PM
> To: Marcelo Tosatti
> Cc: Lever, Charles; NFS maillist
> Subject: RE: [NFS] linux 2.4.20 oops
>=20
>=20
> >>>>> " " =3D=3D Charles Lever <Lever> writes:
>=20
>      > i built 2.4.21-rc1 from 2.4.20.tar.bz2 and the rc1 upgrade
>      > patch, and its not in my version of rc1.
>=20
> Hmmm... strange. AFAICS there are no NFS or RPC changes whatsoever in
> the rc1 patch on ftp.kernel.org.
> As I said, all the changes (including Ulrich Weigand's patch) appear
> to still be in the bitkeeper repository (see for instance the kernel
> source browser on http://linux.bkbits.net:8080/linux-2.4).
>=20
> Marcelo, is this perhaps a problem with an incorrect generation of the
> 'official' 2.4.21-rc1 patch?
>=20
> Cheers,
>   Trond
>=20


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
