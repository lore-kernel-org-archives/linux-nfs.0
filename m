From: Ion Badulescu <ionut@badula.org>
Subject: oops in the 2.4.20-NFSALL sunrpc code
Date: Fri, 13 Dec 2002 10:22:19 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0212131002500.15305-100000@moisil.badula.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ool-4351594a.dyn.optonline.net ([67.81.89.74] helo=buggy.badula.org)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Mre5-0003Z5-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Dec 2002 07:22:33 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi Trond,

I'm running a locally concocted kernel, which is essentially RedHat's 
2.4.18-18.7.x with the {nfs,nfsd,sunrpc} code replaced by the code in 
2.4.20 + NFSALL + Neil's {001,006,008-015,022} patches from Nov 19. Neil's 
patches don't touch the sunrpc code, except for patch 001 which only 
changes an error path, so I'm pretty sure it's the changes in NFSALL that 
cause the problem.

The problem:

Unable to handle kernel NULL pointer dereference at virtual address 00000058
 printing eip:
c0967736
*pde = 00000000
Oops: 0000
nfs rocket nfsd lockd sunrpc autofs 3c59x nls_iso8859-1 isofs loop ext3 jbd  
CPU:    0
EIP:    0010:[<c0967736>]    Not tainted
EFLAGS: 00010202

EIP is at xprt_timer [sunrpc] 0x46 (2.4.18-18.7.x.lime2smp)
eax: 0000002c   ebx: 00000000   ecx: 00000008   edx: 00000001
esi: 8655a074   edi: afe00340   ebp: 8655a000   esp: 80367ed0
ds: 0018   es: 0018   ss: 0018
Process swapper (pid: 0, stackpage=80367000)
Stack: afe00340 c09676f0 00000000 00000000 c0968952 afe00340 afe00394 c09688d0 
       8012654a afe00340 80367f00 00000086 80367f00 80367f00 00000000 00000001 
       00000000 00000000 801227bb 803cf780 80122661 00000000 00000001 803ac100 
Call Trace: [<c09676f0>] xprt_timer [sunrpc] 0x0 (0x80367ed4))
[<c0968952>] rpc_run_timer [sunrpc] 0x82 (0x80367ee0))
[<c09688d0>] rpc_run_timer [sunrpc] 0x0 (0x80367eec))
[<8012654a>] timer_bh [kernel] 0x29a (0x80367ef0))
[<801227bb>] bh_action [kernel] 0x4b (0x80367f18))
[<80122661>] tasklet_hi_action [kernel] 0x61 (0x80367f20))
[<801223eb>] do_softirq [kernel] 0x6b (0x80367f38))
[<8010a85e>] do_IRQ [kernel] 0xfe (0x80367f54))
[<8010d018>] call_do_IRQ [kernel] 0x5 (0x80367f6c))
[<801a38a3>] pr_power_idle [kernel] 0x113 (0x80367f98))
[<80106e60>] default_idle [kernel] 0x0 (0x80367fc4))
[<80105000>] stext [kernel] 0x0 (0x80367fc8))
[<80106ef4>] cpu_idle [kernel] 0x24 (0x80367fcc))

Code: 8b 40 2c 83 f8 09 0f 4c c8 b8 01 00 00 00 d3 e0 39 c2 7d 16 

It's caused, from what I can tell, by task->tk_client being NULL in 
xprt_timer() at the time it is dereferenced. Looks like a race condition, 
probably facilitated by the SMP kernel.

The machine is a dual Athlon MP2100, and it was doing lots of NFS client 
activity at the time it crashed. It's got 1GB of RAM, but I don't think 
that's relevant.

The kernel is SMP and is compiled with a 2GB/2GB kernel/user address space
split, hence the kernel addresses starting with 8. Highmem support is 
turned off.

If you (or anyone else) have any idea about how to fix this, I'd be really 
grateful..

Thanks,
Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.



-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
