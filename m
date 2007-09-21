From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: NFS on loopback locks up entire system(2.6.23-rc6)?
Date: Thu, 20 Sep 2007 20:43:43 -0400
Message-ID: <1190335423.6763.180.camel@heimdal.trondhjem.org>
References: <92cbf19b0709201722k6265e647x31b7d25bc54b63a0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Chakri n <chakriin5@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755238AbXIUAn5@vger.kernel.org>
In-Reply-To: <92cbf19b0709201722k6265e647x31b7d25bc54b63a0@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, 2007-09-20 at 17:22 -0700, Chakri n wrote:
> Hi,
> 
> I am testing NFS on loopback locks up entire system with 2.6.23-rc6 kernel.
> 
> I have mounted a local ext3 partition using loopback NFS (version 3)
> and started my test program. The test program forks 20 threads
> allocates 10MB for each thread, writes & reads a file on the loopback
> NFS mount. After running for about 5 min, I cannot even login to the
> machine. Commands like ps etc, hang in a live session.
> 
> The machine is a DELL 1950 with 4Gig of RAM, so there is plenty of RAM
> & CPU to play around and no other io/heavy processes are running on
> the system.
> 
> vmstat output shows no buffers are actually getting transferred in or
> out and iowait is 100%.
> 
> [root@h46 ~]# vmstat 1
> procs -----------memory---------- ---swap-- -----io---- --system--
> -----cpu------
>  r  b    swpd       free       buff       cache   si   so   bi   bo
> in     cs us sy id wa st
>  0 24    116 110080  11132 3045664    0    0     0     0   28  345  0
> 1  0 99  0
>  0 24    116 110080  11132 3045664    0    0     0     0    5  329  0
> 0  0 100  0
>  0 24    116 110080  11132 3045664    0    0     0     0   26  336  0
> 0  0 100  0
>  0 24    116 110080  11132 3045664    0    0     0     0    8  335  0
> 0  0 100  0
>  0 24    116 110080  11132 3045664    0    0     0     0   26  352  0
> 0  0 100  0
>  0 24    116 110080  11132 3045664    0    0     0     0    8  351  0
> 0  0 100  0
>  0 24    116 110080  11132 3045664    0    0     0     0   23  358  0
> 1  0 99  0
>  0 24    116 110080  11132 3045664    0    0     0     0   10  350  0
> 0  0 100  0
>  0 24    116 110080  11132 3045664    0    0     0     0   26  363  0
> 0  0 100  0
>  0 24    116 110080  11132 3045664    0    0     0     0    8  346  0
> 1  0 99  0
>  0 24    116 110080  11132 3045664    0    0     0     0   26  360  0
> 0  0 100  0
>  0 24    116 110080  11140 3045656    0    0     8     0   11  345  0
> 0  0 100  0
>  0 24    116 110080  11140 3045664    0    0     0     0   27  355  0
> 0  2 97  0
>  0 24    116 110080  11140 3045664    0    0     0     0    9  330  0
> 0  0 100  0
>  0 24    116 110080  11140 3045664    0    0     0     0   26  358  0
> 0  0 100  0
> 
> 
> The following is the backtrace of
> 1. one of the threads of my test program
> 2. nfsd daemon and
> 3. a generic command like pstree, after the machine hangs:
> -------------------------------------------------------------
> crash> bt 3252
> PID: 3252   TASK: f6f3c610  CPU: 0   COMMAND: "test"
>  #0 [f6bdcc10] schedule at c0624a34
>  #1 [f6bdcc84] schedule_timeout at c06250ee
>  #2 [f6bdccc8] io_schedule_timeout at c0624c15
>  #3 [f6bdccdc] congestion_wait at c045eb7d
>  #4 [f6bdcd00] balance_dirty_pages_ratelimited_nr at c045ab91
>  #5 [f6bdcd54] generic_file_buffered_write at c0457148
>  #6 [f6bdcde8] __generic_file_aio_write_nolock at c04576e5
>  #7 [f6bdce40] try_to_wake_up at c042342b
>  #8 [f6bdce5c] generic_file_aio_write at c0457799
>  #9 [f6bdce8c] nfs_file_write at f8c25cee
> #10 [f6bdced0] do_sync_write at c0472e27
> #11 [f6bdcf7c] vfs_write at c0473689
> #12 [f6bdcf98] sys_write at c0473c95
> #13 [f6bdcfb4] sysenter_entry at c0404ddf
>     EAX: 00000004  EBX: 00000013  ECX: a4966008  EDX: 00980000
>     DS:  007b      ESI: 00980000  ES:  007b      EDI: a4966008
>     SS:  007b      ESP: a5ae6ec0  EBP: a5ae6ef0
>     CS:  0073      EIP: b7eed410  ERR: 00000004  EFLAGS: 00000246
> crash> bt 3188
> PID: 3188   TASK: f74c4000  CPU: 1   COMMAND: "nfsd"
>  #0 [f6836c7c] schedule at c0624a34
>  #1 [f6836cf0] __mutex_lock_slowpath at c062543d
>  #2 [f6836d0c] mutex_lock at c0625326
>  #3 [f6836d18] generic_file_aio_write at c0457784
>  #4 [f6836d48] ext3_file_write at f8888fd7
>  #5 [f6836d64] do_sync_readv_writev at c0472d1f
>  #6 [f6836e08] do_readv_writev at c0473486
>  #7 [f6836e6c] vfs_writev at c047358e
>  #8 [f6836e7c] nfsd_vfs_write at f8e7f8d7
>  #9 [f6836ee0] nfsd_write at f8e80139
> #10 [f6836f10] nfsd3_proc_write at f8e86afd
> #11 [f6836f44] nfsd_dispatch at f8e7c20c
> #12 [f6836f6c] svc_process at f89c18e0
> #13 [f6836fbc] nfsd at f8e7c794
> #14 [f6836fe4] kernel_thread_helper at c0405a35
> crash> ps|grep ps
>     234      2   3  cb194000  IN   0.0       0      0  [khpsbpkt]
>     520      2   0  f7e18c20  IN   0.0       0      0  [kpsmoused]
>    2859      1   2  f7f3cc20  IN   0.1    9600   2040  cupsd
>    3340   3310   0  f4a0f840  UN   0.0    4360    816  pstree
>    3343   3284   2  f4a0f230  UN   0.0    4212    944  ps
> crash> bt 3340
> PID: 3340   TASK: f4a0f840  CPU: 0   COMMAND: "pstree"
>  #0 [e856be30] schedule at c0624a34
>  #1 [e856bea4] rwsem_down_failed_common at c04df6c0
>  #2 [e856bec4] rwsem_down_read_failed at c0625c2a
>  #3 [e856bedc] call_rwsem_down_read_failed at c0625c96
>  #4 [e856bee8] down_read at c043c21a
>  #5 [e856bef0] access_process_vm at c0462039
>  #6 [e856bf38] proc_pid_cmdline at c04a1bbb
>  #7 [e856bf58] proc_info_read at c04a2f41
>  #8 [e856bf7c] vfs_read at c04737db
>  #9 [e856bf98] sys_read at c0473c2e
> #10 [e856bfb4] sysenter_entry at c0404ddf
>     EAX: 00000003  EBX: 00000005  ECX: 0804dc58  EDX: 00000062
>     DS:  007b      ESI: 00000cba  ES:  007b      EDI: 0804e0e0
>     SS:  007b      ESP: bfa3afe8  EBP: bfa3d4f8
>     CS:  0073      EIP: b7f64410  ERR: 00000003  EFLAGS: 00000246
> ----------------------------------------------------------
> 
> Any ideas what could potentially trigger this?

This is pretty much expected: the NFS server is trying to allocate
memory. The VM then tries to satisfy that demand by freeing up resources
from the NFS client by telling the client to write out cached pages. The
client again is in a congested state in which it is waiting on the NFS
server to finish writing out what it already sent.
	Quod Erat Deadlocked...

This is why 'mount --bind' is a good idea, and 'mount -t nfs localhost:'
is generally a bad one...

Cheers
  Trond
