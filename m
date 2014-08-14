Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f177.google.com ([209.85.192.177]:57508 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754653AbaHNNAT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Aug 2014 09:00:19 -0400
Message-ID: <53ECB2BA.3060804@gmail.com>
Date: Thu, 14 Aug 2014 20:59:38 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Joe Perches <joe@perches.com>, Jeff Layton <jeff.layton@primarydata.com>,
        Andrew Morton <akpm@linux-foundation.org>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 1/3 v2] fs/locks.c: Copy all information for conflock
References: <53BAAAC5.9000106@gmail.com> <53E22EA5.70708@gmail.com>	 <20140809065112.700e0ecc@tlielax.poochiereds.net>	 <53E791F1.40802@gmail.com>	 <20140811121949.4c3d7894@tlielax.poochiereds.net> <1407774312.20795.20.camel@joe-AO725>
In-Reply-To: <1407774312.20795.20.camel@joe-AO725>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/12/2014 00:25, Joe Perches wrote:
> On Mon, 2014-08-11 at 12:19 -0400, Jeff Layton wrote:
>> On Sun, 10 Aug 2014 23:38:25 +0800
>> Kinglong Mee <kinglongmee@gmail.com> wrote:
>>
>>> Commit d5b9026a67 ([PATCH] knfsd: locks: flag NFSv4-owned locks) using
>>> fl_lmops field in file_lock for checking nfsd4 lockowner.
>>>
>>> But, commit 1a747ee0cc (locks: don't call ->copy_lock methods on return
>>> of conflicting locks) causes the fl_lmops of conflock always be NULL.
>>>
>>> Also, commit 0996905f93 (lockd: posix_test_lock() should not call
>>> locks_copy_lock()) caused the fl_lmops of conflock always be NULL too.
>>>
>>> v2: Only change the order from 3/3 to 1/3 now.
>>>
>>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>>> ---
>>>  fs/lockd/svclock.c |  2 +-
>>>  fs/locks.c         | 25 ++++++-------------------
>>>  include/linux/fs.h |  6 ------
>>>  3 files changed, 7 insertions(+), 26 deletions(-)
>>>
>>> diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
>>> index ab798a8..e1f209c 100644
>>> --- a/fs/lockd/svclock.c
>>> +++ b/fs/lockd/svclock.c
>>> @@ -677,7 +677,7 @@ nlmsvc_update_deferred_block(struct nlm_block *block, struct file_lock *conf,
>>>  		block->b_flags |= B_TIMED_OUT;
>>>  	if (conf) {
>>>  		if (block->b_fl)
>>> -			__locks_copy_lock(block->b_fl, conf);
>>> +			locks_copy_lock(block->b_fl, conf);
>>>  	}
>>>  }
>>>  
>>> diff --git a/fs/locks.c b/fs/locks.c
>>> index 717fbc4..91b0f03 100644
>>> --- a/fs/locks.c
>>> +++ b/fs/locks.c
>>> @@ -266,35 +266,22 @@ static void locks_copy_private(struct file_lock *new, struct file_lock *fl)
>>>  		new->fl_lmops = fl->fl_lmops;
>>>  }
>>>  
>>> -/*
>>> - * Initialize a new lock from an existing file_lock structure.
>>> - */
>>> -void __locks_copy_lock(struct file_lock *new, const struct file_lock *fl)
>>> +void locks_copy_lock(struct file_lock *new, struct file_lock *fl)
>>>  {
>>> +	locks_release_private(new);
>>> +
>>>  	new->fl_owner = fl->fl_owner;
>>>  	new->fl_pid = fl->fl_pid;
>>> -	new->fl_file = NULL;
>>> +	new->fl_file = fl->fl_file;
>>>  	new->fl_flags = fl->fl_flags;
>>>  	new->fl_type = fl->fl_type;
>>>  	new->fl_start = fl->fl_start;
>>>  	new->fl_end = fl->fl_end;
>>>  	new->fl_ops = NULL;
>>>  	new->fl_lmops = NULL;
>>> -}
>>> -EXPORT_SYMBOL(__locks_copy_lock);
>>> -
>>> -void locks_copy_lock(struct file_lock *new, struct file_lock *fl)
>>> -{
>>> -	locks_release_private(new);
>>> -
>>> -	__locks_copy_lock(new, fl);
>>> -	new->fl_file = fl->fl_file;
>>> -	new->fl_ops = fl->fl_ops;
>>> -	new->fl_lmops = fl->fl_lmops;
>>>  
>>>  	locks_copy_private(new, fl);
>>>  }
>>
>> (cc'ing Joe Perches)
> 
> (cc'ing Andrew Morton too)
> 
>> Ok, so you're basically just reverting 1a747ee0cc11a19. The catch there
>> is that you now need to ensure that any conflock structures are
>> properly initialized before passing them to locks_copy_lock.
>>
>> The nfsv4 server code currently doesn't do that and it will need to be
>> fixed to do so or that will be a regression.
>>
>> For the NLM code, Joe Perches has proposed a patch to remove the
>> conflock parameter from lm_grant since the callers always pass in NULL
>> anyway. You may want to pull in his patch and rebase yours on top of it
>> since it'll remove that __locks_copy_lock call altogether.
>>
>> Joe, is Andrew merging that patch or do I need to pull it into the
>> locks tree?
> 
> I believe Andrew is merging it.

Sorry for I don't known Andrew's git tree,
Can you offer me? Thank you very much.

thanks,
Kinglong Mee
