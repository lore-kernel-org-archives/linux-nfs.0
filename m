Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38820 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751330AbaD3HwU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2014 03:52:20 -0400
Date: Wed, 30 Apr 2014 17:52:09 +1000
From: NeilBrown <neilb@suse.de>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
        NFS <linux-nfs@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH/RFC] SCHED: allow wait_on_bit functions to support a
 timeout.
Message-ID: <20140430175209.166a42d9@notabene.brown>
In-Reply-To: <20140430073154.GW11096@twins.programming.kicks-ass.net>
References: <20140429194406.06c580b8@notabene.brown>
	<20140429103217.GQ27561@twins.programming.kicks-ass.net>
	<20140430122926.6bb0c771@notabene.brown>
	<20140430073154.GW11096@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/=nUe5wKFOOKiiWy8fL+WO3t"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/=nUe5wKFOOKiiWy8fL+WO3t
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 30 Apr 2014 09:31:54 +0200 Peter Zijlstra <peterz@infradead.org>
wrote:

> On Wed, Apr 30, 2014 at 12:29:26PM +1000, NeilBrown wrote:
> > If you think it is a good cleanup I'll post a proper patch with all the=
 right
> > Cc:s.
>=20
> Yeah, its a good cleanup. Thanks!
>=20
> > +static inline int
> > +wait_on_bit(void *word, int bit, unsigned mode)
> > +{
> > +	if (!test_bit(bit, word))
> > +		return 0;
> > +	return out_of_line_wait_on_bit(word, bit,
> > +				       bit_wait,
> > +				       mode & 65535);
> > +}
> > +
> > +static inline int
> > +wait_on_bit_io(void *word, int bit, unsigned mode)
> > +{
> > +	if (!test_bit(bit, word))
> > +		return 0;
> > +	return out_of_line_wait_on_bit(word, bit,
> > +				       bit_wait_io,
> > +				       mode & 65535);
> > +}
>=20
> That actually fits on one <80 line. Also, where does the 16 bit mask
> come from? On which, I would write that in hex, 0xFFFF is slightly
> easier to recognise as (1<<16)-1.

That is a hangover from an earlier attempt which didn't work.  Thanks for
catching it.

I'll refresh and do some basic testing tomorrow and send it out, including =
to
Oleg.

Thanks,
NeilBrown

--Sig_/=nUe5wKFOOKiiWy8fL+WO3t
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU2Crqjnsnt1WYoG5AQJuWhAAjHZHmwjdz17W8mW0Ib7fc1Za/+P1KN0s
LDEJ9KqUeNlSx0eu3BUB7dwf7SdRlFpgzpQmiMffPJ7faOd9adyQQQ3Ji0rQe2ZI
gxbjfo6bk9faJc7+uLiP315me+NNQM0R1PRwKZMI0OaPP52qURJHpyeOCdmlpvIy
MFyX+xf0qAMV6EaW/6B1edW4yDe7H6tau7L6/rlufRjf7nU8+0nkmIjufxJLUMv/
IGxI9iS/3ZLrCvksIoLlmNGDKlfUE8wPKyvo+jpefPbxok9yV/c1DDCN0QA/p8Jc
yzUMn1ZsHsPq2B4O6Ou9+7uEnQcBRmPUzcxe65JLbpGGdtGDIMh4JKuWaFniBdsA
9LnyJ0O5JWeQUaNDDoPK3oCD3+JJb5ek65P+0y59PtIjR4nGCMgEqVDyZbY8Ub1O
o068x2pBXpaoYj+isz7Z20HrL0JoCuaNNyRN2NwVPXuPzj/WafqgTkjO84tLMQUC
mOzi7iBTRX5DRz3TT/1OS/NUQAezKM12JnF/N91s1UmaNf+SvjzdkPSlQADpuUsb
rIbcUpzKvUnA4mQM5ED0Tb5YKsctv68V8Zvu1DOsDEZF9bKvlyYzdGjoIAbumDRx
fHbiBycUFxPQmS54qzCKwgvplL5IfxNtyFNHS8NP0aETBS0iA/CrDBlIbyRZ5ntp
IZNJtIe1hmk=
=UbBG
-----END PGP SIGNATURE-----

--Sig_/=nUe5wKFOOKiiWy8fL+WO3t--
