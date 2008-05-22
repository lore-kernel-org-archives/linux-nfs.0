From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: lost interrupt after a signal?
Date: Thu, 22 May 2008 16:39:43 -0400
Message-ID: <1211488783.8361.8.camel@localhost>
References: <2A43EAAA-8AEC-4EA1-AAA6-1AE1C750DB4C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Matthew Wilcox <matthew@wil.cx>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48908 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757214AbYEVUjp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2008 16:39:45 -0400
In-Reply-To: <2A43EAAA-8AEC-4EA1-AAA6-1AE1C750DB4C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-05-22 at 10:57 -0400, Chuck Lever wrote:
> We've been running some tests to understand how the 2.6.25 "intr/ 
> nointr" behavior affects signal handling during I/O on NFS mounts.
> 
> While running an Oracle database workload, we signal the database  
> (this is a normal way administrative tools control database  
> activity).  Subsequently all of the I/O threads block on the inode  
> mutex in nfs_invalidate_mapping() except this one:
> 
> INFO: task oracle:27214 blocked for more than 120 seconds.
> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this  
> message.
> oracle        D f6d85e84  1592 27214      1
>         c93d2920 00200086 00000001 f6d85e84 c04a0080 c04a0080 c04a0080  
> c93d2b84
>         c93d2b84 c4021f80 00000001 cc072000 f341c900 f6d85e7c 10a1a042  
> f6d85e7c
>         cc072ddc c4021f80 03b7e000 cc072ddc c40082b4 c036e21c cc072dd4  
> 00000001
> Call Trace:
>   [<c036e21c>] io_schedule+0x4c/0x90
>   [<c015f63c>] sync_page+0x2c/0x40
>   [<c036e3e5>] __wait_on_bit_lock+0x45/0x70
>   [<c015f610>] sync_page+0x0/0x40
>   [<c015f5f3>] __lock_page+0x73/0x80
>   [<c013cad0>] wake_bit_function+0x0/0x80
>   [<c0167f98>] invalidate_inode_pages2_range+0xb8/0x200
>   [<f905d1a8>] nfs_writepages+0x68/0x90 [nfs]
>   [<f905489f>] nfs_invalidate_mapping_nolock+0x1f/0xd0 [nfs]
>   [<f9054ffa>] nfs_invalidate_mapping+0x5a/0x60 [nfs]
>   [<f90538a5>] nfs_file_read+0x85/0x120 [nfs]
>   [<c0182685>] do_sync_read+0xd5/0x120
>   [<c016cf4a>] __do_fault+0x1ca/0x400
>   [<c011c277>] __update_rq_clock+0x27/0x180
>   [<c013ca80>] autoremove_wake_function+0x0/0x50
>   [<c0136b25>] k_getrusage+0x1f5/0x200
>   [<c01e525c>] security_file_permission+0xc/0x10
>   [<c0182736>] rw_verify_area+0x66/0xd0
>   [<c0136b52>] getrusage+0x22/0x40
>   [<c0182f81>] vfs_read+0xa1/0x140
>   [<c01825b0>] do_sync_read+0x0/0x120
>   [<c01835da>] sys_pread64+0x6a/0x70
>   [<c0103e62>] syscall_call+0x7/0xb
> 
> I haven't looked too closely at this, but maybe the signal caused a  
> lost I/O interrupt?
> 
> What would be the next steps to troubleshoot this further?

'cat /proc/1592/status' should tell you if there is a signal that is
being blocked.


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
