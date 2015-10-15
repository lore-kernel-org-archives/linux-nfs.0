Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59800 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751401AbbJOV5b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Oct 2015 17:57:31 -0400
From: Neil Brown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Fri, 16 Oct 2015 08:57:23 +1100
Cc: Olaf Kirch <okir@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC] sunrpc/cache: make cache flushing more reliable.
In-Reply-To: <20151015135039.GB18976@fieldses.org>
References: <87fv1cwsln.fsf@notabene.neil.brown.name> <87a8rkws7g.fsf@notabene.neil.brown.name> <20151015135039.GB18976@fieldses.org>
Message-ID: <874mhrx0ak.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

"J. Bruce Fields" <bfields@fieldses.org> writes:

>>=20
>> I'll resend it people are otherwise happy.
>
> I'm otherwise happy!  Looks like a reasonable approach.
>
> (The one thing I wonder is whether it would be clearer to outright fail
> writes that attempt to create already-expired cache entries.
>
> But I think that's an unimportant corner case really.  And if there are
> existing cases where that's happening then perhaps it's less disruptive
> just to let them expire a second later rathern than to introduce a new
> error.)

I hadn't thought about.  There is often a good case for failing a
meaningless value rather than silently doing something different.
Were I creating a new interface, I would probably do that.
But revising an old interface that doesn't currently return an error...
I agree with you that it is likely less disruptive to not introduce a
new error.  Thanks for asking the question.

I'll post the proper patch separately.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWICFDAAoJEDnsnt1WYoG5q6EP/1QY+Wfr4PVOiu79CWgAnWUZ
wI/eYPghlBm8uSHm50vKdIZpg5oCSdyfsPZcd/ogOc/kQePKa2nbW2AV7g6b+iUj
Nf+FNObRJWnrpACRK3LavG3rHBERC8pQeIdOaNgSiNKgu37vcfEghAyAWz88il8n
6IEbpwgQCvOE88JkAXmMxsCOd7JMrfE5evP6P5n7oZGhy+wLmX9++6ylqvs6j+Wb
+U9Q3DWFkpqAmPd90vqpOYCOzoSoyJNl4stYMvq5b3JQ+mYhsDHBaUouMT8mEOQ2
3q1AGkHxABoF5OD/E7Uo5QPlJa6o69mSnYwO0Rxuri9ZlyPDpX2vm9SnbQx+Cn5t
kdOT5/0SA8p+KDHwN6vvUxriw8pKUCaHCI1GF2bWCnzGjmr76pUziEmcVAwRt2eO
3XAQgkURldv6AP7WYXdLSxs/wAovJdY8od1+Rpxs7WRxD7lE3Lp9o+eArvamE419
RrMCUggd/ow7W6AOOGTg2G4ZtlHE0KpG1Pzq0FGnGckChtRxbUfUk25RcV92oMYy
8sWL6o1QkVyUVH/vp+w+E8AsioiDar/qPoJHZY/d0rlpIhFAYweucC06GTqG6EfU
LGushBtCz9E8tfAL/YxB4/yMjaC5Ak4xUt8L9284xfLvQGX11rXtGg81ntyVdgBU
j7pU7NnS/RHFr3Hv/w78
=z62r
-----END PGP SIGNATURE-----
--=-=-=--
