From: Garrick Staples <garrick@usc.edu>
Subject: Re: mountd segfault on itanium2
Date: Mon, 3 May 2004 13:47:08 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040503204707.GU23287@polop.usc.edu>
References: <20040430212414.GF22498@polop.usc.edu> <20040430234327.GM22498@polop.usc.edu> <20040501030730.GE23287@polop.usc.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="niUlcCfh/sMBwTxc"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BKkMz-0000rG-Ag
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 13:48:57 -0700
Received: from polop.usc.edu ([128.125.10.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BKkMU-0005hL-I8
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 13:48:26 -0700
Received: from polop.usc.edu (localhost.localdomain [127.0.0.1])
	by polop.usc.edu (8.12.10/8.12.10) with ESMTP id i43Kl8lv013058
	for <nfs@lists.sourceforge.net>; Mon, 3 May 2004 13:47:08 -0700
Received: (from garrick@localhost)
	by polop.usc.edu (8.12.10/8.12.10/Submit) id i43Kl8nL013056
	for nfs@lists.sourceforge.net; Mon, 3 May 2004 13:47:08 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20040501030730.GE23287@polop.usc.edu>
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


--niUlcCfh/sMBwTxc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Apr 30, 2004 at 08:07:30PM -0700, Garrick Staples alleged:
> On Fri, Apr 30, 2004 at 04:43:27PM -0700, Garrick Staples alleged:
> > I just spotted a pattern.  After collecting several strace samples, it =
always
> > segfaults after read() or write() to fd 5.  And fd 5 is always:
> >=20
> >    open("/proc/net/rpc/nfsd.fh/channel", O_RDWR) =3D 5

More info:

Program received signal SIGSEGV, Segmentation fault.
0x20000000002899d0 in svc_getreq_common_internal () from /lib/tls/libc.so.6=
=2E1
(gdb) bt
#0  0x20000000002899d0 in svc_getreq_common_internal ()
   from /lib/tls/libc.so.6.1
#1  0x2000000000289720 in svc_getreqset_internal () from /lib/tls/libc.so.6=
=2E1
#2  0x4000000000009d60 in my_svc_run () at svc_run.c:62
#3  0x4000000000006160 in main (argc=3D4, argv=3D0x60000fffffffb8c8)
    at mountd.c:436



--=20
Garrick Staples, Linux/HPCC Administrator
University of Southern California

--niUlcCfh/sMBwTxc
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFAlq/L0SBUxJbm9HMRAnCAAKC15Ya3/5EQnMErUyFU4iC3wIOdQQCgt465
0oVmZMWeaPq8k2UCekKrc04=
=eLD7
-----END PGP SIGNATURE-----

--niUlcCfh/sMBwTxc--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
