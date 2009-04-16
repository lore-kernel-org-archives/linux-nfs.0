From: Alessio Igor Bogani <abogani-c2gU+FDvWfqonA0d6jMUrA@public.gmane.org>
Subject: Re: [tree] latest kill-the-BKL tree, v12
Date: Thu, 16 Apr 2009 16:35:58 +0200
Message-ID: <63a49ef40904160735w3eab9ea7s3fc5da177ee2ac87@mail.gmail.com>
References: <1239680065-25013-1-git-send-email-fweisbec@gmail.com>
	 <20090414045109.GA26908@orion> <20090414090146.GH27003@elte.hu>
	 <a4423d670904151558r4252c7eamd115793fb36a9163@mail.gmail.com>
	 <20090415230736.GA22710@elte.hu> <20090415233533.GA5962@nowhere>
	 <20090416085153.GC9813@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Frederic Weisbecker <fweisbec@gmail.com>,
	Alexander Beregalov <a.beregalov@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Jeff Mahoney <jeffm@suse.com>,
	ReiserFS Development List <reiserfs-devel@vger.kernel.org>,
	Chris Mason <chris.mason@oracle.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:42893 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579AbZDPOgD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Apr 2009 10:36:03 -0400
In-Reply-To: <20090416085153.GC9813@elte.hu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear Sir Molnar,

2009/4/16 Ingo Molnar <mingo@elte.hu>:
[...]
>> This is still the dependency between bkl and s_umount_key that has
>> been reported recently. I wonder if this is not a problem in the
>> fs layer. I should investigate on it.
>
> The problem seem to be that this NFS call context:
>
> -> #0 (kernel_mutex){+.+.+.}:
> =A0 =A0 =A0 [<00000000004776d0>] lock_acquire+0x5c/0x74
> =A0 =A0 =A0 [<00000000006f0ebc>] mutex_lock_nested+0x48/0x380
> =A0 =A0 =A0 [<00000000006f32dc>] lock_kernel+0x28/0x3c
> =A0 =A0 =A0 [<00000000006d20ec>] rpc_wait_bit_killable+0x64/0x8c
> =A0 =A0 =A0 [<00000000006f0620>] __wait_on_bit+0x64/0xc0
> =A0 =A0 =A0 [<00000000006f06e4>] out_of_line_wait_on_bit+0x68/0x7c
> =A0 =A0 =A0 [<00000000006d2938>] __rpc_execute+0x150/0x2b4
> =A0 =A0 =A0 [<00000000006d2ac0>] rpc_execute+0x24/0x34
> =A0 =A0 =A0 [<00000000006cc338>] rpc_run_task+0x64/0x74
> =A0 =A0 =A0 [<00000000006cc474>] rpc_call_sync+0x58/0x7c
> =A0 =A0 =A0 [<00000000005717b0>] nfs3_rpc_wrapper+0x24/0xa0
> =A0 =A0 =A0 [<0000000000572024>] do_proc_get_root+0x6c/0x10c
> =A0 =A0 =A0 [<00000000005720dc>] nfs3_proc_get_root+0x18/0x5c
> =A0 =A0 =A0 [<000000000056401c>] nfs_get_root+0x34/0x17c
> =A0 =A0 =A0 [<0000000000568adc>] nfs_get_sb+0x9ec/0xa7c
> =A0 =A0 =A0 [<00000000004b7ec8>] vfs_kern_mount+0x44/0xa4
> =A0 =A0 =A0 [<00000000004b7f84>] do_kern_mount+0x30/0xcc
> =A0 =A0 =A0 [<00000000004cf300>] do_mount+0x7c8/0x80c
> =A0 =A0 =A0 [<00000000004ed2a4>] compat_sys_mount+0x224/0x274
> =A0 =A0 =A0 [<0000000000406154>] linux_sparc_syscall32+0x34/0x40

Proposed patch that i just sent
(http://marc.info/?l=3Dlinux-kernel&m=3D123989213917572&w=3D2) seems fi=
x the
lock dependency.
I don't know if it is the right way to solve the problem in any case
but it works on my laptop, at least.

Ciao,
Alessio
