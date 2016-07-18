Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43041 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751265AbcGROia convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jul 2016 10:38:30 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Weston Andros Adamson" <dros@monkey.org>
Cc: "Alexey Dobriyan" <adobriyan@gmail.com>,
        "Trond Myklebust" <trondmy@primarydata.com>,
        "linux-nfs list" <linux-nfs@vger.kernel.org>,
        "Anna Schumaker" <anna.schumaker@netapp.com>
Subject: Re: RHEL7 hang (and probably mainline) while copying big files
 because of subrequests merging(?)
Date: Mon, 18 Jul 2016 10:40:01 -0400
Message-ID: <A539CD87-5ABC-4A30-87FE-E8183C082A2E@redhat.com>
In-Reply-To: <94077596-6FC9-49CF-9735-1EBE2E8E74EA@monkey.org>
References: <CACVxJT8fYGqGbHz97xVR1fWtq3YEfQoN7180fEW-Q27UgD=3Ag@mail.gmail.com>
 <E70C1354-A1F7-47F3-A810-344BA5BE51AB@primarydata.com>
 <37A2D73A-A493-4E29-B590-E5B272390359@redhat.com>
 <05F30186-541D-4149-B3EF-6982DE089205@primarydata.com>
 <CACVxJT83FPmdh9ckFMx9a=LTKCKUwxXRdJwELsA9O9KrrS0JOQ@mail.gmail.com>
 <94077596-6FC9-49CF-9735-1EBE2E8E74EA@monkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 18 Jul 2016, at 10:36, Weston Andros Adamson wrote:

>> On Jul 18, 2016, at 10:32 AM, Alexey Dobriyan <adobriyan@gmail.com> 
>> wrote:
>>
>> On Mon, Jul 18, 2016 at 3:35 PM, Trond Myklebust
>> <trondmy@primarydata.com> wrote:
>>>
>>>> On Jul 18, 2016, at 07:43, Benjamin Coddington 
>>>> <bcodding@redhat.com> wrote:
>>>>
>>>> On 11 Jul 2016, at 9:28, Trond Myklebust wrote:
>>>>
>>>>>> On Jul 11, 2016, at 08:59, Alexey Dobriyan <adobriyan@gmail.com> 
>>>>>> wrote:
>>>>>>
>>>>>> We have a customer who was able to reliably reproduce the 
>>>>>> following hang:
>>>>>> (hang itself is rare but there are many machines, so it is not 
>>>>>> rare)
>>>>>>
>>>>>> INFO: task ascp:66692 blocked for more than 120 seconds.
>>>>>>
>>>>>>> bt 66692
>>>>>> PID: 66692  TASK: ffff883f124ba280  CPU: 5   COMMAND: "ascp"
>>>>>>
>>>>>> __schedule
>>>>>> schedule
>>>>>> schedule_timeout
>>>>>> io_schedule_timeout
>>>>>> io_schedule
>>>>>> nfs_wait_bit_uninterruptible
>>>>>> __wait_on_bit
>>>>>> out_of_line_wait_on_bit
>>>>>> nfs_wait_on_request
>>>>>> nfs_try_to_update_request
>>>>>> nfs_setup_write_request
>>>>>> nfs_writepage_setup
>>>>>> nfs_updatepage
>>>>>> nfs_write_end
>>>>>> generic_file_buffered_write
>>>>>> __generic_file_aio_write
>>>>>> generic_file_aio_write
>>>>>> nfs_file_write
>>>>>> do_sync_write
>>>>>> vfs_write
>>>>>> sys_write
>>>>>> system_call_fastpath
>>>>>>
>>>>>> ascp is Aspera secure copy program. It is multithreaded.
>>>>>> When the hang happens, 5 threads are in S-state and 1 on D-state.
>>>>>>
>>>>>> The workload is copying ~100+ GB files over NFS3 with 10GiB 
>>>>>> ethernet
>>>>>> with the following mount options:
>>>>>> rw,relatime,vers=3,rsize=131072,wsize=524288,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=X.X.X.X,mountvers=3,mountport=300,mountproto=udp,local_lock=none,addr=X.X.X.X
>>>>>>
>>>>>> We got coredump (2 actually) and observations are below:
>>>>>>
>>>>>> 1) one of the inode's pagecache pages has page->private 
>>>>>> available:
>>>>>> struct nfs_page {
>>>>>> wb_list = {
>>>>>>  next = 0xffff885623ac4f80,
>>>>>>  prev = 0xffff885623ac4f80
>>>>>> },
>>>>>> wb_page = 0xffffea01218c2600,
>>>>>> wb_context = 0xffff887f2265de00,
>>>>>> wb_lock_context = 0xffff887f2265de00,
>>>>>> wb_index = 2649328,
>>>>>> wb_offset = 0,
>>>>>> wb_pgbase = 0,
>>>>>> wb_bytes = 0,
>>>>>> wb_kref = {
>>>>>>  refcount = {
>>>>>>    counter = 3
>>>>>>  }
>>>>>> },
>>>>>> wb_flags = 19,
>>>>>> wb_verf = {
>>>>>>  data = "\000\000\000\000\000\000\000"
>>>>>> },
>>>>>> wb_this_page = 0xffff885623ac4f80,
>>>>>> wb_head = 0xffff885623ac4f80
>>>>>> }
>>>>>>
>>>>>> ->wb_list is always empty,
>>>>>> ->wb_bytes is always 0 (!).
>>>>>> ->wb_kref is always 3.
>>>>>> ->wb_flags = PG_BUSY|PG_MAPPED|PG_INODE_REF,
>>>>>>
>>>>>> page->flags = 0x2869 =
>>>>>> PG_writeback|PG_private|PG_active|PF_lru|PG_uptodate|PG_locked
>>>>>>
>>>>>> The zero-length request is created at nfs_create_request():
>>>>>> WARN_ON_ONCE(req->wb_bytes == 0)
>>>>>> nfs_create_request
>>>>>> nfs_setup_write_request
>>>>>> nfs_updatepage
>>>>>> nfs_write_end
>>>>>> generic_perform_write
>>>>>> generic_file_buffered_write
>>>>>> __generic_file_aio_write
>>>>>> generic_file_aio_write
>>>>>> nfs_file_write
>>>>>> do_sync_write
>>>>>> vfs_write
>>>>>> SyS_write
>>>>>>
>>>>>> with count=0 coming from generic_perform_write (where else?).
>>>>>>
>>>>>> Customer is saying that RHEL6 was totally OK, and there are 
>>>>>> several reports
>>>>>> of other people hitting same bug with RHEL7:
>>>>>> https://gist.github.com/Millnert/ecc10d8cc79c81b55d7f
>>>>>> https://bugs.centos.org/view.php?id=9284
>>>>>>
>>>>>
>>>>> Why is this being reported here and not to Red Hat? Is the bug 
>>>>> reproducible on the upstream kernel?
>>>>
>>>> There's a RHEL BZ open for it:
>>>> https://bugzilla.redhat.com/show_bug.cgi?id=132463
>>>>
>>>> Upstream has the problem, too.  The pgio layer doesn't expect 
>>>> zero-length
>>>> requests, so an nfs_page can get locked but never added to a pageio
>>>> descriptor.
>>>>
>>>> To create such a problem, writeback has to happen just after 
>>>> nfs_write_end()
>>>> has created a nfs_page with wb_bytes = 0.  This can happen if
>>>> iov_iter_copy_from_user_atomic() fails to copy pages in
>>>> generic_perform_write().  Normally, we'd just go around the loop 
>>>> and try the
>>>> copy again, but if writeback sneaks in then the request gets locked 
>>>> but
>>>> never added to a pgio descriptor due to the way we use conditions 
>>>> on zero
>>>> bytes to move requests around.
>>>>
>>>> I see two potential ways to fix:
>>>>   - Just skip the creation of the request if the length is zero.  
>>>> We're
>>>>     bound to just come around and created it again.
>>>>
>>>>   - Allow zero-length requests, but fix up 
>>>> __nfs_pageio_add_request,
>>>>     nfs_generic_pg_test, and others that use conditions on zero.
>>>>
>>>> I think the first option to handle the case early is the simpler 
>>>> fix, and
>>>> best approach, since: what do we do with a zero-length request?  
>>>> Not
>>>> creating them helps us be conservative in what we send out to the
>>>> nfs_pageio_ops.
>>>>
>>>> I don't understand what conditions can cause 
>>>> iov_iter_copy_from_user_atomic
>>>> to fail since pagefaults are disabled.  Can anyone enlighten me?
>>>>
>>>> To reproduce this upstream, I've simulated 
>>>> iov_iter_copy_from_user_atomic()
>>>> returning zero once, then inserted a small delay after 
>>>> nfs_write_end to
>>>> allow me to sneak in a sync.
>>>>
>>>> Any advice on how to proceed?  I'll send a patch to fix the first 
>>>> way
>>>> otherwise.  If anyone has trouble with that RHEL BZ, send me your 
>>>> bugzilla
>>>> email and I'll give you access.
>>>
>>> I think adding a check to nfs_updatepage() to bail out if 
>>> ‘count’ is zero would seem to be the right thing to do.
>>
>> This is exactly what we did as a workaround for customer,
>> so I can already confirm it helps. :^)
>
> Makes sense to me too!
>
> Who wants to take the lead and post a patch? Ben?

Sure.. I'll send it.  I was hunting around trying to figure out an 
appropriate version number for a stable tag..   I think it became a 
problem in v3.15 or so -- but there's a lot that moved around so I am 
not sure.

Ben
