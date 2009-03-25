From: Marc Dionne <marc.c.dionne@gmail.com>
Subject: Re: NFS/AFS/Selinux issues with 2.26.29
Date: Wed, 25 Mar 2009 19:24:49 -0400
Message-ID: <49CABD41.1080702@gmail.com>
References: <49CAAB9B.5070104@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	openafs-devel-UX5vO7D78FVAfugRpC6u6w@public.gmane.org
To: Richard A Nelson <cowboy@linux.vnet.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:63028 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbZCYXYw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2009 19:24:52 -0400
In-reply-to: <49CAAB9B.5070104@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/25/2009 06:09 PM, Richard A Nelson wrote:
> -- AFS --
> Mar 24 14:33:54 bandit-hall kernel: BUG: unable to handle kernel NULL pointer dereference at 00000010
> Mar 24 14:33:54 bandit-hall kernel: IP: [<c021ba99>] selinux_key_alloc+0x26/0x3b
> Mar 24 14:33:54 bandit-hall kernel: *pde = 00000000
> Mar 24 14:33:54 bandit-hall kernel: Oops: 0000 [#1] PREEMPT SMP
> Mar 24 14:33:54 bandit-hall kernel: last sysfs file: /sys/class/power_supply/BAT0/energy_full
> Mar 24 14:33:54 bandit-hall kernel: Modules linked in: radeon drm binfmt_misc ppdev lp openafs(P) bnep rfcomm l2cap ipt_ULOG nsc_irc
> Mar 24 14:33:54 bandit-hall kernel: snd_seq_dummy snd_seq_oss snd_seq_midi snd_rawmidi irtty_sir snd_seq_midi_event ipw2100 thinkpad
> Mar 24 14:33:54 bandit-hall kernel:
> Mar 24 14:33:54 bandit-hall kernel: Pid: 20144, comm: ckpasswd Tainted: P           (2.6.29 #2) 2373MU3
> Mar 24 14:33:54 bandit-hall kernel: EIP: 0060:[<c021ba99>] EFLAGS: 00010286 CPU: 0
> Mar 24 14:33:54 bandit-hall kernel: EIP is at selinux_key_alloc+0x26/0x3b
> Mar 24 14:33:54 bandit-hall kernel: EAX: fffffff4 EBX: ce673170 ECX: dd6232a0 EDX: 00000000
> Mar 24 14:33:54 bandit-hall kernel: ESI: f66fb9c0 EDI: f66fba14 EBP: dd645d94 ESP: dd645d8c
> Mar 24 14:33:54 bandit-hall kernel: DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
> Mar 24 14:33:54 bandit-hall kernel: Process ckpasswd (pid: 20144, ti=dd644000 task=ce673170 task.ti=dd644000)
> Mar 24 14:33:54 bandit-hall kernel: Stack:
> Mar 24 14:33:54 bandit-hall kernel: c0495f78 d5cf63c0 dd645da0 c0217eff f66fb9c0 dd645dd4 c02130e6 00000009
> Mar 24 14:33:54 bandit-hall kernel: dd645df4 c0495898 0000000a 00000000 0000000b 0000001b 00004e20 ce673170
> Mar 24 14:33:54 bandit-hall kernel: 00000009 00000009 dd645e14 f887a658 00000009 ce673170 1f3f0000 00000000
> Mar 24 14:33:54 bandit-hall kernel: Call Trace:
> Mar 24 14:33:54 bandit-hall kernel: [<c0217eff>] ? security_key_alloc+0x10/0x13
> Mar 24 14:33:54 bandit-hall kernel: [<c02130e6>] ? key_alloc+0x185/0x2e6
> Mar 24 14:33:54 bandit-hall kernel: [<f887a658>] ? setpag+0xa1/0x17d [openafs]

The arguments to key_alloc() changed with 2.6.29, but this was fixed 
only recently in the OpenAFS source - it wasn't fixed in the original 
patches for 2.6.29.  I would guess that's the cause of the oops.

You might want to try current OpenAFS source or a 1.4.9 pre-release.

Marc
