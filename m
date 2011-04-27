From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: Re: [PATCH] nfsd41: compare request's opcnt with session's maxops
 at nfsd4_sequence
Date: Wed, 27 Apr 2011 13:48:09 +0800
Message-ID: <4DB7AE19.3080308@cn.fujitsu.com>
References: <4DB76CE6.9080404@cn.fujitsu.com> <20110427024126.GB26541@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58816 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751578Ab1D0Fql (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Apr 2011 01:46:41 -0400
In-Reply-To: <20110427024126.GB26541@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



J. Bruce Fields:
> On Wed, Apr 27, 2011 at 09:09:58AM +0800, Mi Jinlong wrote:
>> Make sure nfs server can distinguish request contains more ops
>> than channel allowed.
> 
> Yes, sequence looks like a reasonable op to catch this error.  The spec
> doesn't care as far as I can tell (and it's a buggy-client case, so why
> should it), and we already check that any compound not starting with a
> sequence has only one op.
> 
>> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
>> ---
>>  fs/nfsd/nfs4state.c |    5 +++++
>>  1 files changed, 5 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index fbde6f7..4f9fc68 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -1749,6 +1749,11 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>>  	if (!session)
>>  		goto out;
>>  
>> +	status = nfserr_too_many_ops;
>> +	if (((struct nfsd4_compoundargs *)rqstp->rq_argp)->opcnt >
> 
> Kind of a cumbersome construction, though.
> 
> Eh, maybe overkill, but how about this?:

  That's great!

-- 
----
thanks
Mi Jinlong

> 
> --b.
> 
> commit d5eee1629fb9d3a55e5793d156026248c14cb46c
> Author: Mi Jinlong <mijinlong@cn.fujitsu.com>
> Date:   Wed Apr 27 09:09:58 2011 +0800
> 
>     nfsd41: compare request's opcnt with session's maxops at nfsd4_sequence
>     
>     Make sure nfs server errors out if request contains more ops
>     than channel allows.
>     
>     Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
>     [bfields@redhat.com: use helper function]
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index fbde6f7..487ba47 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1721,6 +1721,13 @@ static void nfsd4_sequence_check_conn(struct nfsd4_conn *new, struct nfsd4_sessi
>  	return;
>  }
>  
> +static bool nfsd4_session_too_many_ops(struct svc_rqst *rqstp, struct nfsd4_session *session)
> +{
> +	struct nfsd4_compoundargs *args = rqstp->rq_argp;
> +
> +	return args->opcnt > session->se_fchannel.maxops;
> +}
> +
>  __be32
>  nfsd4_sequence(struct svc_rqst *rqstp,
>  	       struct nfsd4_compound_state *cstate,
> @@ -1749,6 +1756,10 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  	if (!session)
>  		goto out;
>  
> +	status = nfserr_too_many_ops;
> +	if (nfsd4_session_too_many_ops(rqstp, session))
> +		goto out;
> +
>  	status = nfserr_badslot;
>  	if (seq->slotid >= session->se_fchannel.maxreqs)
>  		goto out;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

