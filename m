Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:57068 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752712AbbGJLhE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Jul 2015 07:37:04 -0400
Date: Fri, 10 Jul 2015 13:36:58 +0200
From: William Dauchy <william@gandi.net>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: William Dauchy <william@gandi.net>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>, jloup@gandi.net
Subject: Re: extra reference to fl->fl_file, possible regression
Message-ID: <20150710113657.GJ15144@gandi.net>
References: <20150710092910.GI15144@gandi.net>
 <20150710072438.08b3417a@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="enLffk0M6cffIOOh"
In-Reply-To: <20150710072438.08b3417a@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--enLffk0M6cffIOOh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Jul10 07:24, Jeff Layton wrote:
> These patches are pretty straightforward. We're just taking an extra
> reference to the filp when running lock operations so that it doesn't
> disappear before the replies can be processed (typically in the event
> that a signal comes in while waiting on the reply). Given the odd stack
> trace above, I have to wonder if there's some sort of memory scribble
> going on.

I was also surprised by such new behavior looking at the impact of those
patches.

> Just to be clear...you are mounting with NFSv4 and running something on
> the mount when you see this, right? If you don't use NFSv4, then is
> everything fine?

yes, it's nfv4.
--=20
William

--enLffk0M6cffIOOh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlWfrlkACgkQ1I6eqOUidQEfmwCaAixvTc/tJLembcmv1tVGQQc1
wMsAnjv6bBMdqt1nSfZe0Y48pG9KtC9V
=N89v
-----END PGP SIGNATURE-----

--enLffk0M6cffIOOh--
