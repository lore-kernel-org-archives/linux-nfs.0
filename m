Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33896 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751239AbdFESeW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Jun 2017 14:34:22 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Jeff Layton" <jlayton@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "kernel test robot" <xiaolong.ye@intel.com>,
        "Alexander Viro" <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        lkp@01.org, "Christoph Hellwig" <hch@infradead.org>
Subject: Re: [lkp-robot] [fs/locks]  9d21d181d0: will-it-scale.per_process_ops
 -14.1% regression
Date: Mon, 05 Jun 2017 14:34:18 -0400
Message-ID: <E3321EB0-9365-456C-9470-E74291F6FFEA@redhat.com>
In-Reply-To: <1496332131.2845.8.camel@redhat.com>
References: <20170601020556.GE16905@yexl-desktop>
 <1496317284.2845.4.camel@redhat.com>
 <8F2C3CFF-5C2D-41B0-A895-B1F074DA7943@redhat.com>
 <1496321961.2845.6.camel@redhat.com> <20170601151415.GA4079@fieldses.org>
 <1496332131.2845.8.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 1 Jun 2017, at 11:48, Jeff Layton wrote:

> On Thu, 2017-06-01 at 11:14 -0400, J. Bruce Fields wrote:
>> On Thu, Jun 01, 2017 at 08:59:21AM -0400, Jeff Layton wrote:
>>> I'm not so sure. That would only be the case if the thing were 
>>> marked
>>> for manadatory locking (a really rare thing).
>>>
>>> The test is really simple and I don't think any read/write activity 
>>> is
>>> involved:
>>>
>>>     https://github.com/antonblanchard/will-it-scale/blob/master/tests/lock1.c
>>
>> So it's just F_WRLCK/F_UNLCK in a loop spread across multiple cores?
>> I'd think real workloads do some work while holding the lock, and a 
>> 15%
>> regression on just the pure lock/unlock loop might not matter?  But 
>> best
>> to be careful, I guess.
>>
>> --b.
>>
>
> Yeah, that's my take.
>
> I was assuming that getting a pid reference would be essentially free,
> but it doesn't seem to be.
>
> So, I think we probably want to avoid taking it for a file_lock that 
> we
> use to request a lock, but do take it for a file_lock that is used to
> record a lock. How best to code that up, I'm not quite sure...

Maybe as simple as only setting fl_nspid in locks_insert_lock_ctx(), but
that seems to just take us back to the problem of getting the pid wrong 
if
the lock is inserted later by a different worker than created the 
request.

I have a mind now to just drop fl_nspid off the struct file_lock 
completely,
and instead just carry fl_pid, and when we do F_GETLK, we can do:

task = find_task_by_pid_ns(fl_pid, init_pid_ns)
fl_nspid = task_pid_nr_ns(task, task_active_pid_ns(current))

That moves all the work off into the F_GETLK case, which I think is not 
used
so much.

Ben
