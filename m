Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.15.15]:62774 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751084AbaGQUdM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jul 2014 16:33:12 -0400
Message-ID: <53C83305.7030407@gmx.de>
Date: Thu, 17 Jul 2014 22:33:09 +0200
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Kinglong Mee <kinglongmee@gmail.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: fuzz tested user mode linux crashed in NFS code path
References: <53C10EAA.2000802@gmx.de> <53C12A93.3040803@gmail.com> <20140716185724.GC2397@fieldses.org> <20140717202721.GG30442@fieldses.org>
In-Reply-To: <20140717202721.GG30442@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/17/2014 10:27 PM, J. Bruce Fields wrote:
> On Wed, Jul 16, 2014 at 02:57:24PM -0400, J. Bruce Fields wrote:
>> On Sat, Jul 12, 2014 at 08:31:15PM +0800, Kinglong Mee wrote:
>>> I think it is caused by kfree an uninitialized address.
>>> Can you test with the patch listed in following url,
>>> I have send some days before ?
>>>
>>> "[PATCH 1/4] NFSD: Fix memory leak in encoding denied lock"
>>> http://www.spinics.net/lists/linux-nfs/msg44719.html
>>
>> I have this queued for 3.17, but if it causes a crash then it should go
>> to 3.16 now.
>>
>> However, I'm confused: the only explicit initialization of lk_denied is
>> in the case vfs_lock_file() returns -EAGAIN.  Our usual tests (cthon,
>> pynfs) do lots of succesful locks, so should have hit this before.
>>
>> OK, I see: this memory zeroed by a memset in svc_process_common():
>>
>> 	memset(rqstp->rq_argp, 0, procp->pc_argsize);
>>
>> *But* in the case of the NFSv4 compound operation, we only have enough
>> space in rq_argp for 8 operations, anything more is allocated in
>> fs/nfsd/nfs4xdr.c:nfsd4_decode_compound:
>>
>> 	if (argp->opcnt > ARRAY_SIZE(argp->iops)) {
>> 		argp->ops = kmalloc(argp->opcnt * sizeof(*argp->ops), GFP_KERNEL);
>> 		...
>>
>> So, perhaps we got a compound with more than 8 operations, with the LOCK
>> operation in the 9th or later position?
>>
>> But the Linux NFS client doesn't do that, so I don't understand how
>> Toralf hit this.
>>
>> Am I missing anything here?
>>
>> Toralf, is that crash reproduceable?  If so, does replacing the above
>> kmalloc by a kcalloc also fix it?
> 
> Sorry, that should be kzalloc.  We should probably fix that regardless.
> 
> But I still don't understand how you hit this case....
> 
> --b.
> 
> commit 5d6031ca742f
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Thu Jul 17 16:20:39 2014 -0400
> 
>     nfsd4: zero op arguments beyond the 8th compound op
>     
>     The first 8 ops of the compound are zeroed since they're a part of the
>     argument that's zeroed by the
>     
>     	memset(rqstp->rq_argp, 0, procp->pc_argsize);
>     
>     in svc_process_common().  But we handle larger compounds by allocating
>     the memory on the fly in nfsd4_decode_compound().  Other than code
>     recently fixed by 01529e3f8179 "NFSD: Fix memory leak in encoding denied
>     lock", I don't know of any examples of code depending on this
>     initialization. But it definitely seems possible, and I'd rather be
>     safe.
>     
>     Compounds this long are unusual so I'm much more worried about failure
>     in this poorly tested cases than about an insignificant performance hit.
>     
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 01023a595163..628b430e743e 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1635,7 +1635,7 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
>  		goto xdr_error;
>  
>  	if (argp->opcnt > ARRAY_SIZE(argp->iops)) {
> -		argp->ops = kmalloc(argp->opcnt * sizeof(*argp->ops), GFP_KERNEL);
> +		argp->ops = kzalloc(argp->opcnt * sizeof(*argp->ops), GFP_KERNEL);
>  		if (!argp->ops) {
>  			argp->ops = argp->iops;
>  			dprintk("nfsd: couldn't allocate room for COMPOUND\n");
> 
I'm trying to reproduce it, but due to the nature of fuzz testing ...


-- 
Toralf

