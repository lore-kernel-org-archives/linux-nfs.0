Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f51.google.com ([209.85.220.51]:49705 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753340AbaHSPLh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Aug 2014 11:11:37 -0400
Message-ID: <53F368FC.6070205@gmail.com>
Date: Tue, 19 Aug 2014 23:10:52 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@poochiereds.net>
CC: Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-fsdevel@vger.kernel.org, kinglongmee@gmail.com
Subject: Re: [PATCH 2/5 v3] locks: Copy all infomation for conflock
References: <53BAAAC5.9000106@gmail.com>	<53E22EA5.70708@gmail.com>	<20140809065112.700e0ecc@tlielax.poochiereds.net>	<53E791F1.40802@gmail.com>	<53ED4F30.4060308@gmail.com>	<20140815071450.498949d8@tlielax.poochiereds.net>	<53EE1A4E.1010707@gmail.com>	<53EF5E35.5090501@gmail.com>	<53F0B13D.2040700@gmail.com> <20140818075433.5f74288e@tlielax.poochiereds.net>
In-Reply-To: <20140818075433.5f74288e@tlielax.poochiereds.net>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 8/18/2014 19:54, Jeff Layton wrote:
> On Sun, 17 Aug 2014 21:42:21 +0800
> Kinglong Mee <kinglongmee@gmail.com> wrote:
> 
>> On 8/16/2014 21:35, Kinglong Mee wrote:
>>> On 8/15/2014 22:33, Kinglong Mee wrote:
>>>> On 8/15/2014 19:14, Jeff Layton wrote:
>>>>> On Fri, 15 Aug 2014 08:07:12 +0800
>>>>> Kinglong Mee <kinglongmee@gmail.com> wrote:
>>>>>
>>>>>> Commit d5b9026a67 ([PATCH] knfsd: locks: flag NFSv4-owned locks) using
>>>>>> fl_lmops field in file_lock for checking nfsd4 lockowner.
>>>>>>
>>>>>> But, commit 1a747ee0cc (locks: don't call ->copy_lock methods on return
>>>>>> of conflicting locks) causes the fl_lmops of conflock always be NULL.
>>>>>>
>>>>>> Also, commit 0996905f93 (lockd: posix_test_lock() should not call
>>>>>> locks_copy_lock()) caused the fl_lmops of conflock always be NULL too.
>>>>>>
>>>>>> Make sure copy the private information by fl_copy_lock() in struct
>>>>>> file_lock_operations, merge __locks_copy_lock() to fl_copy_lock().
>>>>>>
>>>>>> v3: Update based on Joe and Jeff's patch.
>>>>>>
>>>>>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>>>>>> ---
>>>>>>  fs/locks.c         | 24 +++++++-----------------
>>>>>>  include/linux/fs.h |  6 ------
>>>>>>  2 files changed, 7 insertions(+), 23 deletions(-)
>>>>>>
>>>>>> diff --git a/fs/locks.c b/fs/locks.c
>>>>>> index cb66fb0..fe52abb 100644
>>>>>> --- a/fs/locks.c
>>>>>> +++ b/fs/locks.c
>>>>>> @@ -281,33 +281,23 @@ static void locks_copy_private(struct file_lock *new, struct file_lock *fl)
>>>>>>  /*
>>>>>>   * Initialize a new lock from an existing file_lock structure.
>>>>>>   */
>>>>>> -void __locks_copy_lock(struct file_lock *new, const struct file_lock *fl)
>>>>>> +void locks_copy_lock(struct file_lock *new, struct file_lock *fl)
>>>>>>  {
>>>>>> +	/* "new" must be a freshly-initialized lock */
>>>>>> +	WARN_ON_ONCE(new->fl_ops);
>>>>>> +
>>>>>>  	new->fl_owner = fl->fl_owner;
>>>>>>  	new->fl_pid = fl->fl_pid;
>>>>>> -	new->fl_file = NULL;
>>>>>> +	new->fl_file = fl->fl_file;
>>>>>>  	new->fl_flags = fl->fl_flags;
>>>>>>  	new->fl_type = fl->fl_type;
>>>>>>  	new->fl_start = fl->fl_start;
>>>>>>  	new->fl_end = fl->fl_end;
>>>>>>  	new->fl_ops = NULL;
>>>>>>  	new->fl_lmops = NULL;
>>>>>> -}
>>>>>> -EXPORT_SYMBOL(__locks_copy_lock);
>>>>>> -
>>>>>> -void locks_copy_lock(struct file_lock *new, struct file_lock *fl)
>>>>>> -{
>>>>>> -	/* "new" must be a freshly-initialized lock */
>>>>>> -	WARN_ON_ONCE(new->fl_ops);
>>>>>> -
>>>>>> -	__locks_copy_lock(new, fl);
>>>>>> -	new->fl_file = fl->fl_file;
>>>>>> -	new->fl_ops = fl->fl_ops;
>>>>>> -	new->fl_lmops = fl->fl_lmops;
>>>>>>  
>>>>>>  	locks_copy_private(new, fl);
>>>>>>  }
>>>>>> -
>>>>>>  EXPORT_SYMBOL(locks_copy_lock);
>>>>>>  
>>>>>>  static inline int flock_translate_cmd(int cmd) {
>>>>>> @@ -735,7 +725,7 @@ posix_test_lock(struct file *filp, struct file_lock *fl)
>>>>>>  			break;
>>>>>>  	}
>>>>>>  	if (cfl) {
>>>>>> -		__locks_copy_lock(fl, cfl);
>>>>>> +		locks_copy_lock(fl, cfl);
>>>>>>  		if (cfl->fl_nspid)
>>>>>>  			fl->fl_pid = pid_vnr(cfl->fl_nspid);
>>>>>>  	} else
>>>>>> @@ -941,7 +931,7 @@ static int __posix_lock_file(struct inode *inode, struct file_lock *request, str
>>>>>>  			if (!posix_locks_conflict(request, fl))
>>>>>>  				continue;
>>>>>>  			if (conflock)
>>>>>> -				__locks_copy_lock(conflock, fl);
>>>>>> +				locks_copy_lock(conflock, fl);
>>>>>>  			error = -EAGAIN;
>>>>>>  			if (!(request->fl_flags & FL_SLEEP))
>>>>>>  				goto out;
>>>>>> diff --git a/include/linux/fs.h b/include/linux/fs.h
>>>>>> index 908af4f..a383a30 100644
>>>>>> --- a/include/linux/fs.h
>>>>>> +++ b/include/linux/fs.h
>>>>>> @@ -966,7 +966,6 @@ void locks_free_lock(struct file_lock *fl);
>>>>>>  extern void locks_init_lock(struct file_lock *);
>>>>>>  extern struct file_lock * locks_alloc_lock(void);
>>>>>>  extern void locks_copy_lock(struct file_lock *, struct file_lock *);
>>>>>> -extern void __locks_copy_lock(struct file_lock *, const struct file_lock *);
>>>>>>  extern void locks_remove_posix(struct file *, fl_owner_t);
>>>>>>  extern void locks_remove_file(struct file *);
>>>>>>  extern void locks_release_private(struct file_lock *);
>>>>>> @@ -1026,11 +1025,6 @@ static inline void locks_init_lock(struct file_lock *fl)
>>>>>>  	return;
>>>>>>  }
>>>>>>  
>>>>>> -static inline void __locks_copy_lock(struct file_lock *new, struct file_lock *fl)
>>>>>> -{
>>>>>> -	return;
>>>>>> -}
>>>>>> -
>>>>>>  static inline void locks_copy_lock(struct file_lock *new, struct file_lock *fl)
>>>>>>  {
>>>>>>  	return;
>>>>>
>>>>> I'm not sure this is really what you want to do. Calling fl_copy_lock
>>>>> for a conflock looks relatively harmless for nfs and nlm. AFS though
>>>>> seems to add the lock to a list associated with the inode. That seems a
>>>>> little suspicious for a conflock and could be problematic. It may be
>>>>> best to avoid dealing with fl_ops for a conflock.
>>>>>
>>>>> Also in the case of fcntl_getlk, the struct file_lock lives on the
>>>>> stack, and locks_release_private is never called on it. You'll need to
>>>>> audit all of the current callers of __locks_copy_lock to ensure that
>>>>> any resources you end up taking references on when copying the conflock
>>>>> are eventually released.
>>>>
>>>> Sorry for my no further think about it.
>>>> I will check that again next day.
>>>
>>> I think we should not change the logical of coping lock,
>>> leave fl_ops and fl_lmops as private data as right now.
> 
> Why not? I think we'd benefit from making conflock creation a more
> distinct operation.
> 
>>>
>>> I have plan to,
>>> 1. move fl_owner assign from __locks_copy_lock() to locks_copy_private(),
>>>    I think it should be a private data, am I right?
>>> 2. call locks_copy_private() coping private data specifically.
>>>    a. add an argument for posix_test_lock() and __posix_lock_file() and etc,
>>>       to point whether coping private data.
>>>    b. hack the conflock's fl_flags to do the same thing as a,
>>>       adds FL_NEED_PRIV fl_flags only valid for conflock.
>>>
>>> I don't think 2.a is a nice resolve, because it changes the interface
>>> and many caller don't care the private data (I think contains fl_owner)
>>> for conflock except nfsd.
>>>
>>> So, I'd like *2.b*. A draft is appended as following,
>>
>> I'm so sorry for the first draft, there is a bug of it.
>> Please using the new draft.
>>
>> thanks,
>> Kinglong Mee
>>
> 
> Personally, I'm not a fan of the approach below. I don't think we need
> a new flag for this and it doesn't do anything to solve the problem
> where the lockowner could go away while you're operating on it in a
> conflock.

I just want fix the bug with minimal code change.
But, I known my fault now.

> 
> I think we need several smaller changes:
> 
> 1. Right now __locks_copy_lock is only used to copy conflocks. It would
> be good to rename that to something more distinct (i.e.
> locks_copy_conflock), to make it clear that we're generating a conflock
> there.
> 
> 2. Set fl_lmops on conflocks, but don't set fl_ops. fl_ops are
> superfluous, since they are callbacks into the filesystem. There should
> be no need to bother the filesystem at all with info in a conflock.
> But, lock _ownership_ matters for conflocks and that's indicated by the
> fl_lmops. So you really do want to copy the fl_lmops for conflocks I
> think.
> 
> 3. Add the operations you added before to fl_lmops to copy and release
> the owner (maybe even rename them lm_get_owner/lm_put_owner?), and
> ensure that the places that copy conflocks call those operations
> appropriately.
> 
> That should be all that's required here.

I think I know what you are advice.
I will send an update patch as v4.

thanks,
Kinglong Mee
