Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:51041 "EHLO
	prv3-mh.provo.novell.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752162AbbJIF4S (ORCPT
	<rfc822;groupwise-linux-nfs@vger.kernel.org:0:0>);
	Fri, 9 Oct 2015 01:56:18 -0400
From: Neil Brown <nfbrown@novell.com>
To: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        "David S. Miller" <davem@davemloft.net>
Date: Fri, 09 Oct 2015 16:56:06 +1100
Cc: "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2] sunrpc: fix waitqueue_active without memory barrier in sunrpc
In-Reply-To: <17EC94B0A072C34B8DCF0D30AD16044A028748C0@BPXM09GP.gisp.nec.co.jp>
References: <17EC94B0A072C34B8DCF0D30AD16044A028748C0@BPXM09GP.gisp.nec.co.jp>
Message-ID: <87h9m04mbt.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

Kosuke Tatsukawa <tatsu@ab.jp.nec.com> writes:

> There are several places in net/sunrpc/svcsock.c which calls
> waitqueue_active() without calling a memory barrier.  Add a memory
> barrier just as in wq_has_sleeper().
>
> I found this issue when I was looking through the linux source code
> for places calling waitqueue_active() before wake_up*(), but without
> preceding memory barriers, after sending a patch to fix a similar
> issue in drivers/tty/n_tty.c  (Details about the original issue can be
> found here: https://lkml.org/lkml/2015/9/28/849).

hi,
this feels like the wrong approach to the problem.  It requires extra
'smb_mb's to be spread around which are hard to understand as easy to
forget.

A quick look seems to suggest that (nearly) every waitqueue_active()
will need an smb_mb.  Could we just put the smb_mb() inside
waitqueue_active()??

Thanks,
NeilBrown


>
> Signed-off-by: Kosuke Tatsukawa <tatsu@ab.jp.nec.com>
> ---
> v2:
>   - Fixed compiler warnings caused by type mismatch
> v1:
>   - https://lkml.org/lkml/2015/10/8/993
> ---
>  net/sunrpc/svcsock.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
>
> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
> index 0c81202..ec19444 100644
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -414,6 +414,7 @@ static void svc_udp_data_ready(struct sock *sk)
>  		set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
>  		svc_xprt_enqueue(&svsk->sk_xprt);
>  	}
> +	smp_mb();
>  	if (wq && waitqueue_active(wq))
>  		wake_up_interruptible(wq);
>  }

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWF1b2AAoJEDnsnt1WYoG5c7gP+gJWVTeDPzIvVBcT2M0rPCTq
RaarohrDV4dBUUiSIUZKN4MOXoelIMCNUCegFTHloU+Vj6htX2UbdhfooF1MEvdt
aTBCv7w1Gmu0PzWiXilqwPqLehDOg4KGuRfz13RTIsQ0+hP/VXcRqzSwwUa5b0Dt
Piw712sqr+BPaNhtw0INpFn86LwOY6Q3im6l8vflG/38cranR1jj4es63/gQHAKM
ZWI5mmnJNQvkAfDexYIbwlBiU0TDczVP1jnoeQIT7BOM8vFIe5iz6386RUaOJKYl
HKlR4zMLSPH/WnO0R72AJg3AaOrbLXxrL6z+Cpph3mauO747S++4Y4MmH1+IwMQG
Z6uqjjnoJ1L+YCie0lKMMNBZRK5/bfyweQo3sRgSu4epDBSHJ6w1NnIJjPS0u4Bg
r3GBTL3qEWIVelmVwJrWR+lPLu0Jklze1RuXBctcpcXCon7PEtMUoxB4U9yQHCiS
Fk61t4+o7E4rvCvSt+4YJ3KAhF2KNT33FwZi5kAkkbXAYSKp1WSFBSP1v9W/elOX
biKzdPsUiLiklog2ZrWUI9nOzN74UBigG2PlTo22abKpx4l4M9F2hvl09Xf/8lXJ
0hgZwnMrRpB0p9+ctMONJxNuQgG7jRP5M+iGoSus/ZQpUmqTePa8chynFL+a8su7
8jsGEpFxR4RGrQvChe/4
=0dw6
-----END PGP SIGNATURE-----
--=-=-=--
