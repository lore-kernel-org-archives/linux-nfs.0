Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:47377 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751988AbaCDSIQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Mar 2014 13:08:16 -0500
Received: by mail-qc0-f180.google.com with SMTP id x3so3485797qcv.25
        for <linux-nfs@vger.kernel.org>; Tue, 04 Mar 2014 10:08:15 -0800 (PST)
Message-ID: <53161688.6030204@gmail.com>
Date: Tue, 04 Mar 2014 13:08:08 -0500
From: Anna Schumaker <schumaker.anna@gmail.com>
MIME-Version: 1.0
To: andros@netapp.com, trond.myklebust@primarydata.com
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/4] NFSv4 Check errors on stateid changed functions in
 I/O path
References: <1393954269-3974-1-git-send-email-andros@netapp.com> <1393954269-3974-3-git-send-email-andros@netapp.com>
In-Reply-To: <1393954269-3974-3-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/04/2014 12:31 PM, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
>
> Retry I/O from the call prepare state (with the new stateid) if the stateid
> has changed on an stateid expired error
>
> Fail the I/O if the statied represents a lost lock.
>
> Otherwise, let the error handler decide what to do.
>
> Without this change, I/O with a stateid expired error such as
> NFS4ERR_BAD_STATEID can be retried without recovery and loop forever.
>
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/nfs4proc.c | 77 +++++++++++++++++++++++++++++++++++++++++++------------
>  1 file changed, 60 insertions(+), 17 deletions(-)
>
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 2f1997d..de8e7f5 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4107,29 +4107,49 @@ static int nfs4_read_done_cb(struct rpc_task *task, struct nfs_read_data *data)
>  	return 0;
>  }
>  
> -static bool nfs4_read_stateid_changed(struct rpc_task *task,
> +static int nfs4_read_stateid_changed(struct rpc_task *task,
>  		struct nfs_readargs *args)
>  {
> +	int ret;
>  
> -	if (!nfs4_error_stateid_expired(task->tk_status) ||
> -		nfs4_stateid_is_current(&args->stateid,
> +	ret = nfs4_stateid_is_current(&args->stateid,
>  				args->context,
>  				args->lock_context,
> -				FMODE_READ))
> -		return false;
> -	rpc_restart_call_prepare(task);
> -	return true;
> +				FMODE_READ);
> +	switch (ret) {
> +	case 0: /* stateid changed */
> +		if (nfs4_error_stateid_expired(task->tk_status)) {
> +			/* stateid expired error, retry with changed stateid */
> +			rpc_restart_call_prepare(task);
> +			return -EAGAIN;
> +		}
> +		return 0; /* let error handler proceed */
> +
> +	case -EIO:  /* -EIO means lock stateid was lost: fail the I/O */
> +		task->tk_status = -EIO;
> +		return -EIO;
> +
> +	case -EWOULDBLOCK: /* stateid change in progress */
> +	default:/* stateid has not changed, let error handler proceed.*/
> +		return 0;
> +
> +	}
>  }

This bit of code exists down below, too.  Is there any reason it can't be an error handling function?

Anna


>  
>  static int nfs4_read_done(struct rpc_task *task, struct nfs_read_data *data)
>  {
> +	int ret;
>  
>  	dprintk("--> %s\n", __func__);
>  
>  	if (!nfs4_sequence_done(task, &data->res.seq_res))
>  		return -EAGAIN;
> -	if (nfs4_read_stateid_changed(task, &data->args))
> -		return -EAGAIN;
> +	ret = nfs4_read_stateid_changed(task, &data->args);
> +	switch (ret) {
> +	case -EAGAIN:
> +	case -EIO:
> +		return ret;
> +	}
>  	return data->read_done_cb ? data->read_done_cb(task, data) :
>  				    nfs4_read_done_cb(task, data);
>  }
> @@ -4176,23 +4196,46 @@ static int nfs4_write_done_cb(struct rpc_task *task, struct nfs_write_data *data
>  static bool nfs4_write_stateid_changed(struct rpc_task *task,
>  		struct nfs_writeargs *args)
>  {
> +	int ret;
>  
> -	if (!nfs4_error_stateid_expired(task->tk_status) ||
> -		nfs4_stateid_is_current(&args->stateid,
> +	ret = nfs4_stateid_is_current(&args->stateid,
>  				args->context,
>  				args->lock_context,
> -				FMODE_WRITE))
> -		return false;
> -	rpc_restart_call_prepare(task);
> -	return true;
> +				FMODE_WRITE);
> +
> +	switch (ret) {
> +	case 0: /* stateid changed */
> +		if (nfs4_error_stateid_expired(task->tk_status)) {
> +			/* stateid expired error, retry with changed stateid */
> +			rpc_restart_call_prepare(task);
> +			return -EAGAIN;
> +		}
> +		return 0; /* let error handler proceed */
> +
> +	case -EIO:  /* -EIO means lock stateid was lost: fail the I/O */
> +		task->tk_status = -EIO;
> +		return -EIO;
> +
> +	case -EWOULDBLOCK: /* stateid change in progress */
> +	default:/* stateid has not changed, let error handler proceed.*/
> +		return 0;
> +
> +	}
>  }
>  
>  static int nfs4_write_done(struct rpc_task *task, struct nfs_write_data *data)
>  {
> +	int ret;
> +
>  	if (!nfs4_sequence_done(task, &data->res.seq_res))
>  		return -EAGAIN;
> -	if (nfs4_write_stateid_changed(task, &data->args))
> -		return -EAGAIN;
> +
> +	ret = nfs4_write_stateid_changed(task, &data->args);
> +	switch (ret) {
> +	case -EAGAIN:
> +	case -EIO:
> +		return ret;
> +	}
>  	return data->write_done_cb ? data->write_done_cb(task, data) :
>  		nfs4_write_done_cb(task, data);
>  }

