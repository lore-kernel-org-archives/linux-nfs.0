From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lookup_one_len() returning d_count == 0
Date: Sat, 28 Mar 2009 13:31:32 -0400
Message-ID: <1238261492.6679.9.camel@heimdal.trondhjem.org>
References: <49CE2C59.7040102@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:39556 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753738AbZC1Rbi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Mar 2009 13:31:38 -0400
In-Reply-To: <49CE2C59.7040102-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-03-28 at 09:55 -0400, Steve Dickson wrote:
> In some recent work I'm doing, I am seeing something very 
> strange when using an OpenSolaris client which does a
> NFS v4 mount. Here is the scenario
> 
> On the server, the exports look like:
> 
> /fs1          	<world>(rw,wdelay,root_squash,no_subtree_check)
> /fs1/fs2/fs3/fs4/fs5
> 		<world>(rw,wdelay,nohide,root_squash,no_subtree_check)
> 
> With all the fs? directories being a file system which in turn makes them a 
> mount point.
> 
> The client is doing:
> 
> mount server:/fs1 /mnt/tmp
> ls /mnt/tmp/fs2/fs3 
>   Which does only returns the fs4 dir as it should.
> 
> Now when the client does:
>   ls /mnt/tmp/fs2/fs3/fs4
> 
> On the server:
> 
> nfsd_lookup_dentry() calls lookup_one_len() like it always does
> but this time the dentry that's return (for fs4) has a d_count == 0
> which cause the first dget() to blow up...
> 
> Anybody have any ideas as to why lookup_one_len() would be
> returning a (supposedly valid) dentry with a d_count == 0?
> Is giving out dentrys with a d_count == 0 a valid thing to do?

My guess is that the dentry is being dput() twice somewhere, and so ends
up with a d_count==-1. I'd suggest adding a
BUG_ON(atomic_read(&dentry->d_count) <= 0) after the 'repeat:' label at
the top of dput() in order to try to catch the culprit.

Cheers
  Trond

> steved.
> 
> P.S. here is what the oops looks like:
> 
> kernel BUG at include/linux/dcache.h:334!
> invalid opcode: 0000 [#1] SMP 
> last sysfs file: /sys/module/nfsd/initstate
> Modules linked in: nfsd lockd nfs_acl auth_rpcgss exportfs bridge stp llc bnep sco l2cap bluetooth autofs4 sunrpc ipv6 p4_clockmod uinput ppdev snd_intel8x0 snd_ac97_codec ac97_bus snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore pcspkr snd_page_alloc i2c_i801 firewire_ohci firewire_core iTCO_wdt iTCO_vendor_support crc_itu_t intel_rng e1000 parport_pc parport ata_generic pata_acpi radeon drm i2c_algo_bit i2c_core [last unloaded: nfsd]
> 
> Pid: 3554, comm: nfsd Tainted: G        W  (2.6.29-15.fc10.i686.PAE #1)         
> EIP: 0060:[<f9336917>] EFLAGS: 00010246 CPU: 1
> EIP is at nfsd_lookup_dentry+0x259/0x344 [nfsd]
> EAX: 00000000 EBX: f6cbaea0 ECX: f6cbaea0 EDX: f2892800
> ESI: 00010000 EDI: f290f08c EBP: f1095e1c ESP: f1095df4
>  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> Process nfsd (pid: 3554, ti=f1094000 task=f154d500 task.ti=f1094000)
> Stack:
>  f1126120 00014405 00000000 f2892800 00000046 f6cbaea0 f15f73c0 f1095f30
>  f10f65a8 f1095f2c f1095f40 f933de34 00000003 f1095f30 f1095f2c f1126120
>  00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> Call Trace:
>  [<f933de34>] ? nfsd4_secinfo+0x49/0xa0 [nfsd]
>  [<f933efc2>] ? nfsd4_encode_operation+0x57/0x69 [nfsd]
>  [<f933e07c>] ? nfsd4_proc_compound+0x19c/0x2bc [nfsd]
>  [<f933ddeb>] ? nfsd4_secinfo+0x0/0xa0 [nfsd]
>  [<f9331227>] ? nfsd_dispatch+0xd4/0x1a7 [nfsd]
>  [<f8eca07a>] ? svc_process+0x37e/0x58c [sunrpc]
>  [<f933177c>] ? nfsd+0x11e/0x170 [nfsd]
>  [<f933165e>] ? nfsd+0x0/0x170 [nfsd]
>  [<c044bbac>] ? kthread+0x40/0x66
>  [<c044bb6c>] ? kthread+0x0/0x66
>  [<c040a03f>] ? kernel_thread_helper+0x7/0x10
> Code: 0f 84 88 00 00 00 8b 4d ec 8b 55 f0 8b 41 3c 3b 42 20 75 7a 8b 52 1c 85 d2 74 07 8d 42 68 f0 ff 42 68 89 55 e4 8b 01 85 c0 75 04 <0f> 0b eb fe f0 ff 01 89 4d e8 8d 7d e8 8d 5d e4 89 fa 89 d8 e8 
> EIP: [<f9336917>] nfsd_lookup_dentry+0x259/0x344 [nfsd] SS:ESP 0068:f1095df4
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

