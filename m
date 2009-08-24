From: Daniel J Blueman <daniel.blueman@gmail.com>
Subject: Re: [2.6.31-rc7] NFS4 client manager kthread spinning...
Date: Mon, 24 Aug 2009 16:18:28 +0100
Message-ID: <6278d2220908240818g3fc23311i607143b7cb6b965d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:52317 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689AbZHXPS2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Aug 2009 11:18:28 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

On Mon, Aug 17, 2009 at 2:53 PM, Daniel J
Blueman<daniel.blueman@gmail.com> wrote:
> Hi Trond,
>
> On Mon, Aug 17, 2009 at 2:12 PM, Trond
> Myklebust<Trond.Myklebust@netapp.com> wrote:
>> On Sun, 2009-08-16 at 23:40 +0100, Daniel J Blueman wrote:
>>> After losing and regaining ethernet link a few times with 2.6.31-rc5
>>> [1], I've hit an oops in the NFS4 client manager kthread [2] on my
>>> client with NFS4 homedir mount.
>>>
>>> Do you have a frequent test-case for when the client's manager kthread
>>> gets invoked (with and without succeeding callbacks, due to eg a
>>> firewall)? Server here is unpatched 2.6.30-rc6; I recall seeing
>>> problems when the manager kthread gets invoked, across quite a few
>>> kernel releases, just wasn't lucky enough to catch an oops.
>>>
>>> Oppsing in allow_signal() suggests task state corruption perhaps? I'm
>>> downloading the debug kernel to match up the disassembly and line
>>> numbers, if that helps? This time, the client had no firewall (but
>>> have seen other issues when the callback has failed due to the
>>> firewall).
>>
>> Those aren't Oopses. They are 'soft lockup' warnings. Basically, they're
>> saying that the CPU is getting stuck waiting for a spin lock or a mutex.
>>
>> In this case, it is probably the fact that the state manager is going
>> nuts trying to recover, while the connection to the server keeps coming
>> up and going down.
>>
>> What does 'netstat -t' say when you get into this situation?
>
> Whoops; it's true the stack-trace comes from the soft-lockup detector.
>
> There was a single 200s link excursion, but the client didn't recover
> as locks are held and never released it seems; I observe the
> '192.168.1.250-m' NFS4 manager kthread being created and not going
> away, despite IP connectivity with the server being fine after.
>
> I'll reproduce it with stock 2.6.31-rc6 on the client and get 'netstat
> -t' output.

(subject line updated)

After further analysis, I see that NFS services do correctly recover
after the link excursion, however we see:
 - link is restored
 - the manager kthread gets created, does some work
 - we see lock reclamation fail [1]
 - after a short while, NFS read()s continue, all is good
 - the manager kthread spins indefinitely [2, 3] on (struct
rpc_wait_queue)queue->lock with spin_lock_bh() [see rpc_wake_up]

This seems reproducible with various kernel debugging enabled (perhaps
suggesting use-after-free via the lock being reinitialised/poisoned?).

Let me know if anything else may help track this down (config, stack
frame resolution etc). I'll take a deeper look if I get time in a
couple of weeks, but alas it may be after 2.6.31 is released. NFS+RPC
debugging (taken at a different time than [1]) at
http://quora.org/hive/nfs-manager-spin.bz2 .

Thanks,
  Daniel

--- [1]

[ 1692.147184] e1000e: eth0 NIC Link is Down
[ 1894.417242] nfs: server x1 not responding, still trying
[ 1904.715032] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow
Control: RX/TX
[ 1957.423232] nfs: server x1 OK
[ 1957.481925] nfs4_reclaim_open_state: Lock reclaim failed!

--- [2]

$ ps -ef
<snip>
UID        PID  PPID  C STIME TTY          TIME CMD
root      5028     2 99 22:59 ?        00:00:09 [192.168.10.250-]

--- [3]

192.168.10.25 R  running task     4040  5107      2 0x00000000

ffffffff826c5470 00000000000002fb ffff88014b215d90 ffffffff810a2321

ffffffff8168f99e 0000000000024390 0000000100000001 ffff880100000000

0000000100000001 0000000000000001 0000000000000000 ffff8801451b54e8

Call Trace:

[<ffffffff810a2321>] __lock_acquire+0x2d1/0x1240

[<ffffffff8168f99e>] ? trace_hardirqs_on_thunk+0x3a/0x3f

[<ffffffff81693fa2>] ? sub_preempt_count+0x142/0x150

[<ffffffff810a33ae>] lock_acquire+0x11e/0x170

[<ffffffff8163f718>] ? rpc_wake_up+0x18/0xa0

[<ffffffff81693fa2>] ? sub_preempt_count+0x142/0x150

[<ffffffff8168fee6>] ? _spin_lock_bh+0x46/0x80

[<ffffffff8163f718>] ? rpc_wake_up+0x18/0xa0

[<ffffffff8124ff26>] ? nfs4_clear_state_manager_bit+0x36/0x40

[<ffffffff812515a8>] ? nfs4_run_state_manager+0x378/0x500

[<ffffffff81251230>] ? nfs4_run_state_manager+0x0/0x500

[<ffffffff81088946>] ? kthread+0xa6/0xc0

[<ffffffff8100d71a>] ? child_rip+0xa/0x20

[<ffffffff8100d054>] ? restore_args+0x0/0x30

[<ffffffff810888a0>] ? kthread+0x0/0xc0

[<ffffffff8100d710>] ? child_rip+0x0/0x20
-- 
Daniel J Blueman
