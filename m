From: rwhron@earthlink.net
Subject: livelock running bonnie++ on nfs on 2.5.40-mm1
Date: Thu, 3 Oct 2002 19:44:46 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021003234446.GA32092@rushmore>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from hawk.mail.pas.earthlink.net ([207.217.120.22])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17xFb7-0005K6-00
	for <nfs@lists.sourceforge.net>; Thu, 03 Oct 2002 16:41:37 -0700
Received: from user-38lc4p6.dialup.mindspring.com ([209.86.19.38] helo=earthlink.net)
	by hawk.mail.pas.earthlink.net with smtp (Exim 3.33 #1)
	id 17xFb4-0007jV-00
	for nfs@lists.sourceforge.net; Thu, 03 Oct 2002 16:41:35 -0700
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


AMD k6/2 running 2.5.40-mm1 locked up just as bonnie++ started
to run.  Using nfs-utils-1.0.1.  Underlying fs is ext2.  bonnie++
ran fine when it wasn't on nfs.  nfs client and server are the
same machine.  The system wouldn't allow a login.   Console was
dead.

cat /etc/exports
/opt/testing/nfs 192.168.0.0/24(rw,root_squash,no_wdelay,anonuid=18008,anongid=18008,async)


grep ^C .config|egrep 'NFS|RPC'
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
CONFIG_NFSD=y
CONFIG_NFSD_V3=y
CONFIG_SUNRPC=y

SysRq : Show Regs

Pid: 2895, comm:                 nfsd
EIP: 0060:[<c0141186>] CPU: 0EIP is at d_lookup+0xda/0xf0
 EFLAGS: 00000217    Not tainted
EAX: d7f20ca0 EBX: d7a9ef60 ECX: 00000010 EDX: b9011e78
ESI: c29c0120 EDI: cb815e30 EBP: d7a9ef78 DS: 0068 ES: 0068
CR0: 8005003b CR2: 40167000 CR3: 0dfaf000 CR4: 00000090
Call Trace:
 [<c0139076>]cached_lookup+0xe/0x50
 [<c0139cd8>]lookup_hash+0x44/0x9c
 [<c0139d83>]lookup_one_len+0x53/0x64
 [<c0168061>]find_exported_dentry+0x321/0x5a0
 [<c0131d24>]__getblk+0x18/0x3c
 [<c0154a8d>]ext2_alloc_branch+0x29/0x194
 [<c0154e4e>]ext2_get_block+0x256/0x2f0
 [<c0154cbd>]ext2_get_block+0xc5/0x2f0
 [<c010fd5d>]default_wake_function+0x1d/0x2c
 [<c010fda2>]__wake_up_common+0x36/0x50
 [<c01e6006>]skb_release_data+0x8a/0x90
 [<c01e613c>]__kfree_skb+0xd8/0xe0
 [<c01e7b20>]skb_free_datagram+0x1c/0x20
 [<c021bba7>]udp_data_ready+0x143/0x174
 [<c020f15b>]udp_queue_rcv_skb+0x5f/0xa4
 [<c020f494>]udp_rcv+0x120/0x268
 [<c01f3d75>]ip_local_deliver+0xb1/0x12c
 [<c01f40cf>]ip_rcv+0x2df/0x340
 [<c01e9501>]netif_receive_skb+0xfd/0x128
 [<c01e959d>]process_backlog+0x71/0x114
 [<c01e96ae>]net_rx_action+0x6e/0x108
 [<c01685cf>]export_decode_fh+0x67/0x6f
 [<c016a400>]nfsd_acceptable+0x0/0xb8
 [<c016a73e>]fh_verify+0x286/0x404
 [<c016a400>]nfsd_acceptable+0x0/0xb8
 [<c01f6dd6>]ip_build_xmit+0x2b6/0x340
 [<c016b6ba>]nfsd_open+0x36/0x130
 [<c016bafe>]nfsd_write+0x2e/0x2b4
 [<c010fd5d>]default_wake_function+0x1d/0x2c
 [<c010fda2>]__wake_up_common+0x36/0x50
 [<c0170de2>]nfsd3_proc_write+0xee/0x10c
 [<c0168ac2>]nfsd_dispatch+0xce/0x19c
 [<c021fd55>]svc_process+0x28d/0x4d8
 [<c01688b6>]nfsd+0x15e/0x29c
 [<c0168758>]nfsd+0x0/0x29c
 [<c010540d>]kernel_thread_helper+0x5/0xc

SysRq : Show Memory
Mem-info:
Free pages:        3584kB (     0kB HighMem)
Zone:DMA freepages:   384kB min:   128kB low:   256kB high:   384kB active:  1332kB inactive: 10724kB
Zone:Normal freepages:  3200kB min:  1020kB low:  2040kB high:  3060kB active: 58840kB inactive:292512kB
Zone:HighMem freepages:     0kB min:     0kB low:     0kB high:     0kB active:     0kB inactive:     0kB
( Active:15043 inactive:75809 dirty:3625 writeback:0 free:896 )
56*4kB 20*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 384kB)
306*4kB 225*8kB 9*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3200kB)
Swap cache: add 205468, delete 189967, find 139427/156002, race 0+11
Free swap:        19296kB
98304 pages of RAM
0 pages of HIGHMEM
1932 reserved pages
48898 pages shared
15501 pages swap cached


SysRq : Show State

                         free                        sibling
  task             PC    stack   pid father child younger older
init          R C14FFF24     0     1      0     2               (NOTLB)
Call Trace:
 [<c0118028>]schedule_timeout+0x8c/0xac
 [<c0117f90>]process_timeout+0x0/0xc
 [<c013d50a>]do_select+0x1a6/0x1e0
 [<c013d8b2>]sys_select+0x346/0x490
 [<c0106d47>]syscall_call+0x7/0xb

ksoftirqd_CPU S C14FA000     4     2      1             3       (L-TLB)
Call Trace:
 [<c0115301>]ksoftirqd+0x81/0xc8
 [<c0115280>]ksoftirqd+0x0/0xc8
 [<c010540d>]kernel_thread_helper+0x5/0xc

keventd       R C14F9FC0     0     3      1             4     2 (L-TLB)
Call Trace:
 [<c011c41d>]context_thread+0xe1/0x1c4
 [<c011c33c>]context_thread+0x0/0x1c4
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010540d>]kernel_thread_helper+0x5/0xc

kswapd0       S C0274338     4     4      1            25     3 (L-TLB)
Call Trace:
 [<c01270a4>]kswapd+0xcc/0xf8
 [<c0126fd8>]kswapd+0x0/0xf8
 [<c0110d14>]autoremove_wake_function+0x0/0x38
 [<c0110d14>]autoremove_wake_function+0x0/0x38
 [<c010540d>]kernel_thread_helper+0x5/0xc

syslogd       R 7FFFFFFF     4    25      1            28     4 (NOTLB)
Call Trace:
 [<c01e8136>]datagram_poll+0x22/0xbc
 [<c0117fb0>]schedule_timeout+0x14/0xac
 [<c01e379f>]sock_poll+0x1b/0x20
 [<c013d449>]do_select+0xe5/0x1e0
 [<c013d50a>]do_select+0x1a6/0x1e0
 [<c013d8b2>]sys_select+0x346/0x490
 [<c0106d47>]syscall_call+0x7/0xb

klogd         R D7A1E000 10052    28      1            32    25 (NOTLB)
Call Trace:
 [<c01124b8>]do_syslog+0xe8/0x370
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c014ed43>]kmsg_read+0xf/0x14
 [<c012fd82>]vfs_read+0xb2/0xf8
 [<c012fee4>]sys_read+0x28/0x3c
 [<c0106d47>]syscall_call+0x7/0xb

eth0          R CE44BF94     0    32      1            39    28 (L-TLB)
Call Trace:
 [<c0118028>]schedule_timeout+0x8c/0xac
 [<c0117f90>]process_timeout+0x0/0xc
 [<c010ff69>]interruptible_sleep_on_timeout+0x4d/0x74
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c01c63eb>]rtl8139_thread+0x8f/0x198
 [<c01c635c>]rtl8139_thread+0x0/0x198
 [<c010540d>]kernel_thread_helper+0x5/0xc

sshd          S 7FFFFFFF     0    39      1   392     390    32 (NOTLB)
Call Trace:
 [<c0117fb0>]schedule_timeout+0x14/0xac
 [<c01e379f>]sock_poll+0x1b/0x20
 [<c013d449>]do_select+0xe5/0x1e0
 [<c013d50a>]do_select+0x1a6/0x1e0
 [<c013d8b2>]sys_select+0x346/0x490
 [<c010fd1c>]schedule+0x24c/0x270
 [<c0106d47>]syscall_call+0x7/0xb

agetty        S 7FFFFFFF     4   390      1           391    39 (NOTLB)
Call Trace:
 [<c0117fb0>]schedule_timeout+0x14/0xac
 [<c01aeb91>]write_chan+0x195/0x204
 [<c01ae634>]read_chan+0x3c4/0x78c
 [<c01ae684>]read_chan+0x414/0x78c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c01aa8e6>]tty_read+0xaa/0xcc
 [<c012fd82>]vfs_read+0xb2/0xf8
 [<c012fee4>]sys_read+0x28/0x3c
 [<c0106d47>]syscall_call+0x7/0xb

agetty        S 7FFFFFFF     4   391      1          2395   390 (NOTLB)
Call Trace:
 [<c0117fb0>]schedule_timeout+0x14/0xac
 [<c01aeb91>]write_chan+0x195/0x204
 [<c01ae634>]read_chan+0x3c4/0x78c
 [<c01ae684>]read_chan+0x414/0x78c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c01aa8e6>]tty_read+0xaa/0xcc
 [<c012fd82>]vfs_read+0xb2/0xf8
 [<c012fee4>]sys_read+0x28/0x3c
 [<c0106d47>]syscall_call+0x7/0xb

sshd          R 7FFFFFFF     0   392     39   393               (NOTLB)
Call Trace:
 [<c0117fb0>]schedule_timeout+0x14/0xac
 [<c013d449>]do_select+0xe5/0x1e0
 [<c013d50a>]do_select+0x1a6/0x1e0
 [<c013d8b2>]sys_select+0x346/0x490
 [<c0106d47>]syscall_call+0x7/0xb

bash          S FFFFFE00   384   393    392   398               (NOTLB)
Call Trace:
 [<c011431a>]sys_wait4+0xb6/0x3a0
 [<c01145d1>]sys_wait4+0x36d/0x3a0
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c0106d47>]syscall_call+0x7/0xb

bash          S FFFFFE00     0   398    393   403               (NOTLB)
Call Trace:
 [<c011431a>]sys_wait4+0xb6/0x3a0
 [<c01145d1>]sys_wait4+0x36d/0x3a0
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c0106d47>]syscall_call+0x7/0xb

runtests      S FFFFFE00     4   403    398   405               (NOTLB)
Call Trace:
 [<c011431a>]sys_wait4+0xb6/0x3a0
 [<c01145d1>]sys_wait4+0x36d/0x3a0
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c0106d47>]syscall_call+0x7/0xb

vmstat        R D76C9F90     0   405    403           406       (NOTLB)
Call Trace:
 [<c0118028>]schedule_timeout+0x8c/0xac
 [<c0117f90>]process_timeout+0x0/0xc
 [<c01180fb>]sys_nanosleep+0xa3/0xf8
 [<c0106d47>]syscall_call+0x7/0xb

tee           S D76A7F48     0   406    403          2914   405 (NOTLB)
Call Trace:
 [<c0138080>]pipe_wait+0x70/0xac
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c0138183>]pipe_read+0xc7/0x23c
 [<c012fd82>]vfs_read+0xb2/0xf8
 [<c012fee4>]sys_read+0x28/0x3c
 [<c0106d47>]syscall_call+0x7/0xb

postmaster    R D5C53F24     4  2395      1  2400    2479   391 (NOTLB)
Call Trace:
 [<c0118028>]schedule_timeout+0x8c/0xac
 [<c0117f90>]process_timeout+0x0/0xc
 [<c013d50a>]do_select+0x1a6/0x1e0
 [<c013d8b2>]sys_select+0x346/0x490
 [<c0106d47>]syscall_call+0x7/0xb

postmaster    S 7FFFFFFF     0  2400   2395  2402               (NOTLB)
Call Trace:
 [<c0117fb0>]schedule_timeout+0x14/0xac
 [<c013d449>]do_select+0xe5/0x1e0
 [<c013d50a>]do_select+0x1a6/0x1e0
 [<c013d8b2>]sys_select+0x346/0x490
 [<c0106d47>]syscall_call+0x7/0xb

postmaster    S 7FFFFFFF   160  2402   2400                     (NOTLB)
Call Trace:
 [<c0117fb0>]schedule_timeout+0x14/0xac
 [<c013d449>]do_select+0xe5/0x1e0
 [<c013d50a>]do_select+0x1a6/0x1e0
 [<c013d8b2>]sys_select+0x346/0x490
 [<c0106d47>]syscall_call+0x7/0xb


pdflush       R C2852000     4  2479      1          2486  2395 (L-TLB)
Call Trace:
 [<c012cf35>]__pdflush+0xb5/0x17c
 [<c012cffc>]pdflush+0x0/0x14
 [<c012d007>]pdflush+0xb/0x14
 [<c012d2fc>]wb_kupdate+0x0/0xfc
 [<c010540d>]kernel_thread_helper+0x5/0xc

pdflush       S C95CC000     4  2486      1          2878  2479 (L-TLB)
Call Trace:
 [<c012cf35>]__pdflush+0xb5/0x17c
 [<c012cffc>]pdflush+0x0/0x14
 [<c012d007>]pdflush+0xb/0x14
 [<c010540d>]kernel_thread_helper+0x5/0xc

portmap       S 7FFFFFFF     0  2878      1          2880  2486 (NOTLB)
Call Trace:
 [<c013da44>]do_pollfd+0x48/0x88
 [<c0117fb0>]schedule_timeout+0x14/0xac
 [<c013db09>]do_poll+0x85/0xe8
 [<c013db44>]do_poll+0xc0/0xe8
 [<c013dcf8>]sys_poll+0x18c/0x274
 [<c0106d47>]syscall_call+0x7/0xb

rpc.mountd    S 7FFFFFFF     4  2880      1          2882  2878 (NOTLB)
Call Trace:
 [<c013da44>]do_pollfd+0x48/0x88
 [<c0117fb0>]schedule_timeout+0x14/0xac
 [<c013db09>]do_poll+0x85/0xe8
 [<c013db44>]do_poll+0xc0/0xe8
 [<c013dcf8>]sys_poll+0x18c/0x274
 [<c0106d47>]syscall_call+0x7/0xb

nfsd          R D2449F60     0  2882      1          2883  2880 (L-TLB)
Call Trace:
 [<c0118028>]schedule_timeout+0x8c/0xac
 [<c0117f90>]process_timeout+0x0/0xc
 [<c02217de>]svc_recv+0x216/0x448
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c0168800>]nfsd+0xa8/0x29c
 [<c0168758>]nfsd+0x0/0x29c
 [<c010540d>]kernel_thread_helper+0x5/0xc

nfsd          R C7ED5F60     0  2883      1          2884  2882 (L-TLB)
Call Trace:
 [<c0118028>]schedule_timeout+0x8c/0xac
 [<c0117f90>]process_timeout+0x0/0xc
 [<c02217de>]svc_recv+0x216/0x448
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c0168800>]nfsd+0xa8/0x29c
 [<c0168758>]nfsd+0x0/0x29c
 [<c010540d>]kernel_thread_helper+0x5/0xc

nfsd          R D781DF60     4  2884      1          2885  2883 (L-TLB)
Call Trace:
 [<c0118028>]schedule_timeout+0x8c/0xac
 [<c0117f90>]process_timeout+0x0/0xc
 [<c02217de>]svc_recv+0x216/0x448
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c0168800>]nfsd+0xa8/0x29c
 [<c0168758>]nfsd+0x0/0x29c
 [<c010540d>]kernel_thread_helper+0x5/0xc

nfsd          R D117DF60     4  2885      1          2886  2884 (L-TLB)
Call Trace:
 [<c0118028>]schedule_timeout+0x8c/0xac
 [<c0117f90>]process_timeout+0x0/0xc
 [<c02217de>]svc_recv+0x216/0x448
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c0168800>]nfsd+0xa8/0x29c
 [<c0168758>]nfsd+0x0/0x29c
 [<c010540d>]kernel_thread_helper+0x5/0xc

nfsd          R D45FFF60     4  2886      1          2887  2885 (L-TLB)
Call Trace:
 [<c0118028>]schedule_timeout+0x8c/0xac
 [<c0117f90>]process_timeout+0x0/0xc
 [<c02217de>]svc_recv+0x216/0x448
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c0168800>]nfsd+0xa8/0x29c
 [<c0168758>]nfsd+0x0/0x29c
 [<c010540d>]kernel_thread_helper+0x5/0xc

nfsd          R CFA1BF60     0  2887      1          2888  2886 (L-TLB)
Call Trace:
 [<c0118028>]schedule_timeout+0x8c/0xac
 [<c0117f90>]process_timeout+0x0/0xc
 [<c02217de>]svc_recv+0x216/0x448
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c0168800>]nfsd+0xa8/0x29c
 [<c0168758>]nfsd+0x0/0x29c
 [<c010540d>]kernel_thread_helper+0x5/0xc

nfsd          R C9FA7F60     4  2888      1          2889  2887 (L-TLB)
Call Trace:
 [<c0118028>]schedule_timeout+0x8c/0xac
 [<c0117f90>]process_timeout+0x0/0xc
 [<c02217de>]svc_recv+0x216/0x448
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c0168800>]nfsd+0xa8/0x29c
 [<c0168758>]nfsd+0x0/0x29c
 [<c010540d>]kernel_thread_helper+0x5/0xc

nfsd          R C75A3F60     4  2889      1          2890  2888 (L-TLB)
Call Trace:
 [<c0118028>]schedule_timeout+0x8c/0xac
 [<c0117f90>]process_timeout+0x0/0xc
 [<c02217de>]svc_recv+0x216/0x448
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c0168800>]nfsd+0xa8/0x29c
 [<c0168758>]nfsd+0x0/0x29c
 [<c010540d>]kernel_thread_helper+0x5/0xc

nfsd          R D2AB7F60     4  2890      1          2891  2889 (L-TLB)
Call Trace:
 [<c0118028>]schedule_timeout+0x8c/0xac
 [<c0117f90>]process_timeout+0x0/0xc
 [<c02217de>]svc_recv+0x216/0x448
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c0168800>]nfsd+0xa8/0x29c
 [<c0168758>]nfsd+0x0/0x29c
 [<c010540d>]kernel_thread_helper+0x5/0xc

nfsd          R C45BBF60     4  2891      1          2892  2890 (L-TLB)
Call Trace:
 [<c0118028>]schedule_timeout+0x8c/0xac
 [<c0117f90>]process_timeout+0x0/0xc
 [<c02217de>]svc_recv+0x216/0x448
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c0168800>]nfsd+0xa8/0x29c
 [<c0168758>]nfsd+0x0/0x29c
 [<c010540d>]kernel_thread_helper+0x5/0xc

nfsd          R C51CFF60     4  2892      1          2893  2891 (L-TLB)
Call Trace:
 [<c0118028>]schedule_timeout+0x8c/0xac
 [<c0117f90>]process_timeout+0x0/0xc
 [<c02217de>]svc_recv+0x216/0x448
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c0168800>]nfsd+0xa8/0x29c
 [<c0168758>]nfsd+0x0/0x29c
 [<c010540d>]kernel_thread_helper+0x5/0xc

nfsd          R C426FF60     4  2893      1          2894  2892 (L-TLB)
Call Trace:
 [<c0118028>]schedule_timeout+0x8c/0xac
 [<c0117f90>]process_timeout+0x0/0xc
 [<c02217de>]svc_recv+0x216/0x448
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c0168800>]nfsd+0xa8/0x29c
 [<c0168758>]nfsd+0x0/0x29c
 [<c010540d>]kernel_thread_helper+0x5/0xc

nfsd          R D2E43F60     0  2894      1          2895  2893 (L-TLB)
Call Trace:
 [<c0118028>]schedule_timeout+0x8c/0xac
 [<c0117f90>]process_timeout+0x0/0xc
 [<c02217de>]svc_recv+0x216/0x448
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c0168800>]nfsd+0xa8/0x29c
 [<c0168758>]nfsd+0x0/0x29c
 [<c010540d>]kernel_thread_helper+0x5/0xc

nfsd          R current      4  2895      1          2896  2894 (L-TLB)
Call Trace:
 [<c0170de2>]nfsd3_proc_write+0xee/0x10c
 [<c0168ac2>]nfsd_dispatch+0xce/0x19c
 [<c021fd55>]svc_process+0x28d/0x4d8
 [<c01688b6>]nfsd+0x15e/0x29c
 [<c0168758>]nfsd+0x0/0x29c
 [<c010540d>]kernel_thread_helper+0x5/0xc

nfsd          R D6067F60     4  2896      1          2897  2895 (L-TLB)
Call Trace:
 [<c0118028>]schedule_timeout+0x8c/0xac
 [<c0117f90>]process_timeout+0x0/0xc
 [<c02217de>]svc_recv+0x216/0x448
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c010fd40>]default_wake_function+0x0/0x2c
 [<c0168800>]nfsd+0xa8/0x29c
 [<c0168758>]nfsd+0x0/0x29c
 [<c010540d>]kernel_thread_helper+0x5/0xc

nfsd          R C23D7F60     4  2897      1          2898  2896 (L-TLB)
Call Trace:
 [<c0118028>]schedule_timeout+0x8c/0xac
 [<c0117f90>]process_timeout+0x0/0xc
 [<c02217

-- 
Randy Hron
http://home.earthlink.net/~rwhron/kernel/bigbox.html



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
