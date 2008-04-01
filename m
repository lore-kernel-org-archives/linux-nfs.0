From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 2/2] nfs: use compound hdr.status to override op status.
Date: Tue, 01 Apr 2008 12:37:33 +0300
Message-ID: <47F2025D.3030306@panasas.com>
References: <47F0F6AB.3030302@panasas.com>	 <1206974900-368-1-git-send-email-bhalevy@panasas.com> <1207002349.15341.15.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:29349 "EHLO
	cassoulet.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755978AbYDAJhu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Apr 2008 05:37:50 -0400
In-Reply-To: <1207002349.15341.15.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 01, 2008, 1:25 +0300, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Mon, 2008-03-31 at 17:48 +0300, Benny Halevy wrote:
>> The compound header status must be equivalent to the
>> status of the last operation in the compound results.
>> In certain cases like lack of resources or xdr decoding error,
>> the nfs server may return a non-zero status in the compound header
>> which is not returned by any operation.  In this case we would
>> notice that today when looking for the respective operations
>> code in the results and we return -EIO when we cannot find it.
>> This patch fixes that by returning the status available in the
>> comound header instead.
>>
>> This patch also fixes 3 call sites where we looked at the comound
>> hdr.status in the success case which is useless (yet benign).
>> These are nfs4_xdr_dec_{fsinfo,setclientid,setclientid_confirm}
>>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/nfs4xdr.c |   74 +++++++++++++++++++++++++++++++++++++++++++++++++----
>>  1 files changed, 68 insertions(+), 6 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index bb95b7c..edaa2fe 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -3779,6 +3779,8 @@ static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp, __be32 *p, struct
>>  		goto out;
>>  	decode_getfattr(&xdr, res->fattr, res->server);
>>  out:
>> +	if (hdr.status)
>> +		status = nfs4_stat_to_errno(hdr.status);
> 
> This changes the return value so that the outcome of the RPC call now
> depends on the success of a previously optional post-op GETATTR
> operation. For non-idempotent RPC calls, that's not acceptable.

Point taken.

Please see the patch in reply to this message.
It takes a different approach which overrides the status
only in the error case. For example:

+#define nfs4_fixup_status(status, hdr_status) \
+	( likely(!status) ? 0 : nfs4_stat_to_errno(hdr_status) )
+
 /*
  * Decode OPEN_DOWNGRADE response
  */
@@ -3779,7 +3782,7 @@ static int nfs4_xdr_dec_open_downgrade(struct rpc_rqst *rqstp, __be32 *p, struct
 		goto out;
 	decode_getfattr(&xdr, res->fattr, res->server);
 out:
-        return status;
+	return nfs4_fixup_status(status, hdr.status);
 }
 
 /*

Benny

P.S. The reason I defined this macro rather than a static inline function
is that it produced the smallest machine code (for x86_64, as reported by
objdump -h).
