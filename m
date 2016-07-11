Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f48.google.com ([209.85.214.48]:37106 "EHLO
	mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754141AbcGKNsd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jul 2016 09:48:33 -0400
Received: by mail-it0-f48.google.com with SMTP id f6so55504823ith.0
        for <linux-nfs@vger.kernel.org>; Mon, 11 Jul 2016 06:48:33 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: RHEL7 hang (and probably mainline) while copying big files because of subrequests merging(?)
From: Weston Andros Adamson <dros@monkey.org>
In-Reply-To: <E70C1354-A1F7-47F3-A810-344BA5BE51AB@primarydata.com>
Date: Mon, 11 Jul 2016 09:48:31 -0400
Cc: Trond Myklebust <trondmy@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Message-Id: <97B90495-01FF-4F00-B8F3-67A64DFFDE7C@monkey.org>
References: <CACVxJT8fYGqGbHz97xVR1fWtq3YEfQoN7180fEW-Q27UgD=3Ag@mail.gmail.com> <E70C1354-A1F7-47F3-A810-344BA5BE51AB@primarydata.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 11, 2016, at 9:28 AM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
>> 
>> On Jul 11, 2016, at 08:59, Alexey Dobriyan <adobriyan@gmail.com> wrote:
>> 
>> We have a customer who was able to reliably reproduce the following hang:
>> (hang itself is rare but there are many machines, so it is not rare)
>> 
>> INFO: task ascp:66692 blocked for more than 120 seconds.
>> 
>>> bt 66692
>> PID: 66692  TASK: ffff883f124ba280  CPU: 5   COMMAND: "ascp"
>> 
>> __schedule
>> schedule
>> schedule_timeout
>> io_schedule_timeout
>> io_schedule
>> nfs_wait_bit_uninterruptible
>> __wait_on_bit
>> out_of_line_wait_on_bit
>> nfs_wait_on_request
>> nfs_try_to_update_request
>> nfs_setup_write_request
>> nfs_writepage_setup
>> nfs_updatepage
>> nfs_write_end
>> generic_file_buffered_write
>> __generic_file_aio_write
>> generic_file_aio_write
>> nfs_file_write
>> do_sync_write
>> vfs_write
>> sys_write
>> system_call_fastpath
>> 
>> ascp is Aspera secure copy program. It is multithreaded.
>> When the hang happens, 5 threads are in S-state and 1 on D-state.
>> 
>> The workload is copying ~100+ GB files over NFS3 with 10GiB ethernet
>> with the following mount options:
>> rw,relatime,vers=3,rsize=131072,wsize=524288,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=X.X.X.X,mountvers=3,mountport=300,mountproto=udp,local_lock=none,addr=X.X.X.X
>> 
>> We got coredump (2 actually) and observations are below:
>> 
>> 1) one of the inode's pagecache pages has page->private available:
>> struct nfs_page {
>> wb_list = {
>>   next = 0xffff885623ac4f80,
>>   prev = 0xffff885623ac4f80
>> },
>> wb_page = 0xffffea01218c2600,
>> wb_context = 0xffff887f2265de00,
>> wb_lock_context = 0xffff887f2265de00,
>> wb_index = 2649328,
>> wb_offset = 0,
>> wb_pgbase = 0,
>> wb_bytes = 0,
>> wb_kref = {
>>   refcount = {
>>     counter = 3
>>   }
>> },
>> wb_flags = 19,
>> wb_verf = {
>>   data = "\000\000\000\000\000\000\000"
>> },
>> wb_this_page = 0xffff885623ac4f80,
>> wb_head = 0xffff885623ac4f80
>> }
>> 
>> ->wb_list is always empty,
>> ->wb_bytes is always 0 (!).
>> ->wb_kref is always 3.
>> ->wb_flags = PG_BUSY|PG_MAPPED|PG_INODE_REF,
>> 
>> page->flags = 0x2869 =
>> PG_writeback|PG_private|PG_active|PF_lru|PG_uptodate|PG_locked
>> 
>> The zero-length request is created at nfs_create_request():
>> WARN_ON_ONCE(req->wb_bytes == 0)
>> nfs_create_request
>> nfs_setup_write_request
>> nfs_updatepage
>> nfs_write_end
>> generic_perform_write
>> generic_file_buffered_write
>> __generic_file_aio_write
>> generic_file_aio_write
>> nfs_file_write
>> do_sync_write
>> vfs_write
>> SyS_write
>> 
>> with count=0 coming from generic_perform_write (where else?).
>> 
>> Customer is saying that RHEL6 was totally OK, and there are several reports
>> of other people hitting same bug with RHEL7:
>> https://gist.github.com/Millnert/ecc10d8cc79c81b55d7f
>> https://bugs.centos.org/view.php?id=9284
>> 
> 
> Why is this being reported here and not to Red Hat? Is the bug reproducible on the upstream kernel?
> 
> Cheers
>  Trond

Also, you say RHEL7, but which kernel?

-dros



-dros

