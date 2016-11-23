Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:58728 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755463AbcKWDpH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 22 Nov 2016 22:45:07 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>
Date: Wed, 23 Nov 2016 14:44:58 +1100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] sunrpc: Don't engage exponential backoff when connection
 attempt is rejected.
Message-ID: <87r362c11h.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


xs_connect() contains an exponential backoff mechanism so the repeated
connection attempts are delayed by longer and longer amounts.

This is appropriate when the connection failed due to a timeout, but
it not appropriate when a definitive "no" answer is received.  In such
cases, call_connect_status() imposes a minimum 3-second back-off, so
not having the exponetial back-off will never result in immediate
retries.

The current situation is a problem when the NFS server tries to
register with rpcbind but rpcbind isn't running.  All connection
attempts are made on the same "xprt" and as the connection is never
"closed", the exponential back delays successive attempts to register,
or de-register, different protocols.  This results in a multi-minute
delay with no benefit.

So, when call_connect_status() receives a definitive "no", use
xprt_conditional_disconnect() to cancel the previous connection attempt.
This will set XPRT_CLOSE_WAIT so that xprt->ops->close() calls xs_close()
which resets the reestablish_timeout.

To ensure xprt_conditional_disconnect() does the right thing, we
ensure that rq_connect_cookie is set before a connection attempt, and
allow xprt_conditional_disconnect() to complete even when the
transport is not fully connected.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 net/sunrpc/clnt.c | 2 ++
 net/sunrpc/xprt.c | 3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index b31ca97e754e..53acd4e3a317 100644
=2D-- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1926,6 +1926,8 @@ call_connect_status(struct rpc_task *task)
 	case -EADDRINUSE:
 	case -ENOBUFS:
 	case -EPIPE:
+		xprt_conditional_disconnect(task->tk_rqstp->rq_xprt,
+					    task->tk_rqstp->rq_connect_cookie);
 		if (RPC_IS_SOFTCONN(task))
 			break;
 		/* retry with existing socket, after a delay */
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 685e6d225414..9a6be030ca7d 100644
=2D-- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -669,7 +669,7 @@ void xprt_conditional_disconnect(struct rpc_xprt *xprt,=
 unsigned int cookie)
 	spin_lock_bh(&xprt->transport_lock);
 	if (cookie !=3D xprt->connect_cookie)
 		goto out;
=2D	if (test_bit(XPRT_CLOSING, &xprt->state) || !xprt_connected(xprt))
+	if (test_bit(XPRT_CLOSING, &xprt->state))
 		goto out;
 	set_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	/* Try to schedule an autoclose RPC call */
@@ -772,6 +772,7 @@ void xprt_connect(struct rpc_task *task)
 	if (!xprt_connected(xprt)) {
 		task->tk_rqstp->rq_bytes_sent =3D 0;
 		task->tk_timeout =3D task->tk_rqstp->rq_timeout;
+		task->tk_rqstp->rq_connect_cookie =3D xprt->connect_cookie;
 		rpc_sleep_on(&xprt->pending, task, xprt_connect_status);
=20
 		if (test_bit(XPRT_CLOSING, &xprt->state))
=2D-=20
2.10.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYNRC7AAoJEDnsnt1WYoG5ww4P/ivUcQxyrzA+oHNis759tbom
dmD4Z1E4wzJikLw3Wd3hQPpH+UWMk+4g1C54FLPr5kYnXX+aLyGuY389mz0uJhD6
6HHd3ZUVJ5eENuSJrMo0DZYvZfaZDKAynJ/pqO2U1o+ZM8O+wmWPnjJ6xw0LV8q/
r73BDVYCVtQecY+58OtqPO8zYuQI4R1o4oV/4jQU4uI4VBE2M5tVPIoR2zGqdXGf
uOsJx96KGP7q8ASF7rvtzknnNIDAl6gZGYXhXICK29s+UhemFvrCxqDXd0RLYJHw
fYnwZIP2F4XTO2vtqfICtikO1/WU0slWCTx0BKwrpkhxLQYC0+1RLq2hIkZ46jwW
ieckbOp+V7NQvyZAKy7+OAhMGL+CF2+qdcS2FO1cxwv8VNC0Hg8FYNIPkPyKsE2a
PqkntTFqOrEYVZyr11ntalaKgh5W4pK4XjbywlcgV3+hlTFdgsX0vNswFDfezBIp
g5Vw0CKdGqlvV3gNMzXgmpzS2OtZjP4HZb3L5WxIoO3ym99Qhdu2JY1Q+hBr+H3j
0uqTCp0KqHB6prOL9Dxur82Fef4zUag1aZ8ZdwtoO2v3M+n14wFyf2dRt2JQevLM
C6ghLRXCKBHzNILguDxuZBUroJlOaSFnMo05eBEmMDI5R4w4lEhe4jpSFzswhacE
yDymwgvi5WvnhH11Gyrv
=e5qM
-----END PGP SIGNATURE-----
--=-=-=--
