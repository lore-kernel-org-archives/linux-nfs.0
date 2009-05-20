From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [RFC 11/11] nfsd41: Refactor create_client()
Date: Wed, 20 May 2009 11:18:42 +0300
Message-ID: <4A13BCE2.1070303@panasas.com>
References: <273FE88A07F5D445824060902F70034405CEB64D@SACMVEXC1-PRD.hq.netapp.com> <1242788428-18723-1-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-2-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-3-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-4-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-5-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-6-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-7-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-8-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-9-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-10-git-send-email-Ricardo.Labiaga@netapp.com> <1242788428-18723-11-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bfields@fieldses.org, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:26339 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752811AbZETITh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 May 2009 04:19:37 -0400
In-Reply-To: <1242788428-18723-11-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ricardo, this patch conflicts with Andy's DRC changes.
I'm not sure who'll go first into Bruce's branch but
the other guy will need to rebase his patches accordingly...

Benny

On May. 20, 2009, 6:00 +0300, Ricardo Labiaga <Ricardo.Labiaga@netapp.com> wrote:
> Move common initialization of 'struct nfs4_client' inside create_client().
> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> 
> [nfsd41: Remember the auth flavor to use for callbacks]
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c |   90 +++++++++++++++++++++++++-------------------------
>  1 files changed, 45 insertions(+), 45 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 45cbbbc..1e4740f 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -710,27 +710,6 @@ expire_client(struct nfs4_client *clp)
>  	put_nfs4_client(clp);
>  }
>  
> -static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir)
> -{
> -	struct nfs4_client *clp;
> -
> -	clp = alloc_client(name);
> -	if (clp == NULL)
> -		return NULL;
> -	memcpy(clp->cl_recdir, recdir, HEXDIR_LEN);
> -	atomic_set(&clp->cl_count, 1);
> -	atomic_set(&clp->cl_cb_conn.cb_set, 0);
> -	INIT_LIST_HEAD(&clp->cl_idhash);
> -	INIT_LIST_HEAD(&clp->cl_strhash);
> -	INIT_LIST_HEAD(&clp->cl_openowners);
> -	INIT_LIST_HEAD(&clp->cl_delegations);
> -	INIT_LIST_HEAD(&clp->cl_sessions);
> -	INIT_LIST_HEAD(&clp->cl_lru);
> -	clear_bit(0, &clp->cl_cb_slot_busy);
> -	rpc_init_wait_queue(&clp->cl_cb_waitq, "Backchannel slot table");
> -	return clp;
> -}
> -
>  static void copy_verf(struct nfs4_client *target, nfs4_verifier *source)
>  {
>  	memcpy(target->cl_verifier.data, source->data,
> @@ -793,6 +772,46 @@ static void gen_confirm(struct nfs4_client *clp)
>  	*p++ = i++;
>  }
>  
> +static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
> +		struct svc_rqst *rqstp, nfs4_verifier *verf)
> +{
> +	struct nfs4_client *clp;
> +	u32 ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
> +	char *princ;
> +
> +	clp = alloc_client(name);
> +	if (clp == NULL)
> +		return NULL;
> +
> +	princ = svc_gss_principal(rqstp);
> +	if (princ) {
> +		clp->cl_principal = kstrdup(princ, GFP_KERNEL);
> +		if (clp->cl_principal == NULL) {
> +			free_client(clp);
> +			return NULL;
> +		}
> +	}
> +
> +	memcpy(clp->cl_recdir, recdir, HEXDIR_LEN);
> +	atomic_set(&clp->cl_count, 1);
> +	atomic_set(&clp->cl_cb_conn.cb_set, 0);
> +	INIT_LIST_HEAD(&clp->cl_idhash);
> +	INIT_LIST_HEAD(&clp->cl_strhash);
> +	INIT_LIST_HEAD(&clp->cl_openowners);
> +	INIT_LIST_HEAD(&clp->cl_delegations);
> +	INIT_LIST_HEAD(&clp->cl_sessions);
> +	INIT_LIST_HEAD(&clp->cl_lru);
> +	clear_bit(0, &clp->cl_cb_slot_busy);
> +	rpc_init_wait_queue(&clp->cl_cb_waitq, "Backchannel slot table");
> +	copy_verf(clp, verf);
> +	clp->cl_addr = ip_addr;
> +	clp->cl_flavor = rqstp->rq_flavor;
> +	copy_cred(&clp->cl_cred, &rqstp->rq_cred);
> +	gen_confirm(clp);
> +
> +	return clp;
> +}
> +
>  static int check_name(struct xdr_netobj name)
>  {
>  	if (name.len == 0) 
> @@ -1285,17 +1304,13 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
>  
>  out_new:
>  	/* Normal case */
> -	new = create_client(exid->clname, dname);
> +	new = create_client(exid->clname, dname, rqstp, &verf);
>  	if (new == NULL) {
>  		status = nfserr_resource;
>  		goto out;
>  	}
>  
> -	copy_verf(new, &verf);
> -	copy_cred(&new->cl_cred, &rqstp->rq_cred);
> -	new->cl_addr = ip_addr;
>  	gen_clid(new);
> -	gen_confirm(new);
>  	add_to_unconfirmed(new, strhashval);
>  out_copy:
>  	exid->clientid.cl_boot = new->cl_clientid.cl_boot;
> @@ -1535,7 +1550,6 @@ __be32
>  nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		  struct nfsd4_setclientid *setclid)
>  {
> -	struct sockaddr_in	*sin = svc_addr_in(rqstp);
>  	struct xdr_netobj 	clname = { 
>  		.len = setclid->se_namelen,
>  		.data = setclid->se_name,
> @@ -1544,7 +1558,6 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  	unsigned int 		strhashval;
>  	struct nfs4_client	*conf, *unconf, *new;
>  	__be32 			status;
> -	char			*princ;
>  	char                    dname[HEXDIR_LEN];
>  	
>  	if (!check_name(clname))
> @@ -1586,7 +1599,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		 */
>  		if (unconf)
>  			expire_client(unconf);
> -		new = create_client(clname, dname);
> +		new = create_client(clname, dname, rqstp, &clverifier);
>  		if (new == NULL)
>  			goto out;
>  		gen_clid(new);
> @@ -1603,7 +1616,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  			 */
>  			expire_client(unconf);
>  		}
> -		new = create_client(clname, dname);
> +		new = create_client(clname, dname, rqstp, &clverifier);
>  		if (new == NULL)
>  			goto out;
>  		copy_clid(new, conf);
> @@ -1613,7 +1626,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		 * probable client reboot; state will be removed if
>  		 * confirmed.
>  		 */
> -		new = create_client(clname, dname);
> +		new = create_client(clname, dname, rqstp, &clverifier);
>  		if (new == NULL)
>  			goto out;
>  		gen_clid(new);
> @@ -1624,24 +1637,11 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  		 * confirmed.
>  		 */
>  		expire_client(unconf);
> -		new = create_client(clname, dname);
> +		new = create_client(clname, dname, rqstp, &clverifier);
>  		if (new == NULL)
>  			goto out;
>  		gen_clid(new);
>  	}
> -	copy_verf(new, &clverifier);
> -	new->cl_addr = sin->sin_addr.s_addr;
> -	new->cl_flavor = rqstp->rq_flavor;
> -	princ = svc_gss_principal(rqstp);
> -	if (princ) {
> -		new->cl_principal = kstrdup(princ, GFP_KERNEL);
> -		if (new->cl_principal == NULL) {
> -			free_client(new);
> -			goto out;
> -		}
> -	}
> -	copy_cred(&new->cl_cred, &rqstp->rq_cred);
> -	gen_confirm(new);
>  	gen_callback(new, setclid);
>  	add_to_unconfirmed(new, strhashval);
>  	setclid->se_clientid.cl_boot = new->cl_clientid.cl_boot;
