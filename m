From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH RFC 12/13] nfs: nfs4xdr: change COPYMEM macro into a
 static function
Date: Wed, 12 Aug 2009 16:36:16 -0400
Message-ID: <1250109376.5973.13.camel@heimdal.trondhjem.org>
References: <4A82DC7B.3090600@panasas.com>
	 <1250090563-9895-1-git-send-email-bhalevy@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38927 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752345AbZHLUgc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Aug 2009 16:36:32 -0400
In-Reply-To: <1250090563-9895-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-08-12 at 18:22 +0300, Benny Halevy wrote:
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
>  fs/nfs/nfs4xdr.c |   39 ++++++++++++++++++++-------------------
>  1 files changed, 20 insertions(+), 19 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 2e83aef..ed9bbd2 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -2448,11 +2448,6 @@ static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
>   * task to translate them into Linux-specific versions which are more
>   * consistent with the style used in NFSv2/v3...
>   */
> -#define COPYMEM(x,nbytes) do {			\
> -	memcpy((x), p, nbytes);			\
> -	p += XDR_QUADLEN(nbytes);		\
> -} while (0)
> -
>  #define READ_BUF(nbytes)  do { \
>  	p = xdr_inline_decode(xdr, nbytes); \
>  	if (unlikely(!p)) { \
> @@ -2464,6 +2459,12 @@ static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
>  	} \
>  } while (0)
>  
> +static __be32 *copymem(void *x, __be32 *p, u32 nbytes)
> +{
> +	memcpy(x, p, nbytes);
> +	return p + XDR_QUADLEN(nbytes);
> +}
> +
>  static int decode_opaque_inline(struct xdr_stream *xdr, unsigned int *len, char **string)
>  {
>  	__be32 *p;
> @@ -3312,7 +3313,7 @@ static int decode_close(struct xdr_stream *xdr, struct nfs_closeres *res)
>  	if (status)
>  		return status;
>  	READ_BUF(NFS4_STATEID_SIZE);
> -	COPYMEM(res->stateid.data, NFS4_STATEID_SIZE);
> +	copymem(res->stateid.data, p, NFS4_STATEID_SIZE);

I wouldn't mind converting the above 2 lines into a dedicated

static int decode_stateid(struct xdr_stream *xdr, nfs4_stateid *stateid)
{
	__be32 *p;

	p = xdr_inline_decode(xdr, NFS4_STATEID_SIZE);
	if (p) {
		memcpy(stateid->data, p, NFS4_STATEID_SIZE);
		return 0;
	}
	dprintk(....);
	return -EIO;
}

>  	return 0;
>  }
>  
> @@ -3325,7 +3326,7 @@ static int decode_commit(struct xdr_stream *xdr, struct nfs_writeres *res)
>  	if (status)
>  		return status;
>  	READ_BUF(8);
> -	COPYMEM(res->verf->verifier, 8);
> +	copymem(res->verf->verifier, p, 8);

Ditto for this...

>  	return 0;
>  }
>  
> @@ -3601,7 +3602,7 @@ static int decode_getfh(struct xdr_stream *xdr, struct nfs_fh *fh)
>  		return -EIO;
>  	fh->size = len;
>  	READ_BUF(len);
> -	COPYMEM(fh->data, len);
> +	copymem(fh->data, p, len);

Open code as memcpy() since we don't need to update the value of 'p'.

>  	return 0;
>  }
>  

<snip lots of verifier and stateid decodes>

>  
> @@ -4227,7 +4228,7 @@ static int decode_create_session(struct xdr_stream *xdr,
>  
>  	/* sessionid */
>  	READ_BUF(NFS4_MAX_SESSIONID_LEN);
> -	COPYMEM(&session->sess_id, NFS4_MAX_SESSIONID_LEN);
> +	copymem(&session->sess_id, p, NFS4_MAX_SESSIONID_LEN);

Convert into a 'decode_session_id()' helper.
 
>  	/* seqid, flags */
>  	READ_BUF(8);
> @@ -4273,7 +4274,7 @@ static int decode_sequence(struct xdr_stream *xdr,
>  
>  	slot = &res->sr_session->fc_slot_table.slots[res->sr_slotid];
>  	READ_BUF(NFS4_MAX_SESSIONID_LEN + 20);
> -	COPYMEM(id.data, NFS4_MAX_SESSIONID_LEN);
> +	p = copymem(id.data, p, NFS4_MAX_SESSIONID_LEN);
>  	if (memcmp(id.data, res->sr_session->sess_id.data,
>  		   NFS4_MAX_SESSIONID_LEN)) {
>  		dprintk("%s Invalid session id\n", __func__);

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
