Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-db5eur01on0099.outbound.protection.outlook.com ([104.47.2.99]:53472
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757009AbcHDOPK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Aug 2016 10:15:10 -0400
Reply-To: <skinsbursky@virtuozzo.com>
Subject: Re: [RFC PATCH] sunrpc: do not allow process to freeze within RPC
 state machine
References: <20160803165412.22407.47399.stgit@localhost.localdomain>
 <1470245777.13804.34.camel@redhat.com>
 <cb097e9e-760b-5512-ff4a-276b31bfc83f@virtuozzo.com>
 <1470316606.22052.17.camel@redhat.com>
To: Jeff Layton <jlayton@redhat.com>, <bfields@fieldses.org>,
        <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <gorcunov@virtuozzo.com>,
        <davem@davemloft.net>, <devel@openvz.org>
From: Stanislav Kinsburskiy <skinsbursky@virtuozzo.com>
Message-ID: <1638fe19-af90-6683-f04e-6fb94b8b8f67@virtuozzo.com>
Date: Thu, 4 Aug 2016 15:57:24 +0200
MIME-Version: 1.0
In-Reply-To: <1470316606.22052.17.camel@redhat.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



04.08.2016 15:16, Jeff Layton пишет:
> On Thu, 2016-08-04 at 12:55 +0200, Stanislav Kinsburskiy wrote:
>> 03.08.2016 19:36, Jeff Layton пишет:
>>> On Wed, 2016-08-03 at 20:54 +0400, Stanislav Kinsburskiy wrote:
>>>> Otherwise freezer cgroup state might never become "FROZEN".
>>>>
>>>> Here is a deadlock scheme for 2 processes in one freezer cgroup,
>>>> which is
>>>> freezing:
>>>>
>>>> CPU 0                                   CPU 1
>>>> --------                                --------
>>>> do_last
>>>> inode_lock(dir->d_inode)
>>>> vfs_create
>>>> nfs_create
>>>> ...
>>>> __rpc_execute
>>>> rpc_wait_bit_killable
>>>> __refrigerator
>>>>                                           do_last
>>>>                                           inode_lock(dir->d_inode)
>>>>
>>>> So, the problem is that one process takes directory inode mutex,
>>>> executes
>>>> creation request and goes to refrigerator.
>>>> Another one waits till directory lock is released, remains "thawed"
>>>> and thus
>>>> freezer cgroup state never becomes "FROZEN".
>>>>
>>>> Notes:
>>>> 1) Interesting, that this is not a pure deadlock: one can thaw cgroup
>>>> and then
>>>> freeze it again.
>>>> 2) The issue was introduced by commit
>>>> d310310cbff18ec385c6ab4d58f33b100192a96a.
>>>> 3) This patch is not aimed to fix the issue, but to show the problem
>>>> root.
>>>> Look like this problem moght be applicable to other hunks from the
>>>> commit,
>>>> mentioned above.
>>>>
>>>>
>>>>>>> Signed-off-by: Stanislav Kinsburskiy <skinsbursky@virtuozzo.com>
>>>> ---
>>>>    net/sunrpc/sched.c |    1 -
>>>>    1 file changed, 1 deletion(-)
>>>>
>>>> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
>>>> index 9ae5885..ec7ccc1 100644
>>>> --- a/net/sunrpc/sched.c
>>>> +++ b/net/sunrpc/sched.c
>>>> @@ -253,7 +253,6 @@ EXPORT_SYMBOL_GPL(rpc_destroy_wait_queue);
>>>>    
>>>>    static int rpc_wait_bit_killable(struct wait_bit_key *key, int mode)
>>>>    {
>>>>>>> -	freezable_schedule_unsafe();
>>>>>>>    	if (signal_pending_state(mode, current))
>>>>>>>    		return -ERESTARTSYS;
>>>>>>>    	return 0;
>>> Ummm...so what actually does the schedule() with this patch?
>> Schedule() replaces freezable_schedule_unsafe() of course, sorry for this.
>>
>>> There was a bit of discussion on this recently -- see the thread with
>>> this subject line in linux-nfs:
>>>
>>>       Re: Hang due to nfs letting tasks freeze with locked inodes
>> Thanks, had a look.
>>
>>> Basically it comes down to this:
>>>
>>> All of the proposals so far to fix this problem just switch out the
>>> freezable_schedule_unsafe (and similar) calls for those that don't
>>> allow the process to freeze.
>>>
>>> The problem there is that we originally added that stuff in response to
>>> bug reports about machines failing to suspend. What often happens is
>>> that the network interfaces come down, and then the freezer runs over
>>> all of the processes, which never return because they're blocked
>>> waiting on the server to reply.
>> I probably don't understand something, but this sounds somewhat wrong to
>> me: freezing processes _after_ network is down.
>>
>>
>>>
>>> ...shrug...
>>>
>>> Maybe we should just go ahead and do it (and to CIFS as well). Just be
>>> prepared for the inevitable complaints about laptops failing to suspend
>>> once you do.
>> The worst part in all of this, from my POW, is that current behavior
>> makes NFS non-freezable in a generic case, even in case of freezing a
>> container, which has it's own net ns and NFS mount.
>> So, I would say, that returning of previous logic would make the
>> world better.
>>
>>> Part of the fix, I think is to add a return code (similar to
>>> ERESTARTSYS) that gets interpreted near the kernel-userland boundary
>>> as: "allow the process to be frozen, and then retry the call once it's
>>> resumed".
>>>
>>> With that, filesystems could return the error code when they want to
>>> redrive the entire syscall from that level. That won't work for non-
>>> idempotent requests though. We'd need to do something more elaborate
>>> there.
>>>
>> Might be, that breaking rpc request is something that should be avoided
>> at all.
>> With all these locks being held, almost all (any?) of the requests to
>> remote server
>> should be considered as an atomic operation from freezer point of view.
>> The process always can be frozen on signal handling.
>>
>> IOW, I might worth considering a scenario, when NFS is not freezable at all,
>> and any problems with suspend on laptops/whatever have to solved in
>> suspend code.
>>
>>
> Fair enough. At this point, I don't care much one way or another. Maybe
> if we make this change and laptops start failing to suspend, we'll be
> able to use that as leverage pursue other avenues to make the
> suspend/resume subsystem work with NFS.
>
> That said, the patch you have really isn't sufficient. There are places
> where the NFS client can sleep while waiting for things other than RPC
> calls.

Sure. As I said, this patch wasn't aimed to fix the issue but rather 
start the discussion.
Thanks for your patch.

