Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40654 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755527AbdKJBuY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 20:50:24 -0500
From: NeilBrown <neilb@suse.com>
To: Joshua Watt <jpewhacker@gmail.com>,
        Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Date: Fri, 10 Nov 2017 12:50:13 +1100
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: Re: [RFC 3/4] SUNRPC: Simplify client shutdown
In-Reply-To: <20171108145942.5127-4-JPEWhacker@gmail.com>
References: <CAJdd5GZ-EMj8f3RaV_WUdeZs6aWbEAeC6xX8BadMD-aOFL3_jA@mail.gmail.com> <20171108145942.5127-1-JPEWhacker@gmail.com> <20171108145942.5127-4-JPEWhacker@gmail.com>
Message-ID: <87ineiewbu.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 08 2017, Joshua Watt wrote:

> Use the flag to kill all new tasks when shutting down instead of
> repeatedly killing all the pending tasks.
>
> Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
> ---
>  net/sunrpc/clnt.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 70005252b32f..8d51e0788a63 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -860,8 +860,8 @@ void rpc_shutdown_client(struct rpc_clnt *clnt)
>  			clnt->cl_program->name,
>  			rcu_dereference(clnt->cl_xprt)->servername);
>=20=20
> +	rpc_killall_tasks(clnt, 1);
>  	while (!list_empty(&clnt->cl_tasks)) {
> -		rpc_killall_tasks(clnt, 0);
>  		wait_event_timeout(destroy_wait,
>  			list_empty(&clnt->cl_tasks), 1*HZ);
>  	}

The previously called rpc_killall_tasks every second.
Now that it doesn't do that, it doesn't do anything every second.
so:
     rpc_killall_tasks(clnt, 1);
     wait_event(destroy_wait, list_empty(&clnt->cl_tasks));

should be sufficient.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAloFBdcACgkQOeye3VZi
gbkNUg//ZE08WibDpIF/Fgx534QtxO/crJDfwXIZxjqI15Zdt2DZ5ZIKFn4xY6sU
QgMqCFNkhHTN8tI2IG0J+g8PjmvVpjft2Y9xgffs7LkGNKnlkVcDNe88dOvaAxr5
9pR5rai1wX7vlCbEymE4pk8Y8WIx5dMC2C7VxxVS/qiw8pR2vgu04zC/y38oP2mc
T67oPLDzEJkS5dy+pt6uQNBG3q0EWblOuHytc3tRWX1xMqQbO9m3Ak+htogPr9Mi
YU5n2S712mHyXulb/K0PBV8XZbfd4BEVcbtKSTIwv3Ssc4ZqIRBcCEPJma1hm6cQ
OxQq5o89/KwmFijW2BjLK3AjN0zHKcV+tXGDYNxnK41wEwU9whz73IZJ/jnP4ib6
AJ4oQp3LZJ6bCNoAad1K/UEQhp5G6caxN1+t2Ty77/F6wTV+Q/IS8z+J6s7CwuUf
DWMw0EDK/beeyJEUws/d5YFy9Wq1oFPBbCRtOOdZI5RqgSNgmtHMKbyoog3YCeE9
Sm7q9ahzU0y4JO4LrV09Y5pAvxgXQDhZvouNE9/BGuS35duXwQleX8rTFaUF4cL0
YS+plAbqZujg9cLA/fO42Ni7ijctHEpUCHeER2srLmEWeUSzfF482x3nLKyZwlc+
GptWw0pXRPez6p1NRzNvl9Bqko0FZ4DX1QOmJv1SxvpYzUKvyUg=
=Q09l
-----END PGP SIGNATURE-----
--=-=-=--
