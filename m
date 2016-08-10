Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:60561 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932540AbcHJCFk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Aug 2016 22:05:40 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>
Date: Wed, 10 Aug 2016 12:05:31 +1000
Cc: Linux List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Revert "SUNRPC: xs_sock_mark_closed() does not need to trigger socket autoclose"
In-Reply-To: <A059233E-0EFD-472A-9CCB-7BE8411BFC03@primarydata.com>
References: <87a8gtpgw4.fsf@notabene.neil.brown.name> <A059233E-0EFD-472A-9CCB-7BE8411BFC03@primarydata.com>
Message-ID: <87d1lhml90.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 04 2016, Trond Myklebust wrote:

>> On Aug 3, 2016, at 19:33, NeilBrown <neilb@suse.com> wrote:
>>=20
>>=20
>> This reverts commit 4b0ab51db32eba0f48b7618254742f143364a28d.
>>=20
>> This change causes 'rpc.nfsd' to hang for long time if rpcbind is not
>> available.
>> If
>>   --no-nfs-version 2 --no-nfs-version 3
>> is given, the delay is about 6.5 minutes.  When trying to register
>> all versions, the delay is over half an hour.
>> Before this commit, and after reverting it, nfsd fails (when v3 is
>> requested) or succeeds (when only v4 is requested) immediately.
>>=20
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>> net/sunrpc/xprtsock.c | 1 +
>> 1 file changed, 1 insertion(+)
>>=20
>> diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
>> index 111767ab124a..2a938055e95b 100644
>> --- a/net/sunrpc/xprtsock.c
>> +++ b/net/sunrpc/xprtsock.c
>> @@ -795,6 +795,7 @@ static void xs_sock_mark_closed(struct rpc_xprt *xpr=
t)
>> 	xs_sock_reset_connection_flags(xprt);
>> 	/* Mark transport as closed and wake up all pending tasks */
>> 	xprt_disconnect_done(xprt);
>> +	xprt_force_disconnect(xprt);
>> }
>>=20
>
> If there is an outstanding request, then _that_ is supposed to redrive th=
e connection. Why is the xprt_disconnect_done() not functioning as per the =
comment above it?

I made some time to look at this and have a somewhat clearer
understanding.

The rpcbind code makes about 24 requests, include NULL pings, UNSET
requests to clear any old registrations, and SET requests.

The first (a NULL) fails immediately due to ECONNREFUSED.  Others aren't
even attempted for a growing number of seconds because xs_connect()
finds that transport->sock is not NULL, so it delays before trying.
Once it tries, it failed immediately and we move on to the next request.

transport->sock is set to NULL by xs_reset_transport() which xs_connect() c=
alls
as part of the the timeout, but ->reestablish_timeout is not reset.
The next time xs_connect is called, ->sock will be non-NULL again as
transport->reestablish_timeout will be longer.

transport->sock is only set to NULL *before* the test in xs_connect() by a
call to xs_close() or ->close().  But nothing in triggering this.

xs_sock_mark_closed() currently doesn't actually mark the socket as
closed (XPRT_CLOSE_WAITING), or close it directly.

static void xs_sock_mark_closed(struct rpc_xprt *xprt)
{
	xs_sock_reset_connection_flags(xprt);
	/* Mark transport as closed and wake up all pending tasks */
	xprt_disconnect_done(xprt);
}

xs_sock_reset_connection_flags() clears XPRT_CLOSE_WAITING,
XPRT_CLOSING, and XPRT_SOCK_DATA_READY, and adds some memory barrier.

xprt_disconnect_done() clears XPRT_CONNECTED and wakes up the task.

So none of this will "Mark transport as closed" like the comment
suggests.  They just mark it as disconnected.
xs_sock_reset_connection_flags() even *clears* XPRT_CLOSE_WAITING, which
we really want to be set.

The commit said:
=20=20=20
    Under all conditions, it should be quite sufficient just to mark
    the socket as disconnected. It will then be closed by the
    transport shutdown or reconnect code.

The "reconnect code" is presumably xprt_connect()?  This will close the
socket if XPRT_CLOSE_WAIT is set., but not if the socket is marked as
disconnected.  When marked as disconnected, it tries to reconnect -
which incurs a timeout.

The "transport shutdown" code is presumably xprt_destroy()?  Yes, that
would close the socket, but that doesn't straight away.  The rpcbind
client can try 10 UNSET calls before destroying the transport.


It is possible that __svc_unregister should return an error so that
svc_unregister() can abort the loop on error.  That would reduce the
timeouts to some extent, but not completely as we would still get a
timeout when trying to register.  It might make sense that if the
svc_unregister() in svc_rpcb_setup() fails due to ECONNREFUSED, then it
should fail so we never even try to register.  Plumbing that status
through nfsd so that it doesn't abort in the V4-only case when rpcbind
isn't available could be done, but seems like a lot of work for little gain.

Also, the error that comes through to __svc_unregister is "-EAGAIN"
rather then -ECONNREFUSED.

I think that the easiest solution is to make sure reconnection attempts
on an RPC_IS_SOFTCONN tasks do not trigger a delay in xs_connect().
call_connect_status() already adds a 3second delay for other tasks, so
simply forcing a close in xs_sock_marked_close() should be sufficient.
The revert I posted would do that, or we could just add

	set_bit(XPRT_CLOSE_WAIT, &xprt->state);

so that the comment would be correct.  That is sufficient.

Another approach which works is:
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 7f79fb7dc6a0..f80b135b4830 100644
=2D-- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1936,8 +1936,10 @@ call_connect_status(struct rpc_task *task)
 	case -EADDRINUSE:
 	case -ENOBUFS:
 	case -EPIPE:
=2D		if (RPC_IS_SOFTCONN(task))
+		if (RPC_IS_SOFTCONN(task)) {
+			xprt_force_disconnect(task->tk_rqstp->rq_xprt);
 			break;
+		}
 		/* retry with existing socket, after a delay */
 		rpc_delay(task, 3*HZ);
 	case -EAGAIN:

so that we force a disconnect precisely when a connection attempt fails
on a SOFTCONN task.

Which of these solutions do you prefer?

Thanks,
NeilBrown


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXqovsAAoJEDnsnt1WYoG5HpIP/1uxYFiuiMp7qPa1d56nj5df
k5tB+tQuYd1t64slj3pEhdYo44XG6fMlrYXycTjvIqcyFnuVn85mwJHPPiSpnmy/
XwlSnB6lggtypwxj6jTit1CGrf9Sy4NfZQlQ2qYxOebAKD45gR/bwhzAamR2I305
XMzLtLvOE8AElYC5bjM4JY4UTpt/RePb1kW+1c5gicrJAVC7zogTB356bwnUvBNk
Ije/7ImEGuQB9JdfagwWveUFGhPTn2NB1D/N2Vc5eWyZ6+AvncTimtURJOEZdkOu
bL2cYKRYAeSDGTmtk1ngaoEtxigMlrYuaMvDrIgOmQfz+4RFCzxgp3ljfiduYbAN
AdJMN1AlLu7FwO/FzffJzrcRAlv1aue6AYeIM0xF7IyWAoGsUL75n5+PrtwxxHRh
N98/IYG9D/mdJaA3EtEsmp8nLlPf30OwkfvSS3evb+D82zmwXPr9P99l+2nIyr/V
FpAIw8fMm9UDtJjiidlQrwFTaIj4FfqkoBJmJxyR7A6QyctOAHwnNidCYOB/qgrT
nkQ0siM4VX45RFqbJmrxnWKKa9TB8olhIEQOKuFgrQi9ZT1fhwEQyvsJTmrzrUbz
egyBpbOhph8ygCY/H8DoGFqPbTOSzrbs+gGPH7jMBO1SE17qJAQ6uN7bGN1PMDwr
UOw5vg2R/+Xz11/iZObG
=u4Qr
-----END PGP SIGNATURE-----
--=-=-=--
