Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp10.mail.sp.isp-net.nl ([217.149.192.65]:34346 "EHLO
	smtp10.mail.sp.isp-net.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254Ab2FMSTU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Jun 2012 14:19:20 -0400
Message-ID: <4FD8D991.7060002@xmsnet.nl>
Date: Wed, 13 Jun 2012 20:18:57 +0200
From: Hans de Bruin <jmdebruin@xmsnet.nl>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: nfsroot client will not start firefox or thunderbird from 3.4.0
 nfsserver
References: <4FC3F9F6.7010107@xmsnet.nl> <20120610055208.05ea7ea7@tlielax.poochiereds.net> <4FD4A77B.2030506@xmsnet.nl> <20120611071142.44c33587@corrin.poochiereds.net>
In-Reply-To: <20120611071142.44c33587@corrin.poochiereds.net>
Content-Type: multipart/mixed;
 boundary="------------040909060607010102050609"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040909060607010102050609
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 06/11/2012 01:11 PM, Jeff Layton wrote:
> On Sun, 10 Jun 2012 15:56:11 +0200
> Hans de Bruin<jmdebruin@xmsnet.nl>  wrote:
>
>> On 06/10/2012 11:52 AM, Jeff Layton wrote:
>>> On Tue, 29 May 2012 00:19:34 +0200
>>> Hans de Bruin<jmdebruin@xmsnet.nl>   wrote:
>>>
>>>> I just upgraded my home server from kernel 3.3.5 to 3.4.0 and ran into
>>>> some trouble. My laptop, a nfsroot client, will not run firefox and
>>>> thunderbird anymore. When I start these programs from an xterm, the
>>>> cursor goes to the next line and waits indefinitely.
>>>>
>>>> I do not know if there is any order is lsof's output. A lsof | grep
>>>> firefox or thunderbird shows ......./.parentlock as the last line.
>>>>
>>>> It does not matter whether the client is running a 3.4.0 or a 3.3.0
>>>> kernel, or if the server is running on top of xen or not.
>>>>
>>>> There is some noise in the servers dmesg:
>>>>
>>>> [  241.256684] INFO: task kworker/u:2:801 blocked for more than 120 seconds.
>>>> [  241.256691] "echo 0>   /proc/sys/kernel/hung_task_timeout_secs"
>>>> disables this message.
>>>> [  241.256698] kworker/u:2     D 000000000000000c     0   801      2
>>>> 0x00000000
>>>> [  241.256710]  ffff8801390e5cf0 0000000000000046 0000000000012d00
>>>> 0000000000012d00
>>>> [  241.256721]  0000000000012d00 ffff880139f8bd50 0000000000012d00
>>>> ffff8801390e5fd8
>>>> [  241.256732]  ffff8801390e5fd8 0000000000012d00 ffff880139ce4420
>>>> ffff880139f8bd50
>>>> [  241.256743] Call Trace:
>>>> [  241.256759]  [<ffffffff8158733e>] schedule+0x64/0x66
>>>> [  241.256769]  [<ffffffff8120184e>] cld_pipe_upcall+0x95/0xd1
>>>> [  241.256780]  [<ffffffff811fbd8d>] ? nfsd4_exchange_id+0x23e/0x23e
>>>> [  241.256789]  [<ffffffff81201d06>] nfsd4_cld_grace_done+0x50/0x8a
>>>> [  241.256798]  [<ffffffff81202233>] nfsd4_record_grace_done+0x18/0x1a
>>>> [  241.256807]  [<ffffffff811fbdd7>] laundromat_main+0x4a/0x213
>>>> [  241.256818]  [<ffffffff8106a06b>] ? need_resched+0x1e/0x28
>>>> [  241.256826]  [<ffffffff8158725d>] ? __schedule+0x49d/0x4b5
>>>> [  241.256835]  [<ffffffff811fbd8d>] ? nfsd4_exchange_id+0x23e/0x23e
>>>> [  241.256844]  [<ffffffff8105be2d>] process_one_work+0x190/0x28d
>>>> [  241.256854]  [<ffffffff8105ca67>] worker_thread+0x105/0x189
>>>> [  241.256862]  [<ffffffff81587b8d>] ? _raw_spin_unlock_irqrestore+0x1a/0x1d
>>>> [  241.256872]  [<ffffffff8105c962>] ? manage_workers.clone.17+0x173/0x173
>>>> [  241.256881]  [<ffffffff810604b0>] kthread+0x8a/0x92
>>>> [  241.256891]  [<ffffffff815899a4>] kernel_thread_helper+0x4/0x10
>>>> [  241.256900]  [<ffffffff81060426>] ?
>>>> kthread_freezable_should_stop+0x47/0x47
>>>> [  241.256909]  [<ffffffff815899a0>] ? gs_change+0x13/0x13
>>>>
>>>> or xenified:
>>>>
>>>>
>>>> [  240.563448] "echo 0>   /proc/sys/kernel/hung_task_timeout_secs"
>>>> disables this message.
>>>> [  240.563458] kworker/u:2     D ffff88007fc12d00     0   808      2
>>>> 0x00000000
>>>> [  240.563479]  ffff88007532fcf0 0000000000000246 0000000000012d00
>>>> 0000000000012d00
>>>> [  240.563504]  0000000000012d00 ffff880075f7caf0 0000000000012d00
>>>> ffff88007532ffd8
>>>> [  240.563530]  ffff88007532ffd8 0000000000012d00 ffffffff81813020
>>>> ffff880075f7caf0
>>>> [  240.563555] Call Trace:
>>>> [  240.563578]  [<ffffffff8158733e>] schedule+0x64/0x66
>>>> [  240.563594]  [<ffffffff8120184e>] cld_pipe_upcall+0x95/0xd1
>>>> [  240.563611]  [<ffffffff811fbd8d>] ? nfsd4_exchange_id+0x23e/0x23e
>>>> [  240.563625]  [<ffffffff81201d06>] nfsd4_cld_grace_done+0x50/0x8a
>>>> [  240.563640]  [<ffffffff81202233>] nfsd4_record_grace_done+0x18/0x1a
>>>> [  240.563654]  [<ffffffff811fbdd7>] laundromat_main+0x4a/0x213
>>>> [  240.563670]  [<ffffffff8100d085>] ? xen_spin_unlock+0x12/0x30
>>>> [  240.563685]  [<ffffffff811fbd8d>] ? nfsd4_exchange_id+0x23e/0x23e
>>>> [  240.563700]  [<ffffffff8105be2d>] process_one_work+0x190/0x28d
>>>> [  240.563714]  [<ffffffff8100d337>] ? xen_spin_lock+0xb/0xd
>>>> [  240.563729]  [<ffffffff8105ca67>] worker_thread+0x105/0x189
>>>> [  240.563743]  [<ffffffff81587b8d>] ? _raw_spin_unlock_irqrestore+0x1a/0x1d
>>>> [  240.563758]  [<ffffffff8105c962>] ? manage_workers.clone.17+0x173/0x173
>>>> [  240.563772]  [<ffffffff810604b0>] kthread+0x8a/0x92
>>>> [  240.563787]  [<ffffffff815899a4>] kernel_thread_helper+0x4/0x10
>>>> [  240.563802]  [<ffffffff81587f38>] ? retint_restore_args+0x5/0x6
>>>> [  240.563816]  [<ffffffff815899a0>] ? gs_change+0x13/0x13
>>>>
>>>>
>>>
>>> It sounds like you're not running the new nfsdcld daemon on the server,
>>> and /var/lib/nfs/v4recovery does not exist. Is that correct?
>>>
>>
>> Yes that correct. When I create the /var/lib/nfs/v4recovery directory my
>> problems are gone.
>>
>> On the server and the client v3 and v4 are compiled into the kernel. Al
>> mounts are v3. Should I either remove v4 from the kernels or upgrade
>> nfs-utils-1.2.3 to something newer?
>>
>> (a search on the linux-nfs wiki for nfsdcld does not return any hits)
>>
>
> Here's what I see on my machine when I remove the v4recovery dir and
> don't run nfsdcld:
>
> [  109.715080] NFSD: starting 90-second grace period
> [  229.984220] NFSD: Unable to end grace period: -110
>
> ...and -110 is -ETIMEDOUT. So, what happens is that nfsd kicks off the
> laundromat job to run 90s after it starts. When it runs, it attempts to
> talk to nfsdcld because the v4recovery dir isn't present. That fails
> 30s later.
>
> Now, how that works is all rather convoluted. When we do the upcall, we
> put the message on a rpc_pipefs pipe queue, and then set a delayed
> workqueue job to walk that queue later and look for stuff that's been
> sitting there for more than 30s. Anything that has will get the status
> set to -ETIMEDOUT, and the task that submitted the upcall gets woken back up.
>
> It sounds like on your machine that the queue_timeout job isn't getting
> run for some reason. That would leave the upcalling tasks sitting in
> schedule for longer than 30s. Perhaps your workqueues are all blocking
> and the cmwq infrastructure isn't able to spawn new ones?
>
> You may want to look at /proc/<pid>/stack for all of the kworker tasks
> and see what they're doing...
>

Attached is the output of this script which ran at the server:

#!/bin/bash
cd /proc
while :
do
   echo >> /root/log
   date >> /root/log
   echo >> /root/log
   dmesg | tail -n 30 >> /root/log
   echo >> /root/log
   `ps ax|grep '[k]worker'| sed  's/ *\([0-9]*\) ?.*/tail \1\/stack/g'` 
 >> /root/log
   sleep 20
done


It dumps /proc/'pid'/stack for al the worker threads.

-- 
Hans




--------------040909060607010102050609
Content-Type: text/plain; charset=ISO-8859-1;
 name="log"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="log"


Wed Jun 13 20:06:47 CEST 2012

[    5.941152] [drm] Initialized i915 1.6.0 20080730 for 0000:00:02.0 on minor 0
[    5.948500] udev[960]: renamed network interface eth1 to eth0
[    5.984254] udev[977]: renamed network interface eth2-eth1 to eth1
[    7.802803] fuse init (API version 7.18)
[    8.046010] EXT4-fs (md2): re-mounted. Opts: (null)
[    8.132158] EXT4-fs (md2): re-mounted. Opts: (null)
[   12.267823] EXT4-fs (md0): mounted filesystem with ordered data mode. Opts: (null)
[   12.347957] EXT4-fs (dm-1): mounted filesystem with ordered data mode. Opts: (null)
[   13.690688] device eth0 entered promiscuous mode
[   13.705093] device eth1 entered promiscuous mode
[   13.773809] 8139too 0000:04:04.0: eth0: link up, 100Mbps, full-duplex, lpa 0xC5E1
[   13.787852] 8139too 0000:04:06.0: eth1: link down
[   13.790937] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   13.799946] br_lan0: port 1(eth0) entered forwarding state
[   13.799972] br_lan0: port 1(eth0) entered forwarding state
[   14.078393] r8169 0000:02:00.0: eth3: unable to load firmware patch rtl_nic/rtl8168d-1.fw (-2)
[   14.086690] r8169 0000:02:00.0: eth3: link down
[   14.086789] r8169 0000:02:00.0: eth3: link down
[   14.086861] NOHZ: local_softirq_pending 08
[   14.089426] ADDRCONF(NETDEV_UP): eth3: link is not ready
[   15.847332] r8169 0000:02:00.0: eth3: link up
[   15.849673] ADDRCONF(NETDEV_CHANGE): eth3: link becomes ready
[   16.307903] IPv6 over IPv4 tunneling driver
[   17.040382] ip_tables: (C) 2000-2006 Netfilter Core Team
[   17.121335] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   18.710352] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   22.164540] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   22.693375] svc: failed to register lockdv1 RPC service (errno 97).
[   22.693755] NFSD: starting 90-second grace period
[   29.194552] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 

==> 4/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 5/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 8/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 11/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 14/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 20/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 333/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 334/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 335/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 336/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 807/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 808/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 872/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1021/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1032/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1039/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1096/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

Wed Jun 13 20:07:07 CEST 2012

[    8.132158] EXT4-fs (md2): re-mounted. Opts: (null)
[   12.267823] EXT4-fs (md0): mounted filesystem with ordered data mode. Opts: (null)
[   12.347957] EXT4-fs (dm-1): mounted filesystem with ordered data mode. Opts: (null)
[   13.690688] device eth0 entered promiscuous mode
[   13.705093] device eth1 entered promiscuous mode
[   13.773809] 8139too 0000:04:04.0: eth0: link up, 100Mbps, full-duplex, lpa 0xC5E1
[   13.787852] 8139too 0000:04:06.0: eth1: link down
[   13.790937] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   13.799946] br_lan0: port 1(eth0) entered forwarding state
[   13.799972] br_lan0: port 1(eth0) entered forwarding state
[   14.078393] r8169 0000:02:00.0: eth3: unable to load firmware patch rtl_nic/rtl8168d-1.fw (-2)
[   14.086690] r8169 0000:02:00.0: eth3: link down
[   14.086789] r8169 0000:02:00.0: eth3: link down
[   14.086861] NOHZ: local_softirq_pending 08
[   14.089426] ADDRCONF(NETDEV_UP): eth3: link is not ready
[   15.847332] r8169 0000:02:00.0: eth3: link up
[   15.849673] ADDRCONF(NETDEV_CHANGE): eth3: link becomes ready
[   16.307903] IPv6 over IPv4 tunneling driver
[   17.040382] ip_tables: (C) 2000-2006 Netfilter Core Team
[   17.121335] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   18.710352] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   22.164540] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   22.693375] svc: failed to register lockdv1 RPC service (errno 97).
[   22.693755] NFSD: starting 90-second grace period
[   29.194552] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   45.173576] CHAINv6=INPUT IN=br_lan1 OUT= MAC=33:33:00:00:00:01:3a:c0:2c:2f:20:87:86:dd SRC=fe80:0000:0000:0000:38c0:2cff:fe2f:2087 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[   49.891837] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC1E1
[   49.894247] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[   49.894395] br_lan0: port 2(eth1) entered forwarding state
[   49.894456] br_lan0: port 2(eth1) entered forwarding state

==> 4/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 5/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 8/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 11/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 14/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 20/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 333/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 334/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 335/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 336/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 807/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 808/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 872/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1021/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1032/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1039/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1096/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

Wed Jun 13 20:07:27 CEST 2012

[    8.132158] EXT4-fs (md2): re-mounted. Opts: (null)
[   12.267823] EXT4-fs (md0): mounted filesystem with ordered data mode. Opts: (null)
[   12.347957] EXT4-fs (dm-1): mounted filesystem with ordered data mode. Opts: (null)
[   13.690688] device eth0 entered promiscuous mode
[   13.705093] device eth1 entered promiscuous mode
[   13.773809] 8139too 0000:04:04.0: eth0: link up, 100Mbps, full-duplex, lpa 0xC5E1
[   13.787852] 8139too 0000:04:06.0: eth1: link down
[   13.790937] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   13.799946] br_lan0: port 1(eth0) entered forwarding state
[   13.799972] br_lan0: port 1(eth0) entered forwarding state
[   14.078393] r8169 0000:02:00.0: eth3: unable to load firmware patch rtl_nic/rtl8168d-1.fw (-2)
[   14.086690] r8169 0000:02:00.0: eth3: link down
[   14.086789] r8169 0000:02:00.0: eth3: link down
[   14.086861] NOHZ: local_softirq_pending 08
[   14.089426] ADDRCONF(NETDEV_UP): eth3: link is not ready
[   15.847332] r8169 0000:02:00.0: eth3: link up
[   15.849673] ADDRCONF(NETDEV_CHANGE): eth3: link becomes ready
[   16.307903] IPv6 over IPv4 tunneling driver
[   17.040382] ip_tables: (C) 2000-2006 Netfilter Core Team
[   17.121335] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   18.710352] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   22.164540] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   22.693375] svc: failed to register lockdv1 RPC service (errno 97).
[   22.693755] NFSD: starting 90-second grace period
[   29.194552] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   45.173576] CHAINv6=INPUT IN=br_lan1 OUT= MAC=33:33:00:00:00:01:3a:c0:2c:2f:20:87:86:dd SRC=fe80:0000:0000:0000:38c0:2cff:fe2f:2087 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[   49.891837] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC1E1
[   49.894247] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[   49.894395] br_lan0: port 2(eth1) entered forwarding state
[   49.894456] br_lan0: port 2(eth1) entered forwarding state

==> 4/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 5/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 8/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 11/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 14/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 20/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 333/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 334/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 335/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 336/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 807/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 808/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 872/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1021/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1032/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1039/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1096/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

Wed Jun 13 20:07:47 CEST 2012

[   13.773809] 8139too 0000:04:04.0: eth0: link up, 100Mbps, full-duplex, lpa 0xC5E1
[   13.787852] 8139too 0000:04:06.0: eth1: link down
[   13.790937] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   13.799946] br_lan0: port 1(eth0) entered forwarding state
[   13.799972] br_lan0: port 1(eth0) entered forwarding state
[   14.078393] r8169 0000:02:00.0: eth3: unable to load firmware patch rtl_nic/rtl8168d-1.fw (-2)
[   14.086690] r8169 0000:02:00.0: eth3: link down
[   14.086789] r8169 0000:02:00.0: eth3: link down
[   14.086861] NOHZ: local_softirq_pending 08
[   14.089426] ADDRCONF(NETDEV_UP): eth3: link is not ready
[   15.847332] r8169 0000:02:00.0: eth3: link up
[   15.849673] ADDRCONF(NETDEV_CHANGE): eth3: link becomes ready
[   16.307903] IPv6 over IPv4 tunneling driver
[   17.040382] ip_tables: (C) 2000-2006 Netfilter Core Team
[   17.121335] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   18.710352] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   22.164540] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   22.693375] svc: failed to register lockdv1 RPC service (errno 97).
[   22.693755] NFSD: starting 90-second grace period
[   29.194552] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   45.173576] CHAINv6=INPUT IN=br_lan1 OUT= MAC=33:33:00:00:00:01:3a:c0:2c:2f:20:87:86:dd SRC=fe80:0000:0000:0000:38c0:2cff:fe2f:2087 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[   49.891837] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC1E1
[   49.894247] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[   49.894395] br_lan0: port 2(eth1) entered forwarding state
[   49.894456] br_lan0: port 2(eth1) entered forwarding state
[   77.314730] 8139too 0000:04:06.0: eth1: link down
[   77.317312] br_lan0: port 2(eth1) entered disabled state
[   78.936280] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC5E1
[   78.938700] br_lan0: port 2(eth1) entered forwarding state
[   78.938773] br_lan0: port 2(eth1) entered forwarding state

==> 4/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 5/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 8/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 11/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 14/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 20/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 333/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 334/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 335/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 336/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 807/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 808/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 872/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1021/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1032/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1039/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1096/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

Wed Jun 13 20:08:07 CEST 2012

[   13.773809] 8139too 0000:04:04.0: eth0: link up, 100Mbps, full-duplex, lpa 0xC5E1
[   13.787852] 8139too 0000:04:06.0: eth1: link down
[   13.790937] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   13.799946] br_lan0: port 1(eth0) entered forwarding state
[   13.799972] br_lan0: port 1(eth0) entered forwarding state
[   14.078393] r8169 0000:02:00.0: eth3: unable to load firmware patch rtl_nic/rtl8168d-1.fw (-2)
[   14.086690] r8169 0000:02:00.0: eth3: link down
[   14.086789] r8169 0000:02:00.0: eth3: link down
[   14.086861] NOHZ: local_softirq_pending 08
[   14.089426] ADDRCONF(NETDEV_UP): eth3: link is not ready
[   15.847332] r8169 0000:02:00.0: eth3: link up
[   15.849673] ADDRCONF(NETDEV_CHANGE): eth3: link becomes ready
[   16.307903] IPv6 over IPv4 tunneling driver
[   17.040382] ip_tables: (C) 2000-2006 Netfilter Core Team
[   17.121335] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   18.710352] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   22.164540] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   22.693375] svc: failed to register lockdv1 RPC service (errno 97).
[   22.693755] NFSD: starting 90-second grace period
[   29.194552] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   45.173576] CHAINv6=INPUT IN=br_lan1 OUT= MAC=33:33:00:00:00:01:3a:c0:2c:2f:20:87:86:dd SRC=fe80:0000:0000:0000:38c0:2cff:fe2f:2087 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[   49.891837] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC1E1
[   49.894247] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[   49.894395] br_lan0: port 2(eth1) entered forwarding state
[   49.894456] br_lan0: port 2(eth1) entered forwarding state
[   77.314730] 8139too 0000:04:06.0: eth1: link down
[   77.317312] br_lan0: port 2(eth1) entered disabled state
[   78.936280] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC5E1
[   78.938700] br_lan0: port 2(eth1) entered forwarding state
[   78.938773] br_lan0: port 2(eth1) entered forwarding state

==> 4/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 5/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 8/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 11/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 14/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 20/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 333/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 334/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 335/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 336/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 807/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 808/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 872/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1021/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1032/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1039/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1096/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

Wed Jun 13 20:08:27 CEST 2012

[   13.787852] 8139too 0000:04:06.0: eth1: link down
[   13.790937] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   13.799946] br_lan0: port 1(eth0) entered forwarding state
[   13.799972] br_lan0: port 1(eth0) entered forwarding state
[   14.078393] r8169 0000:02:00.0: eth3: unable to load firmware patch rtl_nic/rtl8168d-1.fw (-2)
[   14.086690] r8169 0000:02:00.0: eth3: link down
[   14.086789] r8169 0000:02:00.0: eth3: link down
[   14.086861] NOHZ: local_softirq_pending 08
[   14.089426] ADDRCONF(NETDEV_UP): eth3: link is not ready
[   15.847332] r8169 0000:02:00.0: eth3: link up
[   15.849673] ADDRCONF(NETDEV_CHANGE): eth3: link becomes ready
[   16.307903] IPv6 over IPv4 tunneling driver
[   17.040382] ip_tables: (C) 2000-2006 Netfilter Core Team
[   17.121335] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   18.710352] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   22.164540] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   22.693375] svc: failed to register lockdv1 RPC service (errno 97).
[   22.693755] NFSD: starting 90-second grace period
[   29.194552] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   45.173576] CHAINv6=INPUT IN=br_lan1 OUT= MAC=33:33:00:00:00:01:3a:c0:2c:2f:20:87:86:dd SRC=fe80:0000:0000:0000:38c0:2cff:fe2f:2087 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[   49.891837] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC1E1
[   49.894247] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[   49.894395] br_lan0: port 2(eth1) entered forwarding state
[   49.894456] br_lan0: port 2(eth1) entered forwarding state
[   77.314730] 8139too 0000:04:06.0: eth1: link down
[   77.317312] br_lan0: port 2(eth1) entered disabled state
[   78.936280] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC5E1
[   78.938700] br_lan0: port 2(eth1) entered forwarding state
[   78.938773] br_lan0: port 2(eth1) entered forwarding state
[  114.833612] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 

==> 4/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 5/stack <==
[<ffffffff8120062e>] cld_pipe_upcall+0x95/0xd1
[<ffffffff81200ae6>] nfsd4_cld_grace_done+0x50/0x8a
[<ffffffff81201013>] nfsd4_record_grace_done+0x18/0x1a
[<ffffffff811fabb7>] laundromat_main+0x4a/0x213
[<ffffffff8105b922>] process_one_work+0x190/0x28d
[<ffffffff8105c55c>] worker_thread+0x105/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 8/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 11/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 14/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 20/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 333/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 334/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 335/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 336/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 807/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 808/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 872/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1021/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1032/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1039/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1096/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

Wed Jun 13 20:08:47 CEST 2012

[   13.787852] 8139too 0000:04:06.0: eth1: link down
[   13.790937] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   13.799946] br_lan0: port 1(eth0) entered forwarding state
[   13.799972] br_lan0: port 1(eth0) entered forwarding state
[   14.078393] r8169 0000:02:00.0: eth3: unable to load firmware patch rtl_nic/rtl8168d-1.fw (-2)
[   14.086690] r8169 0000:02:00.0: eth3: link down
[   14.086789] r8169 0000:02:00.0: eth3: link down
[   14.086861] NOHZ: local_softirq_pending 08
[   14.089426] ADDRCONF(NETDEV_UP): eth3: link is not ready
[   15.847332] r8169 0000:02:00.0: eth3: link up
[   15.849673] ADDRCONF(NETDEV_CHANGE): eth3: link becomes ready
[   16.307903] IPv6 over IPv4 tunneling driver
[   17.040382] ip_tables: (C) 2000-2006 Netfilter Core Team
[   17.121335] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   18.710352] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   22.164540] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   22.693375] svc: failed to register lockdv1 RPC service (errno 97).
[   22.693755] NFSD: starting 90-second grace period
[   29.194552] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   45.173576] CHAINv6=INPUT IN=br_lan1 OUT= MAC=33:33:00:00:00:01:3a:c0:2c:2f:20:87:86:dd SRC=fe80:0000:0000:0000:38c0:2cff:fe2f:2087 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[   49.891837] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC1E1
[   49.894247] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[   49.894395] br_lan0: port 2(eth1) entered forwarding state
[   49.894456] br_lan0: port 2(eth1) entered forwarding state
[   77.314730] 8139too 0000:04:06.0: eth1: link down
[   77.317312] br_lan0: port 2(eth1) entered disabled state
[   78.936280] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC5E1
[   78.938700] br_lan0: port 2(eth1) entered forwarding state
[   78.938773] br_lan0: port 2(eth1) entered forwarding state
[  114.833612] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 

==> 4/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 5/stack <==
[<ffffffff8120062e>] cld_pipe_upcall+0x95/0xd1
[<ffffffff81200ae6>] nfsd4_cld_grace_done+0x50/0x8a
[<ffffffff81201013>] nfsd4_record_grace_done+0x18/0x1a
[<ffffffff811fabb7>] laundromat_main+0x4a/0x213
[<ffffffff8105b922>] process_one_work+0x190/0x28d
[<ffffffff8105c55c>] worker_thread+0x105/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 8/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 11/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 14/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 20/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 333/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 334/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 335/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 336/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 807/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 808/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 872/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1021/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1032/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1039/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1096/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

Wed Jun 13 20:09:08 CEST 2012

[   13.790937] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   13.799946] br_lan0: port 1(eth0) entered forwarding state
[   13.799972] br_lan0: port 1(eth0) entered forwarding state
[   14.078393] r8169 0000:02:00.0: eth3: unable to load firmware patch rtl_nic/rtl8168d-1.fw (-2)
[   14.086690] r8169 0000:02:00.0: eth3: link down
[   14.086789] r8169 0000:02:00.0: eth3: link down
[   14.086861] NOHZ: local_softirq_pending 08
[   14.089426] ADDRCONF(NETDEV_UP): eth3: link is not ready
[   15.847332] r8169 0000:02:00.0: eth3: link up
[   15.849673] ADDRCONF(NETDEV_CHANGE): eth3: link becomes ready
[   16.307903] IPv6 over IPv4 tunneling driver
[   17.040382] ip_tables: (C) 2000-2006 Netfilter Core Team
[   17.121335] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   18.710352] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   22.164540] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   22.693375] svc: failed to register lockdv1 RPC service (errno 97).
[   22.693755] NFSD: starting 90-second grace period
[   29.194552] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   45.173576] CHAINv6=INPUT IN=br_lan1 OUT= MAC=33:33:00:00:00:01:3a:c0:2c:2f:20:87:86:dd SRC=fe80:0000:0000:0000:38c0:2cff:fe2f:2087 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[   49.891837] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC1E1
[   49.894247] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[   49.894395] br_lan0: port 2(eth1) entered forwarding state
[   49.894456] br_lan0: port 2(eth1) entered forwarding state
[   77.314730] 8139too 0000:04:06.0: eth1: link down
[   77.317312] br_lan0: port 2(eth1) entered disabled state
[   78.936280] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC5E1
[   78.938700] br_lan0: port 2(eth1) entered forwarding state
[   78.938773] br_lan0: port 2(eth1) entered forwarding state
[  114.833612] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[  170.293605] CHAINv6=INPUT IN=br_lan1 OUT= MAC=33:33:00:00:00:01:3a:c0:2c:2f:20:87:86:dd SRC=fe80:0000:0000:0000:38c0:2cff:fe2f:2087 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 

==> 4/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 5/stack <==
[<ffffffff8120062e>] cld_pipe_upcall+0x95/0xd1
[<ffffffff81200ae6>] nfsd4_cld_grace_done+0x50/0x8a
[<ffffffff81201013>] nfsd4_record_grace_done+0x18/0x1a
[<ffffffff811fabb7>] laundromat_main+0x4a/0x213
[<ffffffff8105b922>] process_one_work+0x190/0x28d
[<ffffffff8105c55c>] worker_thread+0x105/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 8/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 11/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 14/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 20/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 333/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 334/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 335/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 336/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 807/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 808/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 872/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1021/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1032/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1039/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1096/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

Wed Jun 13 20:09:28 CEST 2012

[   13.790937] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   13.799946] br_lan0: port 1(eth0) entered forwarding state
[   13.799972] br_lan0: port 1(eth0) entered forwarding state
[   14.078393] r8169 0000:02:00.0: eth3: unable to load firmware patch rtl_nic/rtl8168d-1.fw (-2)
[   14.086690] r8169 0000:02:00.0: eth3: link down
[   14.086789] r8169 0000:02:00.0: eth3: link down
[   14.086861] NOHZ: local_softirq_pending 08
[   14.089426] ADDRCONF(NETDEV_UP): eth3: link is not ready
[   15.847332] r8169 0000:02:00.0: eth3: link up
[   15.849673] ADDRCONF(NETDEV_CHANGE): eth3: link becomes ready
[   16.307903] IPv6 over IPv4 tunneling driver
[   17.040382] ip_tables: (C) 2000-2006 Netfilter Core Team
[   17.121335] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   18.710352] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   22.164540] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   22.693375] svc: failed to register lockdv1 RPC service (errno 97).
[   22.693755] NFSD: starting 90-second grace period
[   29.194552] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   45.173576] CHAINv6=INPUT IN=br_lan1 OUT= MAC=33:33:00:00:00:01:3a:c0:2c:2f:20:87:86:dd SRC=fe80:0000:0000:0000:38c0:2cff:fe2f:2087 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[   49.891837] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC1E1
[   49.894247] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[   49.894395] br_lan0: port 2(eth1) entered forwarding state
[   49.894456] br_lan0: port 2(eth1) entered forwarding state
[   77.314730] 8139too 0000:04:06.0: eth1: link down
[   77.317312] br_lan0: port 2(eth1) entered disabled state
[   78.936280] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC5E1
[   78.938700] br_lan0: port 2(eth1) entered forwarding state
[   78.938773] br_lan0: port 2(eth1) entered forwarding state
[  114.833612] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[  170.293605] CHAINv6=INPUT IN=br_lan1 OUT= MAC=33:33:00:00:00:01:3a:c0:2c:2f:20:87:86:dd SRC=fe80:0000:0000:0000:38c0:2cff:fe2f:2087 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 

==> 4/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 5/stack <==
[<ffffffff8120062e>] cld_pipe_upcall+0x95/0xd1
[<ffffffff81200ae6>] nfsd4_cld_grace_done+0x50/0x8a
[<ffffffff81201013>] nfsd4_record_grace_done+0x18/0x1a
[<ffffffff811fabb7>] laundromat_main+0x4a/0x213
[<ffffffff8105b922>] process_one_work+0x190/0x28d
[<ffffffff8105c55c>] worker_thread+0x105/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 8/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 11/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 14/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 20/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 333/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 334/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 335/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 336/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 807/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 808/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 872/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1021/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1032/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1039/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1096/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

Wed Jun 13 20:09:48 CEST 2012

[   13.790937] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   13.799946] br_lan0: port 1(eth0) entered forwarding state
[   13.799972] br_lan0: port 1(eth0) entered forwarding state
[   14.078393] r8169 0000:02:00.0: eth3: unable to load firmware patch rtl_nic/rtl8168d-1.fw (-2)
[   14.086690] r8169 0000:02:00.0: eth3: link down
[   14.086789] r8169 0000:02:00.0: eth3: link down
[   14.086861] NOHZ: local_softirq_pending 08
[   14.089426] ADDRCONF(NETDEV_UP): eth3: link is not ready
[   15.847332] r8169 0000:02:00.0: eth3: link up
[   15.849673] ADDRCONF(NETDEV_CHANGE): eth3: link becomes ready
[   16.307903] IPv6 over IPv4 tunneling driver
[   17.040382] ip_tables: (C) 2000-2006 Netfilter Core Team
[   17.121335] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   18.710352] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   22.164540] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   22.693375] svc: failed to register lockdv1 RPC service (errno 97).
[   22.693755] NFSD: starting 90-second grace period
[   29.194552] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   45.173576] CHAINv6=INPUT IN=br_lan1 OUT= MAC=33:33:00:00:00:01:3a:c0:2c:2f:20:87:86:dd SRC=fe80:0000:0000:0000:38c0:2cff:fe2f:2087 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[   49.891837] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC1E1
[   49.894247] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[   49.894395] br_lan0: port 2(eth1) entered forwarding state
[   49.894456] br_lan0: port 2(eth1) entered forwarding state
[   77.314730] 8139too 0000:04:06.0: eth1: link down
[   77.317312] br_lan0: port 2(eth1) entered disabled state
[   78.936280] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC5E1
[   78.938700] br_lan0: port 2(eth1) entered forwarding state
[   78.938773] br_lan0: port 2(eth1) entered forwarding state
[  114.833612] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[  170.293605] CHAINv6=INPUT IN=br_lan1 OUT= MAC=33:33:00:00:00:01:3a:c0:2c:2f:20:87:86:dd SRC=fe80:0000:0000:0000:38c0:2cff:fe2f:2087 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 

==> 4/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 5/stack <==
[<ffffffff8120062e>] cld_pipe_upcall+0x95/0xd1
[<ffffffff81200ae6>] nfsd4_cld_grace_done+0x50/0x8a
[<ffffffff81201013>] nfsd4_record_grace_done+0x18/0x1a
[<ffffffff811fabb7>] laundromat_main+0x4a/0x213
[<ffffffff8105b922>] process_one_work+0x190/0x28d
[<ffffffff8105c55c>] worker_thread+0x105/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 8/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 11/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 14/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 20/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 333/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 334/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 335/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 336/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 807/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 808/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 872/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1021/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1032/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1039/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1096/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

Wed Jun 13 20:10:08 CEST 2012

[   13.790937] ADDRCONF(NETDEV_UP): eth1: link is not ready
[   13.799946] br_lan0: port 1(eth0) entered forwarding state
[   13.799972] br_lan0: port 1(eth0) entered forwarding state
[   14.078393] r8169 0000:02:00.0: eth3: unable to load firmware patch rtl_nic/rtl8168d-1.fw (-2)
[   14.086690] r8169 0000:02:00.0: eth3: link down
[   14.086789] r8169 0000:02:00.0: eth3: link down
[   14.086861] NOHZ: local_softirq_pending 08
[   14.089426] ADDRCONF(NETDEV_UP): eth3: link is not ready
[   15.847332] r8169 0000:02:00.0: eth3: link up
[   15.849673] ADDRCONF(NETDEV_CHANGE): eth3: link becomes ready
[   16.307903] IPv6 over IPv4 tunneling driver
[   17.040382] ip_tables: (C) 2000-2006 Netfilter Core Team
[   17.121335] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
[   18.710352] ip6_tables: (C) 2000-2006 Netfilter Core Team
[   22.164540] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   22.693375] svc: failed to register lockdv1 RPC service (errno 97).
[   22.693755] NFSD: starting 90-second grace period
[   29.194552] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=96 TC=0 HOPLIMIT=255 FLOWLBL=0 PROTO=ICMPv6 TYPE=134 CODE=0 
[   45.173576] CHAINv6=INPUT IN=br_lan1 OUT= MAC=33:33:00:00:00:01:3a:c0:2c:2f:20:87:86:dd SRC=fe80:0000:0000:0000:38c0:2cff:fe2f:2087 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[   49.891837] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC1E1
[   49.894247] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
[   49.894395] br_lan0: port 2(eth1) entered forwarding state
[   49.894456] br_lan0: port 2(eth1) entered forwarding state
[   77.314730] 8139too 0000:04:06.0: eth1: link down
[   77.317312] br_lan0: port 2(eth1) entered disabled state
[   78.936280] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC5E1
[   78.938700] br_lan0: port 2(eth1) entered forwarding state
[   78.938773] br_lan0: port 2(eth1) entered forwarding state
[  114.833612] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[  170.293605] CHAINv6=INPUT IN=br_lan1 OUT= MAC=33:33:00:00:00:01:3a:c0:2c:2f:20:87:86:dd SRC=fe80:0000:0000:0000:38c0:2cff:fe2f:2087 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 

==> 4/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 5/stack <==
[<ffffffff8120062e>] cld_pipe_upcall+0x95/0xd1
[<ffffffff81200ae6>] nfsd4_cld_grace_done+0x50/0x8a
[<ffffffff81201013>] nfsd4_record_grace_done+0x18/0x1a
[<ffffffff811fabb7>] laundromat_main+0x4a/0x213
[<ffffffff8105b922>] process_one_work+0x190/0x28d
[<ffffffff8105c55c>] worker_thread+0x105/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 8/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 11/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 14/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 20/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 333/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 334/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 335/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 336/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 807/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 808/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 872/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1021/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1032/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1039/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1096/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

Wed Jun 13 20:10:28 CEST 2012

[   78.936280] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC5E1
[   78.938700] br_lan0: port 2(eth1) entered forwarding state
[   78.938773] br_lan0: port 2(eth1) entered forwarding state
[  114.833612] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[  170.293605] CHAINv6=INPUT IN=br_lan1 OUT= MAC=33:33:00:00:00:01:3a:c0:2c:2f:20:87:86:dd SRC=fe80:0000:0000:0000:38c0:2cff:fe2f:2087 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[  240.276052] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[  240.580124] INFO: task kworker/u:0:5 blocked for more than 120 seconds.
[  240.580136] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  240.580145] kworker/u:0     D ffff88005fd12d00     0     5      2 0x00000000
[  240.580165]  ffff880055d09cf0 0000000000000246 0000000000012d00 0000000000012d00
[  240.580191]  0000000000012d00 ffff880055ce2fb0 0000000000012d00 ffff880055d09fd8
[  240.580216]  ffff880055d09fd8 0000000000012d00 ffff880055ce1470 ffff880055ce2fb0
[  240.580241] Call Trace:
[  240.580262]  [<ffffffff815132ee>] schedule+0x64/0x66
[  240.580278]  [<ffffffff8120062e>] cld_pipe_upcall+0x95/0xd1
[  240.580294]  [<ffffffff811fab6d>] ? nfsd4_exchange_id+0x23e/0x23e
[  240.580308]  [<ffffffff81200ae6>] nfsd4_cld_grace_done+0x50/0x8a
[  240.580322]  [<ffffffff81201013>] nfsd4_record_grace_done+0x18/0x1a
[  240.580336]  [<ffffffff811fabb7>] laundromat_main+0x4a/0x213
[  240.580351]  [<ffffffff8100d085>] ? xen_spin_unlock+0x12/0x30
[  240.580366]  [<ffffffff811fab6d>] ? nfsd4_exchange_id+0x23e/0x23e
[  240.580381]  [<ffffffff8105b922>] process_one_work+0x190/0x28d
[  240.580395]  [<ffffffff8100d337>] ? xen_spin_lock+0xb/0xd
[  240.580409]  [<ffffffff8105c55c>] worker_thread+0x105/0x189
[  240.580423]  [<ffffffff81513c4d>] ? _raw_spin_unlock_irqrestore+0x1a/0x1d
[  240.580438]  [<ffffffff8105c457>] ? manage_workers.clone.17+0x173/0x173
[  240.580452]  [<ffffffff8105ffa8>] kthread+0x8a/0x92
[  240.580466]  [<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[  240.580480]  [<ffffffff81513ff8>] ? retint_restore_args+0x5/0x6
[  240.580494]  [<ffffffff81515a60>] ? gs_change+0x13/0x13

==> 4/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 5/stack <==
[<ffffffff8120062e>] cld_pipe_upcall+0x95/0xd1
[<ffffffff81200ae6>] nfsd4_cld_grace_done+0x50/0x8a
[<ffffffff81201013>] nfsd4_record_grace_done+0x18/0x1a
[<ffffffff811fabb7>] laundromat_main+0x4a/0x213
[<ffffffff8105b922>] process_one_work+0x190/0x28d
[<ffffffff8105c55c>] worker_thread+0x105/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 8/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 11/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 14/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 20/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 333/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 334/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 335/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 336/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 807/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 808/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 872/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1021/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1032/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1039/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1096/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

Wed Jun 13 20:10:48 CEST 2012

[   78.936280] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC5E1
[   78.938700] br_lan0: port 2(eth1) entered forwarding state
[   78.938773] br_lan0: port 2(eth1) entered forwarding state
[  114.833612] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[  170.293605] CHAINv6=INPUT IN=br_lan1 OUT= MAC=33:33:00:00:00:01:3a:c0:2c:2f:20:87:86:dd SRC=fe80:0000:0000:0000:38c0:2cff:fe2f:2087 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[  240.276052] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[  240.580124] INFO: task kworker/u:0:5 blocked for more than 120 seconds.
[  240.580136] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  240.580145] kworker/u:0     D ffff88005fd12d00     0     5      2 0x00000000
[  240.580165]  ffff880055d09cf0 0000000000000246 0000000000012d00 0000000000012d00
[  240.580191]  0000000000012d00 ffff880055ce2fb0 0000000000012d00 ffff880055d09fd8
[  240.580216]  ffff880055d09fd8 0000000000012d00 ffff880055ce1470 ffff880055ce2fb0
[  240.580241] Call Trace:
[  240.580262]  [<ffffffff815132ee>] schedule+0x64/0x66
[  240.580278]  [<ffffffff8120062e>] cld_pipe_upcall+0x95/0xd1
[  240.580294]  [<ffffffff811fab6d>] ? nfsd4_exchange_id+0x23e/0x23e
[  240.580308]  [<ffffffff81200ae6>] nfsd4_cld_grace_done+0x50/0x8a
[  240.580322]  [<ffffffff81201013>] nfsd4_record_grace_done+0x18/0x1a
[  240.580336]  [<ffffffff811fabb7>] laundromat_main+0x4a/0x213
[  240.580351]  [<ffffffff8100d085>] ? xen_spin_unlock+0x12/0x30
[  240.580366]  [<ffffffff811fab6d>] ? nfsd4_exchange_id+0x23e/0x23e
[  240.580381]  [<ffffffff8105b922>] process_one_work+0x190/0x28d
[  240.580395]  [<ffffffff8100d337>] ? xen_spin_lock+0xb/0xd
[  240.580409]  [<ffffffff8105c55c>] worker_thread+0x105/0x189
[  240.580423]  [<ffffffff81513c4d>] ? _raw_spin_unlock_irqrestore+0x1a/0x1d
[  240.580438]  [<ffffffff8105c457>] ? manage_workers.clone.17+0x173/0x173
[  240.580452]  [<ffffffff8105ffa8>] kthread+0x8a/0x92
[  240.580466]  [<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[  240.580480]  [<ffffffff81513ff8>] ? retint_restore_args+0x5/0x6
[  240.580494]  [<ffffffff81515a60>] ? gs_change+0x13/0x13

==> 4/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 5/stack <==
[<ffffffff8120062e>] cld_pipe_upcall+0x95/0xd1
[<ffffffff81200ae6>] nfsd4_cld_grace_done+0x50/0x8a
[<ffffffff81201013>] nfsd4_record_grace_done+0x18/0x1a
[<ffffffff811fabb7>] laundromat_main+0x4a/0x213
[<ffffffff8105b922>] process_one_work+0x190/0x28d
[<ffffffff8105c55c>] worker_thread+0x105/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 8/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 11/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 14/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 20/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 333/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 334/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 335/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 336/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 807/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 808/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 872/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1021/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1032/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1039/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1096/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

Wed Jun 13 20:11:08 CEST 2012

[   78.936280] 8139too 0000:04:06.0: eth1: link up, 100Mbps, full-duplex, lpa 0xC5E1
[   78.938700] br_lan0: port 2(eth1) entered forwarding state
[   78.938773] br_lan0: port 2(eth1) entered forwarding state
[  114.833612] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[  170.293605] CHAINv6=INPUT IN=br_lan1 OUT= MAC=33:33:00:00:00:01:3a:c0:2c:2f:20:87:86:dd SRC=fe80:0000:0000:0000:38c0:2cff:fe2f:2087 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[  240.276052] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[  240.580124] INFO: task kworker/u:0:5 blocked for more than 120 seconds.
[  240.580136] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  240.580145] kworker/u:0     D ffff88005fd12d00     0     5      2 0x00000000
[  240.580165]  ffff880055d09cf0 0000000000000246 0000000000012d00 0000000000012d00
[  240.580191]  0000000000012d00 ffff880055ce2fb0 0000000000012d00 ffff880055d09fd8
[  240.580216]  ffff880055d09fd8 0000000000012d00 ffff880055ce1470 ffff880055ce2fb0
[  240.580241] Call Trace:
[  240.580262]  [<ffffffff815132ee>] schedule+0x64/0x66
[  240.580278]  [<ffffffff8120062e>] cld_pipe_upcall+0x95/0xd1
[  240.580294]  [<ffffffff811fab6d>] ? nfsd4_exchange_id+0x23e/0x23e
[  240.580308]  [<ffffffff81200ae6>] nfsd4_cld_grace_done+0x50/0x8a
[  240.580322]  [<ffffffff81201013>] nfsd4_record_grace_done+0x18/0x1a
[  240.580336]  [<ffffffff811fabb7>] laundromat_main+0x4a/0x213
[  240.580351]  [<ffffffff8100d085>] ? xen_spin_unlock+0x12/0x30
[  240.580366]  [<ffffffff811fab6d>] ? nfsd4_exchange_id+0x23e/0x23e
[  240.580381]  [<ffffffff8105b922>] process_one_work+0x190/0x28d
[  240.580395]  [<ffffffff8100d337>] ? xen_spin_lock+0xb/0xd
[  240.580409]  [<ffffffff8105c55c>] worker_thread+0x105/0x189
[  240.580423]  [<ffffffff81513c4d>] ? _raw_spin_unlock_irqrestore+0x1a/0x1d
[  240.580438]  [<ffffffff8105c457>] ? manage_workers.clone.17+0x173/0x173
[  240.580452]  [<ffffffff8105ffa8>] kthread+0x8a/0x92
[  240.580466]  [<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[  240.580480]  [<ffffffff81513ff8>] ? retint_restore_args+0x5/0x6
[  240.580494]  [<ffffffff81515a60>] ? gs_change+0x13/0x13

==> 4/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 5/stack <==
[<ffffffff8120062e>] cld_pipe_upcall+0x95/0xd1
[<ffffffff81200ae6>] nfsd4_cld_grace_done+0x50/0x8a
[<ffffffff81201013>] nfsd4_record_grace_done+0x18/0x1a
[<ffffffff811fabb7>] laundromat_main+0x4a/0x213
[<ffffffff8105b922>] process_one_work+0x190/0x28d
[<ffffffff8105c55c>] worker_thread+0x105/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 8/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 11/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 14/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 20/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 333/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 334/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 335/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 336/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 807/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 808/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 872/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1021/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1032/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1039/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1096/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

Wed Jun 13 20:11:28 CEST 2012

[   78.938700] br_lan0: port 2(eth1) entered forwarding state
[   78.938773] br_lan0: port 2(eth1) entered forwarding state
[  114.833612] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[  170.293605] CHAINv6=INPUT IN=br_lan1 OUT= MAC=33:33:00:00:00:01:3a:c0:2c:2f:20:87:86:dd SRC=fe80:0000:0000:0000:38c0:2cff:fe2f:2087 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[  240.276052] CHAINv6=INPUT IN=eth3 OUT= MAC=33:33:00:00:00:01:00:30:18:ae:75:d8:86:dd SRC=fe80:0000:0000:0000:0230:18ff:feae:75d8 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 
[  240.580124] INFO: task kworker/u:0:5 blocked for more than 120 seconds.
[  240.580136] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[  240.580145] kworker/u:0     D ffff88005fd12d00     0     5      2 0x00000000
[  240.580165]  ffff880055d09cf0 0000000000000246 0000000000012d00 0000000000012d00
[  240.580191]  0000000000012d00 ffff880055ce2fb0 0000000000012d00 ffff880055d09fd8
[  240.580216]  ffff880055d09fd8 0000000000012d00 ffff880055ce1470 ffff880055ce2fb0
[  240.580241] Call Trace:
[  240.580262]  [<ffffffff815132ee>] schedule+0x64/0x66
[  240.580278]  [<ffffffff8120062e>] cld_pipe_upcall+0x95/0xd1
[  240.580294]  [<ffffffff811fab6d>] ? nfsd4_exchange_id+0x23e/0x23e
[  240.580308]  [<ffffffff81200ae6>] nfsd4_cld_grace_done+0x50/0x8a
[  240.580322]  [<ffffffff81201013>] nfsd4_record_grace_done+0x18/0x1a
[  240.580336]  [<ffffffff811fabb7>] laundromat_main+0x4a/0x213
[  240.580351]  [<ffffffff8100d085>] ? xen_spin_unlock+0x12/0x30
[  240.580366]  [<ffffffff811fab6d>] ? nfsd4_exchange_id+0x23e/0x23e
[  240.580381]  [<ffffffff8105b922>] process_one_work+0x190/0x28d
[  240.580395]  [<ffffffff8100d337>] ? xen_spin_lock+0xb/0xd
[  240.580409]  [<ffffffff8105c55c>] worker_thread+0x105/0x189
[  240.580423]  [<ffffffff81513c4d>] ? _raw_spin_unlock_irqrestore+0x1a/0x1d
[  240.580438]  [<ffffffff8105c457>] ? manage_workers.clone.17+0x173/0x173
[  240.580452]  [<ffffffff8105ffa8>] kthread+0x8a/0x92
[  240.580466]  [<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[  240.580480]  [<ffffffff81513ff8>] ? retint_restore_args+0x5/0x6
[  240.580494]  [<ffffffff81515a60>] ? gs_change+0x13/0x13
[  295.733561] CHAINv6=INPUT IN=br_lan1 OUT= MAC=33:33:00:00:00:01:3a:c0:2c:2f:20:87:86:dd SRC=fe80:0000:0000:0000:38c0:2cff:fe2f:2087 DST=ff02:0000:0000:0000:0000:0000:0000:0001 LEN=72 TC=0 HOPLIMIT=1 FLOWLBL=0 PROTO=ICMPv6 TYPE=130 CODE=0 

==> 4/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 5/stack <==
[<ffffffff8120062e>] cld_pipe_upcall+0x95/0xd1
[<ffffffff81200ae6>] nfsd4_cld_grace_done+0x50/0x8a
[<ffffffff81201013>] nfsd4_record_grace_done+0x18/0x1a
[<ffffffff811fabb7>] laundromat_main+0x4a/0x213
[<ffffffff8105b922>] process_one_work+0x190/0x28d
[<ffffffff8105c55c>] worker_thread+0x105/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 14/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 20/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 334/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 336/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 807/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1021/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1032/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1039/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

==> 1096/stack <==
[<ffffffff8105c5db>] worker_thread+0x184/0x189
[<ffffffff8105ffa8>] kthread+0x8a/0x92
[<ffffffff81515a64>] kernel_thread_helper+0x4/0x10
[<ffffffffffffffff>] 0xffffffffffffffff

--------------040909060607010102050609--
