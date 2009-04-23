From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 01/29] nfsd41: add create session slot buffer to struc
	nfs4_client
Date: Thu, 23 Apr 2009 18:55:18 -0400
Message-ID: <20090423225518.GH1906@fieldses.org>
References: <1240504988-9572-1-git-send-email-andros@netapp.com> <1240504988-9572-2-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:39351 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155AbZDWWzS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Apr 2009 18:55:18 -0400
In-Reply-To: <1240504988-9572-2-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 23, 2009 at 12:42:40PM -0400, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> The nfs41 single slot clientid cache holds create session response which
> has a maximum size of 88 bytes. Add a static buffer to struct nfs4_client
> to cache the encoded create session response.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/nfs4state.c        |    3 +++
>  include/linux/nfsd/state.h |    8 ++++++++
>  2 files changed, 11 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index e82a518..27ad37f 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1283,6 +1283,9 @@ out_new:
>  		status = nfserr_resource;
>  		goto out;
>  	}
> +	/* Set the create session cache buffer */
> +	new->cl_slot.sl_cache_entry.ce_datav.iov_base = new->cl_slot_buf;
> +	new->cl_slot.sl_cache_entry.ce_datav.iov_len = CS_MAX_ENC_SZ;

Any reason not to do this as part of the other client initialization in
create_client()?

--b.

>  
>  	copy_verf(new, &verf);
>  	copy_cred(&new->cl_cred, &rqstp->rq_cred);
> diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
> index 14da8f6..87f3eaa 100644
> --- a/include/linux/nfsd/state.h
> +++ b/include/linux/nfsd/state.h
> @@ -174,6 +174,13 @@ struct nfsd4_sessionid {
>  #define HEXDIR_LEN     33 /* hex version of 16 byte md5 of cl_name plus '\0' */
>  
>  /*
> + * maximum encoded size of create session response
> + * 16 - sessionid, 8 - sequence # and flags,
> + * 32 - fore channel attrs, 32 - back channel attrs
> + */
> +#define CS_MAX_ENC_SZ  88
> +
> +/*
>   * struct nfs4_client - one per client.  Clientids live here.
>   * 	o Each nfs4_client is hashed by clientid.
>   *
> @@ -206,6 +213,7 @@ struct nfs4_client {
>  	/* for nfs41 */
>  	struct list_head	cl_sessions;
>  	struct nfsd4_slot	cl_slot;	/* create_session slot */
> +	char			cl_slot_buf[CS_MAX_ENC_SZ]; /* slot buffer */
>  	u32			cl_exchange_flags;
>  	struct nfs4_sessionid	cl_sessionid;
>  
> -- 
> 1.5.4.3
> 
