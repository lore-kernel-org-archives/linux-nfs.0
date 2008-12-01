From: Chuck Lever <chuck.lever@oracle.com>
Subject: Fwd: nfs related backtrace. (.27.5)
Date: Mon, 1 Dec 2008 12:47:47 -0500
Message-ID: <CB3C93ED-DDB4-411B-B484-F4F18C363E3A@oracle.com>
References: <20081126224158.GA20195@redhat.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: netdev@vger.kernel.org
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:63867 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753385AbYLARsJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2008 12:48:09 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Forwarding to linux-nfs@vger.kernel.org

Begin forwarded message:

> From: Dave Jones <davej@redhat.com>
> Date: November 26, 2008 5:41:58 PM GMT-05:00
> To: netdev@vger.kernel.org
> Subject: nfs related backtrace. (.27.5)
>
> Whilst doing some NFS operations from a mac to a linux server,
> I got the following trace, followed by the mac crapping itself
> with 'lockd not responding' messages.
>
> 	Dave
>
> WARNING: at net/ipv4/af_inet.c:154 inet_sock_destruct+0x160/0x17d()  
> (Not tainted)
> Modules linked in: tun nfsd lockd nfs_acl auth_rpcgss exportfs vfat  
> fat fuse sunrpc cpufreq_ondemand acpi_cpufreq freq_table ext2  
> dm_multipath uinput snd_emu10k1_synth snd_emux_synth snd_seq_virmidi  
> snd_seq_midi_emul snd_emu10k1 snd_rawmidi snd_ac97_codec ac97_bus  
> snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_pcm_oss  
> snd_mixer_oss snd_pcm snd_seq_device snd_timer snd_page_alloc  
> snd_util_mem floppy pcspkr snd_hwdep snd i2c_i801 soundcore  
> firewire_ohci firewire_core emu10k1_gp gameport sata_sil crc_itu_t  
> usb_storage ov511 compat_ioctl32 videodev e1000e v4l1_compat  
> i82975x_edac edac_core raid456 async_xor async_memcpy async_tx xor  
> raid0 radeon drm i2c_algo_bit i2c_core [last unloaded: tun]
> Pid: 6613, comm: nfsd Not tainted 2.6.27.5-117.fc10.x86_64.debug #1
>
> Call Trace:
> [<ffffffff8104254a>] warn_on_slowpath+0x60/0x90
> [<ffffffff810636a6>] ? trace_hardirqs_on_caller+0x1f/0x133
> [<ffffffff812b53bd>] ? sk_common_release+0x69/0xc9
> [<ffffffff8130e95b>] inet_sock_destruct+0x160/0x17d
> [<ffffffff812b5290>] sk_free+0x1e/0xe2
> [<ffffffff812b5418>] sk_common_release+0xc4/0xc9
> [<ffffffff8130623f>] udp_lib_close+0x9/0xb
> [<ffffffff8130e3f9>] inet_release+0x58/0x5f
> [<ffffffff812b2553>] sock_release+0x1a/0x76
> [<ffffffff812b25e3>] sock_close+0x34/0x3a
> [<ffffffff810ca753>] __fput+0xca/0x16d
> [<ffffffff810ca80b>] fput+0x15/0x17
> [<ffffffffa02be8cb>] svc_sock_free+0x3b/0x51 [sunrpc]
> [<ffffffffa02c86e9>] svc_xprt_free+0x4a/0x5a [sunrpc]
> [<ffffffffa02c869f>] ? svc_xprt_free+0x0/0x5a [sunrpc]
> [<ffffffff81174be1>] kref_put+0x43/0x4f
> [<ffffffffa02c7ac0>] svc_close_xprt+0x50/0x58 [sunrpc]
> [<ffffffffa02c7b25>] svc_close_all+0x5d/0x77 [sunrpc]
> [<ffffffffa02bdd5f>] svc_destroy+0x9c/0x146 [sunrpc]
> [<ffffffffa02bdea4>] svc_exit_thread+0x9b/0xa4 [sunrpc]
> [<ffffffffa03398b7>] nfsd+0x18f/0x1a9 [nfsd]
> [<ffffffffa0339728>] ? nfsd+0x0/0x1a9 [nfsd]
> [<ffffffffa0339728>] ? nfsd+0x0/0x1a9 [nfsd]
> [<ffffffff8105629d>] kthread+0x49/0x76
> [<ffffffff81011789>] child_rip+0xa/0x11
> [<ffffffff81010a9e>] ? restore_args+0x0/0x30
> [<ffffffff8105622f>] ? kthreadd+0x183/0x1a8
> [<ffffffff81056254>] ? kthread+0x0/0x76
> [<ffffffff8101177f>] ? child_rip+0x0/0x11
>
>
> -- 
> http://www.codemonkey.org.uk
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




