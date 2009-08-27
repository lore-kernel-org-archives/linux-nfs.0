From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH] nfsd41: renew_client must be called under the
 state lock
Date: Thu, 27 Aug 2009 19:37:02 +0300
Message-ID: <4A96B62E.3040708@panasas.com>
References: <1250727716-28107-1-git-send-email-bhalevy@panasas.com> <20090824162904.GC4985@fieldses.org> <4A938D7A.3070908@panasas.com> <20090825131829.GA24049@fieldses.org> <4A941931.8070609@panasas.com> <20090825215948.GG32708@fieldses.org> <4A94F060.4080209@panasas.com> <20090826210242.GB22723@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Boaz Harrosh <bharrosh@panasas.com>, linux-nfs@vger.kernel.org,
	pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-67.z220-152-67.customer.algx.net ([67.152.220.67]:53065
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752890AbZH0QhD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Aug 2009 12:37:03 -0400
In-Reply-To: <20090826210242.GB22723@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug. 27, 2009, 0:02 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Wed, Aug 26, 2009 at 11:20:48AM +0300, Boaz Harrosh wrote:
>> On 08/26/2009 12:59 AM, J. Bruce Fields wrote:
>>> commit fdf7875040506ca7e595dffef56cbd81ae6b384b
>>> Author: Benny Halevy <bhalevy@panasas.com>
>>> Date:   Thu Aug 20 03:21:56 2009 +0300
>>>
>>>     nfsd41: renew_client must be called under the state lock
>>>     
>>>     Until we work out the state locking so we can use a spin lock to protect
>>>     the cl_lru, we need to take the state_lock to renew the client.
>>>     
>>>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>     [nfsd41: Do not renew state on error]
>>>     Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
>>>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>     Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>>>
>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>>> index d2a0524..8e5ac49 100644
>>> --- a/fs/nfsd/nfs4state.c
>>> +++ b/fs/nfsd/nfs4state.c
>>> @@ -1463,12 +1463,16 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>>>  	spin_lock(&sessionid_lock);
>>>  	status = nfserr_badsession;
>>>  	session = find_in_sessionid_hashtbl(&seq->sessionid);
>>> -	if (!session)
>>> -		goto out;
>>> +	if (!session) {
>>> +		spin_unlock(&sessionid_lock);
>>> +		goto err;
>>> +	}
>>>  
>>>  	status = nfserr_badslot;
>>> -	if (seq->slotid >= session->se_fchannel.maxreqs)
>>> -		goto out;
>>> +	if (seq->slotid >= session->se_fchannel.maxreqs) {
>>> +		spin_unlock(&sessionid_lock);
>>> +		goto err;
>>> +	}
>>>  
>> A spin_unlock is a big and delicate inlined code site
>> Why not do a "goto err_unlock" or something
> 
> Yes, we could add an
> 
> 	err_unlock:
> 		spin_unlock(&sessionid_lock);
> 		goto err;
> 
> at the end.  It still seems little delicate.
> 
> How about the following (on top of Benny's patch), which sends all the
> unlock cases to one label?  (Disclaimer: untested.  And this depends on
> the assumption that cstate->session is NULL on entry to this function,
> which I haven't checked.)
> 
> --b.
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 8e5ac49..5f634d2 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1463,16 +1463,12 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  	spin_lock(&sessionid_lock);
>  	status = nfserr_badsession;
>  	session = find_in_sessionid_hashtbl(&seq->sessionid);
> -	if (!session) {
> -		spin_unlock(&sessionid_lock);
> -		goto err;
> -	}
> +	if (!session)
> +		goto out;
>  
>  	status = nfserr_badslot;
> -	if (seq->slotid >= session->se_fchannel.maxreqs) {
> -		spin_unlock(&sessionid_lock);
> -		goto err;
> -	}
> +	if (seq->slotid >= session->se_fchannel.maxreqs)
> +		goto out;
>  
>  	slot = &session->se_slots[seq->slotid];
>  	dprintk("%s: slotid %d\n", __func__, seq->slotid);
> @@ -1487,10 +1483,8 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  		cstate->status = nfserr_replay_cache;
>  		goto out;
>  	}
> -	if (status) {
> -		spin_unlock(&sessionid_lock);
> -		goto err;
> -	}
> +	if (status)
> +		goto out;
>  
>  	/* Success! bump slot seqid */
>  	slot->sl_inuse = true;
> @@ -1510,10 +1504,11 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  out:
>  	spin_unlock(&sessionid_lock);
>  	/* Renew the clientid on success and on replay */
> -	nfs4_lock_state();
> -	renew_client(session->se_client);
> -	nfs4_unlock_state();
> -err:
> +	if (cstate->session) {
> +		nfs4_lock_state();
> +		renew_client(session->se_client);
> +		nfs4_unlock_state();
> +	}
>  	dprintk("%s: return %d\n", __func__, ntohl(status));
>  	return status;
>  }

The code looks correct.
Coming to think about it, I hope that cstate is initialized to zeroes
since we're not explicitly clearing it. Should we?
cstate comes from the struct nfsd4_compoundres * nfsd4_proc_compound
is being called with...

Benny
