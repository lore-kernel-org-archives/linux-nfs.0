Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp4-g21.free.fr ([212.27.42.4]:26159 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752554AbcGLLs6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jul 2016 07:48:58 -0400
Subject: Re: WARNING: CPU: 0 PID: 0 at net/ipv4/af_inet.c:155
 inet_sock_destruct+0x1c4/0x1dc
To: Florian Fainelli <f.fainelli@gmail.com>, netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>,
        Sebastian Frias <sf84@laposte.net>
References: <577BB72E.3020904@free.fr> <577BC94A.4060204@free.fr>
 <577BD201.2040202@gmail.com> <5784BE36.8060200@free.fr>
From: Mason <slash.tmp@free.fr>
Message-ID: <5784D918.30904@free.fr>
Date: Tue, 12 Jul 2016 13:48:40 +0200
MIME-Version: 1.0
In-Reply-To: <5784BE36.8060200@free.fr>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/07/2016 11:53, Mason wrote:

> However, the 310 seconds time span still seems to be relevant.
> 
> Steps to reproduce: I booted the system, logged in as root,
> mounted an NFS file system, then left the system idling at
> the prompt.
> 
> (I don't remember seeing this warning in v4.1 and v4.4)
> 
> What's going wrong here? Is it related to NFS?
> 
> Here is the defconfig I'm using
> http://pastebin.ubuntu.com/19160299/
> 
> 
> [  317.940133] ------------[ cut here ]------------
> [  317.944815] WARNING: CPU: 1 PID: 0 at net/ipv4/af_inet.c:155 inet_sock_destruct+0x1c4/0x1dc
> [  317.953223] Modules linked in:
> [  317.956305] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.7.0-rc6-00010-gd07031bdc433-dirty #2
> [  317.964784] Hardware name: Sigma Tango DT
> [  317.968809] Backtrace: 
> [  317.971279] [<c010b974>] (dump_backtrace) from [<c010bb70>] (show_stack+0x18/0x1c)
> [  317.978884]  r7:60000113 r6:c080ea84 r5:00000000 r4:c080ea84
> [  317.984590] [<c010bb58>] (show_stack) from [<c02e9fc4>] (dump_stack+0x80/0x94)
> [  317.991856] [<c02e9f44>] (dump_stack) from [<c011bfb0>] (__warn+0xec/0x104)
> [  317.998849]  r7:00000009 r6:c05e3fc8 r5:00000000 r4:00000000
> [  318.004549] [<c011bec4>] (__warn) from [<c011c080>] (warn_slowpath_null+0x28/0x30)
> [  318.012154]  r9:dfbea4e0 r8:0000000a r7:df45fe30 r6:dec19594 r5:df68f144 r4:df68f040
> [  318.019954] [<c011c058>] (warn_slowpath_null) from [<c0463be4>] (inet_sock_destruct+0x1c4/0x1dc)
> [  318.028788] [<c0463a20>] (inet_sock_destruct) from [<c03e9c40>] (__sk_destruct+0x28/0xe0)
> [  318.037005]  r7:df45fe30 r6:dec19594 r5:df68f040 r4:df68f1ec
> [  318.042710] [<c03e9c18>] (__sk_destruct) from [<c016f218>] (rcu_process_callbacks+0x488/0x59c)
> [  318.051363]  r5:00000000 r4:00000000
> [  318.054962] [<c016ed90>] (rcu_process_callbacks) from [<c01207cc>] (__do_softirq+0x138/0x264)
> [  318.063527]  r10:c08020a0 r9:40000001 r8:00000101 r7:df45e000 r6:c08020a4 r5:00000009
> [  318.071408]  r4:00000000
> [  318.073953] [<c0120694>] (__do_softirq) from [<c0120bec>] (irq_exit+0xc8/0x104)
> [  318.081296]  r10:df45ff58 r9:df402400 r8:00000001 r7:00000000 r6:00000013 r5:00000000
> [  318.089176]  r4:c0735428
> [  318.091723] [<c0120b24>] (irq_exit) from [<c01625f8>] (__handle_domain_irq+0x88/0xf4)
> [  318.099595] [<c0162570>] (__handle_domain_irq) from [<c01014ac>] (gic_handle_irq+0x50/0x94)
> [  318.107986]  r10:00000000 r9:e0803100 r8:e0802100 r7:df45ff58 r6:e080210c r5:c080277c
> [  318.115865]  r4:c080eca0 r3:df45ff58
> [  318.119461] [<c010145c>] (gic_handle_irq) from [<c010c694>] (__irq_svc+0x54/0x90)
> [  318.126980] Exception stack(0xdf45ff58 to 0xdf45ffa0)
> [  318.132053] ff40:                                                       00000001 00000000
> [  318.140273] ff60: 0000ab80 c0117c80 df45e000 c08024f8 c0802494 c081e2d6 c05b9550 413fc090
> [  318.148492] ff80: 00000000 df45ffb4 df45ffb8 df45ffa8 c01086b0 c01086b4 60000013 ffffffff
> [  318.156709]  r9:413fc090 r8:c05b9550 r7:df45ff8c r6:ffffffff r5:60000013 r4:c01086b4
> [  318.164512] [<c0108674>] (arch_cpu_idle) from [<c0155f3c>] (default_idle_call+0x28/0x34)
> [  318.172646] [<c0155f14>] (default_idle_call) from [<c0156070>] (cpu_startup_entry+0x128/0x17c)
> [  318.181305] [<c0155f48>] (cpu_startup_entry) from [<c010dc14>] (secondary_start_kernel+0x158/0x164)
> [  318.190395]  r7:c081e7c8 r4:c080b4f0
> [  318.193993] [<c010dabc>] (secondary_start_kernel) from [<8010158c>] (0x8010158c)
> [  318.201423]  r5:00000051 r4:9f44006a
> [  318.205024] ---[ end trace 6e04001434b19cb9 ]---
> 
> 
> Just to be sure, I performed the same steps a second time:
> 
> [  316.238527] ------------[ cut here ]------------
> [  316.243210] WARNING: CPU: 1 PID: 0 at net/ipv4/af_inet.c:155 inet_sock_destruct+0x1c4/0x1dc
> [  316.251619] Modules linked in:
> [  316.254702] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 4.7.0-rc6-00010-gd07031bdc433-dirty #2
> [  316.263182] Hardware name: Sigma Tango DT
> [  316.267206] Backtrace: 
> [  316.269675] [<c010b974>] (dump_backtrace) from [<c010bb70>] (show_stack+0x18/0x1c)
> [  316.277280]  r7:60000113 r6:c080ea84 r5:00000000 r4:c080ea84
> [  316.282986] [<c010bb58>] (show_stack) from [<c02e9fc4>] (dump_stack+0x80/0x94)
> [  316.290254] [<c02e9f44>] (dump_stack) from [<c011bfb0>] (__warn+0xec/0x104)
> [  316.297247]  r7:00000009 r6:c05e3fc8 r5:00000000 r4:00000000
> [  316.302947] [<c011bec4>] (__warn) from [<c011c080>] (warn_slowpath_null+0x28/0x30)
> [  316.310552]  r9:dfbea4e0 r8:0000000a r7:df45fe30 r6:dec15694 r5:df6063c4 r4:df6062c0
> [  316.318354] [<c011c058>] (warn_slowpath_null) from [<c0463be4>] (inet_sock_destruct+0x1c4/0x1dc)
> [  316.327190] [<c0463a20>] (inet_sock_destruct) from [<c03e9c40>] (__sk_destruct+0x28/0xe0)
> [  316.335406]  r7:df45fe30 r6:dec15694 r5:df6062c0 r4:df60646c
> [  316.341112] [<c03e9c18>] (__sk_destruct) from [<c016f218>] (rcu_process_callbacks+0x488/0x59c)
> [  316.349765]  r5:00000000 r4:00000000
> [  316.353363] [<c016ed90>] (rcu_process_callbacks) from [<c01207cc>] (__do_softirq+0x138/0x264)
> [  316.361929]  r10:c08020a0 r9:40000001 r8:00000101 r7:df45e000 r6:c08020a4 r5:00000009
> [  316.369811]  r4:00000000
> [  316.372356] [<c0120694>] (__do_softirq) from [<c0120bec>] (irq_exit+0xc8/0x104)
> [  316.379699]  r10:df45ff58 r9:df402400 r8:00000001 r7:00000000 r6:00000013 r5:00000000
> [  316.387579]  r4:c0735428
> [  316.390127] [<c0120b24>] (irq_exit) from [<c01625f8>] (__handle_domain_irq+0x88/0xf4)
> [  316.397998] [<c0162570>] (__handle_domain_irq) from [<c01014ac>] (gic_handle_irq+0x50/0x94)
> [  316.406388]  r10:00000000 r9:e0803100 r8:e0802100 r7:df45ff58 r6:e080210c r5:c080277c
> [  316.414268]  r4:c080eca0 r3:df45ff58
> [  316.417862] [<c010145c>] (gic_handle_irq) from [<c010c694>] (__irq_svc+0x54/0x90)
> [  316.425382] Exception stack(0xdf45ff58 to 0xdf45ffa0)
> [  316.430456] ff40:                                                       00000001 00000000
> [  316.438676] ff60: 00009370 c0117c80 df45e000 c08024f8 c0802494 c081e2d6 c05b9550 413fc090
> [  316.446897] ff80: 00000000 df45ffb4 df45ffb8 df45ffa8 c01086b0 c01086b4 60000013 ffffffff
> [  316.455113]  r9:413fc090 r8:c05b9550 r7:df45ff8c r6:ffffffff r5:60000013 r4:c01086b4
> [  316.462916] [<c0108674>] (arch_cpu_idle) from [<c0155f3c>] (default_idle_call+0x28/0x34)
> [  316.471051] [<c0155f14>] (default_idle_call) from [<c0156070>] (cpu_startup_entry+0x128/0x17c)
> [  316.479709] [<c0155f48>] (cpu_startup_entry) from [<c010dc14>] (secondary_start_kernel+0x158/0x164)
> [  316.488799]  r7:c081e7c8 r4:c080b4f0
> [  316.492395] [<c010dabc>] (secondary_start_kernel) from [<8010158c>] (0x8010158c)
> [  316.499826]  r5:00000051 r4:9f44006a
> [  316.503430] ---[ end trace 2dd53d8e86a1a69b ]---

Adding linux-nfs in case it is NFS-related.
(I'm using an nfsroot file system, and the issue is triggered by
mounting an NFS file system.)

Similar warnings here:

http://thread.gmane.org/gmane.linux.kernel/2100812
WARNING: CPU: 1 PID: 81 at net/ipv4/af_inet.c:155 inet_sock_destruct+0x188/0x1dc()
(different call stack though)

https://www.spinics.net/lists/linux-nfs/msg58133.html
WARNING: CPU: 9 PID: 31049 at net/ipv4/af_inet.c:155 .inet_sock_destruct+0x170/0x220
(different call stack though)

http://thread.gmane.org/gmane.linux.network/134151
WARNING: at net/ipv4/af_inet.c:155 inet_sock_destruct+0x122/0x13a()
(different call stack though)

http://oops.kernel.org/oops/?function=inet_sock_destruct&bugline=155&search=submit

None of these seem to mention rcu_process_callbacks() in the call stack.

I can reproduce the warning systematically.
What can I do to pinpoint the root of the issue?

Regards.

