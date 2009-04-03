From: Felix Blyakher <felixb@sgi.com>
Subject: Re: [PATCH] lockd: call locks_release_private to cleanup per-filesystem state
Date: Fri, 3 Apr 2009 00:56:12 -0500
Message-ID: <B4947BA8-0B54-4A43-AF11-15C001BA875D@sgi.com>
References: <1238530376-28013-1-git-send-email-felixb@sgi.com> <20090402224601.GF18195@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090402224601.GF18195@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 2, 2009, at 5:46 PM, J. Bruce Fields wrote:

> On Tue, Mar 31, 2009 at 03:12:56PM -0500, Felix Blyakher wrote:
>> For every lock request lockd creates a new file_lock object
>> in nlmsvc_setgrantargs() by copying the passed in file_lock with
>> locks_copy_lock(). A filesystem can attach it's own lock_operations
>> vector to the file_lock. It has to be cleaned up at the end of the
>> file_lock's life. However, lockd doesn't do it today, yet it
>> asserts in nlmclnt_release_lockargs() that the per-filesystem
>> state is clean.
>> This patch fixes it by exporting locks_release_private() and adding
>> it to nlmsvc_freegrantargs(), to be symmetrical to creating a
>> file_lock in nlmsvc_setgrantargs().
>
> On a quick skim your diagnosis and fix both look correct to me,  
> thanks.

> I need to take another look and then I'll pass it along.  How did you
> originally notice this, and has this bug always existed,

AFAICT it's been there always.
It's just not usual to go that route. To trigger the bug nfs server
should be running a top of filesystem with its own fl_ops.
And the kernel must be post 2.6.24, were nfs started calling into
filesystem callouts. With that setup it's straightforward.
I did verify the fix by adding simple wrappers to generic posix lock
functions in fl_ops for xfs. At first I triggered the panic with the
following backtrace:

lockd[6142]: bugcheck! 0 [1]
...
Call Trace:
  [<a000000100016810>] show_stack+0x50/0xa0
                                 sp=e0000030ace8f9a0  
bsp=e0000030ace81350
  [<a000000100017080>] show_regs+0x820/0x860
                                 sp=e0000030ace8fb70  
bsp=e0000030ace812f8
  [<a00000010003bd60>] die+0x1a0/0x2c0
                                 sp=e0000030ace8fb70  
bsp=e0000030ace812b8
  [<a00000010003bed0>] die_if_kernel+0x50/0x80
                                 sp=e0000030ace8fb70  
bsp=e0000030ace81288
  [<a00000010068e440>] ia64_bad_break+0x220/0x440
                                 sp=e0000030ace8fb70  
bsp=e0000030ace81260
  [<a00000010000c800>] ia64_native_leave_kernel+0x0/0x270
                                 sp=e0000030ace8fc00  
bsp=e0000030ace81260
  [<a000000208132170>] nlm_release_call+0xb0/0x100 [lockd]
                                 sp=e0000030ace8fdd0  
bsp=e0000030ace81228
  [<a0000002081388b0>] nlmsvc_free_block+0x170/0x1e0 [lockd]
                                 sp=e0000030ace8fdd0  
bsp=e0000030ace81200
  [<a0000001003684a0>] kref_put+0xc0/0x100
                                 sp=e0000030ace8fdd0  
bsp=e0000030ace811d0
  [<a00000020813a4c0>] nlmsvc_lock+0x5c0/0x660 [lockd]
                                 sp=e0000030ace8fdd0  
bsp=e0000030ace81170
  [<a0000002081463d0>] nlm4svc_proc_lock+0x150/0x2a0 [lockd]
                                 sp=e0000030ace8fdd0  
bsp=e0000030ace81138
  [<a000000207a3b2a0>] svc_process+0xaa0/0x1be0 [sunrpc]
                                 sp=e0000030ace8fde0  
bsp=e0000030ace810e0
  [<a000000208137200>] lockd+0x340/0x460 [lockd]
                                 sp=e0000030ace8fdf0  
bsp=e0000030ace81090
  [<a0000001000deee0>] kthread+0xc0/0x140
                                 sp=e0000030ace8fe30  
bsp=e0000030ace81068
  [<a000000100014950>] kernel_thread_helper+0xd0/0x100
                                 sp=e0000030ace8fe30  
bsp=e0000030ace81040
  [<a00000010000a4c0>] start_kernel_thread+0x20/0x40
                                 sp=e0000030ace8fe30  
bsp=e0000030ace81040



And then verified it works correctly with the patch.

Felix

> or was there a
> previous kernel version where this worked?
>
>
> --b.
>
>>
>> Signed-off-by: Felix Blyakher <felixb@sgi.com>
>> ---
>> fs/lockd/svclock.c |    2 ++
>> fs/locks.c         |    3 ++-
>> include/linux/fs.h |    1 +
>> 3 files changed, 5 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
>> index 763b78a..865504a 100644
>> --- a/fs/lockd/svclock.c
>> +++ b/fs/lockd/svclock.c
>> @@ -326,6 +326,8 @@ static void nlmsvc_freegrantargs(struct  
>> nlm_rqst *call)
>> {
>> 	if (call->a_args.lock.oh.data != call->a_owner)
>> 		kfree(call->a_args.lock.oh.data);
>> +
>> +	locks_release_private(&call->a_args.lock.fl);
>> }
>>
>> /*
>> diff --git a/fs/locks.c b/fs/locks.c
>> index ec3deea..5b745dc 100644
>> --- a/fs/locks.c
>> +++ b/fs/locks.c
>> @@ -151,7 +151,7 @@ static struct file_lock *locks_alloc_lock(void)
>> 	return kmem_cache_alloc(filelock_cache, GFP_KERNEL);
>> }
>>
>> -static void locks_release_private(struct file_lock *fl)
>> +void locks_release_private(struct file_lock *fl)
>> {
>> 	if (fl->fl_ops) {
>> 		if (fl->fl_ops->fl_release_private)
>> @@ -165,6 +165,7 @@ static void locks_release_private(struct  
>> file_lock *fl)
>> 	}
>>
>> }
>> +EXPORT_SYMBOL(locks_release_private);
>>
>> /* Free a lock which is not in use. */
>> static void locks_free_lock(struct file_lock *fl)
>> diff --git a/include/linux/fs.h b/include/linux/fs.h
>> index 92734c0..3aa4ff6 100644
>> --- a/include/linux/fs.h
>> +++ b/include/linux/fs.h
>> @@ -1047,6 +1047,7 @@ extern void locks_copy_lock(struct file_lock  
>> *, struct file_lock *);
>> extern void __locks_copy_lock(struct file_lock *, const struct  
>> file_lock *);
>> extern void locks_remove_posix(struct file *, fl_owner_t);
>> extern void locks_remove_flock(struct file *);
>> +extern void locks_release_private(struct file_lock *);
>> extern void posix_test_lock(struct file *, struct file_lock *);
>> extern int posix_lock_file(struct file *, struct file_lock *,  
>> struct file_lock *);
>> extern int posix_lock_file_wait(struct file *, struct file_lock *);
>> -- 
>> 1.5.4.rc3
>>

