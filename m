From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS intr/nointr: SIGKILL may leave pages locked forever
Date: Wed, 26 Nov 2008 11:16:31 -0500
Message-ID: <A21BBBC8-2C5D-4384-BCCF-A7290D53EB8C@oracle.com>
References: <1A5BADE4-02EB-473A-957A-2329DFBC92B3@oracle.com> <E0B63DDE-B5D0-4DCA-B521-044759E1BFF0@oracle.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754455AbYKZQQz@vger.kernel.org>
In-Reply-To: <E0B63DDE-B5D0-4DCA-B521-044759E1BFF0@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 29, 2008, at 12:38 PM, Chuck Lever wrote:
> On Oct 24, 2008, at 11:11 AM, Chuck Lever wrote:
>> Hi Matthew-
>>
>> We are still trying to pursue intr/nointr testing on 2.6.25+  
>> kernels.  Looks like this week's kernel version is 2.6.27-rc7, but  
>> I will need to confirm that.
>>
>> Since 2.6.25, the problem is the "sql shutdown abort" command,  
>> which is designed to trigger an immediate database shutdown, causes  
>> the database instance to hang.  It leaves database writer processes  
>> stuck in "D" state after it sends a SIGKILL.
>>
>> The process backtraces suggest that these processes are waiting for  
>> the inode mutex before trying to invalidate the database file's  
>> cache (nfs_invalidate_mapping).  There is one process that owns the  
>> mutex and is stuck waiting for a page lock in  
>> invalidate_inode_pages2_range.  This suggests that the signal is  
>> causing some other code path to neglect to unlock that page.
>>
>> It's a little out of my league.  Are there ways we can gather more  
>> information?
>
> As a follow-up, we've found that we don't have this problem on UP  
> NFS clients.  On single processor clients, SIGKILL works correctly  
> and the database shuts down without corrupting its data files.  On  
> SMP clients, the signal results in hung database writers.
>
> We've confirmed this difference on 2.6.25-rc2 and 2.6.27-rc7.


Second follow up.  I've constructed a patch that saves the stack  
backtrace of the page locker.  sysRq-T dumps the backtrace into the  
kernel log.  On 2.6.27 SMP after the deadlock, this is what we get:

kernel: pages waiting in invalidate_inode_pages2_range:
kernel:   page index 80832
kernel:       [<c04540b2>] generic_file_aio_read+0x364/0x507
kernel:       [<f8d26322>] nfs_file_read+0xc6/0xd4 [nfs]
kernel:       [<c047196f>] do_sync_read+0xab/0xe9
kernel:       [<c0472085>] vfs_read+0x8a/0x106
kernel:       [<c047244c>] sys_pread64+0x43/0x5c
kernel:       [<c0403859>] sysenter_do_call+0x12/0x21
kernel:       [<ffffffff>] 0xffffffff

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
