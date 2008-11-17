From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 26/51] nfsd41: destroy_session operation
Date: Mon, 17 Nov 2008 16:10:03 +0200
Message-ID: <49217B3B.4090609@panasas.com>
References: <491895A0.3040809@panasas.com> <1226350174-11074-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:10762 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752089AbYKQOKG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2008 09:10:06 -0500
In-Reply-To: <1226350174-11074-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov. 10, 2008, 22:49 +0200, Benny Halevy <bhalevy@panasas.com> wrote:
> Implement the destory_session operation confoming to
> http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion1-26
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfsd/nfs4state.c       |   26 +++++++++++++++++++++++++-
>  fs/nfsd/nfs4xdr.c         |    7 +++++--
>  include/linux/nfsd/xdr4.h |    2 +-
>  3 files changed, 31 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 73bc8de..77b89b6 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1050,7 +1050,31 @@ nfsd4_destroy_session(struct svc_rqst *r,
>  		      struct nfsd4_compound_state *cstate,
>  		      struct nfsd4_destroy_session *sessionid)
>  {
> -	return -1;	/* stub */
> +	struct nfs41_session *ses;
> +	u32 status = nfserr_badsession;
> +
> +	/* Notes:
> +	 * - The confirmed nfs4_client->cl_sessionid holds destroyed sessinid
> +	 * - Should we return nfserr_back_chan_busy if waiting for
> +	 *   callbacks on to-be-destroyed session?
> +	 * - Do we need to clear any callback info from previous session?
> +	 */
> +
> +	dump_sessionid(__func__, &sessionid->sessionid);
> +	nfs4_lock_state();
> +	ses = find_in_sessionid_hashtbl(&sessionid->sessionid);
> +	if (!ses)
> +		goto out;
> +
> +	/* wait for callbacks */
> +	shutdown_callback_client(ses->se_client);

review 11-12: we need ref. counting for that backchannel
to support trunking.
clp->cl_callback.cb_client is shared?

> +
> +	destroy_session(ses);
> +	status = nfs_ok;
> +out:
> +	nfs4_unlock_state();
> +	dprintk("%s returns %d\n", __func__, ntohl(status));
> +	return status;
>  }
>  
>  __be32
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 02c82d4..f49ddde 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1227,7 +1227,11 @@ static __be32
>  nfsd4_decode_destroy_session(struct nfsd4_compoundargs *argp,
>  			     struct nfsd4_destroy_session *destroy_session)
>  {
> -	return nfserr_opnotsupp;	/* stub */
> +	DECODE_HEAD;
> +	READ_BUF(NFS4_MAX_SESSIONID_LEN);
> +	COPYMEM(destroy_session->sessionid, NFS4_MAX_SESSIONID_LEN);
> +
> +	DECODE_TAIL;
>  }
>  
>  static __be32
> @@ -2990,7 +2994,6 @@ static __be32
>  nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, int nfserr,
>  			     struct nfsd4_destroy_session *destroy_session)
>  {
> -	/* stub */
>  	return nfserr;
>  }
>  
> diff --git a/include/linux/nfsd/xdr4.h b/include/linux/nfsd/xdr4.h
> index 75d93ab..8b166d8 100644
> --- a/include/linux/nfsd/xdr4.h
> +++ b/include/linux/nfsd/xdr4.h
> @@ -390,7 +390,7 @@ struct nfsd4_sequence {
>  };
>  
>  struct nfsd4_destroy_session {
> -	int	foo;	/* stub */
> +	nfs41_sessionid		sessionid;
>  };
>  #endif /* CONFIG_NFSD_V4_1 */
>  
