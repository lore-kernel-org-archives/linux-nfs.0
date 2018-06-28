Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:57222 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966209AbeF1O34 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jun 2018 10:29:56 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.4 \(3445.8.2\))
Subject: Re: [PATCH] Handle RPC_CANTDECODEARGS response in rpcbind query
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <b4786b94c7a2fc3c30e09e317b3bdb3855203469.camel@hammerspace.com>
Date: Thu, 28 Jun 2018 10:29:41 -0400
Cc: libtirpc List <libtirpc-devel@lists.sourceforge.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <99AF8F3B-CD0A-4234-9341-E1C2A85F58DC@oracle.com>
References: <20180628134503.13942.25482.stgit@klimt.1015granger.net>
 <b4786b94c7a2fc3c30e09e317b3bdb3855203469.camel@hammerspace.com>
To: Trond Myklebust <trondmy@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jun 28, 2018, at 10:17 AM, Trond Myklebust =
<trondmy@hammerspace.com> wrote:
>=20
> On Thu, 2018-06-28 at 09:45 -0400, Chuck Lever wrote:
>> We have a report that some commercial NFS file servers still do not
>> support rpcbind v4 correctly. They return RPC_CANTDECODEARGS instead
>> of RPC_PROGVERSMISMATCH, so our rpcbind client now errors out
>> immediately instead of trying a lower rpcbind version.
>>=20
>> To address this, convert the "if () else if () else if ()" to a
>> switch statement to make it straightforward to add new status codes
>> to the error processing logic. Then, add a case for
>> RPC_CANTDECODEARGS.
>>=20
>> Reported-by: Yuan-Yao Sung <yysung@cs.nctu.edu.tw>
>> Fixes: 5e7b57bc20bd ("rpcinfo: change order of version to be ... ")
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> Tested-by: Yuan-Yao Sung <yysung@cs.nctu.edu.tw>
>> ---
>> src/rpcb_clnt.c |   13 +++++++++----
>> 1 file changed, 9 insertions(+), 4 deletions(-)
>>=20
>> diff --git a/src/rpcb_clnt.c b/src/rpcb_clnt.c
>> index 4b44364..d6fefd0 100644
>> --- a/src/rpcb_clnt.c
>> +++ b/src/rpcb_clnt.c
>> @@ -846,6 +846,7 @@ __rpcb_findaddr_timed(program, version, nconf,
>> host, clpp, tp)
>> 	struct netbuf *address =3D NULL;
>> 	rpcvers_t start_vers =3D RPCBVERS4;
>> 	struct netbuf servaddr;
>> +	struct rpc_err rpcerr;
>>=20
>> 	/* parameter checking */
>> 	if (nconf =3D=3D NULL) {
>> @@ -902,7 +903,8 @@ __rpcb_findaddr_timed(program, version, nconf,
>> host, clpp, tp)
>> 		clnt_st =3D CLNT_CALL(client,
>> (rpcproc_t)RPCBPROC_GETADDR,
>> 		    (xdrproc_t) xdr_rpcb, (char *)(void *)&parms,
>> 		    (xdrproc_t) xdr_wrapstring, (char *)(void *)
>> &ua, *tp);
>> -		if (clnt_st =3D=3D RPC_SUCCESS) {
>> +		switch (clnt_st) {
>> +		case RPC_SUCCESS:
>> 			if ((ua =3D=3D NULL) || (ua[0] =3D=3D 0)) {
>> 				/* address unknown */
>> 				rpc_createerr.cf_stat =3D
>> RPC_PROGNOTREGISTERED;
>> @@ -924,12 +926,15 @@ __rpcb_findaddr_timed(program, version, nconf,
>> host, clpp, tp)
>> 			    (char *)(void *)&servaddr);
>> 			__rpc_fixup_addr(address, &servaddr);
>> 			goto done;
>> -		} else if (clnt_st =3D=3D RPC_PROGVERSMISMATCH) {
>> -			struct rpc_err rpcerr;
>> +		case RPC_PROGVERSMISMATCH:
>> 			clnt_geterr(client, &rpcerr);
>> 			if (rpcerr.re_vers.low > RPCBVERS4)
>> 				goto error;  /* a new version, can't
>> handle */
>> -		} else if (clnt_st !=3D RPC_PROGUNAVAIL) {
>> +			/* Try the next lower version */
>> +		case RPC_PROGUNAVAIL:
>> +		case RPC_CANTDECODEARGS:
>> +			break;
>> +		default:
>> 			/* Cant handle this error */
>> 			rpc_createerr.cf_stat =3D clnt_st;
>> 			clnt_geterr(client,
>> &rpc_createerr.cf_error);
>>=20
>> --
>=20
> Interesting... Do these servers return any other non-sanctioned =
errors?

It's a NetApp filer. GARBAGE_ARGS is what goes on the wire.


> I can't find RPC_CANTDECODEARGS described in any of the official RFCs
> pertaining to RPC, NFS or the RPCBIND protocol. It appears to be =
listed
> among the private error codes in the libtirpc header files, and in =
some
> java libraries, but googling around appeared to indicate that those
> codes are intended for internal library signaling only, and should not
> appear on the wire:
>=20
> https://people.eecs.berkeley.edu/~jonah/javadoc/org/acplt/oncrpc/OncRp
> cException.html

RPC_CANTDECODEARGS is part of the public RPC API, it doesn't go on
the wire.

I will fix the patch description and resend.


--
Chuck Lever



