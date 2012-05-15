Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx01.sz.bfs.de ([194.94.69.103]:18702 "EHLO mx01.sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758946Ab2EOQtY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 May 2012 12:49:24 -0400
Message-ID: <4FB28911.1070500@bfs.de>
Date: Tue, 15 May 2012 18:49:21 +0200
From: walter harms <wharms@bfs.de>
Reply-To: wharms@bfs.de
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Dan Carpenter <dan.carpenter@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: Re: [patch] NFS: kmalloc() doesn't return an ERR_PTR()
References: <20120514194528.GA19613@elgon.mountain> <4FB25EA7.9050702@panasas.com> <20120515135733.GJ16984@mwanda> <4FB2659C.5090005@panasas.com>
In-Reply-To: <4FB2659C.5090005@panasas.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Am 15.05.2012 16:18, schrieb Boaz Harrosh:
> On 05/15/2012 04:57 PM, Dan Carpenter wrote:
> 
>> On Tue, May 15, 2012 at 04:48:23PM +0300, Boaz Harrosh wrote:
>>> On 05/14/2012 10:45 PM, Dan Carpenter wrote:
>>>
>>>> Obviously we should check for NULL here instead of IS_ERR().
>>>>
>>>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>>>>
>>>> diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
>>>> index ba3019f..233beea 100644
>>>> --- a/fs/nfs/idmap.c
>>>> +++ b/fs/nfs/idmap.c
>>>> @@ -644,14 +644,14 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,
>>>>  
>>>>  	/* msg and im are freed in idmap_pipe_destroy_msg */
>>>>  	msg = kmalloc(sizeof(*msg), GFP_KERNEL);
>>>> -	if (IS_ERR(msg)) {
>>>> -		ret = PTR_ERR(msg);
>>>> +	if (!msg) {
>>>
>>>
>>> While at it please put an unlikely()
>>>
>>
>> Normally we wouldn't put an unlikely() here.  It makes the code
>> less readable and it's not going to affect benchmarks.  But I can
>> add one if people prefer.
>>
> 
> 
> Personally It makes it more readable for me. It's like a statement:
> "error, always slow-path case here". I have brain parsers set
> for these.
> 
> Specifically here the if () is very small but if it is more code
> it is exactly where it counts. But as a general rule I like the
> error/slow-path case to be in an unlikely(). Later someone
> might add more code which will matter.
> 
>> regards,
>> dan carpenter
>>
> 
> 

Not long a go we had a hint from one of the developers that this likely()-stuff
should be used in the scheduler and has no use outside.

re,
 wh
