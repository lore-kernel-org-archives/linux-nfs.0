Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36850 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750949AbdJBWOA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 2 Oct 2017 18:14:00 -0400
From: NeilBrown <neilb@suse.com>
To: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 03 Oct 2017 09:13:48 +1100
Cc: Richard Laager <rlaager@wiktel.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: PROBLEM: NFS Client Ignores TCP Resets
In-Reply-To: <CAN-5tyG7BeAoy_tqap23CM8rCHcyOcy2Jee3us+xU4kxVV54gA@mail.gmail.com>
References: <56BFE55D.1010509@wiktel.com> <87twjjpcl8.fsf@notabene.neil.brown.name> <57062C53.9080102@wiktel.com> <87wpo9lydp.fsf@notabene.neil.brown.name> <CAN-5tyG7BeAoy_tqap23CM8rCHcyOcy2Jee3us+xU4kxVV54gA@mail.gmail.com>
Message-ID: <878tgt42qr.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Mon, Oct 02 2017, Olga Kornievskaia wrote:

> Hi Neil,
>
> Was your patch 3ffbc1d6558 (net/sunrpc/xprt_sock: fix regression in
> connection error reporting) is an attempt to fix this problem or was
> it  something else (latter is what I think but would like to verify)?

That patch fixed a bit that was introduced in 4.12.  As you reported a
problem with 4.5, it must be a different problem.

>
> I was wondering if there was anything done upstream that fixed this issue.
>

Not that I know of.  I don't think it can be reproduced upstream, which
make it difficult.

The last think I said was:

>>
>> It might help to see a tcpdump trace of the case where the "ssh"
>> connection was broken successfully for comparison with the case where
>> the nfs connection wasn't broken.  Or it might not.

Seeing the trace might not help, but not seeing (which is the current
situation) definitely won't help.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlnSuh0ACgkQOeye3VZi
gbnhJxAAkwEgb6F58dSR4TBr1kkXAfDZkAUp1WAO04CRPKH5RDA0GiUE79dr7oHE
q17nyAvtoUgYTSn/+gFV0IeCdH0ftwo9uRHWMyWQ9CwVBYiLzOJ9ZNOosnTetdL6
938l/QM/ouASIJtPnyGvuScLcEp+255ISpp+6JBGURXURYF7cBsHYKCQIX/0gy34
Yp8HyZzhyHXXn3eBrZGwGJSw1zpvYxXEIeOvl492nG+gHxpyGkBVvqIZILnhhpCk
lmnT8SXjF2s90M1KOt8f5aqfyl/hsijtEuOlFNDF03FyyX7DPu0d8uXAxLgoLYTk
mr6NPE7Dx9UWj3V3ckxP+J6RUgpgTXwOy0o5WoCFpwaxgFYAdUtwfQkclT8hPUDa
rgtc0YaOPJxrCnci9HpdoyZGRzgcQdYS+k13FAGx+baT0SShrzFyDNnyuEVJqETh
OJmLnOjAeKHEQHwO+WmJRPofNqD3j84uyo8NU7Vct06O8MpPEMZGMRoJtKKmFOPX
fipTk0J2cu0ZmR72+3C6Af8Q5hArv6GVqnhp7JzUcpE1Zf6QRCl8u8oLPE08fRGZ
p0NgiCM7PKKWxzLYVIfPC9YRp+OcJRv/Iq5fjXGQuK52zhtpHlmC4uBvnxwLIxIH
Z+ZlbdhrKx6IFHgcacMw1SrGFd1Nfeirfewp2Rb7A4vWrgDIM20=
=v4+T
-----END PGP SIGNATURE-----
--=-=-=--
