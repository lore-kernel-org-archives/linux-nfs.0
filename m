Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:36081 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612Ab2EOOSa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 10:18:30 -0400
Message-ID: <4FB2659C.5090005@panasas.com>
Date: Tue, 15 May 2012 17:18:04 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Dan Carpenter <dan.carpenter@oracle.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>,
        <kernel-janitors@vger.kernel.org>
Subject: Re: [patch] NFS: kmalloc() doesn't return an ERR_PTR()
References: <20120514194528.GA19613@elgon.mountain> <4FB25EA7.9050702@panasas.com> <20120515135733.GJ16984@mwanda>
In-Reply-To: <20120515135733.GJ16984@mwanda>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/15/2012 04:57 PM, Dan Carpenter wrote:

> On Tue, May 15, 2012 at 04:48:23PM +0300, Boaz Harrosh wrote:
>> On 05/14/2012 10:45 PM, Dan Carpenter wrote:
>>
>>> Obviously we should check for NULL here instead of IS_ERR().
>>>
>>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>>>
>>> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
>>> index ba3019f..233beea 100644
>>> --- a/fs/nfs/idmap.c
>>> +++ b/fs/nfs/idmap.c
>>> @@ -644,14 +644,14 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,
>>>  
>>>  	/* msg and im are freed in idmap_pipe_destroy_msg */
>>>  	msg = kmalloc(sizeof(*msg), GFP_KERNEL);
>>> -	if (IS_ERR(msg)) {
>>> -		ret = PTR_ERR(msg);
>>> +	if (!msg) {
>>
>>
>> While at it please put an unlikely()
>>
> 
> Normally we wouldn't put an unlikely() here.  It makes the code
> less readable and it's not going to affect benchmarks.  But I can
> add one if people prefer.
> 


Personally It makes it more readable for me. It's like a statement:
"error, always slow-path case here". I have brain parsers set
for these.

Specifically here the if () is very small but if it is more code
it is exactly where it counts. But as a general rule I like the
error/slow-path case to be in an unlikely(). Later someone
might add more code which will matter.

> regards,
> dan carpenter
> 


Thanks
Boaz
