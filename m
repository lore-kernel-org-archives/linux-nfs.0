Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:42612 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932253AbcHDCko (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2016 22:40:44 -0400
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trondmy@primarydata.com>
Date: Thu, 04 Aug 2016 12:35:50 +1000
Cc: Linux List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Revert "SUNRPC: xs_sock_mark_closed() does not need to trigger socket autoclose"
In-Reply-To: <A059233E-0EFD-472A-9CCB-7BE8411BFC03@primarydata.com>
References: <87a8gtpgw4.fsf@notabene.neil.brown.name> <A059233E-0EFD-472A-9CCB-7BE8411BFC03@primarydata.com>
Message-ID: <871t25p8ft.fsf@notabene.neil.brown.name>
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

No idea, sorry.  I haven't tried to follow though exactly what is
happening.
The symptom is trivial to reproduce:
  rpc.nfsd 0
  killall rpcbind
  rpc.nfsd 8

This will either complete immediately with kernel log messages, or block
for a long time.
I might try to figure out what is happening, but I suspect there are
others who know this code a lot better than I do.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXoqoGAAoJEDnsnt1WYoG5fdYP/R16AtggM8uPOzEBuPzazmY7
7DYxKg080XZdZvjVR4ynnjSUrTLscwLpeMKFicTxpoORYiPAVT+/tQ01MvGiODbc
6jgJfZh0jiBrV1zs39YA3EIMzJcHYI2LHRYfJRDwq8sCCkjUBaQv4VBN8CdoBFF9
fFO/cFfkMksJuwOHT1tgcBOqB0cUDoZkFFP/3Zm7I5+g5Mf0JP3btQvd9R7f9Kf6
RwmMOfT6iTsPVO5iGxaaq2WVgviX38FlnU+u6Rh2pHdih8OODk/iLvYhS4nu/u9y
aUaY4EuiJzzBaatlFSIH95AuLrA6sJ02w/eivUhhp3IX4dxJMsEcscKBFUsc5PQu
kaTEIXKqGdZZOQaq+piles7z0+UKGHJaaAq87kTDFS/E0IxddUx45CbMqA/xbfKA
3EpjGcrpkZtADqnIX8CWtnXiBiatVyj3v+cMgxeZ3T21qHTb9cRx2ff5NXXGX1so
DTkdcspeohsWsEDx8KqW57cb/K43bzASQUfalaK0iZcUeE3FCN32Hxwd7+MmL6wS
hgGVVXa96DqsHPV0ZshjKGnQ8feIuuL56MbEnaImVv7CjUKSpSDvoA+cJmWCpwTt
txXVoho3VCMdVPxqB15nL4FVNBQVqxvZ4bX4YBiHt2wDGcmCP3oxNvIQ0/L5tSEJ
Vz2rVLP+lpntHzHTQf/L
=sW50
-----END PGP SIGNATURE-----
--=-=-=--
