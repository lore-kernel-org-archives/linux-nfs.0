Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44679 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2390117AbeGJSkx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Jul 2018 14:40:53 -0400
Subject: Re: [PATCH v2] Handle GARBAGE_ARGS response in rpcbind query
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        libtirpc-devel@lists.sourceforge.net
References: <20180628143422.14145.77695.stgit@klimt.1015granger.net>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <856134b8-c95e-184f-346b-2d77957412a4@RedHat.com>
Date: Tue, 10 Jul 2018 13:23:15 -0400
MIME-Version: 1.0
In-Reply-To: <20180628143422.14145.77695.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/28/2018 10:34 AM, Chuck Lever wrote:
> We have a report that some commercial NFS file servers still do not
> support rpcbind v4 correctly. They return GARBAGE_ARGS instead of
> PROG_MISMATCH or PROG_UNAVAIL, so our rpcbind client now errors out
> immediately instead of trying a lower rpcbind version.
> 
> To address this, convert the "if () else if () else if ()" to a
> switch statement to make it straightforward to add new status codes
> to the error processing logic. Then, add a case for
> RPC_CANTDECODEARGS (the API status code used when the remote
> responds with GARBAGE_ARGS).
> 
> Reported-by: Yuan-Yao Sung <yysung@cs.nctu.edu.tw>
> Fixes: 5e7b57bc20bd ("rpcinfo: change order of version to be ... ")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Tested-by: Yuan-Yao Sung <yysung@cs.nctu.edu.tw>
Committed... 

steved.

> ---
>  src/rpcb_clnt.c |   13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/src/rpcb_clnt.c b/src/rpcb_clnt.c
> index 4b44364..d6fefd0 100644
> --- a/src/rpcb_clnt.c
> +++ b/src/rpcb_clnt.c
> @@ -846,6 +846,7 @@ __rpcb_findaddr_timed(program, version, nconf, host, clpp, tp)
>  	struct netbuf *address = NULL;
>  	rpcvers_t start_vers = RPCBVERS4;
>  	struct netbuf servaddr;
> +	struct rpc_err rpcerr;
>  
>  	/* parameter checking */
>  	if (nconf == NULL) {
> @@ -902,7 +903,8 @@ __rpcb_findaddr_timed(program, version, nconf, host, clpp, tp)
>  		clnt_st = CLNT_CALL(client, (rpcproc_t)RPCBPROC_GETADDR,
>  		    (xdrproc_t) xdr_rpcb, (char *)(void *)&parms,
>  		    (xdrproc_t) xdr_wrapstring, (char *)(void *) &ua, *tp);
> -		if (clnt_st == RPC_SUCCESS) {
> +		switch (clnt_st) {
> +		case RPC_SUCCESS:
>  			if ((ua == NULL) || (ua[0] == 0)) {
>  				/* address unknown */
>  				rpc_createerr.cf_stat = RPC_PROGNOTREGISTERED;
> @@ -924,12 +926,15 @@ __rpcb_findaddr_timed(program, version, nconf, host, clpp, tp)
>  			    (char *)(void *)&servaddr);
>  			__rpc_fixup_addr(address, &servaddr);
>  			goto done;
> -		} else if (clnt_st == RPC_PROGVERSMISMATCH) {
> -			struct rpc_err rpcerr;
> +		case RPC_PROGVERSMISMATCH:
>  			clnt_geterr(client, &rpcerr);
>  			if (rpcerr.re_vers.low > RPCBVERS4)
>  				goto error;  /* a new version, can't handle */
> -		} else if (clnt_st != RPC_PROGUNAVAIL) {
> +			/* Try the next lower version */
> +		case RPC_PROGUNAVAIL:
> +		case RPC_CANTDECODEARGS:
> +			break;
> +		default:
>  			/* Cant handle this error */
>  			rpc_createerr.cf_stat = clnt_st;
>  			clnt_geterr(client, &rpc_createerr.cf_error);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
