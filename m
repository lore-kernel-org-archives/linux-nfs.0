From: Timo Sirainen <tss@iki.fi>
Subject: Re: [NFS] Cache flushing
Date: Sun, 18 Nov 2007 00:11:56 +0200
Message-ID: <1195337516.6039.239.camel@hurina>
References: <1195258291.6039.189.camel@hurina>
	<1195328785.6999.5.camel@localhost.localdomain>
	<600549E3-82CF-44EB-8394-E57A3BB41118@iki.fi>
	<1195332062.6999.20.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1222174696=="
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ItVtR-0000We-Cz
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 14:12:01 -0800
Received: from dovecot.org ([82.118.211.50])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ItVtW-0007Qa-OC
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 14:12:07 -0800
In-Reply-To: <1195332062.6999.20.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


--===============1222174696==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-aUsKjzIYw6IrbEj6y1zj"


--=-aUsKjzIYw6IrbEj6y1zj
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2007-11-17 at 15:41 -0500, Trond Myklebust wrote:
> On Sat, 2007-11-17 at 22:12 +0200, Timo Sirainen wrote:
> > On 17.11.2007, at 21.46, Trond Myklebust wrote:
> > > Why is this needed?
> >=20
> > Do you mean why is flushing attribute cache needed, or why is this =20
> > particular way to flush it needed?
> >=20
> > I need to be able to find out if a file has changed, so I need to get =20
> > its attribute cache flushed. fchown()ing to -1, -1 would work safely =20
> > in all situations because it's guaranteed not to change the file in =20
> > any way.
>=20
> Why can't you simply close(), and then re-open() the file? That is _the_
> standard way to force an attribute cache revalidation on all NFS
> versions. The close-to-open caching model, which is implemented on most
> NFS clients guarantees this.

Interesting. Too bad this is the first time I have heard of it (where as
I've seen fchown()/chown() suggested in several mailing lists before). I
understood NFS FAQ's close-to-open caching description to mean only how
data caching is handled.

close()+open() would have been difficult to handle because open() can
fail, but looks like opening another file descriptor and closing it
works just as well. Also looks like it works for flushing directories'
attribute cache (which doesn't seem to work with FreeBSD though).

There's one potential problem with closing a file descriptor though. It
loses all fcntl locks for that file from all fds. I'm not sure if this a
problem for me though.

> > Also O_DIRECT is a bit too much for my use case. I do want the file =20
> > to be cached for the most part, but there are times occationally when =20
> > parts of it can be overwritten, and I need to make sure that in those =20
> > situations the newest data is read.
> >=20
> > If you want a wider description of what I'm trying to do: I'm =20
> > developing Dovecot IMAP server. A lot of people store mails on NFS =20
> > and want to have multiple IMAP servers be able to access the mails. =20
> > Dovecot uses somewhat complex index files to speed up accessing the =20
> > mailboxes, and it's mainly for these index files that I need this =20
> > explicit control over caching. If two servers are accessing the same =20
> > mailbox at the same time, the index files get easily corrupted if I =20
> > can't control the caching.
>=20
> So how are you ensuring that both servers don't try writing to the same
> locations? You must have some form of synchronisation scheme for this to
> work.

Well, there's no simple answer for that. :) There are 3 different kinds
of index files with completely different locking behavior, because I try
to avoid long lasting locks. I do use write locks, but reads are mainly
lockless. There's this transaction log file which tells me when
something has changed, so I know when data cache need to be flushed.

Anyway, all of this is working already, but I'd just like to get the
performance a bit better with Linux by avoiding those unnecessary lock
+unlock sequences.

--=-aUsKjzIYw6IrbEj6y1zj
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHP2csyUhSUUBViskRAvzbAJ0a9Ua2mElJ3hloyZ7Os8ogpTbIcwCdELoV
NV8HMAhhJXKltxLLK8QFtCY=
=QmHk
-----END PGP SIGNATURE-----

--=-aUsKjzIYw6IrbEj6y1zj--



--===============1222174696==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============1222174696==
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

--===============1222174696==--



