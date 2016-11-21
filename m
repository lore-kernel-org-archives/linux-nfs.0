Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60078 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752307AbcKUDYZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 20 Nov 2016 22:24:25 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>
Date: Mon, 21 Nov 2016 14:24:17 +1100
Cc: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Revert "SUNRPC: xs_sock_mark_closed() does not need to trigger socket autoclose"
In-Reply-To: <E2DB8B0D-1A5D-49DD-A710-ED26FE328187@primarydata.com>
References: <87a8gtpgw4.fsf@notabene.neil.brown.name> <A059233E-0EFD-472A-9CCB-7BE8411BFC03@primarydata.com> <87d1lhml90.fsf@notabene.neil.brown.name> <E2DB8B0D-1A5D-49DD-A710-ED26FE328187@primarydata.com>
Message-ID: <87lgwdecri.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Sat, Nov 19 2016, Trond Myklebust wrote:

>> On Aug 9, 2016, at 22:05, NeilBrown <neilb@suse.com> wrote:
....
>>=20
>> Another approach which works is:
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index 7f79fb7dc6a0..f80b135b4830 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -1936,8 +1936,10 @@ call_connect_status(struct rpc_task *task)
>> 	case -EADDRINUSE:
>> 	case -ENOBUFS:
>> 	case -EPIPE:
>> -		if (RPC_IS_SOFTCONN(task))
>> +		if (RPC_IS_SOFTCONN(task)) {
>> +			xprt_force_disconnect(task->tk_rqstp->rq_xprt);
>> 			break;
>> +		}
>> 		/* retry with existing socket, after a delay */
>> 		rpc_delay(task, 3*HZ);
>> 	case -EAGAIN:
>>=20
>> so that we force a disconnect precisely when a connection attempt fails
>> on a SOFTCONN task.
>>=20
>> Which of these solutions do you prefer?
>
>
> Instead of the above, could we rather look at adding a call to xprt_condi=
tional_disconnect() to ensure that we don=E2=80=99t keep disconnecting mult=
iple times? It means we=E2=80=99d have to set req->rq_connect_cookie in xpr=
t_connect() before sleeping on xprt->pending, but I don=E2=80=99t think tha=
t is a major imposition.
>
> I also think we might not want to make that call conditional on RPC_IS_SO=
FTCONN.

Something like this maybe?

Just using xprt_conditional_disconnect() doesn't work as it does
nothing when !xprt_connected(xprt).
I commented out that test and then the change works.  I don't know if
that is what you want though.

Thanks,
NeilBrown


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
index 685e6d225414..52007d018135 100644
=2D-- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -669,7 +669,7 @@ void xprt_conditional_disconnect(struct rpc_xprt *xprt,=
 unsigned int cookie)
 	spin_lock_bh(&xprt->transport_lock);
 	if (cookie !=3D xprt->connect_cookie)
 		goto out;
=2D	if (test_bit(XPRT_CLOSING, &xprt->state) || !xprt_connected(xprt))
+	if (test_bit(XPRT_CLOSING, &xprt->state) /*|| !xprt_connected(xprt)*/)
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

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYMmjhAAoJEDnsnt1WYoG5ovQQAITfMLQaacZt6yYCIQ6jNI8O
gEMDwLpTxPybjpBRQD2gXcj6Bt78lS1LQOgHeJ3qgzLklJnUPMVefpHqWSMjHCbb
eS2VO/qcjZhc7ktmkwxEGjIrLthU/RqV0okipcTmkoWY5Zk25F8dWRRT2F2UPgdI
EgKjalH200L/ulOaRwtYwucvHEYXVZtO1bDNeUqrCA/aOQ2vTtCGktMWwqivWh4/
V7rJUOFQlz0Y0rO71Ru5fhnOTgF5UHsOhN+m2OQDkBkHSQzV4ngX3SublBQS47HM
s9xGXO3DMgaZCJLX3blPPItBsCzSc4B6qlucXWUn2c4R6DzHkObiMlMzjLn+jCsm
9LBLYUd9K6letLR8Yfse+l212JPak26zPhB9sS9pGWZIKL8Wxmao3/V6IxhcLIZ5
iRhSnMB+XXWqs6cHoNmGqRMtBztrTlav47tItnZTxqjAtpFF5NGL2gfY3Fb6oy9O
XOMhs87OWOAvf6W94j8fkSdzJAwj1NcxmxbARZhMtEKT3sS/zdx95svwXrIWOASg
diGY9LSGlez4v/KCEpFlJbFCk1MqcvvfzQO0dw1oFaJ+1R2X8EPO/CUHTcdqNt6m
xKZhZlh1bogv0cbCLxx8u9pxnCwNjJo/Hiq4Pez7kE9qZiF5ojh5Bx+IHM5Gr374
hqg2v0BX4BFXp5/Aa0rR
=x5W1
-----END PGP SIGNATURE-----
--=-=-=--
