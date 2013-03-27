Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53094 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752639Ab3C0V51 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Mar 2013 17:57:27 -0400
Date: Wed, 27 Mar 2013 17:57:27 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: kernel 3.8.4 : kernel BUG at fs/locks.c:2093!   part #2
Message-ID: <20130327215727.GB27426@fieldses.org>
References: <514F31AF.3080709@gmx.de>
 <20130325220143.GD10887@fieldses.org>
 <20130326144640.GB3353@fieldses.org>
 <51536610.7010809@gmx.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <51536610.7010809@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 27, 2013 at 10:35:12PM +0100, Toralf Förster wrote:
> On 03/26/2013 03:46 PM, J. Bruce Fields wrote:
> > Can you run with test patches?
> 
> applied - today I got a warning instead a bug at the host kernel (3.8.4):

Excellent!  Thanks, I think I see the bug now....

--b.

> 2013-03-27T22:28:43.480+01:00 n22 kernel: ------------[ cut here ]------------
> 2013-03-27T22:28:43.480+01:00 n22 kernel: WARNING: at fs/locks.c:2093 locks_remove_flock+0xe5/0x110()
> 2013-03-27T22:28:43.480+01:00 n22 kernel: Hardware name: 4180F65
> 2013-03-27T22:28:43.480+01:00 n22 kernel: Modules linked in: loop md5 nfsd auth_rpcgss ipt_MASQUERADE xt_owner xt_multiport ipt_REJECT xt_tcpudp xt_recent xt_conntrack nf_conntrack_ftp xt_limit xt_LOG iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_filter ip_tables x_tables af_packet pppoe pppox ppp_generic slhc bridge stp llc tun msr i915 cfbfillrect cfbimgblt i2c_algo_bit cfbcopyarea intel_agp intel_gtt sdhci_pci fbcon bitblit softcursor font drm_kms_helper sdhci usblp drm arc4 mmc_core iwldvm mac80211 uvcvideo videobuf2_vmalloc snd_hda_codec_conexant videobuf2_memops videobuf2_core coretemp videodev acpi_cpufreq iwlwifi mperf cfg80211 snd_hda_intel agpgart fb fbdev i2c_i801 thinkpad_acpi processor video thermal ac snd_hda_codec snd_pcm snd_page_alloc 8250_pci i2c_core kvm_intel snd_timer nvram snd soundcore 8250_core e1000e serial_core button tpm_tis tpm kvm rfkill tpm_bios psmouse thermal_sys battery wmi evdev hwmon aesni_intel ablk!
 _helper cryp
> td lrw aes_i586 xts gf128mul cbc sha256_generic fuse nfs lockd sunrpc dm_crypt dm_mod hid_monterey hid_microsoft hid_logitech hid_ezkey hid_cypress hid_chicony hid_cherry hid_belkin hid_apple hid_a4tech hid_generic usbhid hid sr_mod cdrom sg [last unloaded: microcode]
> 2013-03-27T22:28:43.480+01:00 n22 kernel: Pid: 7442, comm: nfsd Not tainted 3.8.4 #13
> 2013-03-27T22:28:43.480+01:00 n22 kernel: Call Trace:
> 2013-03-27T22:28:43.480+01:00 n22 kernel: [<c1033ba2>] warn_slowpath_common+0x72/0xa0
> 2013-03-27T22:28:43.480+01:00 n22 kernel: [<c1160885>] ? locks_remove_flock+0xe5/0x110
> 2013-03-27T22:28:43.480+01:00 n22 kernel: [<c1160885>] ? locks_remove_flock+0xe5/0x110
> 2013-03-27T22:28:43.480+01:00 n22 kernel: [<c1033bf2>] warn_slowpath_null+0x22/0x30
> 2013-03-27T22:28:43.480+01:00 n22 kernel: [<c1160885>] locks_remove_flock+0xe5/0x110
> 2013-03-27T22:28:43.480+01:00 n22 kernel: [<c110eb53>] ? kmem_cache_alloc+0x73/0x140
> 2013-03-27T22:28:43.480+01:00 n22 kernel: [<c111e719>] __fput+0x79/0x1f0
> 2013-03-27T22:28:43.480+01:00 n22 kernel: [<c111ed1b>] __fput_sync+0x4b/0x60
> 2013-03-27T22:28:43.480+01:00 n22 kernel: [<f8bb8b17>] __nfs4_file_put_access+0x57/0x80 [nfsd]
> 2013-03-27T22:28:43.480+01:00 n22 kernel: [<f8bb8b73>] nfs4_file_put_access+0x33/0x40 [nfsd]
> 2013-03-27T22:28:43.480+01:00 n22 kernel: [<f8bbd4f6>] nfsd4_open_downgrade+0x1b6/0x210 [nfsd]
> 2013-03-27T22:28:43.480+01:00 n22 kernel: [<f8bbd340>] ? nfsd4_open_confirm+0x130/0x130 [nfsd]
> 2013-03-27T22:28:43.480+01:00 n22 kernel: [<f8baf94b>] nfsd4_proc_compound+0x41b/0x530 [nfsd]
> 2013-03-27T22:28:43.480+01:00 n22 kernel: [<f8bbf180>] ? nfsd4_set_lockstateid+0x50/0x50 [nfsd]
> 2013-03-27T22:28:43.481+01:00 n22 kernel: [<f8ba1ba0>] nfsd_dispatch+0xa0/0x1b0 [nfsd]
> 2013-03-27T22:28:43.481+01:00 n22 kernel: [<f857b8a8>] svc_process+0x3f8/0x6d0 [sunrpc]
> 2013-03-27T22:28:43.481+01:00 n22 kernel: [<f8586d5e>] ? svc_xprt_received+0x3e/0x80 [sunrpc]
> 2013-03-27T22:28:43.481+01:00 n22 kernel: [<f85879e1>] ? svc_recv+0x2d1/0x3c0 [sunrpc]
> 2013-03-27T22:28:43.481+01:00 n22 kernel: [<f8ba165d>] nfsd+0xad/0x110 [nfsd]
> 2013-03-27T22:28:43.481+01:00 n22 kernel: [<f8ba15b0>] ? nfsd_destroy+0x70/0x70 [nfsd]
> 2013-03-27T22:28:43.481+01:00 n22 kernel: [<c1053b94>] kthread+0x94/0xa0
> 2013-03-27T22:28:43.481+01:00 n22 kernel: [<c13d0f77>] ret_from_kernel_thread+0x1b/0x28
> 2013-03-27T22:28:43.481+01:00 n22 kernel: [<c1053b00>] ? flush_kthread_work+0xd0/0xd0
> 2013-03-27T22:28:43.481+01:00 n22 kernel: ---[ end trace 66f6fe36b0d13e8f ]---
> 
> 
> The UML kernel was 3.9.0-rc4-00144-ga8c4528, and the trinity command just :
> $> trinity --children 2 --victims /mnt/nfs/n22/victims -x mremap
> 
> -- 
> MfG/Sincerely
> Toralf Förster
> pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
