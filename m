Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:64788 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755282Ab1JTJkq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 05:40:46 -0400
Message-ID: <4E9FEDC3.2050200@cn.fujitsu.com>
Date: Thu, 20 Oct 2011 17:45:39 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs41: implement DESTROY_CLIENTID operation
References: <4E9FE112.3080907@cn.fujitsu.com> <20111020093452.GD5444@fieldses.org>
In-Reply-To: <20111020093452.GD5444@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



J. Bruce Fields:
> On Thu, Oct 20, 2011 at 04:51:30PM +0800, Mi Jinlong wrote:
>> According to rfc5661 18.50, implement DESTROY_CLIENTID operation.
>>
>> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
>> ---
>>  fs/nfsd/nfs4proc.c  |    2 +-
>>  fs/nfsd/nfs4state.c |   51 +++++++++++++++++++++++++++++++++++++++++++++++++++
>>  fs/nfsd/nfs4xdr.c   |   12 +++++++++++-
>>  fs/nfsd/xdr4.h      |    5 +++++
>>  4 files changed, 68 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index e807776..8412a22 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -1433,7 +1433,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
>>  		.op_name = "OP_SEQUENCE",
>>  	},
>>  	[OP_DESTROY_CLIENTID] = {
>> -		.op_func = NULL,
>> +		.op_func = (nfsd4op_func)nfsd4_destroy_clientid,
>>  		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
>>  		.op_name = "OP_DESTROY_CLIENTID",
>>  	},
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 3787ec1..d46cbbe 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -1858,6 +1858,57 @@ out:
>>  	return status;
>>  }
>>  
>> +static inline bool has_resources(struct nfs4_client *clp)
>> +{
>> +	return !list_empty(&clp->cl_openowners)
>> +		|| !list_empty(&clp->cl_delegations)
>> +		|| !list_empty(&clp->cl_sessions)
>> +		|| !list_empty(&clp->cl_callbacks);
> 
> I don't think the existance of callbacks should prevent destroying the
> client.

  It's my fault.

> 
>> +}
>> +
>> +__be32
>> +nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, struct nfsd4_destroy_clientid *dc)
>> +{
>> +	struct nfs4_client *conf, *unconf, *clp;
>> +	int status = 0;
>> +
>> +	nfs4_lock_state();
>> +	unconf = find_unconfirmed_client(&dc->clientid);
>> +	conf = find_confirmed_client(&dc->clientid);
>> +
>> +	if (conf) {
>> +		clp = conf;
>> +
>> +		if (!is_client_expired(conf) && has_resources(conf)) {
>> +			status = nfserr_clientid_busy;
>> +			goto out;
>> +		}
>> +
>> +		/*
>> +		 * DESTROY_CLIENTID MAY be preceded with a SEQUENCE operation as
>> +		 * long as the client ID derived from the session ID of SEQUENCE
>> +		 * is not the same as the client ID to be destroyed. 
>> +		 * If the client IDs are the same, then the server MUST return
>> +		 * NFS4ERR_CLIENTID_BUSY.
>> +		 */
> 
> Let's just replace that comment by:
> 
> 		/* rfc 551 18.50.3: */
> 
> (I agree that it's useful to have a reference to explain where this
> requirement came from, but I don't think it's necessary to write out the
> whole thing, as the behavior is obvious enough from the following code.)

  Yes.

  A new version will be post.

thanks,
Mi Jinlong 

