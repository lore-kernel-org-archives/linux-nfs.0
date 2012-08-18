Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx.scalarmail.ca ([98.158.95.75]:30920 "EHLO
	ironport-01.sms.scalar.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903Ab2HRR5x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Aug 2012 13:57:53 -0400
Date: Sat, 18 Aug 2012 13:57:50 -0400
From: Nick Bowler <nbowler@elliptictech.com>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: NFSv4 WARNING: at linux/fs/inode.c:280 drop_nlink+0x23/0x44()
Message-ID: <20120818175750.GA12736@elliptictech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

I just noticed the following WARNING in my logs.  Looking through the
older logs, I see quite a few of these going (at least) all the way back
to 3.3.x days.  The process which triggers the warning always seems to
be the same (icecat).

This is on a Linux 3.5.2 NFSv4 client machine using sec=krb5.  Other
than the log noise, there seems to be no adverse effects.

------------[ cut here ]------------
WARNING: at /home/nbowler/misc/linux/fs/inode.c:280 drop_nlink+0x23/0x44()
Hardware name: System Product Name
Modules linked in: sha1_ssse3 sha1_generic hmac aes_x86_64 aes_generic cbc cts rpcsec_gss_krb5 nfs lockd auth_rpcgss nfs_acl sunrpc ipv6 nls_iso8859_1 nls_cp437 vfat fat w83627ehf hwmon_vid snd_pcm_oss snd_mixer_oss acpi_cpufreq mperf i915 drm_kms_helper drm snd_hda_codec_hdmi snd_hda_codec_realtek arc4 ath9k mac80211 ath9k_common ath9k_hw intel_agp i2c_algo_bit intel_gtt snd_hda_intel snd_hda_codec snd_pcm snd_timer coretemp agpgart hwmon kvm_intel snd ath cfg80211 soundcore snd_page_alloc i2c_i801 r8169 mii psmouse kvm evdev video sg
Pid: 1995, comm: icecat Not tainted 3.5.2 #46
Call Trace:
 [<ffffffff8102b8b3>] warn_slowpath_common+0x80/0x98
 [<ffffffff8102b8e0>] warn_slowpath_null+0x15/0x17
 [<ffffffff810c5195>] drop_nlink+0x23/0x44
 [<ffffffffa03aa2a1>] nfs_dentry_iput+0x35/0x4d [nfs]
 [<ffffffff810c25d0>] dentry_kill+0x149/0x171
 [<ffffffff810c2850>] dput+0xed/0xfe
 [<ffffffff810b2ff4>] fput+0x1a5/0x1bd
 [<ffffffff810b0454>] filp_close+0x6b/0x76
 [<ffffffff810b04f1>] sys_close+0x92/0xd4
 [<ffffffff8131efa2>] system_call_fastpath+0x16/0x1b
---[ end trace b160c7dc08b4910c ]---

Please let me know if you need any more info,
-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)

