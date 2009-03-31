From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/47] NFSv4.1 Sessions server code for 2.6.30
Date: Tue, 31 Mar 2009 10:04:02 +0300
Message-ID: <49D1C062.5040900@panasas.com>
References: <49CC40E5.2080506@panasas.com> <20090328000134.GH18222@fieldses.org> <49CDDFC2.4070402@panasas.com> <20090330183338.GE31237@fieldses.org> <49D1178B.50408@panasas.com> <20090330190710.GG31237@fieldses.org> <49D11FC7.8030007@panasas.com> <20090330211514.GL31237@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ricardo Labiaga <ricardo.labiaga@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:9248 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751219AbZCaHEH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2009 03:04:07 -0400
In-Reply-To: <20090330211514.GL31237@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 31, 2009, 0:15 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Mon, Mar 30, 2009 at 10:38:47PM +0300, Benny Halevy wrote:
>> On Mar. 30, 2009, 22:07 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>> On Mon, Mar 30, 2009 at 10:03:39PM +0300, Benny Halevy wrote:
>>>> On Mar. 30, 2009, 21:33 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>>> On Sat, Mar 28, 2009 at 11:28:50AM +0300, Benny Halevy wrote:
>>>>>> On Mar. 28, 2009, 3:01 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>>>>> On Fri, Mar 27, 2009 at 05:58:45AM +0300, Benny Halevy wrote:
>>>>>>>> Hi Bruce,
>>>>>>>>
>>>>>>>> Here's the latest server patches implementing the NFSv4.1
>>>>>>>> Sessions features.
>>>>>>>>
>>>>>>>> This patchset is based over your for-2.6.30 branch
>>>>>>>> and is also available from
>>>>>>>> git://linux-nfs.org/~bhalevy/linux-pnfs.git nfsd41-for-2.6.30
>>>>>>> There's a few merge conflicts with my current for-2.6.30--probably my
>>>>>>> fault for not pushing that out recently enough, apologies.  Would you
>>>>>>> mind updating?
>>>>>>>
>>>>>>> --b.
>>>>>>>
>>>>>> Sure. Here's a rebased version with two minor changes (see below)
>>>>> On the latest version of nfsd41-for-2.6.30 (a564667..) I'm getting a new NULL
>>>>> dereference in the callback code.  Looks like it probably happened while
>>>>> running connectathon over NFSv4.0 with krb5p.  That's all I've figured out so
>>>> Weird. nfs4_xdr_dec_cb_recall+0x4e doesn't seem like a valid IP
>>>> for nfsd.ko @a564667.  Bruce, can you please send me you .config file?
>>> I'm building without CONFIG_NFSD_V4_1 for now; .config appended.
>> It looks like rpc_res would be NULL without CONFIG_NFSD_V4_1.
>> Does the following patch help?
> 
> Yep!

Cool.  I'll add this as a SQUASHME patch.

Benny

> 
> --b.
> 
>> Benny
>>
>> git diff --stat -p
>>  fs/nfsd/nfs4callback.c |    8 +++++---
>>  1 files changed, 5 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
>> index 02e0a61..10c6a80 100644
>> --- a/fs/nfsd/nfs4callback.c
>> +++ b/fs/nfsd/nfs4callback.c
>> @@ -441,9 +441,11 @@ nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p,
>>  	status = decode_cb_compound_hdr(&xdr, &hdr);
>>  	if (status)
>>  		goto out;
>> -	status = decode_cb_sequence(&xdr, rpc_res->res_seq, rqstp);
>> -	if (status)
>> -		goto out;
>> +	if (rpc_res && rpc_res->res_seq) {
>> +		status = decode_cb_sequence(&xdr, rpc_res->res_seq, rqstp);
>> +		if (status)
>> +			goto out;
>> +	}
>>  	status = decode_cb_op_hdr(&xdr, OP_CB_RECALL);
>>  out:
>>  	return status;
>>
