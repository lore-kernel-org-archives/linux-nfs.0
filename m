From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 18/19] lockd: Update NSM state from SM_MON replies
Date: Tue, 28 Apr 2009 15:11:07 -0400
Message-ID: <528F3128-71DD-4B0F-AA31-6A60BC808708@oracle.com>
References: <20090423231550.17283.24432.stgit@ingres.1015granger.net> <20090423233332.17283.23011.stgit@ingres.1015granger.net> <20090428162524.GI17891@fieldses.org> <20423538-9733-44FE-8DAC-AD0995DA1B58@oracle.com> <20090428163803.GN17891@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:33260 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbZD1TLa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 15:11:30 -0400
In-Reply-To: <20090428163803.GN17891@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 28, 2009, at 12:38 PM, J. Bruce Fields wrote:
> On Tue, Apr 28, 2009 at 12:34:19PM -0400, Chuck Lever wrote:
>> On Apr 28, 2009, at 12:25 PM, J. Bruce Fields wrote:
>>> On Thu, Apr 23, 2009 at 07:33:33PM -0400, Chuck Lever wrote:
>>>> When rpc.statd starts up in user space at boot time, it attempts to
>>>> write the latest NSM local state number into
>>>> /proc/sys/fs/nfs/nsm_local_state.
>>>>
>>>> If lockd.ko isn't loaded yet (as is the case in most  
>>>> configurations),
>>>> that file doesn't exist, thus the kernel's NSM state remains set to
>>>> its initial value of zero during lockd operation.
>>>>
>>>> This is a problem because rpc.statd and lockd use the NSM state
>>>> number
>>>> to prevent repeated lock recovery on rebooted hosts.  If lockd  
>>>> sends
>>>> a zero NSM state, but then a delayed SM_NOTIFY with a real NSM  
>>>> state
>>>> number is received, there is no way for lockd or rpc.statd to
>>>> distinguish that stale SM_NOTIFY from an actual reboot.  Thus lock
>>>> recovery could be performed after the rebooted host has already
>>>> started reclaiming locks, and those locks will be lost.
>>>>
>>>> We could change /etc/init.d/nfslock so it always modprobes lockd.ko
>>>> before starting rpc.statd.  However, if lockd.ko is ever unloaded
>>>> and reloaded, we are back at square one, since the NSM state is not
>>>> preserved across an unload/reload cycle.  This may happen  
>>>> frequently
>>>> on clients that use automounter.  A period of NFS inactivity causes
>>>> lockd.ko to be unloaded, and the kernel loses its NSM state  
>>>> setting.
>>>
>>> Aie.  Can we also fix the automounter or some other part of the
>>> userspace configuration?
>>
>> User space isn't the problem here... it's the fact that lockd can get
>> unloaded after a period of inactivity.  IMO lockd should be pinned in
>> the kernel after it is loaded with /etc/init.d/nfslock.
>>
>>>> Instead, let's use the fact that rpc.statd plants the local  
>>>> system's
>>>> NSM state in every SM_MON (and SM_UNMON) reply.  lockd performs a
>>>> synchronous SM_MON upcall to the local rpc.statd _before_ sending  
>>>> its
>>>> first NLM request to a new remote.  This would permit rpc.statd to
>>>> provide the current NSM state to lockd, even after lockd.ko had  
>>>> been
>>>> unloaded and reloaded.
>>>>
>>>> Note that NLMPROC_LOCK arguments are constructed before the
>>>> nsm_monitor() call, so we have to rearrange argument construction
>>>> very
>>>> slightly to make this all work out.
>>>>
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>>
>>>> fs/lockd/clntproc.c |    2 +-
>>>> fs/lockd/mon.c      |    6 +++++-
>>>> 2 files changed, 6 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
>>>> index dd79570..f55b900 100644
>>>> --- a/fs/lockd/clntproc.c
>>>> +++ b/fs/lockd/clntproc.c
>>>> @@ -126,7 +126,6 @@ static void nlmclnt_setlockargs(struct nlm_rqst
>>>> *req, struct file_lock *fl)
>>>> 	struct nlm_lock	*lock = &argp->lock;
>>>>
>>>> 	nlmclnt_next_cookie(&argp->cookie);
>>>> -	argp->state   = nsm_local_state;
>>>> 	memcpy(&lock->fh, NFS_FH(fl->fl_file->f_path.dentry->d_inode),
>>>> sizeof(struct nfs_fh));
>>>> 	lock->caller  = utsname()->nodename;
>>>> 	lock->oh.data = req->a_owner;
>>>> @@ -519,6 +518,7 @@ nlmclnt_lock(struct nlm_rqst *req, struct
>>>> file_lock *fl)
>>>>
>>>> 	if (nsm_monitor(host) < 0)
>>>> 		goto out;
>>>> +	req->a_args.state = nsm_local_state;
>>>
>>> Hm.  It looks like a_args.state is never used, except in ifdef'd-out
>>> code in nlm4svc_proc_lock() and nlmsvc_proc_lock() ifdef'd out.
>>> Something's wrong there.  (Not your fault; but needs looking into.)
>>
>> This isn't a big deal on the server side (I guess I should give this
>> patch to Trond instead of you, in that case).
>>
>> The client passes its NSM state number to the server in NLMPROC_LOCK
>> calls.  There is no mechanism for the server to pass its NSM state
>> number to the client via the NLM protocol.  So the first the client  
>> is
>> aware of the server's NSM state number is after the server reboots  
>> (via
>> SM_NOTIFY).  If the server never reboots, the client will never  
>> know the
>> server's NSM state number.
>
> So the #if 0'd code should just be deleted?

OK, I misread your question before.

As I read the code, our server does not appear to utilize the client's  
NSM state number, except for gating SM_NOTIFY requests with a  
previously-seen NSM state number.  The #ifdef'd code would potentially  
deny lock requests if it detected the state number going backwards.

It would be nicer if the server actually tracked the client's state  
number, but it doesn't appear to do that today.  The #ifdef'd code  
serves to remind us that we should consider this.  This would also  
prevent a delayed SM_NOTIFY from causing the server to drop locks  
reacquired during the grace period accidentally.

So I think it would be good to leave it, or replace it with a FIXME  
comment, for now.  Eventually we should add a little extra logic to  
handle this case.

> --b.
>
>>
>>>> 	fl->fl_flags |= FL_ACCESS;
>>>> 	status = do_vfs_lock(fl);
>>>> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
>>>> index 6d5d4a4..5017d50 100644
>>>> --- a/fs/lockd/mon.c
>>>> +++ b/fs/lockd/mon.c
>>>> @@ -188,8 +188,12 @@ int nsm_monitor(const struct nlm_host *host)
>>>> 		status = -EIO;
>>>> 	if (status < 0)
>>>> 		printk(KERN_NOTICE "lockd: cannot monitor %s\n", nsm->sm_name);
>>>> -	else
>>>> +	else {
>>>> 		nsm->sm_monitored = 1;
>>>> +		nsm_local_state = res.state;
>>>> +		dprintk("lockd: nsm_monitor: NSM state is now %d\n",
>>>> +				nsm_local_state);
>>>
>>> Could we make that a dprintk in the case where this changes  
>>> nsm_local
>>> state from something other than zero (nsm_lock_state &&
>>> nsm_local_state
>>> != res.state)?
>>>
>>> (Just to make sure no statd is returning inconsistent  
>>> nsm_local_stats
>>> here.)
>>
>> I'm not sure that's a big deal, but...
>>
>> Note that the XNFS version 3 spec suggests the local lockd should
>> request the NSM state number when it starts up by posting an
>> SM_UNMON_ALL to the local statd.  That might be safer than loading it
>> after every SM_MON.
>>
>>>> +	}
>>>> 	return status;
>>>> }
>>>
>>> --b.
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




