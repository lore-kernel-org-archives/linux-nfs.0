From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: lost interrupt after a signal?
Date: Tue, 9 Dec 2008 17:52:10 -0500
Message-ID: <0927A36E-5553-468F-997D-0E8594A01EBF@oracle.com>
References: <2A43EAAA-8AEC-4EA1-AAA6-1AE1C750DB4C@oracle.com> <20080523035004.GY2638@parisc-linux.org> <D56CE258-FB78-4449-A1D8-376BB3D93387@oracle.com> <20080527173530.GM30894@parisc-linux.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <trond.myklebust@netapp.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:23618 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755405AbYLIWwS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Dec 2008 17:52:18 -0500
In-Reply-To: <20080527173530.GM30894-6jwH94ZQLHl74goWV3ctuw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 27, 2008, at May 27, 2008, 1:35 PM, Matthew Wilcox wrote:
> On Tue, May 27, 2008 at 11:59:00AM -0400, Chuck Lever wrote:
>>> This isn't jumping out screaming that it's my fault (obviously it
>>> probably is, but ...).  invalidate_inode_pages2_range calls
>>> lock_page()
>>> ... which uses TASK_UNINTERRUPTIBLE.  If it were calling
>>> lock_page_killable(), I'd understand.
>>
>> I don't think it's directly caused by your changes, but my concern is
>> that you may have exposed a latent bug, or exposed an underlying
>> design assumption in the NFS/RPC client stack that causes the hang in
>> this situation.
>
> Certainly possible.
>
>>> Maybe this isn't the problem task though.  Maybe this is just the
>>> canary that dropped dead, and we should stop trying to autopsy it  
>>> and
>>> start running.  [ok, I'll stop with the bad analogies now]
>>
>> This appears to be the only task that is in this state.  All the
>> others in the dump are waiting for this inode's mutex.  I don't know
>> if the dump is complete, though.
>
> My thought is that the task which caused the problem has gone away and
> left this page in a state where sync_page will never finish.

One thing to note: NFS doesn't have a sync_page() a_op.  So this  
shouldn't be the problem, right?

>> I've passed your suggestions along to our testers.
>
> Thanks!  I'm keen to get this fixed.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
