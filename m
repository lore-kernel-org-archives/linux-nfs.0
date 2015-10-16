Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:58812 "EHLO
	prv3-mh.provo.novell.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752024AbbJPAte (ORCPT
	<rfc822;groupwise-linux-nfs@vger.kernel.org:0:0>);
	Thu, 15 Oct 2015 20:49:34 -0400
From: Neil Brown <nfbrown@novell.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
Date: Fri, 16 Oct 2015 11:49:18 +1100
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "David S. Miller" <davem@davemloft.net>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2] sunrpc: fix waitqueue_active without memory barrier in sunrpc
In-Reply-To: <20151015205742.GB20155@fieldses.org>
References: <17EC94B0A072C34B8DCF0D30AD16044A02877D53@BPXM09GP.gisp.nec.co.jp> <17EC94B0A072C34B8DCF0D30AD16044A02878443@BPXM09GP.gisp.nec.co.jp> <20151015205742.GB20155@fieldses.org>
Message-ID: <87y4f3vdrl.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

"J. Bruce Fields" <bfields@fieldses.org> writes:

> On Thu, Oct 15, 2015 at 11:44:20AM +0000, Kosuke Tatsukawa wrote:
>> Tatsukawa Kosuke wrote:
>> > J. Bruce Fields wrote:
>> >> Thanks for the detailed investigation.
>> >>=20
>> >> I think it would be worth adding a comment if that might help someone
>> >> having to reinvestigate this again some day.
>> >=20
>> > It would be nice, but I find it difficult to write a comment in the
>> > sunrpc layer why a memory barrier isn't necessary, using the knowledge
>> > of how nfsd uses it, and the current implementation of the network cod=
e.
>> >=20
>> > Personally, I would prefer removing the call to waitqueue_active() whi=
ch
>> > would make the memory barrier totally unnecessary at the cost of a
>> > spin_lock + spin_unlock by unconditionally calling
>> > wake_up_interruptible.
>>=20
>> On second thought, the callbacks will be called frequently from the tcp
>> code, so it wouldn't be a good idea.
>
> So, I was even considering documenting it like this, if it's not
> overkill.
>
> Hmm... but if this is right, then we may as well ask why we're doing the
> wakeups at all.  Might be educational to test the code with them
> removed.
>
> --b.
>
> commit 0882cfeb39e0
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Thu Oct 15 16:53:41 2015 -0400
>
>     svcrpc: document lack of some memory barriers.
>=20=20=20=20=20
>     Kosuke Tatsukawa points out an odd lack of memory barriers in some si=
tes
>     here.  I think the code's correct, but it's probably worth documentin=
g.
>=20=20=20=20=20
>     Reported-by: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
>
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 856407fa085e..90480993ec4a 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -399,6 +399,25 @@ static int svc_sock_secure_port(struct svc_rqst *rqs=
tp)
>  	return svc_port_is_privileged(svc_addr(rqstp));
>  }
>=20=20
> +static void svc_no_smp_mb(void)
> +{
> +	/*
> +	 * Kosuke Tatsukawa points out there should normally be an
> +	 * smp_mb() at the callsites of this function.  (Either that or
> +	 * we could just drop the waitqueue_active() checks.)
> +	 *
> +	 * It appears they aren't currently necessary, though, basically
> +	 * because nfsd does non-blocking reads from these sockets, so
> +	 * the only places we wait on this waitqueue is in sendpage and
> +	 * sendmsg, which won't be waiting for wakeups on newly arrived
> +	 * data.
> +	 *
> +	 * Maybe we should add the memory barriers anyway, but these are
> +	 * hot paths so we'd need to be convinced there's no sigificant
> +	 * penalty.
> +	 */
> +}
> +
>  /*
>   * INET callback when data has been received on the socket.
>   */
> @@ -414,7 +433,7 @@ static void svc_udp_data_ready(struct sock *sk)
>  		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
>  		svc_xprt_enqueue(&svsk->sk_xprt);
>  	}
> -	smp_mb();
> +	svc_no_smp_mb();
>  	if (wq && waitqueue_active(wq))
>  		wake_up_interruptible(wq);
>  }
> @@ -433,7 +452,7 @@ static void svc_write_space(struct sock *sk)
>  		svc_xprt_enqueue(&svsk->sk_xprt);
>  	}
>=20=20
> -	smp_mb();
> +	svc_no_smp_mb();
>  	if (wq && waitqueue_active(wq)) {
>  		dprintk("RPC svc_write_space: someone sleeping on %p\n",
>  		       svsk);
> @@ -789,7 +808,7 @@ static void svc_tcp_listen_data_ready(struct sock *sk)
>  	}
>=20=20
>  	wq =3D sk_sleep(sk);
> -	smp_mb();
> +	svc_no_smp_mb();
>  	if (wq && waitqueue_active(wq))
>  		wake_up_interruptible_all(wq);
>  }
> @@ -811,7 +830,7 @@ static void svc_tcp_state_change(struct sock *sk)
>  		set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
>  		svc_xprt_enqueue(&svsk->sk_xprt);
>  	}
> -	smp_mb();
> +	svc_no_smp_mb();
>  	if (wq && waitqueue_active(wq))
>  		wake_up_interruptible_all(wq);
>  }
> @@ -827,7 +846,7 @@ static void svc_tcp_data_ready(struct sock *sk)
>  		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
>  		svc_xprt_enqueue(&svsk->sk_xprt);
>  	}
> -	smp_mb();
> +	svc_no_smp_mb();
>  	if (wq && waitqueue_active(wq))
>  		wake_up_interruptible(wq);
>  }
> @@ -1599,7 +1618,7 @@ static void svc_sock_detach(struct svc_xprt *xprt)
>  	sk->sk_write_space =3D svsk->sk_owspace;
>=20=20
>  	wq =3D sk_sleep(sk);
> -	smp_mb();
> +	svc_no_smp_mb();
>  	if (wq && waitqueue_active(wq))
>  		wake_up_interruptible(wq);
>  }

I would feel a lot more comfortable if you instead created:

static inline bool sunrpc_waitqueue_active(struct wait_queue_head *wq)
{
	if (!wq)
        	return false;
        /* long comment abot not needing a memory barrier */
        return waitqueue_active(wq);
}

and then replace various "if (wq && waitqueue_active(wq))" calls with
if (sunrpc_waitqueue_active(wq))"

The comment seems readable and seems to make sense.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWIEmOAAoJEDnsnt1WYoG5AvsP/iz/VQ182MdeetXVXuv/X+dQ
ISrHAxsQi6s1mRPLLz3C8fzl8aP4TU0ONelLDcnRiPKkSdUNMWnIzIHm6E0loZhd
vZImEJiEzIFHyJyqXLNX3R1tiys7pV3tKGemIDQse3oWrd5YU42owzly+ZAqGDmQ
u9XCRsdjs4XGaz62oizjQaxg8In5E4DvRuy7dznbrvrPlhU6VbZFHki+6bz0ua16
RrU/eklgrUOAGotoGtw8+m2nBGdoc8XZvzIsJKRjWo2RPo3ncWXbaAiI6IDqZ5+E
56FgL6OUSsnlNSsZV6XVM02nXOU67Vq3QKQnK9BJGV4odINbFtyKZtT+gbPt4zbk
eLWYL7AF+jU+fxKdLF2Ysg6UtEYYw+x15NUWqXfJIOJT2QjMX4YJs4Bc3i9nYz17
josLDE3znKFu8GtuboiB3XxuPPgmqOm378K6fW81U2YbKVLhtpa4JmfLsMPqSNq3
KhZ8z9NGJdZiHwTT4Gw8GsyxWlTYCdIHqv2KSpsJCy0LWsqWCpmCMnkUnKR3gxly
8oCj5KdNxwEg0U2vC4EqL0ZyCLysWSkrEox4CD1/fTpYjKwxuiDqa95mL247/l/1
gAb6516aWkM5aT+RNd2GfFIDTH/1d4+GRSTUzUgAZ5spl6Vc0Zt75Li+r35CJE42
4iSPHWVJZK+N/Oc8lXBU
=LGut
-----END PGP SIGNATURE-----
--=-=-=--
