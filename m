Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42303 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750822AbdGSEFR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Jul 2017 00:05:17 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Wed, 19 Jul 2017 14:05:01 +1000
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] net/sunrpc/xprt_sock: fix regression in connection error reporting.
Message-ID: <87r2xdxeaa.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Commit 3d4762639dd3 ("tcp: remove poll() flakes when receiving
RST") in v4.12 changed the order in which ->sk_state_change()
and ->sk_error_report() are called when a socket is shut
down - sk_state_change() is now called first.

This causes xs_tcp_state_change() -> xs_sock_mark_closed() ->
xprt_disconnect_done() to wake all pending tasked with -EAGAIN.
When the ->sk_error_report() callback arrives, it is too late to
pass the error on, and it is lost.

As easy way to demonstrate the problem caused is to try to start
rpc.nfsd while rcpbind isn't running.
nfsd will attempt a tcp connection to rpcbind.  A ECONNREFUSED
error is returned, but sunrpc code loses the error and keeps
retrying.  If it saw the ECONNREFUSED, it would abort.

To fix this, handle the sk->sk_err in the TCP_CLOSE branch of
xs_tcp_state_change().

Fixes: 3d4762639dd3 ("tcp: remove poll() flakes when receiving RST")
Cc: stable@vger.kernel.org (v4.12)
Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 net/sunrpc/xprtsock.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d5b54c020dec..4f154d388748 100644
=2D-- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1624,6 +1624,8 @@ static void xs_tcp_state_change(struct sock *sk)
 		if (test_and_clear_bit(XPRT_SOCK_CONNECTING,
 					&transport->sock_state))
 			xprt_clear_connecting(xprt);
+		if (sk->sk_err)
+			xprt_wake_pending_tasks(xprt, -sk->sk_err);
 		xs_sock_mark_closed(xprt);
 	}
  out:
=2D-=20
2.12.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAllu2nAACgkQOeye3VZi
gbmeZA//Q8wtVydWnaSmch48kUWOy8LYkVv1uHUVm7vTce+4Sd9321lgkgAOI+Cc
h8s6AipYKGTFyBm/Kssii+Oa33F4+TT+9NBP7GDf7j/5b/vq35ozR/Xmc+Ra+xJW
FC++eibIl6YDnZH2S918mgt29qBpomvPF/YN0itlfIatPiZ3OpNMa4a54vz2s6JA
5TcfZJJoAvSvm9RbF7/5eQs1YkxpvvYnVw+6k+QNHLEkUAqZOKqp1dYXFjayofz3
27QzvwDvzuPHG3ikhacypRbhkVDwc0zgXADDEnXX6vEQyHy9MlRZSS3q4yBYukvT
HlhMydrHaaa/ZfGE8LSZKXz5fJMFGf9GkEIw8DCR4g1dYuysTU/avvtX1n4kOeDE
bWsCcsW8ZJ6fD0Cer7eEUEyAsDNdoXPV+a9LFfDsD6skB/heJ2UsIPdWGXQG59Mc
ZA1KiiUPjw8xvFzyX4uliukXbCLvi+IsFIQhvGPaAMzzLLrS3NTBTam98WvuEiOQ
EM5guYgf2OR455egWtCLONB/DfXQUS7mb4QVxUQLHJ3T+yQrrUYN+6dS2sWwGESx
Ny5jbNjdJdMPSSsj8arVjQ1kDsypA11trxf8kZYlnBvY+JApXeo7ifn4eTei+98j
snwod/PiazgGC0GPWN6p09+v3UrJ7qh0sXgaP+fUGj2IMVlCseI=
=AsPR
-----END PGP SIGNATURE-----
--=-=-=--
