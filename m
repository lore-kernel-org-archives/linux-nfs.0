From: Timo Sirainen <tss@iki.fi>
Subject: Re: [NFS] Cache flushing
Date: Tue, 20 Nov 2007 04:14:50 +0200
Message-ID: <1195524890.6039.315.camel@hurina>
References: <1195258291.6039.189.camel@hurina>
	<1195328785.6999.5.camel@localhost.localdomain>
	<600549E3-82CF-44EB-8394-E57A3BB41118@iki.fi>
	<1195332062.6999.20.camel@localhost.localdomain>
	<1195337516.6039.239.camel@hurina>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0471855515=="
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IuIda-0004Bp-A1
	for nfs@lists.sourceforge.net; Mon, 19 Nov 2007 18:14:54 -0800
Received: from dovecot.org ([82.118.211.50])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IuIde-0002Wd-UP
	for nfs@lists.sourceforge.net; Mon, 19 Nov 2007 18:15:00 -0800
In-Reply-To: <1195337516.6039.239.camel@hurina>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


--===============0471855515==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-FMumx+QeOBJKoPFYkuVd"


--=-FMumx+QeOBJKoPFYkuVd
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2007-11-18 at 00:11 +0200, Timo Sirainen wrote:
> > Why can't you simply close(), and then re-open() the file? That is _the=
_
> > standard way to force an attribute cache revalidation on all NFS
> > versions. The close-to-open caching model, which is implemented on most
> > NFS clients guarantees this.
..
> close()+open() would have been difficult to handle because open() can
> fail, but looks like opening another file descriptor and closing it
> works just as well. Also looks like it works for flushing directories'
> attribute cache (which doesn't seem to work with FreeBSD though).

Actually it works for flushing a directory's attribute cache in
v2.6.17-rc2, but not in v2.6.22. chown() works in v2.6.22 also. Is there
a reason for this change? I guess it anyway means that I'm back to using
chown() for flushing a directory's attribute cache.

The reason for flushing a directory's attribute cache is so that I can
see with stat() if an open file under it has been replaced (if its inode
has changed).

http://dovecot.org/tools/nfstest.c can be used to easily test what works
and what doesn't for cache flushes.


--=-FMumx+QeOBJKoPFYkuVd
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHQkMayUhSUUBViskRAgvnAKCH8uYTYg5/EXJrBDIxEize+cO+FgCdE88K
gbNOJdn79EFW8u1cZHy+cns=
=aqe1
-----END PGP SIGNATURE-----

--=-FMumx+QeOBJKoPFYkuVd--



--===============0471855515==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============0471855515==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--===============0471855515==--



