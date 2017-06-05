Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from m12-12.163.com ([220.181.12.12]:42775 "EHLO m12-12.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751657AbdFEMe0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Jun 2017 08:34:26 -0400
Message-ID: <5935505B.8050009@163.com>
Date: Mon, 05 Jun 2017 20:36:43 +0800
From: Jia-Ju Bai <baijiaju1990@163.com>
MIME-Version: 1.0
To: Trond Myklebust <trondmy@primarydata.com>
CC: "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] fs: nfs: Fix a sleep-in-atomic bug in nfs_access_add_cache
References: <1496649904-1855-1-git-send-email-baijiaju1990@163.com> <1496663315.3433.1.camel@primarydata.com>
In-Reply-To: <1496663315.3433.1.camel@primarydata.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/05/2017 07:48 PM, Trond Myklebust wrote:
> On Mon, 2017-06-05 at 16:05 +0800, Jia-Ju Bai wrote:
>> The driver may sleep under a rcu read lock, and function call path
>> is:
>> nfs_permission (acquire the lock by rcu_read_lock)
>>    nfs_do_access
>>      nfs_access_add_cache
>>        kmalloc(GFP_KERNEL) -->  may sleep
>>
>> To fix it, "GFP_KERNEL" is replaced with "GFP_ATOMIC".
>>
>> Signed-off-by: Jia-Ju Bai<baijiaju1990@163.com>
>> ---
>>   fs/nfs/dir.c |    2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>> index 32ccd77..7a074db 100644
>> --- a/fs/nfs/dir.c
>> +++ b/fs/nfs/dir.c
>> @@ -2333,7 +2333,7 @@ static void nfs_access_add_rbtree(struct inode
>> *inode, struct nfs_access_entry *
>>   
>>   void nfs_access_add_cache(struct inode *inode, struct
>> nfs_access_entry *set)
>>   {
>> -	struct nfs_access_entry *cache = kmalloc(sizeof(*cache),
>> GFP_KERNEL);
>> +	struct nfs_access_entry *cache = kmalloc(sizeof(*cache),
>> GFP_ATOMIC);
>>   	if (cache == NULL)
>>   		return;
>>   	RB_CLEAR_NODE(&cache->rb_node);
> The RCU locked codepath will not ever hit nfs_access_add_rbtree(). It
> returns with an error code of -ECHILD after the test of "may_block".
>
> Cheers
>    Trond
Yes, I think you are right.

Thanks,
Jia-Ju Bai

