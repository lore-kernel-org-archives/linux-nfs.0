From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH v3] nfs: use compound hdr.status to override op status.
Date: Sun, 11 May 2008 18:54:47 -0700
Message-ID: <4827A367.7010403@panasas.com>
References: <47F0F6AB.3030302@panasas.com>	 <1206974900-368-1-git-send-email-bhalevy@panasas.com>	 <1207002349.15341.15.camel@heimdal.trondhjem.org>	 <47F2025D.3030306@panasas.com> <47F20334.7040208@panasas.com>	 <4824E08E.6070401@panasas.com> <1210440276.12927.0.camel@localhost>	 <48277F7B.2060307@panasas.com> <1210548365.7796.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:17602 "EHLO
	cassoulet.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754374AbYELBzL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 May 2008 21:55:11 -0400
In-Reply-To: <1210548365.7796.2.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 11, 2008, 16:26 -0700, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Sun, 2008-05-11 at 16:21 -0700, Benny Halevy wrote:
>> The compound header status must be equivalent to the
>> status of the last operation in the compound results.
>> In certain cases like lack of resources or xdr decoding error,
>> the nfs server may return a non-zero status in the compound header
>> which is not returned by any operation.  In this case we would
>> notice that today when looking for the respective operations
>> code in the results and we return -EIO when we cannot find it.
>> This patch fixes that by returning the status available in the
>> compound header instead.
>>
>> This patch also fixes 3 call sites where we looked at the compound
>> hdr.status in the success case which is useless (yet benign).
>> These are nfs4_xdr_dec_{fsinfo,setclientid,setclientid_confirm}
>>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/nfs4xdr.c |   88 +++++++++++++++++++++++++++---------------------------
>>  1 files changed, 44 insertions(+), 44 deletions(-)
>>
>> Changes in PATCH v3:
>> * nfs4_fixup_status made static inline (with very minor increase
>> in code size over macro)
>>
>> Changes in PATCH v2:
>> * rebased onto 2.6.26 (off of linux-2.6 28a4acb4)
>> * fixed checkpatch.pl nits
>> * do not fixup status in nfs4_xdr_enc_setacl
>>
>>
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index 5a2d649..e6f7f0b 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -3791,6 +3791,13 @@ static int decode_delegreturn(struct xdr_stream *xdr)
>>  	return decode_op_hdr(xdr, OP_DELEGRETURN);
>>  }
>>  
>> +static inline int nfs4_fixup_status(int status, int hdr_status)
>> +{
>> +	if (likely(!status))
>> +		return 0;
>> +	return nfs4_stat_to_errno(hdr_status);
>> +}
>> +
>>  /*
>>   * Decode OPEN_DOWNGRADE response
>>   */
>> @@ -3812,7 +3819,7 @@ static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp, __be32 *p, struct
>>  		goto out;
>>  	decode_getfattr(&xdr, res->fattr, res->server);
>>  out:
>> -        return status;
>> +	return nfs4_fixup_status(status, hdr.status);
>>  }
> 
> NACK.
> 
> This is still screwed up: if the getattr above fails, then your change
> will propagate that error despite the fact that we don't care. Please
> see the same comments on earlier drafts of this patch.
> 

Trond, sorry, but I don't see the problem.

If all ops before the getattr succeeded then "status" will be zero
regardless if getattr failed or not and nfs4_fixup_status will
return success.

If any other op before the getattr failed then getfattr will not get
processed and hdr.status will contain the latest failure.

Benny
