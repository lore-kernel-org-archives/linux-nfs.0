From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 23/51] nfsd41: exchange_id operation
Date: Mon, 17 Nov 2008 16:07:52 +0200
Message-ID: <49217AB8.5080308@panasas.com>
References: <491895A0.3040809@panasas.com> <1226350112-10960-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:12579 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751780AbYKQOH4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 09:07:56 -0500
In-Reply-To: <1226350112-10960-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:48 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> Implement the exchange_id operation confoming to
> http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26
> 
> Based on the client provided name, hash a client id.
> If a confirmed one is found, compare the op's creds and
> verifier.  If the creds match and the verifier is different
> then expire the old client (client re-incarnated), otherwise,
> if both match, assume it's a replay and ignore it.
> 
> If an unconfirmed client is found, then copy the new creds
> and verifer if need update, otherwise assume replay.
> 
> The client is moved to a confirmed state on create_session.
> 
> In the nfs41 branch set the exchange_id flags to
> EXCHGID4_FLAG_USE_NON_PNFS | EXCHGID4_FLAG_SUPP_MOVED_REFER
> (pNFS is not supported, Referrals are supported,
> Migration is not.).
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c        |  113 ++++++++++++++++++++++++++++++++++-
>  fs/nfsd/nfs4xdr.c          |  143 +++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/nfsd/state.h |    4 +
>  include/linux/nfsd/xdr4.h  |    7 ++-
>  4 files changed, 263 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 5c96c39..76b2870 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -781,12 +781,123 @@ out_err:
>  }
>  
>  #if defined(CONFIG_NFSD_V4_1)
> +/*
> + * Set the exchange_id flags returned by the server.
> + */
> +static void
> +nfsd4_set_ex_flags(struct nfs4_client *new, struct nfsd4_exchange_id *clid)
> +{
> +	/* pNFS is not supported */
> +	new->cl_exchange_flags |= EXCHGID4_FLAG_USE_NON_PNFS;
> +
> +	/* Referrals are supported, Migration is not. */
> +	new->cl_exchange_flags |= EXCHGID4_FLAG_SUPP_MOVED_REFER;
> +
> +	/* set the wire flags to return to client. */
> +	clid->flags = new->cl_exchange_flags;
> +}
> +

review 11-13: Andy to add a "TODO" comment.
Document the ramfications of the present implementation
shortcuts we made.
Document server owner implementation.

>  __be32
>  nfsd4_exchange_id(struct svc_rqst *rqstp,
>  		  struct nfsd4_compound_state *cstate,
>  		  struct nfsd4_exchange_id *clid)
>  {
> -	return -1;	/* stub */
> +	struct nfs4_client *unconf, *conf, *new;
> +	int status;
> +	unsigned int		strhashval;
> +	char			dname[HEXDIR_LEN];
> +	nfs4_verifier		verf = clid->verifier;
> +	u32			ip_addr = svc_addr_in(rqstp)->sin_addr.s_addr;
> +	struct xdr_netobj clname = {
> +		.len = clid->id_len,
> +		.data = clid->id,
> +	};
> +
> +	dprintk("%s rqstp=%p clid=%p clname.len=%u clname.data=%p "
> +		" ip_addr=%u flags %x\n",
> +		__func__, rqstp, clid, clname.len, clname.data,
> +		ip_addr, clid->flags);
> +
> +	if (!check_name(clname) || (clid->flags & EXCHGID4_INVAL_FLAG_MASK))
> +		return nfserr_inval;
> +
> +	status = nfs4_make_rec_clidname(dname, &clname);
> +
> +	if (status)
> +		goto error;
> +
> +	strhashval = clientstr_hashval(dname);
> +
> +	nfs4_lock_state();
> +	status = nfserr_clid_inuse;
> +
> +	conf = find_confirmed_client_by_str(dname, strhashval);

review 11-13: pass a minorversion flag down to find_{,un}confirmed_client*()
check cl_exchange_id != 0 for minorversion 1
to logically separate nfs4.0 clients from nfs4.1

> +	if (conf) {
> +		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred) ||
> +		    (ip_addr != conf->cl_addr)) {
> +			/* Client collision: send nfserr_clid_inuse */
> +			goto out;
> +		}
> +
> +		if (!same_verf(&verf, &conf->cl_verifier)) {
> +			/* Client reboot: destroy old state */
> +			expire_client(conf);
> +			goto out_new;
> +		}
> +		/* router replay */

review 11-13: for now just return success.

> +		goto out;
> +	}
> +
> +	unconf  = find_unconfirmed_client_by_str(dname, strhashval);
> +	if (unconf) {
> +		status = nfs_ok;
> +		/* Found an unconfirmed record */
> +		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred)) {
> +			/* Principal changed: update to the new principal
> +			 * and send nfs_ok */
> +			copy_cred(&unconf->cl_cred, &rqstp->rq_cred);
> +		}
> +
> +		if (!same_verf(&unconf->cl_verifier, &verf)) {
> +			/* Reboot before confirmation: update the verifier and
> +			 * send nfs_ok */
> +			copy_verf(unconf, &verf);
> +			new = unconf;
> +			goto out_copy;
> +		}
> +		goto out;
> +	}
> +
> +out_new:
> +	/* Normal case */
> +	status = nfserr_resource;
> +	new = create_client(clname, dname);
> +
> +	if (new == NULL)
> +		goto out;
> +
> +	copy_verf(new, &verf);
> +	copy_cred(&new->cl_cred, &rqstp->rq_cred);
> +	new->cl_addr = ip_addr;
> +	gen_clid(new);
> +	gen_confirm(new);
> +	add_to_unconfirmed(new, strhashval);
> +out_copy:
> +	clid->clientid.cl_boot = new->cl_clientid.cl_boot;
> +	clid->clientid.cl_id = new->cl_clientid.cl_id;
> +
> +	new->cl_seqid = clid->seqid = 1;
> +	nfsd4_set_ex_flags(new, clid);
> +
> +	dprintk("nfsd4_exchange_id seqid %d flags %x\n",
> +		new->cl_seqid, new->cl_exchange_flags);
> +	status = nfs_ok;
> +
> +out:
> +	nfs4_unlock_state();
> +error:
> +	dprintk("nfsd4_exchange_id returns %d\n", ntohl(status));
> +	return status;
>  }
>  
>  __be32
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index fc613cd..055f1ad 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1021,7 +1021,98 @@ static __be32
>  nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
>  			 struct nfsd4_exchange_id *clid)
>  {
> -	return nfserr_opnotsupp;	/* stub */
> +	int dummy;
> +	DECODE_HEAD;
> +
> +	READ_BUF(NFS4_VERIFIER_SIZE);
> +	COPYMEM(clid->verifier.data, NFS4_VERIFIER_SIZE);
> +
> +	READ_BUF(4);
> +	READ32(clid->id_len);
> +
> +	READ_BUF(clid->id_len);
> +	SAVEMEM(clid->id, clid->id_len);
> +
> +	READ_BUF(4);
> +	READ32(clid->flags);
> +
> +	/* Ignore state_protect4_a */
> +	READ_BUF(4);
> +	READ32(dummy);

review 11-13: store sp_how, return NFS4ERR_ENCR_ALG_UNSUPP
error from proc later on.

> +	switch (dummy) {
> +	case SP4_NONE:
> +		break;
> +	case SP4_MACH_CRED:
> +		/* spo_must_enforce */
> +		READ_BUF(4);
> +		READ32(dummy);
> +		READ_BUF(dummy * 4);
> +		p += dummy;
> +
> +		/* spo_must_allow */
> +		READ_BUF(4);
> +		READ32(dummy);
> +		READ_BUF(dummy * 4);
> +		p += dummy;
> +		break;
> +	case SP4_SSV:
> +		/* ssp_ops */
> +		READ_BUF(4);
> +		READ32(dummy);
> +		READ_BUF(dummy * 4);
> +		p += dummy;
> +
> +		READ_BUF(4);
> +		READ32(dummy);
> +		READ_BUF(dummy * 4);
> +		p += dummy;
> +
> +		/* ssp_hash_algs<> */
> +		READ_BUF(4);
> +		READ32(dummy);
> +		READ_BUF(dummy);
> +		p += XDR_QUADLEN(dummy);
> +
> +		/* ssp_encr_algs<> */
> +		READ_BUF(4);
> +		READ32(dummy);
> +		READ_BUF(dummy);
> +		p += XDR_QUADLEN(dummy);
> +
> +		/* ssp_window and ssp_num_gss_handles */
> +		READ_BUF(8);
> +		READ32(dummy);
> +		READ32(dummy);
> +		break;
> +	default:
> +		goto xdr_error;
> +	}
> +
> +	/* Ignore Implementation ID */
> +	READ_BUF(4);    /* nfs_impl_id4 array length */
> +	READ32(dummy);
> +
> +	if (dummy > 1)
> +		goto xdr_error;
> +
> +	if (dummy == 1) {
> +		/* nii_domain */
> +		READ_BUF(4);
> +		READ32(dummy);
> +		READ_BUF(dummy);
> +		p += XDR_QUADLEN(dummy);
> +
> +		/* nii_name */
> +		READ_BUF(4);
> +		READ32(dummy);
> +		READ_BUF(dummy);
> +		p += XDR_QUADLEN(dummy);
> +
> +		/* nii_date */
> +		READ_BUF(12);
> +		p += 3;
> +	}
> +	DECODE_TAIL;
>  }
>  
>  static __be32
> @@ -2692,7 +2783,55 @@ static __be32
>  nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, int nfserr,
>  			 struct nfsd4_exchange_id *exid)
>  {
> -	/* stub */
> +	ENCODE_HEAD;
> +	char *major_id = "fixme_please";
> +	char *server_scope = "fixme_please";
> +	int major_id_sz;
> +	int server_scope_sz;
> +	uint64_t minor_id = 0;

review 11-13: use utsname for major_id (and copy to server_scope)
MUST DO before submitting.

> +
> +	if (nfserr)
> +		goto out;
> +
> +	/* XXX FIXME We currently use ia dummy  as the major id. Need to change
> +	 * this to something more meaningful...
> +	 */
> +	major_id_sz = strlen(major_id);
> +	server_scope_sz = strlen(server_scope);
> +
> +	RESERVE_SPACE(
> +		8 /* eir_clientid */ +
> +		4 /* eir_sequenceid */ +
> +		4 /* eir_flags */ +
> +		4 /* spr_how (SP4_NONE) */ +
> +		8 /* so_minor_id */ +
> +		4 /* so_major_id.len */ +
> +		(XDR_QUADLEN(major_id_sz) * 4) +
> +		4 /* eir_server_scope.len */ +
> +		(XDR_QUADLEN(server_scope_sz) * 4) +
> +		4 /* eir_server_impl_id.count (0) */);
> +
> +	WRITEMEM(&exid->clientid, 8);
> +	WRITE32(exid->seqid);
> +	WRITE32(exid->flags);
> +
> +	/* state_protect4_r */
> +	WRITE32(SP4_NONE);

review 11-13: BUG_ON(sp_how (that we saved previously) != SP4_NONE)

> +
> +	/* The server_owner struct */
> +	WRITE64(minor_id);      /* Minor id */
> +	/* major id */
> +	WRITE32(major_id_sz);
> +	WRITEMEM(major_id, major_id_sz);
> +
> +	/* Server scope */
> +	WRITE32(server_scope_sz);
> +	WRITEMEM(server_scope, server_scope_sz);
> +
> +	/* Implementation id */
> +	WRITE32(0);	/* zero length nfs_impl_id4 array */
> +	ADJUST_ARGS();
> +out:
>  	return nfserr;
>  }
>  
> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> index 5cb4142..9bbfd88 100644
> --- a/include/linux/nfsd/state.h
> +++ b/include/linux/nfsd/state.h
> @@ -214,6 +214,10 @@ struct nfs4_client {
>  	struct nfs4_callback	cl_callback;    /* callback info */
>  	atomic_t		cl_count;	/* ref count */
>  	u32			cl_firststate;	/* recovery dir creation */
> +#if defined(CONFIG_NFSD_V4_1)
> +	u32			cl_seqid;	/* seqid for create_session */
> +	u32			cl_exchange_flags;
> +#endif /* CONFIG_NFSD_V4_1 */
>  };
>  
>  /* struct nfs4_client_reset
> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> index d7dbdab..aee8996 100644
> --- a/include/linux/nfsd/xdr4.h
> +++ b/include/linux/nfsd/xdr4.h
> @@ -354,7 +354,12 @@ struct nfsd4_write {
>  
>  #if defined(CONFIG_NFSD_V4_1)
>  struct nfsd4_exchange_id {
> -	int	foo;	/* stub */
> +	nfs4_verifier	verifier;
> +	u32		id_len;
> +	char		*id;
> +	u32		flags;
> +	clientid_t	clientid;
> +	u32		seqid;
>  };
>  
>  struct nfsd4_create_session {
