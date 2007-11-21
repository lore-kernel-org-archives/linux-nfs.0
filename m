From: Timo Sirainen <tss@iki.fi>
Subject: Re: [NFS] Cache flushing
Date: Wed, 21 Nov 2007 15:14:11 +0200
Message-ID: <1195650851.6039.425.camel@hurina>
References: <1195258291.6039.189.camel@hurina>
	<1195328785.6999.5.camel@localhost.localdomain>
	<600549E3-82CF-44EB-8394-E57A3BB41118@iki.fi>
	<1195332062.6999.20.camel@localhost.localdomain>
	<1195337516.6039.239.camel@hurina> <1195524890.6039.315.camel@hurina>
	<1195602454.7234.100.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1233884158=="
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IupPD-0000dE-8M
	for nfs@lists.sourceforge.net; Wed, 21 Nov 2007 05:14:17 -0800
Received: from dovecot.org ([82.118.211.50])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IupPH-0006kI-Ml
	for nfs@lists.sourceforge.net; Wed, 21 Nov 2007 05:14:21 -0800
In-Reply-To: <1195602454.7234.100.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


--===============1233884158==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-mp1PHKvitBTb4NQ6ZE3c"


--=-mp1PHKvitBTb4NQ6ZE3c
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-11-20 at 18:47 -0500, Trond Myklebust wrote:
> On Tue, 2007-11-20 at 04:14 +0200, Timo Sirainen wrote:
> > On Sun, 2007-11-18 at 00:11 +0200, Timo Sirainen wrote:
> > > > Why can't you simply close(), and then re-open() the file? That is =
_the_
> > > > standard way to force an attribute cache revalidation on all NFS
> > > > versions. The close-to-open caching model, which is implemented on =
most
> > > > NFS clients guarantees this.
> > ..
> > > close()+open() would have been difficult to handle because open() can
> > > fail, but looks like opening another file descriptor and closing it
> > > works just as well. Also looks like it works for flushing directories=
'
> > > attribute cache (which doesn't seem to work with FreeBSD though).
> >=20
> > Actually it works for flushing a directory's attribute cache in
> > v2.6.17-rc2, but not in v2.6.22. chown() works in v2.6.22 also. Is ther=
e
> > a reason for this change? I guess it anyway means that I'm back to usin=
g
> > chown() for flushing a directory's attribute cache.
>=20
> close-to-open caching works fine for me in v2.6.22. It does indeed send
> a GETATTR and revalidate the inode.

I don't have my own NFS test setup, so I can't check what actually
happens in the network, but I can easily reproduce this as a user:

1. touch foo.1 foo.2

2. Run on NFS client 1:

rm -f foo;ln foo.1 foo;sleep 0.5;rm -f foo;ln foo.2 foo

3. Run on NFS client 2 within that 0.5 secs:

echo *>/dev/null;stat foo;sleep 0.5;echo * >/dev/null;stat foo

After repeating this a few (2-5) times stat will return foo.1's inode
for both stats and running the command over and over again will return
only foo.1's inode. The only way to get NFS client 2 to notice the
change and return foo.2's inode is to either wait for attribute cache to
timeout or to run "chown 0 ."

Now that I think of it, I guess the reason is that my 2.6.22 setup has
Linux+ext3 as NFS server and 2.6.17-rc2 setup has NetApp as server. So
even though open()+close() flushes the directory's attribute cache, it
doesn't flush the file name -> NFS handle cache unless mtime changes?

--=-mp1PHKvitBTb4NQ6ZE3c
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHRC8jyUhSUUBViskRAqUtAJ90mlkeW/+xCmDKHShj0QrRAGF67gCfQHDP
ekUyQHh2R5M5bp3ljdo5y6s=
=kSsi
-----END PGP SIGNATURE-----

--=-mp1PHKvitBTb4NQ6ZE3c--



--===============1233884158==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============1233884158==
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

--===============1233884158==--



