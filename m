Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40750 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751552AbdHQDeA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 16 Aug 2017 23:34:00 -0400
From: NeilBrown <neilb@suse.com>
To: Bennett Amodio <bamodio@purestorage.com>, linux-nfs@vger.kernel.org
Date: Thu, 17 Aug 2017 13:33:49 +1000
Cc: anna.schumaker@netapp.com, trond.myklebust@primarydata.com,
        Igor Ostrovsky <igor@purestorage.com>,
        Vas Chellappa <vas@purestorage.com>,
        Jui-Yu Chang <juchang@purestorage.com>
Subject: Re: [RFC v3 2/2] SUNRPC: Mask XIDs to prevent replay cache collision
In-Reply-To: <CAKk7tABaTxA102tUHEuYyC8rtbNDjzHX6MdVcCkTy_26yfVkvA@mail.gmail.com>
References: <CAKk7tABaTxA102tUHEuYyC8rtbNDjzHX6MdVcCkTy_26yfVkvA@mail.gmail.com>
Message-ID: <87mv6yna02.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Tue, Aug 15 2017, Bennett Amodio wrote:
>
>   for (i = 0; i < args->nconnect - 1; i++) {
> +     xprtargs.transport_id += 1;
>       if (rpc_clnt_add_xprt(clnt, &xprtargs, NULL, NULL) < 0)
>           break;
>   }

hi,
 this is a tiny point, but I think this code would look nicer as

   for (i = 1; i < args->nconnect; i++) {
           xprtargs.transport_id = i;
           if (rpc_clnt_add_xprt(clnt, &xprtargs, NULL, NULL) < 0)
                   break;
   }

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmVDp8ACgkQOeye3VZi
gbn4OA//a5Fy/Fz3NPMClC0JbO/G/5WK0pJJMd6qefdQwdS3FbVuzMuGbP2F/Pei
olZw8PPMqsdLckkkicuir/GbCIVpSOpwGzxOhyo8of0n9KZM9iWywHxXd0gBzkUp
DwXc++z1LZWcuoKExGezjaNE+mhfj6tm+J/P9p0rcny8QKjHgoLvWRTrABHcbk9T
syHmDuiFzT4lp+2zJ63wbQzsz0JBn9Kh+kkLjZXhdXOGHAY0YRBXUc6ODMEWtZNi
PIApm2K9ePaRjR17dJe95NoyAmhhXTekaq7gd2/pN3VgS6NuTSxTdfj72SAYjwVn
LxqA3zFIsjBlA5er30GpErvwbwUFjkk5A6jywwCjVYglhMqovcpWXrokh8waSdf+
I1K6OQnFfN253vM36XK1AMfTIAIvZu8l2AHsxQ1ugvxMBE/opAjV8quuS1S5bT6j
UOs+oB8Oba8gNFzWIyFnTw5s2HIVEFYDPzuww1rv4mVqGJWbsDAear9cfEzk8GgO
eAAY7hFCDFdrs88c5/dTEZVGik+wq0K4r013cQ+Iupy4k4HJQcLwj6MvAM/fsb/O
qXhZUcOBNcMjgaZn6Hpdk4KxhKN7Bf2LvdvA6Yf/jn0qS25wFZJApDlyuugNLYMi
wYBGdbl4jmtcFd/dByf0K3EeNE3VS80QVAq6GKUNBk44DfzdD0Y=
=E+Uj
-----END PGP SIGNATURE-----
--=-=-=--
