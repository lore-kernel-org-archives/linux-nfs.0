From: Ron Reed <ron.reed@arm.gov>
Subject: RedHat Linux 2.4.9-31 and Solaris 5.7 with Apache
Date: Wed, 03 Apr 2002 08:59:58 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CAB18EE.4000809@arm.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
To: NFS@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

I have run into a strange problem that is causing me some headaches. I
have done some searches for an answer, we have even talked with RedHat
support with no solution. I am hopeing that someone on the list can help
me solve this. Here is the setup, a Redhat 7.1, kernel 2.4.9-31, with
the latest nfs-utils release has a 140 gig raid array attached to it.
This is our NFS server. One of the clients is a Sun Solaris 5.7 machine.
Everything seems to work just fine, until something happens to the
Apache 1.3.19 daemon running on the Solaris over a NFS mount. Here is
the oops output that has been run thru ksymoops:

ksymoops 2.4.0 on i686 2.4.9-31.  Options used
      -V (default)
      -k /proc/ksyms (default)
      -l /proc/modules (default)
      -o /lib/modules/2.4.9-31/ (default)
      -m /boot/System.map-2.4.9-31 (default)

Warning: You did not tell me where to find symbol information.  I will
assume that the log matches the kernel and modules that are running
right now and I'll use the default options above for symbol resolution.
If the current kernel and/or modules do not match the log, you can get
more accurate output by telling me the kernel version and where to find
map, modules, ksyms etc.  ksymoops -h explains the options.

Error (expand_objects): cannot stat(/lib/aic7xxx.o) for aic7xxx
Error (expand_objects): cannot stat(/lib/megaraid.o) for megaraid
Error (expand_objects): cannot stat(/lib/aacraid.o) for aacraid
Error (expand_objects): cannot stat(/lib/sd_mod.o) for sd_mod
Error (expand_objects): cannot stat(/lib/scsi_mod.o) for scsi_mod
Warning (compare_maps): mismatch on symbol partition_name  , ksyms_base 
says c01ad97c, System.map says c01510cc.  Ignoring ksyms_base entry
Warning (compare_maps): mismatch on symbol nlmsvc_grace_period  , lockd 
says e0976674, /lib/modules/2.4.9-31/kernel/fs/lockd/lockd.o says 
e0975ad4.  Ignoring /lib/modules/2.4.9-31/kernel/fs/lockd/lockd.o entry
Warning (compare_maps): mismatch on symbol nlmsvc_ops  , lockd says 
e0976670, /lib/modules/2.4.9-31/kernel/fs/lockd/lockd.o says e0975ad0. 
Ignoring /lib/modules/2.4.9-31/kernel/fs/lockd/lockd.o entry
Warning (compare_maps): mismatch on symbol nlmsvc_timeout  , lockd says 
e0976678, /lib/modules/2.4.9-31/kernel/fs/lockd/lockd.o says e0975ad8. 
Ignoring /lib/modules/2.4.9-31/kernel/fs/lockd/lockd.o entry
Warning (compare_maps): mismatch on symbol nfs_debug  , sunrpc says 
e0968560, /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o says 
e0968240.  Ignoring /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o entry
Warning (compare_maps): mismatch on symbol nfsd_debug  , sunrpc says 
e0968564, /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o says 
e0968244.  Ignoring /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o entry
Warning (compare_maps): mismatch on symbol nlm_debug  , sunrpc says 
e0968568, /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o says 
e0968248.  Ignoring /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o entry
Warning (compare_maps): mismatch on symbol rpc_debug  , sunrpc says 
e096855c, /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o says 
e096823c.  Ignoring /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o entry
Warning (compare_maps): mismatch on symbol rpc_garbage_args  , sunrpc 
says e096853c, /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o says 
e096821c.  Ignoring /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o entry
Warning (compare_maps): mismatch on symbol rpc_success  , sunrpc says 
e096852c, /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o says 
e096820c.  Ignoring /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o entry
Warning (compare_maps): mismatch on symbol rpc_system_err  , sunrpc says 
e0968540, /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o says 
e0968220.  Ignoring /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o entry
Warning (compare_maps): mismatch on symbol xdr_one  , sunrpc says 
e0968524, /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o says 
e0968204.  Ignoring /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o entry
Warning (compare_maps): mismatch on symbol xdr_two  , sunrpc says 
e0968528, /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o says 
e0968208.  Ignoring /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o entry
Warning (compare_maps): mismatch on symbol xdr_zero  , sunrpc says 
e0968520, /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o says 
e0968200.  Ignoring /lib/modules/2.4.9-31/kernel/net/sunrpc/sunrpc.o entry
Warning (map_ksym_to_module): cannot match loaded module aacraid to a 
unique module object.  Trace may not be reliable.
Warning (compare_maps): mismatch on symbol sd  , sd_mod says e081bea0, 
/lib/modules/2.4.9-31/kernel/drivers/scsi/sd_mod.o says e081be00. 
Ignoring /lib/modules/2.4.9-31/kernel/drivers/scsi/sd_mod.o entry
Warning (compare_maps): mismatch on symbol proc_scsi  , scsi_mod says 
e081715c, /lib/modules/2.4.9-31/kernel/drivers/scsi/scsi_mod.o says 
e0815994.  Ignoring /lib/modules/2.4.9-31/kernel/drivers/scsi/scsi_mod.o 
entry
Warning (compare_maps): mismatch on symbol scsi_devicelist  , scsi_mod 
says e0817188, /lib/modules/2.4.9-31/kernel/drivers/scsi/scsi_mod.o says 
e08159c0.  Ignoring /lib/modules/2.4.9-31/kernel/drivers/scsi/scsi_mod.o 
entry
Warning (compare_maps): mismatch on symbol scsi_hostlist  , scsi_mod 
says e0817184, /lib/modules/2.4.9-31/kernel/drivers/scsi/scsi_mod.o says 
e08159bc.  Ignoring /lib/modules/2.4.9-31/kernel/drivers/scsi/scsi_mod.o 
entry
Warning (compare_maps): mismatch on symbol scsi_hosts  , scsi_mod says 
e081718c, /lib/modules/2.4.9-31/kernel/drivers/scsi/scsi_mod.o says 
e08159c4.  Ignoring /lib/modules/2.4.9-31/kernel/drivers/scsi/scsi_mod.o 
entry
Warning (compare_maps): mismatch on symbol scsi_logging_level  , 
scsi_mod says e0817158, 
/lib/modules/2.4.9-31/kernel/drivers/scsi/scsi_mod.o says e0815990. 
Ignoring /lib/modules/2.4.9-31/kernel/drivers/scsi/scsi_mod.o entry
Apr  2 19:35:16 nfs-twpc3 kernel: c014044e
Apr  2 19:35:16 nfs-twpc3 kernel: *pde = 00000000
Apr  2 19:35:16 nfs-twpc3 kernel: Oops: 0002
Apr  2 19:35:16 nfs-twpc3 kernel: CPU:    0
Apr  2 19:35:16 nfs-twpc3 kernel: EIP: 
0010:[locks_delete_block+14/68]    Not tainted
Apr  2 19:35:16 nfs-twpc3 kernel: EIP:    0010:[<c014044e>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
Apr  2 19:35:16 nfs-twpc3 kernel: EFLAGS: 00010246
Apr  2 19:35:16 nfs-twpc3 kernel: eax: c9470c70   ebx: de3dc69c   ecx: 
c9470c7c   edx: 00000000
Apr  2 19:35:16 nfs-twpc3 kernel: esi: c9470c7c   edi: dccd8000   ebp: 
de3dc690   esp: dccd9eb8
Apr  2 19:35:16 nfs-twpc3 kernel: ds: 0018   es: 0018   ss: 0018
Apr  2 19:35:16 nfs-twpc3 kernel: Process lockd (pid: 722, 
stackpage=dccd9000)
Apr  2 19:35:16 nfs-twpc3 kernel: Stack: c9470c70 c014054e c9470c70 
de3dc69c de3dc690 de3dc694 00000000 de3dc690
Apr  2 19:35:16 nfs-twpc3 kernel:        c0140627 de3dc690 00000000 
00000000 df737220 00000000 c013ff88 7fffffff
Apr  2 19:35:16 nfs-twpc3 kernel:        00000000 c0140ed1 df7372d0 
00000000 ffffffff 7fffffff ffffffff 7fffffff
Apr  2 19:35:16 nfs-twpc3 kernel: Call Trace: 
[locks_wake_up_blocks+94/140] locks_wake_up_blocks [kernel] 0x5e
Apr  2 19:35:16 nfs-twpc3 kernel: Call Trace: [<c014054e>] 
locks_wake_up_blocks [kernel] 0x5e
Apr  2 19:35:16 nfs-twpc3 kernel: [<c0140627>] locks_delete_lock 
[kernel] 0x73
Apr  2 19:35:16 nfs-twpc3 kernel: [<c013ff88>] locks_alloc_lock [kernel] 
0x30
Apr  2 19:35:16 nfs-twpc3 kernel: [<c0140ed1>] posix_lock_file [kernel] 
0x2cd
Apr  2 19:35:16 nfs-twpc3 kernel: [<e096c6b5>] lockd_down_Ra7b91a7b 
[lockd] 0xb2d
Apr  2 19:35:16 nfs-twpc3 kernel: [<e096c62e>] lockd_down_Ra7b91a7b 
[lockd] 0xaa6
Apr  2 19:35:16 nfs-twpc3 kernel: [<e0970b51>] 
nlmsvc_invalidate_client_Rb1c3f825 [lockd] 0x2a61
Apr  2 19:35:16 nfs-twpc3 kernel: [<e09761cc>] 
__insmod_lockd_S.data_L2956 [lockd] 0x90c
Apr  2 19:35:16 nfs-twpc3 kernel: [<e095efa8>] svc_process_R02aedea7 
[sunrpc] 0x304
Apr  2 19:35:16 nfs-twpc3 kernel: [<e0975938>] 
__insmod_lockd_S.data_L2956 [lockd] 0x78
Apr  2 19:35:16 nfs-twpc3 kernel: [<e097595c>] 
__insmod_lockd_S.data_L2956 [lockd] 0x9c
Apr  2 19:35:16 nfs-twpc3 kernel: [<e096b9d3>] nlmclnt_proc_R4c9f6104 
[lockd] 0x15a3
Apr  2 19:35:16 nfs-twpc3 kernel: [<c010567a>] kernel_thread [kernel] 0x26
Apr  2 19:35:16 nfs-twpc3 kernel: [<e096b82c>] nlmclnt_proc_R4c9f6104 
[lockd] 0x13fc
Apr  2 19:35:16 nfs-twpc3 kernel: Code: 89 5a 04 89 13 c7 41 04 00 00 00 
00 89 48 0c 89 48 10 8d 48

 >>EIP; c014044e <locks_delete_block+e/44>   <=====
Trace; c014054e <locks_wake_up_blocks+5e/8c>
Trace; c0140627 <locks_delete_lock+73/cc>
Trace; c013ff88 <locks_alloc_lock+30/48>
Trace; c0140ed1 <posix_lock_file+2cd/51c>
Trace; e096c6b5 <[lockd]nlmsvc_cancel_blocked+6d/94>
Trace; e096c62e <[lockd]nlmsvc_unlock+aa/c4>
Trace; e0970b51 <[lockd]nlm4svc_proc_unlock+7d/c0>
Trace; e09761cc <[lockd]nlmsvc_procedures4+80/2ff>
Trace; e095efa8 <[sunrpc]svc_process+304/54c>
Trace; e0975938 <[lockd]nlmsvc_version4+0/10>
Trace; e097595c <[lockd]nlmsvc_program+0/1c>
Trace; e096b9d3 <[lockd]lockd+1a7/264>
Trace; c010567a <kernel_thread+26/30>
Trace; e096b82c <[lockd]lockd+0/264>
Code;  c014044e <locks_delete_block+e/44>
00000000 <_EIP>:
Code;  c014044e <locks_delete_block+e/44>   <=====
    0:   89 5a 04                  mov    %ebx,0x4(%edx)   <=====
Code;  c0140451 <locks_delete_block+11/44>
    3:   89 13                     mov    %edx,(%ebx)
Code;  c0140453 <locks_delete_block+13/44>
    5:   c7 41 04 00 00 00 00      movl   $0x0,0x4(%ecx)
Code;  c014045a <locks_delete_block+1a/44>
    c:   89 48 0c                  mov    %ecx,0xc(%eax)
Code;  c014045d <locks_delete_block+1d/44>
    f:   89 48 10                  mov    %ecx,0x10(%eax)
Code;  c0140460 <locks_delete_block+20/44>
   12:   8d 48 00                  lea    0x0(%eax),%ecx


22 warnings and 5 errors issued.  Results may not be reliable.

Does anyone have any sugguestions on this? There are 4 of these network
setups in production around the world and I need to fix all of them as
soon as I can.

Ron Reed



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
