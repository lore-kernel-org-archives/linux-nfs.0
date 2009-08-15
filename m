From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH RFC v2 16/21] nfs: nfs4xdr: introduce decode_verifier
 helper
Date: Sat, 15 Aug 2009 13:27:04 +0300
Message-ID: <4A868D78.3070400@panasas.com>
References: <4A8571E2.8020800@panasas.com>	 <1250259596-13993-1-git-send-email-bhalevy@panasas.com> <1250272482.5476.14.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	lkml <linux-kernel@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:20442
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750856AbZHOK1U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 15 Aug 2009 06:27:20 -0400
In-Reply-To: <1250272482.5476.14.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug. 14, 2009, 20:54 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Fri, 2009-08-14 at 17:19 +0300, Benny Halevy wrote:
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/nfs4xdr.c |   20 +++++++++++---------
>>  1 files changed, 11 insertions(+), 9 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index 86e6983..b835dcc 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -3320,17 +3320,19 @@ static int decode_close(struct xdr_stream *xdr, struct nfs_closeres *res)
>>  	return status;
>>  }
>>  
>> +static int decode_verifier(struct xdr_stream *xdr, void *verifier)
>> +{
>> +	return decode_opaque_fixed(xdr, verifier, 8);
>> +}
>> +
>>  static int decode_commit(struct xdr_stream *xdr, struct nfs_writeres *res)
>>  {
>> -	__be32 *p;
>>  	int status;
>>  
>>  	status = decode_op_hdr(xdr, OP_COMMIT);
>> -	if (status)
>> -		return status;
>> -	READ_BUF(8);
>> -	COPYMEM(res->verf->verifier, 8);
>> -	return 0;
>> +	if (!status)
>> +		status = decode_verifier(xdr, res->verf->verifier);
>> +	return status;
>>  }
>>  
>>  static int decode_create(struct xdr_stream *xdr, struct nfs4_change_info *cinfo)
>> @@ -3852,10 +3854,10 @@ static int decode_readdir(struct xdr_stream *xdr, struct rpc_rqst *req, struct n
>>  	int		status;
>>  
>>  	status = decode_op_hdr(xdr, OP_READDIR);
>> -	if (status)
>> +	if (!status)
>> +		status = decode_verifier(xdr, readdir->verifier.data);
>> +	if (unlikely(status))
>>  		return status;
>> -	READ_BUF(8);
>> -	COPYMEM(readdir->verifier.data, 8);
>>  	dprintk("%s: verifier = %08x:%08x\n",
>>  			__func__,
>>  			((u32 *)readdir->verifier.data)[0],
> 
> This introduces an uninitialised variable warning into decode_readdir.
> The fix would be to use xdr->p in the calculation of hdrlen.
> 
> I'll add that, no need to resend.

Thanks!

Sadly, I didn't see this warning with gcc 4.4.0 on Fedora 11.
I'm not sure why, but without the -Os (optimize for size) option
it does print the warning. I tried this by manually running the gcc
command "make KBUILD_VERBOSE=1" prints - with and without the -Os option.

Benny
