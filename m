From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH] oops when unloading sunrpc module.
Date: Thu, 24 Jun 2004 15:49:43 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0406241542480.2427@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bdd2V-0007kG-QO
	for nfs@lists.sourceforge.net; Thu, 24 Jun 2004 15:49:51 -0700
Received: from e34.co.us.ibm.com ([32.97.110.132])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1Bdd2V-0006Yk-Bc
	for nfs@lists.sourceforge.net; Thu, 24 Jun 2004 15:49:51 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.10/8.12.2) with ESMTP id i5OMni10475064
	for <nfs@lists.sourceforge.net>; Thu, 24 Jun 2004 18:49:44 -0400
Received: from w-sridhar.beaverton.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id i5OMnhEv336394
	for <nfs@lists.sourceforge.net>; Thu, 24 Jun 2004 16:49:44 -0600
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

I am seeing the following warning message followed by a oops when unloading
sunrpc module in linux 2.6.7. This happens only if lock operations are
performed on a file that is mounted on the client before unloading nfs modules.

Badness in remove_proc_entry at fs/proc/generic.c:685
 [<c018e799>] remove_proc_entry+0x109/0x150
 [<d091dfdc>] rpc_proc_exit+0x3c/0x50 [sunrpc]
 [<c0134386>] sys_delete_module+0x176/0x1b0
 [<c014c2d8>] do_munmap+0x178/0x1e0
 [<c010462b>] syscall_call+0x7/0xb

Unable to handle kernel paging request at virtual address d0929c74
 printing eip:
c01258d0
*pde = 0fdc0067
*pte = 00000000
Oops: 0000 [#1]
PREEMPT SMP
Modules linked in: netconsole 3c59x e100
CPU:    0
EIP:    0060:[<c01258d0>]    Not tainted
EFLAGS: 00010006   (2.6.7)
EIP is at cascade+0x30/0x70
eax: cb5afeb8   ebx: d0929c58   ecx: 0009c000   edx: c1202e04
esi: c12030e4   edi: c12025a0   ebp: 00000027   esp: c0383f10
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, threadinfo=c0382000 task=c030b180)
Stack: c12025a0 cfdb01f0 c12025a0 00000000 0000000a c0382000 c0125fa7 c12025a0
       c1202fac 00000027 c030dc8c c0382000 c0383f40 c0383f40 00000000 00000001
       c0381008 0000000a c0383f94 c0121527 c0381008 00000046 00000000 c03a70a4
Call Trace:
 [<c0125fa7>] run_timer_softirq+0x197/0x1e0
 [<c0121527>] __do_softirq+0xb7/0xc0
 [<c012155d>] do_softirq+0x2d/0x30
 [<c0111a47>] smp_apic_timer_interrupt+0xe7/0x160
 [<c0102310>] default_idle+0x0/0x40
 [<c010501a>] apic_timer_interrupt+0x1a/0x20
 [<c0102310>] default_idle+0x0/0x40
 [<c010233d>] default_idle+0x2d/0x40
 [<c01023d6>] cpu_idle+0x46/0x50
 [<c0384919>] start_kernel+0x179/0x1b0
 [<c0384380>] unknown_bootoption+0x0/0x140

Code: 39 7b 1c 89 d8 75 21 8b 1b 89 3c 24 89 44 24 04 e8 9b f9 ff
 <0>Kernel panic: Fatal exception in interrupt
In interrupt handler - not syncing

The following simple patch fixes the problem.

diff -Nru a/fs/nfsd/lockd.c b/fs/nfsd/lockd.c
--- a/fs/nfsd/lockd.c   Thu Jun 24 15:38:29 2004
+++ b/fs/nfsd/lockd.c   Thu Jun 24 15:38:29 2004
@@ -40,7 +40,6 @@
                mntget(filp->f_vfsmnt);
        }
        fh_put(&fh);
-       rqstp->rq_client = NULL;
        exp_readunlock();
        /* nlm and nfsd don't share error codes.
         * we invent: 0 = no error

I am not sure why rqstp->rq_client is set to NULL in nlm_fopen. This results
in leaking of auth_domain cache entries.
I think we should do a auth_domain_put() before clearing rq_client. This is
done in the release function(eg:svcauth_unix_release).

Thanks
Sridhar


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
