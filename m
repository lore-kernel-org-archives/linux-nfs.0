Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:17377 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755428Ab3DXRLW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2013 13:11:22 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH] nfsd4: implement minimal SP4_MACH_CRED
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130424155748.GH20275@fieldses.org>
Date: Wed, 24 Apr 2013 13:11:10 -0400
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trond@netapp.com>
Message-Id: <945737E0-AD51-4170-BFAA-971614A5993F@oracle.com>
References: <20130424154447.GG20275@fieldses.org> <20130424155748.GH20275@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 24, 2013, at 11:57 AM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Apr 24, 2013 at 11:44:47AM -0400, bfields wrote:
>> From: "J. Bruce Fields" <bfields@redhat.com>
>> 
>> Do a minimal SP4_MACH_CRED implementation suggested by Trond, ignoring
>> the client-provided spo_must_* arrays and just enforcing credential
>> checks for the minimum required operations.
>> 
>> Note also that this assumes krb5.  This works in practice, since that's
>> the only gss mechanism we support, but we should really pass around a
>> gss mechanism and make this general.
>> 
>> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>> ---
>> fs/nfsd/nfs4state.c |   64 ++++++++++++++++++++++++++++++++++++++++-----------
>> fs/nfsd/nfs4xdr.c   |   23 ++++++++++++++++++
>> fs/nfsd/state.h     |    1 +
>> 3 files changed, 75 insertions(+), 13 deletions(-)
>> 
>> More of an rfc for now, mostly untested.
>> 
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index a964a17..bd7acd2 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -1267,6 +1267,20 @@ same_creds(struct svc_cred *cr1, struct svc_cred *cr2)
>> 	return 0 == strcmp(cr1->cr_principal, cr2->cr_principal);
>> }
>> 
>> +static bool mach_creds_match(struct nfs4_client *cl, struct svc_rqst *rqstp)
>> +{
>> +	struct svc_cred *cr = &rqstp->rq_cred;
>> +	if (!cl->cl_mach_cred)
>> +		return true;
>> +	/* XXX: more general test for integrity or privacy needed: */
>> +	if (!cr->cr_flavor == RPC_AUTH_GSS_KRB5I &&
>> +	    !cr->cr_flavor == RPC_AUTH_GSS_KRB5P)
>> +		return false;
> 
> So obviously this all assumes kerberos.
> 
> What we're actually supposed to check is that a) the mechanism matches,
> b) the service is integrity or privacy, c) the principal matches.
> 
> So I guess what I actually want to do is store a reference to the struct
> gss_api_mech, compare that, and check the service with
> gss_pseudoflavor_to_service()?
> 
> Not sure if your patches change how any of that's done, Chuck.

If the full GSS tuple is available for this check, it probably should be used, I suspect.

Once Trond has merged my RPCGSS-related work for 3.10, I'll send you the three server-side patches for 3.11 that make use of these new APIs.  We can discuss any changes you might like in this area at that time.

> 
> --b.
> 
>> +	if (!cr->cr_principal)
>> +		return false;
>> +	return 0 == strcmp(cl->cl_cred.cr_principal, cr->cr_principal);
>> +}
>> +
>> static void gen_clid(struct nfs4_client *clp, struct nfsd_net *nn)
>> {
>> 	static u32 current_clientid = 1;
>> @@ -1644,16 +1658,14 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
>> 	if (exid->flags & ~EXCHGID4_FLAG_MASK_A)
>> 		return nfserr_inval;
>> 
>> -	/* Currently only support SP4_NONE */
>> 	switch (exid->spa_how) {
>> +	case SP4_MACH_CRED:
>> 	case SP4_NONE:
>> 		break;
>> 	default:				/* checked by xdr code */
>> 		WARN_ON_ONCE(1);
>> 	case SP4_SSV:
>> 		return nfserr_encr_alg_unsupp;
>> -	case SP4_MACH_CRED:
>> -		return nfserr_serverfault;	/* no excuse :-/ */
>> 	}
>> 
>> 	/* Cases below refer to rfc 5661 section 18.35.4: */
>> @@ -1668,6 +1680,10 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
>> 				status = nfserr_inval;
>> 				goto out;
>> 			}
>> +			if (!mach_creds_match(conf, rqstp)) {
>> +				status = nfserr_wrong_cred;
>> +				goto out;
>> +			}
>> 			if (!creds_match) { /* case 9 */
>> 				status = nfserr_perm;
>> 				goto out;
>> @@ -1715,7 +1731,7 @@ out_new:
>> 		goto out;
>> 	}
>> 	new->cl_minorversion = 1;
>> -
>> +	new->cl_mach_cred = (exid->spa_how == SP4_MACH_CRED);
>> 	gen_clid(new, nn);
>> 	add_to_unconfirmed(new);
>> out_copy:
>> @@ -1879,6 +1895,9 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>> 	WARN_ON_ONCE(conf && unconf);
>> 
>> 	if (conf) {
>> +		status = nfserr_wrong_cred;
>> +		if (!mach_creds_match(conf, rqstp))
>> +			goto out_free_conn;
>> 		cs_slot = &conf->cl_cs_slot;
>> 		status = check_slot_seqid(cr_ses->seqid, cs_slot->sl_seqid, 0);
>> 		if (status == nfserr_replay_cache) {
>> @@ -1895,6 +1914,9 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>> 			status = nfserr_clid_inuse;
>> 			goto out_free_conn;
>> 		}
>> +		status = nfserr_wrong_cred;
>> +		if (!mach_creds_match(unconf, rqstp))
>> +			goto out_free_conn;
>> 		cs_slot = &unconf->cl_cs_slot;
>> 		status = check_slot_seqid(cr_ses->seqid, cs_slot->sl_seqid, 0);
>> 		if (status) {
>> @@ -1991,6 +2013,9 @@ __be32 nfsd4_bind_conn_to_session(struct svc_rqst *rqstp,
>> 	status = nfserr_badsession;
>> 	if (!session)
>> 		goto out;
>> +	status = nfserr_wrong_cred;
>> +	if (!mach_creds_match(session->se_client, rqstp))
>> +		goto out;
>> 	status = nfsd4_map_bcts_dir(&bcts->dir);
>> 	if (status)
>> 		goto out;
>> @@ -2033,6 +2058,9 @@ nfsd4_destroy_session(struct svc_rqst *r,
>> 	status = nfserr_badsession;
>> 	if (!ses)
>> 		goto out_client_lock;
>> +	status = nfserr_wrong_cred;
>> +	if (!mach_creds_match(ses->se_client, r))
>> +		goto out_client_lock;
>> 	status = mark_session_dead_locked(ses);
>> 	if (status)
>> 		goto out_client_lock;
>> @@ -2063,26 +2091,31 @@ static struct nfsd4_conn *__nfsd4_find_conn(struct svc_xprt *xpt, struct nfsd4_s
>> 	return NULL;
>> }
>> 
>> -static void nfsd4_sequence_check_conn(struct nfsd4_conn *new, struct nfsd4_session *ses)
>> +static __be32 nfsd4_sequence_check_conn(struct nfsd4_conn *new, struct nfsd4_session *ses)
>> {
>> 	struct nfs4_client *clp = ses->se_client;
>> 	struct nfsd4_conn *c;
>> +	__be32 status = nfs_ok;
>> 	int ret;
>> 
>> 	spin_lock(&clp->cl_lock);
>> 	c = __nfsd4_find_conn(new->cn_xprt, ses);
>> -	if (c) {
>> -		spin_unlock(&clp->cl_lock);
>> -		free_conn(new);
>> -		return;
>> -	}
>> +	if (c)
>> +		goto out_free;
>> +	status = nfserr_conn_not_bound_to_session;
>> +	if (clp->cl_mach_cred)
>> +		goto out_free;
>> 	__nfsd4_hash_conn(new, ses);
>> 	spin_unlock(&clp->cl_lock);
>> 	ret = nfsd4_register_conn(new);
>> 	if (ret)
>> 		/* oops; xprt is already down: */
>> 		nfsd4_conn_lost(&new->cn_xpt_user);
>> -	return;
>> +	return nfs_ok;
>> +out_free:
>> +	spin_unlock(&clp->cl_lock);
>> +	free_conn(new);
>> +	return status;
>> }
>> 
>> static bool nfsd4_session_too_many_ops(struct svc_rqst *rqstp, struct nfsd4_session *session)
>> @@ -2174,8 +2207,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>> 	if (status)
>> 		goto out_put_session;
>> 
>> -	nfsd4_sequence_check_conn(conn, session);
>> +	status = nfsd4_sequence_check_conn(conn, session);
>> 	conn = NULL;
>> +	if (status)
>> +		goto out_put_session;
>> 
>> 	/* Success! bump slot seqid */
>> 	slot->sl_seqid = seq->seqid;
>> @@ -2237,7 +2272,10 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
>> 		status = nfserr_stale_clientid;
>> 		goto out;
>> 	}
>> -
>> +	if (!mach_creds_match(clp, rqstp)) {
>> +		status = nfserr_wrong_cred;
>> +		goto out;
>> +	}
>> 	expire_client(clp);
>> out:
>> 	nfs4_unlock_state();
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index 888a600..7054fde 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -1215,6 +1215,7 @@ nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
>> 	case SP4_NONE:
>> 		break;
>> 	case SP4_MACH_CRED:
>> +		/* XXX: uh, what should I be doing with this?: */
>> 		/* spo_must_enforce */
>> 		READ_BUF(4);
>> 		READ32(dummy);
>> @@ -3220,6 +3221,14 @@ nfsd4_encode_write(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_w
>> 	return nfserr;
>> }
>> 
>> +static const u32 nfs4_minimal_spo_must_enforce[2] = {
>> +	[1] = 1 << (OP_BIND_CONN_TO_SESSION - 32) |
>> +	      1 << (OP_EXCHANGE_ID - 32) |
>> +	      1 << (OP_CREATE_SESSION - 32) |
>> +	      1 << (OP_DESTROY_SESSION - 32) |
>> +	      1 << (OP_DESTROY_CLIENTID - 32)
>> +};
>> +
>> static __be32
>> nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
>> 			 struct nfsd4_exchange_id *exid)
>> @@ -3258,6 +3267,20 @@ nfsd4_encode_exchange_id(struct nfsd4_compoundres *resp, __be32 nfserr,
>> 	/* state_protect4_r. Currently only support SP4_NONE */
>> 	BUG_ON(exid->spa_how != SP4_NONE);
>> 	WRITE32(exid->spa_how);
>> +	switch (exid->spa_how) {
>> +	case SP4_NONE:
>> +		break;
>> +	case SP4_MACH_CRED:
>> +		/* spo_must_enforce bitmap: */
>> +		WRITE32(2);
>> +		WRITE32(nfs4_minimal_spo_must_enforce[0]);
>> +		WRITE32(nfs4_minimal_spo_must_enforce[1]);
>> +		/* empty spo_must_allow bitmap: */
>> +		WRITE32(0);
>> +		break;
>> +	default:
>> +		WARN_ON_ONCE(1);
>> +	}
>> 
>> 	/* The server_owner struct */
>> 	WRITE64(minor_id);      /* Minor id */
>> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
>> index 274e2a1..424d8f5 100644
>> --- a/fs/nfsd/state.h
>> +++ b/fs/nfsd/state.h
>> @@ -246,6 +246,7 @@ struct nfs4_client {
>> 	nfs4_verifier		cl_verifier; 	/* generated by client */
>> 	time_t                  cl_time;        /* time of last lease renewal */
>> 	struct sockaddr_storage	cl_addr; 	/* client ipaddress */
>> +	bool			cl_mach_cred;	/* SP4_MACH_CRED in force */
>> 	struct svc_cred		cl_cred; 	/* setclientid principal */
>> 	clientid_t		cl_clientid;	/* generated by server */
>> 	nfs4_verifier		cl_confirm;	/* generated by server */
>> -- 
>> 1.7.9.5
>> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



