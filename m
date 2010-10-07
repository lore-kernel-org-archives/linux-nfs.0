Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og105.obsmtp.com ([64.18.0.180]:42817 "HELO
	exprod5og105.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752554Ab0JGTX6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Oct 2010 15:23:58 -0400
Message-ID: <4CAE1E4E.2010106@panasas.com>
Date: Thu, 07 Oct 2010 15:23:58 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: andros@netapp.com
CC: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>
Subject: Re: [PATCH 3/3] pnfs_submit: enforce requested DS only pNFS role
References: <1286480230-9418-1-git-send-email-andros@netapp.com> <1286480230-9418-2-git-send-email-andros@netapp.com> <1286480230-9418-3-git-send-email-andros@netapp.com> <4CADFE2E.7050401@panasas.com> <4CAE0C8B.5060204@panasas.com> <4CAE145F.5070809@panasas.com>
In-Reply-To: <4CAE145F.5070809@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-10-07 14:41, Benny Halevy wrote:
> On 2010-10-07 14:08, Benny Halevy wrote:
>> On 2010-10-07 13:06, Benny Halevy wrote:
>>> On 2010-10-07 15:37, andros@netapp.com wrote:
>>>> From: Andy Adamson <andros@netapp.com>
>>>>
>>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>>> ---
>>>>  fs/nfs/nfs4filelayoutdev.c |    5 -----
>>>>  fs/nfs/nfs4state.c         |    5 +++++
>>>>  2 files changed, 5 insertions(+), 5 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
>>>> index e0edf93..1f0ab62 100644
>>>> --- a/fs/nfs/nfs4filelayoutdev.c
>>>> +++ b/fs/nfs/nfs4filelayoutdev.c
>>>> @@ -183,11 +183,6 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
>>>>  		goto out_put;
>>>>  	}
>>>>  	/*
>>>> -	 * Mask the (possibly) returned EXCHGID4_FLAG_USE_PNFS_MDS pNFS role
>>>> -	 * The is_ds_only_session depends on this.
>>>> -	 */
>>>> -	clp->cl_exchange_flags &= ~EXCHGID4_FLAG_USE_PNFS_MDS;
>>>> -	/*
>>>>  	 * Set DS lease equal to the MDS lease, renewal is scheduled in
>>>>  	 * create_session
>>>>  	 */
>>>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>>>> index 91584ad..e2fc175 100644
>>>> --- a/fs/nfs/nfs4state.c
>>>> +++ b/fs/nfs/nfs4state.c
>>>> @@ -188,6 +188,7 @@ static int nfs4_begin_drain_session(struct nfs_client *clp)
>>>>  int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
>>>>  {
>>>>  	int status;
>>>> +	u32 req_exchange_flags = clp->cl_exchange_flags;
>>>>  
>>>>  	nfs4_begin_drain_session(clp);
>>>>  	status = nfs4_proc_exchange_id(clp, cred);
>>>> @@ -196,6 +197,10 @@ int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
>>>>  	status = nfs4_proc_create_session(clp);
>>>>  	if (status != 0)
>>>>  		goto out;
>>>> +	if (is_ds_only_session(req_exchange_flags))
>>>> +		/* Mask the (possibly) returned MDS and non-pNFS roles */
>>>
>>> This comment does not really add anything substantial that the code doesn't tell you :)
>>>
>>>> +		clp->cl_exchange_flags &=
>>>> +		     ~(EXCHGID4_FLAG_USE_PNFS_MDS | EXCHGID4_FLAG_USE_NON_PNFS);
>>>
>>> I'm not why you want to mask out EXCHGID4_FLAG_USE_NON_PNFS.
>>> If the server is not a DS why not just return an error?
>>
>> So Andy convinced me and the spec. says that USE_PNFS_DS | USE_NON_PNFS
>> is a valid response.
>> However, if USE_PNFS_DS is unset in the response in this case
>> we need not create the client and better return an error.
>> I'll send a patch that does that.
> 
> So this is what I have in mind:
> 
> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> index e2fc175..4723c41 100644
> --- a/fs/nfs/nfs4state.c
> +++ b/fs/nfs/nfs4state.c
> @@ -197,10 +197,14 @@ int nfs41_init_clientid(struct nfs_client *clp, struct rpc_cred *cred)
>  	status = nfs4_proc_create_session(clp);
>  	if (status != 0)
>  		goto out;
> -	if (is_ds_only_session(req_exchange_flags))
> -		/* Mask the (possibly) returned MDS and non-pNFS roles */
> +	if (is_ds_only_session(req_exchange_flags)) {
>  		clp->cl_exchange_flags &=
>  		     ~(EXCHGID4_FLAG_USE_PNFS_MDS | EXCHGID4_FLAG_USE_NON_PNFS);
> +		if (!is_ds_only_session(clp->cl_exchange_flags)) {
> +			nfs4_proc_destroy_session(clp);

This should be {
	nfs4_destroy_session(clp->cl_session);
	clp->cl_session = NULL;
}


> +			status = -ENOTSUPP;
> +		}
> +	}
>  	nfs41_setup_state_renewal(clp);
>  	nfs_mark_client_ready(clp, NFS_CS_READY);
>  out:
> 
>>
>> Benny
>>
>>>
>>> Benny
>>>
>>>>  	nfs41_setup_state_renewal(clp);
>>>>  	nfs_mark_client_ready(clp, NFS_CS_READY);
>>>>  out:
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
