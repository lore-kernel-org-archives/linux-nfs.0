Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.gmx.net ([212.227.17.20]:51029 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751656Ab3CZRqn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Mar 2013 13:46:43 -0400
Received: from mailout-de.gmx.net ([10.1.76.17]) by mrigmx.server.lan
 (mrigmx001) with ESMTP (Nemesis) id 0MZANm-1U6AN30VFk-00Kze4 for
 <linux-nfs@vger.kernel.org>; Tue, 26 Mar 2013 18:46:41 +0100
Message-ID: <5151DEF7.3060003@gmx.de>
Date: Tue, 26 Mar 2013 18:46:31 +0100
From: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: kernel 3.8.4 : kernel BUG at fs/locks.c:2093!   part #2
References: <514F31AF.3080709@gmx.de> <20130325220143.GD10887@fieldses.org> <20130326144640.GB3353@fieldses.org>
In-Reply-To: <20130326144640.GB3353@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/26/2013 03:46 PM, J. Bruce Fields wrote:
> Can you run with test patches?
> 
> This just makes nfsd's fput calls synchronous so that we see in the
> backtrace who called them.

Well - the patched 3.8.4 host kernel now survives the stress test of the UML system.
What I get at the host is now :

2013-03-26T18:32:17.487+01:00 n22 kernel: ------------[ cut here ]------------
2013-03-26T18:32:17.487+01:00 n22 kernel: WARNING: at mm/page_alloc.c:2376 __alloc_pages_nodemask+0x262/0x7c0()
2013-03-26T18:32:17.487+01:00 n22 kernel: Hardware name: 4180F65
2013-03-26T18:32:17.487+01:00 n22 kernel: Modules linked in: md5 nfsd auth_rpcgss ipt_MASQUERADE xt_owner xt_multiport ipt_REJECT xt_tcpudp xt_recent xt_conntrack nf_conntrack_ftp xt_limit xt_LOG iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_filter ip_tables x_tables af_packet pppoe pppox ppp_generic slhc bridge stp llc tun msr snd_hda_codec_conexant snd_hda_intel uvcvideo i915 usblp snd_hda_codec sdhci_pci snd_pcm cfbfillrect videobuf2_vmalloc arc4 iwldvm cfbimgblt i2c_algo_bit cfbcopyarea intel_agp videobuf2_memops sdhci coretemp videobuf2_core mac80211 snd_page_alloc kvm_intel acpi_cpufreq fbcon mperf bitblit softcursor font intel_gtt videodev mmc_core snd_timer kvm drm_kms_helper thinkpad_acpi drm nvram agpgart fb snd i2c_i801 video i2c_core tpm_tis soundcore processor 8250_pci 8250_core iwlwifi thermal battery cfg80211 fbdev ac tpm rfkill psmouse serial_core e1000e evdev thermal_sys button tpm_bios wmi hwmon aesni_intel ablk_helper!
  cryptd lr
w aes_i586 xts gf128mul cbc sha256_generic fuse nfs lockd sunrpc dm_crypt dm_mod hid_monterey hid_microsoft hid_logitech hid_ezkey hid_cypress hid_chicony hid_cherry hid_belkin hid_apple hid_a4tech hid_generic usbhid hid sr_mod cdrom sg [last unloaded: microcode]
2013-03-26T18:32:17.487+01:00 n22 kernel: Pid: 6614, comm: nfsd Not tainted 3.8.4 #9
2013-03-26T18:32:17.487+01:00 n22 kernel: Call Trace:
2013-03-26T18:32:17.487+01:00 n22 kernel: [<c1033ba2>] warn_slowpath_common+0x72/0xa0
2013-03-26T18:32:17.487+01:00 n22 kernel: [<c10db802>] ? __alloc_pages_nodemask+0x262/0x7c0
2013-03-26T18:32:17.487+01:00 n22 kernel: [<c10db802>] ? __alloc_pages_nodemask+0x262/0x7c0
2013-03-26T18:32:17.487+01:00 n22 kernel: [<c1033bf2>] warn_slowpath_null+0x22/0x30
2013-03-26T18:32:17.487+01:00 n22 kernel: [<c10db802>] __alloc_pages_nodemask+0x262/0x7c0
2013-03-26T18:32:17.487+01:00 n22 kernel: [<c1069758>] ? dequeue_task_fair+0x258/0x6f0
2013-03-26T18:32:17.487+01:00 n22 kernel: [<c13a8803>] ? inet_recvmsg+0x73/0x90
2013-03-26T18:32:17.487+01:00 n22 kernel: [<c10dbd7c>] __get_free_pages+0x1c/0x30
2013-03-26T18:32:17.487+01:00 n22 kernel: [<c110e0f9>] kmalloc_order_trace+0x29/0xb0
2013-03-26T18:32:17.487+01:00 n22 kernel: [<f857e480>] ? ip_map_request+0xd0/0xd0 [sunrpc]
2013-03-26T18:32:17.487+01:00 n22 kernel: [<f85824d6>] ? cache_revisit_request+0x26/0xd0 [sunrpc]
2013-03-26T18:32:17.487+01:00 n22 kernel: [<c110f149>] __kmalloc+0x1b9/0x1e0
2013-03-26T18:32:17.487+01:00 n22 kernel: [<f85835bf>] ? cache_check+0x22f/0x340 [sunrpc]
2013-03-26T18:32:17.487+01:00 n22 kernel: [<f90a0b1c>] nfs4_acl_new+0x1c/0x30 [nfsd]
2013-03-26T18:32:17.488+01:00 n22 kernel: [<f9095482>] nfsd4_decode_fattr+0x302/0x6c0 [nfsd]
2013-03-26T18:32:17.488+01:00 n22 kernel: [<c110f068>] ? __kmalloc+0xd8/0x1e0
2013-03-26T18:32:17.488+01:00 n22 kernel: [<f9095871>] nfsd4_decode_setattr+0x31/0x40 [nfsd]
2013-03-26T18:32:17.488+01:00 n22 kernel: [<f909804d>] nfs4svc_decode_compoundargs+0x23d/0x280 [nfsd]
2013-03-26T18:32:17.488+01:00 n22 kernel: [<f9097e10>] ? nfsd4_release_compoundargs+0x70/0x70 [nfsd]
2013-03-26T18:32:17.488+01:00 n22 kernel: [<f9081b3f>] nfsd_dispatch+0x3f/0x1b0 [nfsd]
2013-03-26T18:32:17.488+01:00 n22 kernel: [<f857b8a8>] svc_process+0x3f8/0x6d0 [sunrpc]
2013-03-26T18:32:17.488+01:00 n22 kernel: [<f8586d5e>] ? svc_xprt_received+0x3e/0x80 [sunrpc]
2013-03-26T18:32:17.488+01:00 n22 kernel: [<f85879e1>] ? svc_recv+0x2d1/0x3c0 [sunrpc]
2013-03-26T18:32:17.488+01:00 n22 kernel: [<f908165d>] nfsd+0xad/0x110 [nfsd]
2013-03-26T18:32:17.488+01:00 n22 kernel: [<f90815b0>] ? nfsd_destroy+0x70/0x70 [nfsd]
2013-03-26T18:32:17.488+01:00 n22 kernel: [<c1053b94>] kthread+0x94/0xa0
2013-03-26T18:32:17.488+01:00 n22 kernel: [<c13d0f77>] ret_from_kernel_thread+0x1b/0x28
2013-03-26T18:32:17.488+01:00 n22 kernel: [<c1053b00>] ? flush_kthread_work+0xd0/0xd0
2013-03-26T18:32:17.488+01:00 n22 kernel: ---[ end trace 82b96ff8bcd5453f ]---


-- 
MfG/Sincerely
Toralf Förster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
