From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: lost interrupt after a signal?
Date: Tue, 27 May 2008 11:59:00 -0400
Message-ID: <D56CE258-FB78-4449-A1D8-376BB3D93387@oracle.com>
References: <2A43EAAA-8AEC-4EA1-AAA6-1AE1C750DB4C@oracle.com> <20080523035004.GY2638@parisc-linux.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:60603 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756440AbYE0P7w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 May 2008 11:59:52 -0400
In-Reply-To: <20080523035004.GY2638-6jwH94ZQLHl74goWV3ctuw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 22, 2008, at 11:50 PM, Matthew Wilcox wrote:
> On Thu, May 22, 2008 at 10:57:35AM -0400, Chuck Lever wrote:
>> We've been running some tests to understand how the 2.6.25 "intr/
>> nointr" behavior affects signal handling during I/O on NFS mounts.
>
> I believe intr is now a no-op ... we still recognise the option, but  
> it
> does nothing.

Understood...

>> While running an Oracle database workload, we signal the database
>> (this is a normal way administrative tools control database
>> activity).  Subsequently all of the I/O threads block on the inode
>> mutex in nfs_invalidate_mapping() except this one:
>>
>> INFO: task oracle:27214 blocked for more than 120 seconds.
>> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
>> message.
>> oracle        D f6d85e84  1592 27214      1
>>       c93d2920 00200086 00000001 f6d85e84 c04a0080 c04a0080 c04a0080
>> c93d2b84
>>       c93d2b84 c4021f80 00000001 cc072000 f341c900 f6d85e7c 10a1a042
>> f6d85e7c
>>       cc072ddc c4021f80 03b7e000 cc072ddc c40082b4 c036e21c cc072dd4
>> 00000001
>> Call Trace:
>> [<c036e21c>] io_schedule+0x4c/0x90
>> [<c015f63c>] sync_page+0x2c/0x40
>> [<c036e3e5>] __wait_on_bit_lock+0x45/0x70
>> [<c015f610>] sync_page+0x0/0x40
>> [<c015f5f3>] __lock_page+0x73/0x80
>> [<c013cad0>] wake_bit_function+0x0/0x80
>> [<c0167f98>] invalidate_inode_pages2_range+0xb8/0x200
>> [<f905d1a8>] nfs_writepages+0x68/0x90 [nfs]
> [...]
>
> This isn't jumping out screaming that it's my fault (obviously it
> probably is, but ...).  invalidate_inode_pages2_range calls  
> lock_page()
> ... which uses TASK_UNINTERRUPTIBLE.  If it were calling
> lock_page_killable(), I'd understand.

I don't think it's directly caused by your changes, but my concern is  
that you may have exposed a latent bug, or exposed an underlying  
design assumption in the NFS/RPC client stack that causes the hang in  
this situation.

> Maybe this isn't the problem task though.  Maybe this is just the
> canary that dropped dead, and we should stop trying to autopsy it and
> start running.  [ok, I'll stop with the bad analogies now]

This appears to be the only task that is in this state.  All the  
others in the dump are waiting for this inode's mutex.  I don't know  
if the dump is complete, though.

> It might be informative to do something like:
>
> int __fatal_signal_pending(struct task_struct *tsk)
> {
> -	return sigismember(&tsk->pending.signal, SIGKILL);
> +	if (sigismember(&tsk->pending.signal, SIGKILL)) {
> +		dump_stack();
> +		return 1;
> +	}
> +	return 0;
> }
>
>> I haven't looked too closely at this, but maybe the signal caused a
>> lost I/O interrupt?
>
> I wonder if the signal caused something bad to happen to the page that
> we're trying to sync?  Maybe dumping the page struct would give us  
> some
> useful information?

I've passed your suggestions along to our testers.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
