From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: BUG: oops in gss_validate on 2.6.31
Date: Wed, 16 Sep 2009 08:46:56 -0400
Message-ID: <1253105216.5154.8.camel@heimdal.trondhjem.org>
References: <20090916102953.GA18674@wavehammer.waldi.eu.org>
	 <1253104249.5154.3.camel@heimdal.trondhjem.org>
	 <4AB22E13.6020501@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Aioanei Rares <krnl.list@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:53144 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752927AbZIPMq5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Sep 2009 08:46:57 -0400
In-Reply-To: <4AB22E13.6020501@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-09-17 at 15:39 +0300, Aioanei Rares wrote:
> Trond Myklebust wrote:
> > On Wed, 2009-09-16 at 12:29 +0200, Bastian Blank wrote:
> >   
> >> Hi
> >>
> >> Since 2.6.31 my gssapi authenticated nfs oopses.
> >>
> >> BUG: unable to handle kernel NULL pointer dereference at 00000010
> >> IP: [<f8dd594a>] gss_validate+0xad/0x175 [auth_rpcgss]
> >> *pdpt = 0000000001473001 *pde = 0000000000000000
> >> Oops: 0000 [#1] SMP
> >> last sysfs file: /sys/devices/virtual/block/dm-13/range
> >> Modules linked in: kvm_intel kvm ext4 jbd2 crc16 usb_storage usbhid hid i915 drm i2c_algo_bit sco bridge stp bnep rfcomm l2cap xt_mac ipt_REJECT xt_tcpudp xt_conntrack iptable_filter ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables x_tables tun nfsd exportfs nfs lockd fscache nfs_acl deflate zlib_deflate ctr twofish twofish_common camellia serpent blowfish cast5 des_generic xcbc rmd160 sha1_generic hmac crypto_null af_key fuse rpcsec_gss_krb5 auth_rpcgss sunrpc loop acpi_cpufreq arc4 snd_hda_codec_analog ecb snd_hda_intel snd_hda_codec iwl3945 snd_hwdep iwlcore snd_pcm snd_seq snd_timer thinkpad_acpi snd_seq_device nsc_ircc i2c_i801 btusb mac80211 i2c_core serio_raw snd soundcore battery button psmouse processor rng_core snd_page_alloc evdev nv
 ram ac cfg80211 bluetooth irda rfkill crc_ccitt ext3 jbd mbcache sha256_generic aes_i586 aes_generic cbc dm_crypt dm_mod sd_mod crc_t10dif ata_generic ide_pci_generic ahci libata scsi_mod sdhci_pci piix sdhci firewire_ohci firewire_core crc_itu_t ide_core mmc_core led_class uhci_hcd ehci_hcd usbcore nls_base e1000e intel_agp agpgart video output thermal fan thermal_sys [last unloaded: kvm]
> >>
> >> Pid: 2025, comm: rpciod/0 Not tainted (2.6.31-trunk-686-bigmem #1) 170255G
> >> EIP: 0060:[<f8dd594a>] EFLAGS: 00010246 CPU: 0
> >> EIP is at gss_validate+0xad/0x175 [auth_rpcgss]
> >> EAX: d5d7e830 EBX: f60f5ef8 ECX: f60f5ee4 EDX: f60f5ef8
> >> ESI: 00000025 EDI: 00000000 EBP: cdc30bc0 ESP: f60f5edc
> >>  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
> >> Process rpciod/0 (pid: 2025, ti=f60f4000 task=f6685ae0 task.ti=f60f4000)
> >> Stack:
> >>  f5c512c0 d5d7e830 00000025 d5d7e830 f60f5ef4 00000004 9cd00000 f60f5ef4
> >> <0> 00000004 00000000 00000000 00000000 00000001 00000000 f847888c 00000004
> >> <0> 00000004 be91f5c4 cdc30bc0 f5c512c0 d5d7e828 f3c807f8 f8d9de34 be91f5c4
> >> Call Trace:
> >>  [<f8d9de34>] ? rpcauth_checkverf+0x4a/0x60 [sunrpc]
> >>  [<f8d972a0>] ? call_decode+0x30f/0x5de [sunrpc]
> >>  [<f8d96199>] ? rpcproc_decode_null+0x0/0x21 [sunrpc]
> >>  [<f8d9d246>] ? __rpc_execute+0x76/0x21e [sunrpc]
> >>  [<c10528b6>] ? worker_thread+0x146/0x1d9
> >>  [<f8d9d473>] ? rpc_async_schedule+0x0/0x29 [sunrpc]
> >>  [<c105710f>] ? autoremove_wake_function+0x0/0x4f
> >>  [<c1052770>] ? worker_thread+0x0/0x1d9
> >>  [<c1056d7f>] ? kthread+0x7a/0x7f
> >>  [<c1056d05>] ? kthread+0x0/0x7f
> >>  [<c1009d07>] ? kernel_thread_helper+0x7/0x10
> >> Code: 24 18 89 da 89 44 24 10 8d 44 24 10 c7 44 24 14 04 00 00 00 e8 a4 f0 fc ff 89 da 8b 44 24 04 89 74 24 08 8d 4c 24 08 89 44 24 0c <8b> 47 10 e8 3c 16 00 00 3d 00 00 0c 00 89 c2 75 0a 8d 45 28 f0
> >> EIP: [<f8dd594a>] gss_validate+0xad/0x175 [auth_rpcgss] SS:ESP 0068:f60f5edc
> >> CR2: 0000000000000010
> >> ---[ end trace 92895856d62132dd ]---
> >>
> >> I saw this two times in the last days. Always under load. I've never
> >> seen this with 2.6.30. The server is a 2.6.30 machine.
> >>     
> >
> > Hmm... I don't see any obvious candidates in the changelog. My only
> > guess is that something is amiss after the merge of the nfsv4.1
> > backchannel code.
> >
> > Would you be able to do a git bisect in order to finger the culprit?
> >
> > Cheers
> >   Trond
> >
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> >
> >   
> Guess i'll have to look into some manuals, since I'm not my git-fu is 
> weak, and I'll get back to you. Meanwhile I'll test my .config with a 
> release kernel.

I believe that starting with something along the lines of

	git bisect start v2.6.31 v2.6.30 -- net/sunrpc include/linux/sunrpc

should be the most efficient thing to do. Then use 'git bisect bad' and
'git bisect good' to label the resulting kernels as bad or good.

Cheers
  Trond

