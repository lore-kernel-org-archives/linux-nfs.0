Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59665 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751042Ab3J1UyQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 16:54:16 -0400
Date: Mon, 28 Oct 2013 16:54:15 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/4] NFSD: Create nfs v4.2 decode ops
Message-ID: <20131028205414.GL31322@fieldses.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-3-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1382972247-1108-3-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 28, 2013 at 10:57:24AM -0400, Anna Schumaker wrote:
> I'm doing this in a separate patch to keep from putting in a lot of
> extra code when I go to add operations to the server for real.

Makes sense.

But: now we're duplicating the list of 4.0 op decoders 3 times and the
4.1 ops twice.  We'll never need different decoders for different
minorversions (worst case we can test for the minorversion in the
decoder if necessary).

I wonder if there's a better way to organize this....  Maybe something
more like a single array with

	[OP_SETCLIENTID] = {
		.op_decode = (nfsd4_dec)nfsd4_decode_access,
		.op_unsupported_since_version = 1,
	}
	...
	[OP_EXCHANGE_ID] = {
		.op_decode = (nfsd4_dec)nfsd4_decode_exchange_id,
		.op_first_supported_in_version = 1,
	}

?

--b.

> 
> Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
> ---
>  fs/nfsd/nfs4xdr.c    | 85 +++++++++++++++++++++++++++++++++++++++++++++++++++-
>  include/linux/nfs4.h | 11 +++++++
>  2 files changed, 95 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index d9454fe..60f5a1f 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1599,6 +1599,78 @@ static nfsd4_dec nfsd41_dec_ops[] = {
>  	[OP_RECLAIM_COMPLETE]	= (nfsd4_dec)nfsd4_decode_reclaim_complete,
>  };
>  
> +static nfsd4_dec nfsd42_dec_ops[] = {
> +	[OP_ACCESS]		= (nfsd4_dec)nfsd4_decode_access,
> +	[OP_CLOSE]		= (nfsd4_dec)nfsd4_decode_close,
> +	[OP_COMMIT]		= (nfsd4_dec)nfsd4_decode_commit,
> +	[OP_CREATE]		= (nfsd4_dec)nfsd4_decode_create,
> +	[OP_DELEGPURGE]		= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_DELEGRETURN]	= (nfsd4_dec)nfsd4_decode_delegreturn,
> +	[OP_GETATTR]		= (nfsd4_dec)nfsd4_decode_getattr,
> +	[OP_GETFH]		= (nfsd4_dec)nfsd4_decode_noop,
> +	[OP_LINK]		= (nfsd4_dec)nfsd4_decode_link,
> +	[OP_LOCK]		= (nfsd4_dec)nfsd4_decode_lock,
> +	[OP_LOCKT]		= (nfsd4_dec)nfsd4_decode_lockt,
> +	[OP_LOCKU]		= (nfsd4_dec)nfsd4_decode_locku,
> +	[OP_LOOKUP]		= (nfsd4_dec)nfsd4_decode_lookup,
> +	[OP_LOOKUPP]		= (nfsd4_dec)nfsd4_decode_noop,
> +	[OP_NVERIFY]		= (nfsd4_dec)nfsd4_decode_verify,
> +	[OP_OPEN]		= (nfsd4_dec)nfsd4_decode_open,
> +	[OP_OPENATTR]		= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_OPEN_CONFIRM]	= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_OPEN_DOWNGRADE]	= (nfsd4_dec)nfsd4_decode_open_downgrade,
> +	[OP_PUTFH]		= (nfsd4_dec)nfsd4_decode_putfh,
> +	[OP_PUTPUBFH]		= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_PUTROOTFH]		= (nfsd4_dec)nfsd4_decode_noop,
> +	[OP_READ]		= (nfsd4_dec)nfsd4_decode_read,
> +	[OP_READDIR]		= (nfsd4_dec)nfsd4_decode_readdir,
> +	[OP_READLINK]		= (nfsd4_dec)nfsd4_decode_noop,
> +	[OP_REMOVE]		= (nfsd4_dec)nfsd4_decode_remove,
> +	[OP_RENAME]		= (nfsd4_dec)nfsd4_decode_rename,
> +	[OP_RENEW]		= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_RESTOREFH]		= (nfsd4_dec)nfsd4_decode_noop,
> +	[OP_SAVEFH]		= (nfsd4_dec)nfsd4_decode_noop,
> +	[OP_SECINFO]		= (nfsd4_dec)nfsd4_decode_secinfo,
> +	[OP_SETATTR]		= (nfsd4_dec)nfsd4_decode_setattr,
> +	[OP_SETCLIENTID]	= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_SETCLIENTID_CONFIRM]= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_VERIFY]		= (nfsd4_dec)nfsd4_decode_verify,
> +	[OP_WRITE]		= (nfsd4_dec)nfsd4_decode_write,
> +	[OP_RELEASE_LOCKOWNER]	= (nfsd4_dec)nfsd4_decode_notsupp,
> +
> +	/* new operations for NFSv4.1 */
> +	[OP_BACKCHANNEL_CTL]	= (nfsd4_dec)nfsd4_decode_backchannel_ctl,
> +	[OP_BIND_CONN_TO_SESSION]= (nfsd4_dec)nfsd4_decode_bind_conn_to_session,
> +	[OP_EXCHANGE_ID]	= (nfsd4_dec)nfsd4_decode_exchange_id,
> +	[OP_CREATE_SESSION]	= (nfsd4_dec)nfsd4_decode_create_session,
> +	[OP_DESTROY_SESSION]	= (nfsd4_dec)nfsd4_decode_destroy_session,
> +	[OP_FREE_STATEID]	= (nfsd4_dec)nfsd4_decode_free_stateid,
> +	[OP_GET_DIR_DELEGATION]	= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_GETDEVICEINFO]	= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_GETDEVICELIST]	= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_LAYOUTCOMMIT]	= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_LAYOUTGET]		= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_LAYOUTRETURN]	= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_SECINFO_NO_NAME]	= (nfsd4_dec)nfsd4_decode_secinfo_no_name,
> +	[OP_SEQUENCE]		= (nfsd4_dec)nfsd4_decode_sequence,
> +	[OP_SET_SSV]		= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_TEST_STATEID]	= (nfsd4_dec)nfsd4_decode_test_stateid,
> +	[OP_WANT_DELEGATION]	= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_DESTROY_CLIENTID]	= (nfsd4_dec)nfsd4_decode_destroy_clientid,
> +	[OP_RECLAIM_COMPLETE]	= (nfsd4_dec)nfsd4_decode_reclaim_complete,
> +
> +	/* new operations for NFSv4.2 */
> +	[OP_COPY]		= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_OFFLOAD_ABORT]	= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_OFFLOAD_REVOKE]	= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_OFFLOAD_STATUS]	= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_WRITE_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_notsupp,
> +	[OP_IO_ADVISE]		= (nfsd4_dec)nfsd4_decode_notsupp,
> +};
> +
>  struct nfsd4_minorversion_ops {
>  	nfsd4_dec *decoders;
>  	int nops;
> @@ -1607,7 +1679,7 @@ struct nfsd4_minorversion_ops {
>  static struct nfsd4_minorversion_ops nfsd4_minorversion[] = {
>  	[0] = { nfsd4_dec_ops, ARRAY_SIZE(nfsd4_dec_ops) },
>  	[1] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
> -	[2] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
> +	[2] = { nfsd42_dec_ops, ARRAY_SIZE(nfsd42_dec_ops) },
>  };
>  
>  static __be32
> @@ -3591,6 +3663,17 @@ static nfsd4_enc nfsd4_enc_ops[] = {
>  	[OP_WANT_DELEGATION]	= (nfsd4_enc)nfsd4_encode_noop,
>  	[OP_DESTROY_CLIENTID]	= (nfsd4_enc)nfsd4_encode_noop,
>  	[OP_RECLAIM_COMPLETE]	= (nfsd4_enc)nfsd4_encode_noop,
> +
> +	/* NFSv4.2 operations */
> +	[OP_COPY]		= (nfsd4_enc)nfsd4_encode_noop,
> +	[OP_OFFLOAD_ABORT]	= (nfsd4_enc)nfsd4_encode_noop,
> +	[OP_COPY_NOTIFY]	= (nfsd4_enc)nfsd4_encode_noop,
> +	[OP_OFFLOAD_REVOKE]	= (nfsd4_enc)nfsd4_encode_noop,
> +	[OP_OFFLOAD_STATUS]	= (nfsd4_enc)nfsd4_encode_noop,
> +	[OP_WRITE_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
> +	[OP_READ_PLUS]		= (nfsd4_enc)nfsd4_encode_noop,
> +	[OP_SEEK]		= (nfsd4_enc)nfsd4_encode_noop,
> +	[OP_IO_ADVISE]		= (nfsd4_enc)nfsd4_encode_noop,
>  };
>  
>  /*
> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
> index a92e065..2bc5217 100644
> --- a/include/linux/nfs4.h
> +++ b/include/linux/nfs4.h
> @@ -110,6 +110,17 @@ enum nfs_opnum4 {
>  	OP_DESTROY_CLIENTID = 57,
>  	OP_RECLAIM_COMPLETE = 58,
>  
> +	/* nfs42 */
> +	OP_COPY = 59,
> +	OP_OFFLOAD_ABORT = 60,
> +	OP_COPY_NOTIFY = 61,
> +	OP_OFFLOAD_REVOKE = 62,
> +	OP_OFFLOAD_STATUS = 63,
> +	OP_WRITE_PLUS = 64,
> +	OP_READ_PLUS = 65,
> +	OP_SEEK = 66,
> +	OP_IO_ADVISE = 67,
> +
>  	OP_ILLEGAL = 10044,
>  };
>  
> -- 
> 1.8.4.1
> 
