Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f41.google.com ([209.85.220.41]:55301 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbaHOOaB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Aug 2014 10:30:01 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so3553480pab.14
        for <linux-nfs@vger.kernel.org>; Fri, 15 Aug 2014 07:30:00 -0700 (PDT)
Message-ID: <53EE195A.6060100@gmail.com>
Date: Fri, 15 Aug 2014 22:29:46 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: Re: [PATCH 2/2] NFSD: Revert setting op_encode_lockowner_maxsz
References: <53E2EE2E.9040007@gmail.com> <20140811200118.GG9095@fieldses.org> <20140812175826.GE22365@fieldses.org> <53EE0ECB.5040202@gmail.com> <20140815135524.GB3343@fieldses.org>
In-Reply-To: <20140815135524.GB3343@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/15/2014 21:55, J. Bruce Fields wrote:
> On Fri, Aug 15, 2014 at 09:44:43PM +0800, Kinglong Mee wrote:
>> On 8/13/2014 01:58, J. Bruce Fields wrote:
>>> On Mon, Aug 11, 2014 at 04:01:18PM -0400, J. Bruce Fields wrote:
>>>> On Thu, Aug 07, 2014 at 11:10:38AM +0800, Kinglong Mee wrote:
>>>>> Commit 8c7424cff6 (nfsd4: don't try to encode conflicting owner if low on space)
>>>>> set op_encode_lockowner_maxsz to zero.
>>>>>
>>>>> If setting op_encode_lockowner_maxsz to zero, nfsd will not encode
>>>>> the owner of conflock forever.
>>>>
>>>> Right, so the problem is that the lock reply encoder is unique in that
>>>> it will happily adjust the xdr encoding if it's running out of space.
>>>>
>>>> This came about with 8c7424cff6 "nfsd4: don't try to encode conflicting
>>>> owner if low on space".  The problem is that:
>>>>
>>>> 	- the maximum size of a lock reply is kind of big (the original
>>>> 	  calculation below is actually wrong, IDMAP_NAMESZ should be
>>>> 	  NFS4_OPAQUE_LIMIT).
>>>> 	- we may not be the only server that's been sloppy about
>>>> 	  enforcing the theoretical maximum here, and I'd rather be
>>>> 	  forgiving to clients that don't insist on the theoretical
>>>> 	  maximum maxresp_cached.
>>>>
>>>> So best seems just to allow a LOCK even if space is insufficient and
>>>> just throw out the conflicting lockowner if there isn't enough space,
>>>> since large lockowners should be rare and we don't care about the
>>>> conflicting lockowner anyway.
>>>>
>>>> So anyway we need to leave the maximum reserved in rq_reserved without
>>>> changing the check we make before executing the LOCK.
>>>
>>> I think this is all we need, but I haven't actually tested whether it
>>> fixes the warnings.
>>>
>>> --b.
>>>
>>> commit 5e78bb7e34d6
>>> Author: J. Bruce Fields <bfields@redhat.com>
>>> Date:   Tue Aug 12 11:41:40 2014 -0400
>>>
>>>     nfsd4: reserve adequate space for LOCK op
>>>     
>>>     As of  8c7424cff6 "nfsd4: don't try to encode conflicting owner if low
>>>     on space", we permit the server to process a LOCK operation even if
>>>     there might not be space to return the conflicting lockowner, because
>>>     we've made returning the conflicting lockowner optional.
>>>     
>>>     However, the rpc server still wants to know the most we might possibly
>>>     return, so we need to take into account the possible conflicting
>>>     lockowner in the svc_reserve_space() call here.
>>>     
>>>     Symptoms were log messages like "RPC request reserved 88 but used 108".
>>>     
>>>     Fixes: 8c7424cff6 "nfsd4: don't try to encode conflicting owner if low on space"
>>>     Reported-by: Kinglong Mee <kinglongmee@gmail.com>
>>>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>>>
>>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>>> index 8112ce8f4b23..e771a1a7c6f1 100644
>>> --- a/fs/nfsd/nfs4xdr.c
>>> +++ b/fs/nfsd/nfs4xdr.c
>>> @@ -1663,6 +1663,14 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
>>>  			readbytes += nfsd4_max_reply(argp->rqstp, op);
>>>  		} else
>>>  			max_reply += nfsd4_max_reply(argp->rqstp, op);
>>> +		/*
>>> +		 * OP_LOCK may return a conflicting lock.  (Special case
>>> +		 * because it will just skip encoding this if it runs
>>> +		 * out of xdr buffer space, and it is the only operation
>>> +		 * that behaves this way.)
>>> +		 */
>>> +		if (op->opnum == OP_LOCK)
>>> +			max_reply += NFS4_OPAQUE_LIMIT;
>>>  
>>>  		if (op->status) {
>>>  			argp->opcnt = i+1;
>>>
>>
>> Yes, this patch can fixes the warnings.
>> But, I don't think it's the best fix for the problem.
>>
>> Why not save reply size of NFS4_OPAQUE_LIMIT in op_encode_lockowner_maxsz,
> 
> A lock request is nonidempotent, so clients usually want to cache it.
> This would force maxresp_cached to be larger than otherwise necessary.
> 
> Which I guess the spec already requires.  But I'd rather be forgiving if
> a client overlooks this and requests too small a maxresp_cached.

Got it, thanks.
I just test LOCK/LOCKT that on nfsv4.0, I will test on nfsv4.1 next day.

You can push out this patch on your git tree,
I will comment you if I have other questions. Thanks again.

> 
>> nfsd4_lockt also needs it.
> 
> nfsd4_lockt is nonidempotent (and probably not terribly common) so we
> don't care about it that much--there's not even a lockt_rsize defined
> for it.

Thanks for your comment.

thanks,
Kinglong Mee
