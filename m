From: Stuart Anderson <anderson@ligo.caltech.edu>
Subject: Re: kernel Oops in rpc.mountd
Date: Mon, 7 Feb 2005 20:47:10 -0800
Message-ID: <200502080447.j184lA2k012260@m27.ligo.caltech.edu>
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyNHO-0002Pf-Tn
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 20:47:14 -0800
Received: from acrux.ligo.caltech.edu ([131.215.115.14])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CyNHN-0006va-EE
	for nfs@lists.sourceforge.net; Mon, 07 Feb 2005 20:47:14 -0800
To: neilb@cse.unsw.edu.au
Sender: nfs-admin@lists.sourceforge.net
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

We are going to rebuild 2.6.10-1.760_FC3smp with 8k stack (just my
paranoia about the 4k stacks), and remove absolutely everything we do
not need, however, I will add in the CONFIG_DEBUG_SLAB. Are there any
other kernel debug flags that might be helpful?

Perhaps the bug is due to having a large list of static NFS mountes (290)?
I would desparately like to get rid of these but recent versions
of autofs have a problem running more than ~1 mount per second
due to using too many priveleged TCP ports per mount, and some
of our applications go through the 290 cross-mounts faster than that.
For that matter, recent versions of /bin/mount have the same problem
so we have to throttle the rate of mounts at boot time in /etc/rc.local.

I have also had 6 crashes with no console or syslog trace and 2 other
kernel Oops in the last few days that I suspect are related based on
the cluster usage patttern that might help understand the problem.
One did not get the syslog written to disk beyond,

Feb  6 07:53:45 node24 kernel: Unable to handle kernel paging request at virtual address 00001000
Feb  6 07:53:45 node24 kernel:  printing eip:
Feb  6 07:53:45 node24 kernel: c013f7e0
Feb  6 07:53:45 node24 kernel: *pde = 37281001

but the console had something like,

Process events/2 (pid: 12 ...)
...
Call Trace:
drain_array_locked
cache_reap
worker_thread
cache_reap
default_wake_function
default_wake_function
worker_thread
kthread
kthread
kernel_thread_helper

and another that logged the full Oops message,

Feb  7 18:06:27 node52 kernel: Unable to handle kernel paging request at virtual address 20202024
Feb  7 18:06:27 node52 kernel:  printing eip:
Feb  7 18:06:27 node52 kernel: f8a5179e
Feb  7 18:06:27 node52 kernel: *pde = 29455001
Feb  7 18:06:27 node52 kernel: Oops: 0000 [#1]
Feb  7 18:06:27 node52 kernel: SMP
Feb  7 18:06:27 node52 kernel: Modules linked in: nfsd exportfs md5 ipv6 nfs lockd sunrpc dm_mod video button battery ac uhci_hcd hw_random i2c_i801 i2c_core e1000 floppy ext3 jbd
Feb  7 18:06:27 node52 kernel: CPU:    0
Feb  7 18:06:27 node52 kernel: EIP:    0060:[<f8a5179e>]    Not tainted VLI
Feb  7 18:06:27 node52 kernel: EFLAGS: 00010202   (2.6.10-1.760_FC3smp)
Feb  7 18:06:27 node52 kernel: EIP is at cache_clean+0xe6/0x1b7 [sunrpc]
Feb  7 18:06:27 node52 kernel: eax: 20305550   ebx: 20202020   ecx: 000000a8   edx: f8a62fa0
Feb  7 18:06:27 node52 kernel: esi: f24cc000   edi: 00000000   ebp: f7f46000   esp: f7f1bf58
Feb  7 18:06:27 node52 kernel: ds: 007b   es: 007b   ss: 0068
Feb  7 18:06:27 node52 kernel: Process events/0 (pid: 10, threadinfo=f7f1b000 task=f7fefa60)
Feb  7 18:06:27 node52 kernel: Stack: 00000005 f8a63124 00000206 f8a5187a f8a63120 c012b2bf 00000000 f8a5186f
Feb  7 18:06:27 node52 kernel:        ffffffff ffffffff 00000001 00000000 c011a3de 00010000 00000000 c03f00a0
Feb  7 18:06:27 node52 kernel:        c201f060 00000000 00000000 f7fefa60 c011a3de 00100100 00200200 f7fefbcc
Feb  7 18:06:27 node52 kernel: Call Trace:
Feb  7 18:06:27 node52 kernel:  [<f8a5187a>] do_cache_clean+0xb/0x33 [sunrpc]
Feb  7 18:06:27 node52 kernel:  [<c012b2bf>] worker_thread+0x168/0x1d5
Feb  7 18:06:27 node52 kernel:  [<f8a5186f>] do_cache_clean+0x0/0x33 [sunrpc]
Feb  7 18:06:27 node52 kernel:  [<c011a3de>] default_wake_function+0x0/0xc
Feb  7 18:06:27 node52 kernel:  [<c011a3de>] default_wake_function+0x0/0xc
Feb  7 18:06:27 node52 kernel:  [<c012b157>] worker_thread+0x0/0x1d5
Feb  7 18:06:27 node52 kernel:  [<c012e569>] kthread+0x73/0x9b
Feb  7 18:06:27 node52 kernel:  [<c012e4f6>] kthread+0x0/0x9b
Feb  7 18:06:27 node52 kernel:  [<c01021f5>] kernel_thread_helper+0x5/0xb
Feb  7 18:06:27 node52 kernel: Code: f8 0f 8d e5 00 00 00 8d 42 08 e8 4d a5 86 c7 a1 00 4f a6 f8 8b 50 04 a1 04 4f a6 f8 8d 34 82 8b 1e 85 db 74 74 8b 15 00 4f a6 f8 <8b> 43 04 39 42 34 7e 04 40 89 42 34 8b 43 04 3b 05 10 1d 41 c0

According to Neil Brown:
> On Monday February 7, anderson@ligo.caltech.edu wrote:
> > I just had a physically different node Oops with an identical stack trace
> > in rpc.mountd:
>
> Well, that's pretty convincing!!!
>
> The code in question is walking down a hash chain looking for old
> entries to discard.  It finds an entry at 0x00100100.
> My guess is that some entry is being freed without being unlinked
> properly and the memory gets reused so that the ->next point becomes
> corrupt.
>
> If it is convenient, recompiling the kernel with
>   CONFIG_DEBUG_SLAB=y
>
> might help narrow down the problem, as the memory will be "poisoned"
> as soon as it is freed.
>
> I will also try to review the code and see if I can find a race that
> might get lost.
>
> NeilBrown
>


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
