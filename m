Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38287 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753367AbcC2Wfz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Mar 2016 18:35:55 -0400
From: NeilBrown <neilb@suse.com>
To: Tom Talpey <tom@talpey.com>, Frank Filz <ffilzlnx@mindspring.com>,
        NeilBrown <neilb@suse.com>,
        "'Linux NFS mailing list'" <linux-nfs@vger.kernel.org>
Date: Wed, 30 Mar 2016 09:35:47 +1100
Subject: Re: Should NLM resends change the xid ??
In-Reply-To: <56F9A923.2060700@talpey.com>
References: <877fgnwkuv.fsf@notabene.neil.brown.name> <00a301d1890b$8b6ac190$a24044b0$@mindspring.com> <56F9A923.2060700@talpey.com>
Message-ID: <87a8lgvrng.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Tue, Mar 29 2016, Tom Talpey wrote:

> On 3/28/2016 12:04 PM, Frank Filz wrote:
>>>
>>> Forcing the xid to change on every retransmit (for NLM) would ensure that
>>> we only accept the last reply, which I think is safe.
>>
>> That sounds like a good solution to me. Since the requests are non-blocking,
>> each request should be considered separate from the others.
>
> I totally disagree. To issue a new XID contradicts the entire notion of
> "retransmit". It will badly break any hope of idempotency.
>
> To me, there are two issues here:
> 1) The client should not be retransmitting on an unbroken connection.

Do you mean by that that it shouldn't retransmit, or that it should
break the connection?
The first would help in my case, but is a fairly substantial change to
the protocol.  I'm not at all certain the second would help.

> 2) The server should have a reply cache.

As I said, I think a reply cache would make problems less common, but
unless it is of unlimited size, it cannot guarantee anything.

>
> If both of those were true, this problem would not occur.
>
> That said, if client B were to *drop the connection* and then *reissue*
> the lock with a new XID, there would be a chance of things working
> as desired.

That is consistent with what I was proposing.

>
> But this would still leave many existing NLM issues on the table. It's
> a pipe dream that NLM (and NSM) will truly support correct locking
> semantics in the face of transient errors.

While perfection may well be unattainable, that shouldn't stop us from
fixing things which can be fixed.

Thanks,
NeilBrown


>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW+wNDAAoJEDnsnt1WYoG5/s0P/RHNRbPdCmPtZ+YZMK4HmrvR
/hatcTJfuEk6U3lLDoxT/KMuhP92R6ni3Tf1tubF+4o3f5X98eJLardlMz+kZGRO
oPGVkEbJ/RZqLqhijkVU3Ser+q3pSHVg2pKdmcrrjG4g1wtR87LQ75cXPj5Cpzkv
2HMP4Iiu+zlGUaHJIyInh6vfe/zKzPQqGOoLQaHeS5W3BMkwugQqGfbPWPflm6Jh
0YfLYNGvzY2dvdF5uGk4oVmzSZqvSty+ILL96/jymyeKpphyyFMpdvxPJB7zby5V
7At6T8itAcuxXGzg6cHGoMS7+MeTkTI5SCHC7Atr45NgXm61T7inZdQYGtgYEkcC
MLPO//qjIPvjHJcA2CUPFyaEW/8g1af2cFUPRceAqt2VpwmP5NIvkH2I88h5Kvsc
OCnZKsaJvEWlAoRU4c5D+znejHXmk+XN/7eKmhohUGmFUBlW9G81+hhDVoUhlYeO
BLjOD28ETisbIYZAA+RHBf5eoxdD7OX7OqLz7WoP+HABuCC3mCCWW7H6rcpu85pZ
oHig7Iqm+4VbtkguQjBjvpF3YRmW1ZPfyJ/auM3qTJMnTICIAkTCW4fzJnLxcbOm
BYTfXDGqApwFAZk2P3OOa/VTqpFyLCF461dY8AjuNYHfGrBw3l3Jw+n6M38vC+Fr
AFGh6fGT/17r3xLdgGfw
=PxZP
-----END PGP SIGNATURE-----
--=-=-=--
