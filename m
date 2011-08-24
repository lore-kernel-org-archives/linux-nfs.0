Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53314 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756777Ab1HXJD4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Aug 2011 05:03:56 -0400
Message-ID: <4E54BF6B.4020803@cn.fujitsu.com>
Date: Wed, 24 Aug 2011 17:07:55 +0800
From: Mi Jinlong <mijinlong@cn.fujitsu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [RFC][PATCH v2] nfsd41: try to check reply size before operation
References: <4E0C31B5.9090302@cn.fujitsu.com> <20110706201920.GA32275@fieldses.org> <4E4F8853.8080607@cn.fujitsu.com> <20110823213916.GB25350@fieldses.org>
In-Reply-To: <20110823213916.GB25350@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



J. Bruce Fields :
> On Sat, Aug 20, 2011 at 06:11:31PM +0800, Mi Jinlong wrote:
>> For checking the size of reply before calling a operation, 
>> we need try to get maxsize of the operation's reply.
>>
>> v1->v2:
>>     move op_enc_size from nfsd4_enc_ops to nfsd4_operation;
>>     add helper function to get payload len which is need as READ, READDIR ...
> 
> I just want to make sure I understand the logic here.  So while
> encoding this operation, we estimate the size of the *next* operation:

  Yes,

> 
>> @@ -1466,6 +1791,22 @@ static const char *nfsd4_op_name(unsigned opnum)
>>  	return "unknown_operation";
>>  }
>>  
>> +u32 get_ops_max_respz(struct svc_rqst * rqstp)
>> +{
>> +	struct nfsd4_compoundargs *args = rqstp->rq_argp;
>> +	struct nfsd4_compoundres *resp = rqstp->rq_resp;
>> +	__be32 opnum = args->ops[resp->opcnt].opnum;
>> +	__be32 length = 0;
>> +
>> +	length = nfsd4_ops[opnum].op_enc_size * 4;
>> +	if (nfsd4_ops[opnum].op_payload)
>> +		length += nfsd4_ops[opnum].op_payload(rqstp);
>> +
>> +	dprintk("%s opnum %u max reply %u\n", __func__, opnum, length);
>> +
>> +	return length;
>> +}
>> +
>>  #define nfsd4_voidres			nfsd4_voidargs
>>  struct nfsd4_voidargs { int dummy; };
> 
> and we stick the result into the next op's status field:

  Yes,

> 
>> @@ -3374,10 +3373,14 @@ static int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
>>  	dprintk("%s length %u, xb->page_len %u tlen %u pad %u\n", __func__,
>>  		length, xb->page_len, tlen, pad);
>>  
>> -	if (length <= session->se_fchannel.maxresp_cached)
>> -		return status;
>> -	else
>> -		return nfserr_rep_too_big_to_cache;
>> +	if (length > session->se_fchannel.maxresp_sz)
>> +		args->ops[resp->opcnt].status = nfserr_rep_too_big;
>> +
>> +	if (slot->sl_cachethis == 1 &&
>> +	    length > session->se_fchannel.maxresp_cached)
>> +		args->ops[resp->opcnt].status = nfserr_rep_too_big_to_cache;
>> +
>> +	return 0;
>>  }
> 
> and then we check that status and use it when we process the next
> compound:

  Yes,

> 
>> @@ -1188,7 +1196,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
>>  			goto encode_op;
>>  		}
>>  
>> -		if (opdesc->op_func)
>> +		if (op->status == 0 && opdesc->op_func)
>>  			op->status = opdesc->op_func(rqstp, cstate, &op->u);
>>  		else
>>  			BUG_ON(op->status == nfs_ok);
> 
> Do I have that right?

  Yes, you are right.

> 
> Is there some reason we need to do it that way?  Why not instead do
> something like:

 It sounds great!
 I will have a try.

> 
> 		}
> 
>  +		op->status == nfsd4_check_resp_size(resp)
>  +		if (op->status)
>  +			goto encode_op;
> 		if (opdesc->op_func)
> 			op->status = opdesc->op_func(rqstp-, cstate, &op->u);
> 
> in nfsd4_proc_compound.
> 
> A minor nitpick (already in the existing code):
> 
>> @@ -3336,32 +3336,31 @@ static nfsd4_enc nfsd4_enc_ops[] = {
>>   * Calculate the total amount of memory that the compound response has taken
>>   * after encoding the current operation.
>>   *
>> - * pad: add on 8 bytes for the next operation's op_code and status so that
>> - * there is room to cache a failure on the next operation.
>> - *
>> - * Compare this length to the session se_fmaxresp_cached.
>> + * Compare this length to the session se_fmaxresp_sz and se_fmaxresp_cached.
>>   *
>>   * Our se_fmaxresp_cached will always be a multiple of PAGE_SIZE, and so
>>   * will be at least a page and will therefore hold the xdr_buf head.
>>   */
>> -static int nfsd4_check_drc_limit(struct nfsd4_compoundres *resp)
>> +static int nfsd4_check_resp_limit(struct nfsd4_compoundres *resp)
>>  {
>>  	int status = 0;
> 
> Status is *always* 0 in this function.  Let's just get rid of it.

  OK.

> 
> Oh boy:
> 
>> +static u32 nfsd4_enc_getattr_playload(struct svc_rqst *rqstp)
>> +{
>> +	struct nfsd4_compoundargs *args = rqstp->rq_argp;
>> +	struct nfsd4_compoundres *resp = rqstp->rq_resp;
>> +	struct nfsd4_op op = args->ops[resp->opcnt];
>> +	u32 *bmval = op.u.getattr.ga_bmval;
>> +	u32 bmval0 = bmval[0];
>> +	u32 bmval1 = bmval[1];
>> +	u32 bmval2 = bmval[2];
>> +	u32 mlen = 0, lc = 0;
>> +
>> +	if (bmval2)
>> +		mlen += 16;
>> +	else if (bmval1)
>> +		mlen += 12;
>> +	else
>> +		mlen += 8;
>> +
>> +	if (bmval0 & FATTR4_WORD0_SUPPORTED_ATTRS) {
>> +		if (!nfsd_suppattrs2(resp->cstate.minorversion))
>> +			mlen += 12;
>> +		else
>> +			mlen += 16;
>> +	}
>> +
>> +	if (bmval0 & FATTR4_WORD0_TYPE)
>> +		mlen += 4;
>> +	if (bmval0 & FATTR4_WORD0_FH_EXPIRE_TYPE)
>> +		mlen += 4;
> 
> 
> This is getting complicated....

  Agree,

> 
> The thing is, some of the most complicated ops (read, readdir, getattr)
> don't *really* matter that much, because they don't change anything on
> the filesystem, and don't change the server state in any way.
> 
> So maybe we could handle operations in two different ways:
> 
> 	- For operations that actually change something (write, rename,
> 	  open, close, ...), do it the way we're doing it now: be
> 	  very careful to estimate the size of the response before even
> 	  processing the operation.
> 	- For operations that don't change anything (read, getattr, ...)
> 	  just go ahead and do the operation.  If you realize after the
> 	  fact that the response is too large, then return the error at
> 	  that point.
> 
> So we'd add another flag to op_flags: say, OP_MODIFIES_SOMETHING.  And for
> operations with OP_MODIFIES_SOMETHING set, we'd do the first thing.  For
> operations without it set, we'd do the second.
> 
> Would there be any problem with doing it that way?

  No, I will try to do it as that.

  Thanks for comment!


-- 
----
thanks
Mi Jinlong

