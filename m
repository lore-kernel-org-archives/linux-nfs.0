Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f52.google.com ([74.125.83.52]:63952 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751936Ab3LRDII convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Dec 2013 22:08:08 -0500
Received: by mail-ee0-f52.google.com with SMTP id d17so3253845eek.39
        for <linux-nfs@vger.kernel.org>; Tue, 17 Dec 2013 19:08:07 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: NFS unmount causes system hang
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <52B10487.8080804@alexforencich.com>
Date: Wed, 18 Dec 2013 05:08:03 +0200
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D686BC44-9FD0-435F-B99B-12052CC4465E@primarydata.com>
References: <52B10487.8080804@alexforencich.com>
To: Alex Forencich <alex@alexforencich.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 18, 2013, at 4:12, Alex Forencich <alex@alexforencich.com> wrote:

> I may have found a bug in NFS unmount that causes a system hang. 
> 
> I have a home server that I just set up recently that runs Arch linux. 
> It exports a couple of external hard drives via NFS.  I have been
> mouting them with autofs on my laptop.  However, after several hours the
> entire system completely hangs up.  I originally thought it had
> something to do with the rpc-gssd daemon that the Arch Linux NFS wiki
> page recommends running as it was dying in a strange way and I thought
> that may have been related to the hang ups.  After implementing a
> different workaround (blacklist rpcsec_gss_krb5) and disabling rpc-gssd,
> I am still having the same hang issue. 
> 
> Here is what happens:
> 
> I boot up my computer, start Firefox, Thunderbird, various terminals,
> etc.  I mount the NFS share with autofs by opening up the
> /media/net/atomic/qx2_data directory.  After a while, the NFS mounts in
> Thunar start disappering momentarily and then reappearing.  Then a
> little while later the system completely hangs and requires a hard
> reboot.  The end of the log from journalctl is posted below. 
> 
> Right now I have disabled autofs and I will only mount the drives on the
> server via SFTP to avoid this problem, but I would really like to get
> this debugged.  Also, this is not likely related to any sort of a
> connection issue as both computers are hardwired to the same Gigabit
> Ethernet switch. 
> 
> I posted this to the Arch Linux forum here:
> https://bbs.archlinux.org/viewtopic.php?pid=1361402 and a user replied
> saying this is a bug in NFS unmount.  I can add try to collect more
> debug information if necessary. 
> 
> /etc/autofs/auto.net:
> 
> |atomic -fstype=nfs4,rw,async,sec=sys,bg,intr atomic.local:/|
> 
> uname -a:
> 
> |Linux watatsumi 3.12.5-1-ARCH #1 SMP PREEMPT Thu Dec 12 12:57:31 CET 2013 x86_64 GNU/Linux|
> 
> Log:
> 
> |Dec 17 16:33:35 watatsumi automount[19747]: key ".hidden" not found in map source(s).
> Dec 17 16:34:51 watatsumi automount[19747]: key ".hidden" not found in map source(s).
> Dec 17 16:36:07 watatsumi automount[19747]: key ".hidden" not found in map source(s).
> Dec 17 16:37:23 watatsumi automount[19747]: key ".hidden" not found in map source(s).
> Dec 17 16:38:35 watatsumi automount[19747]: key ".hidden" not found in map source(s).
> Dec 17 16:39:51 watatsumi automount[19747]: key ".hidden" not found in map source(s).
> Dec 17 16:41:07 watatsumi automount[19747]: key ".hidden" not found in map source(s).
> Dec 17 16:42:23 watatsumi automount[19747]: key ".hidden" not found in map source(s).
> Dec 17 16:43:39 watatsumi automount[19747]: key ".hidden" not found in map source(s).
> Dec 17 16:45:16 watatsumi kernel: BUG: soft lockup - CPU#5 stuck for 23s! [htop:2505]
> Dec 17 16:45:16 watatsumi kernel: Modules linked in: usbtmc auth_rpcgss oid_registry nfsv4 tun joydev snd_hda_codec_hdmi x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel kvm crct10dif_pclmul crct10dif_common crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel aes_x86_64 lrw gf128mul glue_helper ablk_helper cryptd fuse nvidia(PO) iTCO_wdt iTCO_vendor_support uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_core snd_usb_audio videodev snd_usbmidi_lib snd_rawmidi media snd_seq_device arc4 evdev microcode psmouse serio_raw iwldvm mac80211 snd_hda_codec_realtek iwlwifi snd_hda_intel snd_hda_codec cfg80211 snd_hwdep drm snd_pcm jme jmb38x_ms rfkill mii snd_page_alloc memstick snd_timer i2c_i801 mei_me snd i2c_core soundcore mei thermal shpchp wmi lpc_ich processor battery ac button video pcspkr nfs lockd
> Dec 17 16:45:16 watatsumi kernel:  sunrpc fscache ext4 crc16 mbcache jbd2 sd_mod hid_generic usbhid hid ahci libahci libata ehci_pci firewire_ohci sdhci_pci xhci_hcd scsi_mod ehci_hcd sdhci firewire_core crc_itu_t mmc_core usbcore usb_common
> Dec 17 16:45:16 watatsumi kernel: CPU: 5 PID: 2505 Comm: htop Tainted: P           O 3.12.5-1-ARCH #1
> Dec 17 16:45:16 watatsumi kernel: Hardware name: CLEVO                             P150HMx/P150HMx, BIOS 4.6.4 08/09/2011

Can you please demonstrate the problem _without_ the binary nvidia module, since this looks like a memory corruption issue? There is no way to sanely debug problems with kernels to which we don’t have the source.

Trond