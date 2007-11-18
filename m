From: Timo Sirainen <tss@iki.fi>
Subject: Re: [NFS] Cache flushing
Date: Sun, 18 Nov 2007 04:03:49 +0200
Message-ID: <1195351429.6039.259.camel@hurina>
References: <1195258291.6039.189.camel@hurina>
	<1195328785.6999.5.camel@localhost.localdomain>
	<600549E3-82CF-44EB-8394-E57A3BB41118@iki.fi>
	<1195332062.6999.20.camel@localhost.localdomain>
	<1195337516.6039.239.camel@hurina>
	<1195343531.7084.11.camel@localhost.localdomain>
	<6513EED9-82AA-4613-A207-686CFFB95430@iki.fi>
	<1195346790.8908.0.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0467050399=="
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ItZVp-0004lJ-4N
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 18:03:53 -0800
Received: from dovecot.org ([82.118.211.50])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ItZVt-0006jv-Lk
	for nfs@lists.sourceforge.net; Sat, 17 Nov 2007 18:03:59 -0800
In-Reply-To: <1195346790.8908.0.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


--===============0467050399==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-EI+VQvEtQbS/4hdJLwWc"


--=-EI+VQvEtQbS/4hdJLwWc
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sat, 2007-11-17 at 19:46 -0500, Trond Myklebust wrote:

> Right. I understood that you were not using fcntl() locks. Those will
> in
> any case ensure cache revalidation, so you wouldn't have to use
> anything
> else.

I just noticed that FreeBSD's fcntl() locking doesn't flush either
attribute or data cache. So things seem to be a lot more difficult to
handle with it.

> On Sun, 2007-11-18 at 02:26 +0200, Timo Sirainen wrote:
> > Most people are using NetApps, and they also seem to have 1 second =20
> > resolution (at least the one I just tested had). So this isn't a =20
> > solution. "Let's hope that there are no writes less than 1 second =20
> > apart" isn't really a solution either. People like their mailboxes =20
> > uncorrupted.
>=20
> No. NetApp filers and WAFL have nanosecond resolution. They should be
> fine.

I guess I ran my test accidentally on local filesystem. I see only
microsecond resolution though, the last 3 digits in st_mtim.tv_nsec are
always zeroes. But maybe that's enough to be trusted.

Looks like this mtime checking works only with close+open, but not with
fchown()ing the file. That explains a few other things I was mistaken
about as well.

BTW. I've been writing these things down to
http://iki.fi/tss/nfs-coding-howto.html. Would be nice to know if there
are still some mistakes in it.

--=-EI+VQvEtQbS/4hdJLwWc
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBHP52FyUhSUUBViskRApl2AJ4k71+UhF5Ws1AZfY25HV8R9sXUiQCbBmNW
7bK4Ib5vgP8C0SZtap6AvUg=
=//ft
-----END PGP SIGNATURE-----

--=-EI+VQvEtQbS/4hdJLwWc--



--===============0467050399==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============0467050399==
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

--===============0467050399==--



