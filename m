From: James Chamberlain <jamesc@exa.com>
Subject: NFS mandelbug
Date: Wed, 2 Jun 2004 13:28:28 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.3.96.1040602104637.19937A-100000@einstein>
Reply-To: James Chamberlain <jamesc@exa.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVZYR-00012y-2J
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 10:29:31 -0700
Received: from fermi.exa.com ([149.65.3.1])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BVZYQ-0004BB-Aj
	for nfs@lists.sourceforge.net; Wed, 02 Jun 2004 10:29:30 -0700
Received: from localhost (localhost.localdomain [127.0.0.1])
	by fermi.exa.com (Postfix) with ESMTP id ED924203D1
	for <nfs@lists.sourceforge.net>; Wed,  2 Jun 2004 13:29:22 -0400 (EDT)
Received: from fermi.exa.com ([127.0.0.1])
 by localhost (fermi [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
 id 10558-04 for <nfs@lists.sourceforge.net>;
 Wed,  2 Jun 2004 13:29:21 -0400 (EDT)
Received: from einstein.exa.com (einstein [149.65.2.27])
	by fermi.exa.com (Postfix) with SMTP id C0C39203AD
	for <nfs@lists.sourceforge.net>; Wed,  2 Jun 2004 13:29:21 -0400 (EDT)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi all,

Apologies for the braindump, but I've tried everything I can think of and am
hoping someone on the list can think of something I haven't.  I've got an NFS
server here which seems to randomly stop serving NFS - though the rest of the
system remains up and running.

The first thing I noticed in the syslog was that the "kernel is unable to
handle a NULL pointer dereference at virtual address 00000020".  The culprit
for this message seems to be lockd.  (ksymoops at the end of the message)

I've been having some trouble narrowing down exactly what triggers the NFS
server on this system to stop working, but I've come up with one set of
conditions so far:  a relatively short time after the lockd oops, attempts to
mount filesystems from the server trigger the problem.  At roughly the same
time, with additional debugging enabled, I start getting messages in the
syslog saying "svc: socket <hex-num> TCP data ready" and "svc: socket
<hex-num> busy, not enqueued".  I have observed this problem regardless of
whether I was running a SMP or uniprocessor kernel.

To my knowledge, nothing about the system has changed from when it was
working perfectly to now, and in fact I have restored the boot/root disk to
the factory default just to be sure.  It's running kernel 2.4.18-i49smp at
the moment, and unfortunately I can't upgrade to a newer kernel because of a
custom RAID card driver.  I can't shake the feeling that this has got to be a
configuration issue, since like I said, the software itself is back to a
configuration where it was known to be working.

I'm not sure what additional information to provide that would be helpful in
figuring this thing out, so here's what I could think of:

The underlying filesystem is reiserfs.
The filesystems are exported as:
    (rw,no_root_squash,no_subtree_check,insecure)
/proc/fs/nfs/exports shows for them:
    (rw,insecure,no_root_squash,async,wdelay,no_subtree_check)
[root@raidzone /root]# wc -l /proc/fs/nfs/exports
    539 /proc/fs/nfs/exports
[root@raidzone /root]# rpm -q nfs-utils
nfs-utils-0.3.3-1
[root@raidzone /root]# cat /etc/issue
Raidzone OpenNAS Linux Release 1.4-8
Kernel 2.4.18-i49smp on a 2-processor i686
[root@raidzone /root]# cat /etc/redhat-release 
Red Hat Linux release 7.1 (Seawolf)
[root@raidzone /root]# dmesg | ksymoops
ksymoops 2.4.0 on i686 2.4.18-i49smp.  Options used
     -V (default)
     -k /proc/ksyms (default)
     -l /proc/modules (default)
     -o /lib/modules/2.4.18-i49smp/ (default)
     -m /boot/System.map-2.4.18-i49smp (default)

Warning: You did not tell me where to find symbol information.  I will
assume that the log matches the kernel and modules that are running
right now and I'll use the default options above for symbol resolution.
If the current kernel and/or modules do not match the log, you can get
more accurate output by telling me the kernel version and where to find
map, modules, ksyms etc.  ksymoops -h explains the options.

Warning (compare_maps): mismatch on symbol nlmsvc_ops  , lockd says c17863b0, /l
ib/modules/2.4.18-i49smp/kernel/fs/lockd/lockd.o says c1785730.  Ignoring /lib/m
odules/2.4.18-i49smp/kernel/fs/lockd/lockd.o entry
Warning (compare_maps): mismatch on symbol nfs_debug  , sunrpc says c1778104, /l
ib/modules/2.4.18-i49smp/kernel/net/sunrpc/sunrpc.o says c1777dc4.  Ignoring /li
b/modules/2.4.18-i49smp/kernel/net/sunrpc/sunrpc.o entry
Warning (compare_maps): mismatch on symbol nfsd_debug  , sunrpc says c1778108, /
lib/modules/2.4.18-i49smp/kernel/net/sunrpc/sunrpc.o says c1777dc8.  Ignoring /l
ib/modules/2.4.18-i49smp/kernel/net/sunrpc/sunrpc.o entry
Warning (compare_maps): mismatch on symbol nlm_debug  , sunrpc says c177810c, /l
ib/modules/2.4.18-i49smp/kernel/net/sunrpc/sunrpc.o says c1777dcc.  Ignoring /li
b/modules/2.4.18-i49smp/kernel/net/sunrpc/sunrpc.o entry
Warning (compare_maps): mismatch on symbol rpc_debug  , sunrpc says c1778100, /l
ib/modules/2.4.18-i49smp/kernel/net/sunrpc/sunrpc.o says c1777dc0.  Ignoring /li
b/modules/2.4.18-i49smp/kernel/net/sunrpc/sunrpc.o entry
cpu: 0, clocks: 1329139, slice: 443046
cpu: 1, clocks: 1329139, slice: 443046
SGI XFS with ACLs, DMAPI, quota, no debug enabled
e1000: eth1 NIC Link is Up 100 Mbps Full Duplex
e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex
Unable to handle kernel NULL pointer dereference at virtual address 00000020
c178137c
*pde = 00000000
Oops: 0000
CPU:    1
EIP:    0010:[<c178137c>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010286
eax: 00000000   ebx: b8c1e6e0   ecx: c1798740   edx: ad257800
esi: b8c1e5e0   edi: b8c1e6ec   ebp: ad089000   esp: ad3d9f50
ds: 0018   es: 0018   ss: 0018
Process lockd (pid: 910, stackpage=ad3d9000)
Stack: 00000000 00000000 b8c1e6e0 b8c1e5e0 ad089000 c1785e70 c1781565 ad089000 
       b8c1e6e0 ad3d9f7c ad3d9f80 ae61005c b8c1e6ec ad089448 b8c1e6e0 b8c1e6e0 
       c176e50a ad089000 b8c1e6e0 b8c1e5e0 000186b5 00000002 ae610018 c17855b4 
Call Trace: [<c1785e70>] [<c1781565>] [<c176e50a>] [<c17855b4>] [<c17855d8>] 
   [<c177c2af>] [<c177c070>] [<80105836>] [<c177c070>] 
Code: 8b 40 20 8b 70 10 55 e8 a8 a1 ff ff 89 c3 58 85 db 74 71 53 

>>EIP; c178137c <[lockd]nlm4svc_retrieve_args+6c/110>   <=====
Trace; c1785e70 <[lockd]nlmsvc_procedures4+48/35f>
Trace; c1781565 <[lockd]nlm4svc_proc_lock+65/d0>
Trace; c176e50a <[sunrpc]svc_process+2ca/508>
Trace; c17855b4 <[lockd]nlmsvc_version4+0/10>
Trace; c17855d8 <[lockd]nlmsvc_program+0/1c>
Trace; c177c2af <[lockd]lockd+23f/300>
Trace; c177c070 <[lockd]lockd+0/300>
Trace; 80105836 <arch_kernel_thread+26/30>
Trace; c177c070 <[lockd]lockd+0/300>
Code;  c178137c <[lockd]nlm4svc_retrieve_args+6c/110>
00000000 <_EIP>:
Code;  c178137c <[lockd]nlm4svc_retrieve_args+6c/110>   <=====
   0:   8b 40 20                  mov    0x20(%eax),%eax   <=====
Code;  c178137f <[lockd]nlm4svc_retrieve_args+6f/110>
   3:   8b 70 10                  mov    0x10(%eax),%esi
Code;  c1781382 <[lockd]nlm4svc_retrieve_args+72/110>
   6:   55                        push   %ebp
Code;  c1781383 <[lockd]nlm4svc_retrieve_args+73/110>
   7:   e8 a8 a1 ff ff            call   ffffa1b4 <_EIP+0xffffa1b4> c177b530 <[l
ockd]nlmsvc_lookup_host+0/30>
Code;  c1781388 <[lockd]nlm4svc_retrieve_args+78/110>
   c:   89 c3                     mov    %eax,%ebx
Code;  c178138a <[lockd]nlm4svc_retrieve_args+7a/110>
   e:   58                        pop    %eax
Code;  c178138b <[lockd]nlm4svc_retrieve_args+7b/110>
   f:   85 db                     test   %ebx,%ebx
Code;  c178138d <[lockd]nlm4svc_retrieve_args+7d/110>
  11:   74 71                     je     84 <_EIP+0x84> c1781400 <[lockd]nlm4svc
_retrieve_args+f0/110>
Code;  c178138f <[lockd]nlm4svc_retrieve_args+7f/110>
  13:   53                        push   %ebx

6 warnings issued.  Results may not be reliable.

If anyone has any thoughts, I would greatly appreciate them.  If there's any
additional information I should provide, let me know and I will do so.

Thanks,

James Chamberlain




-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
