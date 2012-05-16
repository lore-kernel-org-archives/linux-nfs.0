Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19630 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754330Ab2EPBcm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 May 2012 21:32:42 -0400
Date: Tue, 15 May 2012 21:32:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] NFSD: SETCLIENTID_CONFIRM returns NFS4ERR_CLID_INUSE
 too often
Message-ID: <20120516013239.GA24133@pad.fieldses.org>
References: <20120515213808.1518.81260.stgit@lebasque.1015granger.net>
 <20120515214207.1518.78590.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120515214207.1518.78590.stgit@lebasque.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 15, 2012 at 05:42:08PM -0400, Chuck Lever wrote:
> According to RFC 3530bis, the only items SETCLIENTID_CONFIRM
> processing should be concerned with is the clientid, clientid
> verifier, and authentication flavor.

Nit: the spec says "principal", not "authentication flavor".

(I was looking at this yesterday because our current code only compares
uid's, which is pretty meaningless--any client using a krb5 service
principal, for example, will likely get mapped to the same uid--so I
have patches that instead compare flavor, principal name (when we have
it--our current userspace only passes it down for service principals)
and groups and auxiliary groups as well as uid.  But not IP address...)

Anyway, this patch looks reasonable, thanks.

--b.

> The client's IP address
> is not supposed to be interesting.
> 
> And, NFS4ERR_CLID_INUSE is meant only for authentication flavor
> mismatches.
> 
> I triggered this logic with a prototype UCS client -- one that
> uses the same nfs_client_id4 string for all servers.  The client
> mounted our server via its IPv4, then via its IPv6 address.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  fs/nfsd/nfs4state.c |   14 ++------------
>  1 files changed, 2 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 7f71c69..27e6401 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2213,7 +2213,6 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
>  			 struct nfsd4_compound_state *cstate,
>  			 struct nfsd4_setclientid_confirm *setclientid_confirm)
>  {
> -	struct sockaddr *sa = svc_addr(rqstp);
>  	struct nfs4_client *conf, *unconf;
>  	nfs4_verifier confirm = setclientid_confirm->sc_confirm; 
>  	clientid_t * clid = &setclientid_confirm->sc_clientid;
> @@ -2231,17 +2230,12 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
>  	conf = find_confirmed_client(clid);
>  	unconf = find_unconfirmed_client(clid);
>  
> -	status = nfserr_clid_inuse;
> -	if (conf && !rpc_cmp_addr((struct sockaddr *) &conf->cl_addr, sa))
> -		goto out;
> -	if (unconf && !rpc_cmp_addr((struct sockaddr *) &unconf->cl_addr, sa))
> -		goto out;
> -
>  	/*
>  	 * section 14.2.34 of RFC 3530 has a description of
>  	 * SETCLIENTID_CONFIRM request processing consisting
>  	 * of 4 bullet points, labeled as CASE1 - CASE4 below.
>  	 */
> +	status = nfserr_clid_inuse;
>  	if (conf && unconf && same_verf(&confirm, &unconf->cl_confirm)) {
>  		/*
>  		 * RFC 3530 14.2.34 CASE 1:
> @@ -2254,7 +2248,6 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
>  			nfsd4_probe_callback(conf);
>  			expire_client(unconf);
>  			status = nfs_ok;
> -
>  		}
>  	} else if (conf && !unconf) {
>  		/*
> @@ -2296,11 +2289,8 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
>  		 * Client probably hasn't noticed that we rebooted yet.
>  		 */
>  		status = nfserr_stale_clientid;
> -	} else {
> -		/* check that we have hit one of the cases...*/
> -		status = nfserr_clid_inuse;
>  	}
> -out:
> +
>  	nfs4_unlock_state();
>  	return status;
>  }
> 
