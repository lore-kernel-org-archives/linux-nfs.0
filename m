Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dsl-67-204-24-19.acanac.net ([67.204.24.19]:44714 "EHLO
	mail.ellipticsemi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751344Ab1AXWes (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Jan 2011 17:34:48 -0500
Date: Mon, 24 Jan 2011 17:34:42 -0500
From: Nick Bowler <nbowler@elliptictech.com>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Regression, bisected: NFSv3 BUG when quitting vim in 2.6.38-rc2+.
Message-ID: <20110124223442.GA3831@elliptictech.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

With an NFSv3 client machine running latest Linus' git, quitting vim in
some circumstances causes an NFS BUG.  The exact conditions which cause
the BUG are not entirely clear to me, but running

 vim /path/to/some/directory (this opens a directory listing)
   :q (quits vim)

causes it to crash 100% of the time.  The directory given to vim can be
anything: not necessarily anything to do with the NFS mount.  Since my
home directory is NFS mounted, my guess is that vim's access to its
config and/or state files (~/.vim/, ~/.vimrc and/or ~/.viminfo) cause
the crash.

Crash dump and bisection results follow.  Unfortunately, the implicated
commit does not revert cleanly.

  ------------[ cut here ]------------
  kernel BUG at /scratch_space/linux-2.6/fs/nfs/nfs3xdr.c:1338!
  invalid opcode: 0000 [#1] PREEMPT SMP 
  last sysfs file: /sys/devices/pci0000:00/0000:00:1b.0/subsystem_device
  CPU 2 
  Modules linked in: nfs nfs_acl bridge stp llc autofs4 nfsd lockd exportfs sunrpc ipv6 iptable_filter iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4 ip_tables x_tables snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device snd_pcm_oss snd_mixer_oss snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_pcm snd_timer snd soundcore snd_page_alloc sg evdev usb_storage ext2 ehci_hcd sr_mod cdrom loop tun acpi_cpufreq mperf arc4 ecb crypto_blkcipher cryptomgr aead crypto_algapi rt2800pci rt2800lib crc_ccitt rt2x00pci rt2x00lib mac80211 cfg80211 eeprom_93cx6 e1000e
  
  Pid: 31703, comm: vi Not tainted 2.6.38-rc2-00019-gd315777 #133 WG43M/Aspire X3810
  RIP: 0010:[<ffffffffa03812f9>]  [<ffffffffa03812f9>] nfs3_xdr_enc_setacl3args+0x78/0xb6 [nfs]
  RSP: 0018:ffff88012798da08  EFLAGS: 00010282
  RAX: 00000000ffffffea RBX: ffff88012798dbf8 RCX: 0000000000000004
  RDX: 0000000000000000 RSI: ffff88012798d8f8 RDI: ffff8801393a30e8
  RBP: ffff88012798da28 R08: 0000000000000001 R09: 0000000000000000
  R10: 0000000000000226 R11: 0000000000000004 R12: ffff88012798da48
  R13: 000000000000009c R14: ffff8801390f0840 R15: ffffffffa0381281
  FS:  00007f6f68727740(0000) GS:ffff8800b7b00000(0000) knlGS:0000000000000000
  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  CR2: 00007f6f67499400 CR3: 000000013571d000 CR4: 00000000000406e0
  DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
  DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
  Process vi (pid: 31703, threadinfo ffff88012798c000, task ffff88013efad940)
  Stack:
  000000002798da68 ffff88012798da48 ffff88013549c888 ffff8801393a30e0
  ffff88012798dab8 ffffffffa02b51f3 0000000000000000 ffff88012798dbf8
  ffff88013549c8a4 ffff8801393a30e8 ffff88013549c9d8 ffff8801393a30e8
  Call Trace:
  [<ffffffffa02b51f3>] rpcauth_wrap_req+0x9c/0xad [sunrpc]
  [<ffffffffa02adeee>] call_transmit+0x1df/0x25e [sunrpc]
  [<ffffffffa02b458c>] __rpc_execute+0x83/0x1dd [sunrpc]
  [<ffffffffa02b4723>] rpc_execute+0x3d/0x41 [sunrpc]
  [<ffffffffa02aea59>] rpc_run_task+0xed/0xf9 [sunrpc]
  [<ffffffffa02aeb43>] rpc_call_sync+0x3f/0x60 [sunrpc]
  [<ffffffffa03825f5>] nfs3_proc_setacls+0x1f5/0x2d6 [nfs]
  [<ffffffff810aedef>] ? __slab_free+0x7f/0x108
  [<ffffffff810c36d8>] ? dput+0xcf/0xee
  [<ffffffffa036eec7>] ? nfs_lookup_revalidate+0x2c3/0x420 [nfs]
  [<ffffffffa0382b72>] nfs3_proc_setacl+0xab/0xcb [nfs]
  [<ffffffffa0382c61>] nfs3_setxattr+0x7b/0x98 [nfs]
  [<ffffffff810c36d8>] ? dput+0xcf/0xee
  [<ffffffff810cc301>] __vfs_setxattr_noperm+0x28/0x41
  [<ffffffff8113920a>] ? cap_inode_setxattr+0x38/0x55
  [<ffffffff810cc393>] vfs_setxattr+0x79/0x97
  [<ffffffff810cc469>] setxattr+0xb8/0xd6
  [<ffffffff810bdc14>] ? user_path_at+0x66/0x95
  [<ffffffff810badd3>] ? path_put+0x1d/0x22
  [<ffffffff810b15a6>] ? sys_fchmodat+0xa3/0xb6
  [<ffffffff810cc5ee>] sys_setxattr+0x60/0x85
  [<ffffffff810029bb>] system_call_fastpath+0x16/0x1b
  Code: 45 8b 6d 40 f6 43 08 01 74 04 48 8b 4b 10 45 31 c9 49 8b 7c 24 08 41 b8 01 00 00 00 48 8b 13 44 89 ee e8 9c 5f fe ff 85 c0 79 04 <0f> 0b eb fe 31 c9 f6 43 08 04 74 04 48 8b 4b 18 42 8d 34 28 49 
  RIP  [<ffffffffa03812f9>] nfs3_xdr_enc_setacl3args+0x78/0xb6 [nfs]
  RSP <ffff88012798da08>
  ---[ end trace 284553ae693ad393 ]---

ad96b5b5eae59696b97e207d730b8c8cfb9d4e42 is the first bad commit
commit ad96b5b5eae59696b97e207d730b8c8cfb9d4e42
Author: Chuck Lever <chuck.lever@oracle.com>
Date:   Tue Dec 14 14:56:01 2010 +0000

    NFS: Replace old NFSv3 encoder functions with xdr_stream-based ones

    The naming scheme of the new encoder functions, which follows the
    NFSv4 XDR encoder functions, is slightly different than the scheme
    used for the old functions.  Rename the functions as a separate
    step to keep the patches clean.

    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
    Tested-by: J. Bruce Fields <bfields@redhat.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

:040000 040000 795b37efad99589a07e4f2b2d6da2ec80f08c56e 37b1643869b5f388fcb1e96cab49d9bbd9cab71e M      fs

git bisect start
# bad: [d315777b32a4696feb86f2a0c9e9f39c94683649] Merge branch 'BUG_ON' of git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux-2.6-for-linus
git bisect bad d315777b32a4696feb86f2a0c9e9f39c94683649
# good: [3c0eee3fe6a3a1c745379547c7e7c904aa64f6d5] Linux 2.6.37
git bisect good 3c0eee3fe6a3a1c745379547c7e7c904aa64f6d5
# skip: [443e6221e465efa8efb752a8405a759ef1161af9] Merge branch 'for_linus' of git://git.kernel.org/pub/scm/linux/kernel/git/mjg59/platform-drivers-x86
git bisect skip 443e6221e465efa8efb752a8405a759ef1161af9
# good: [11dbf0acb4aba818a4f0600996216be55667b400] ASoC: soc-cache: Remove unnecessary debugging info
git bisect good 11dbf0acb4aba818a4f0600996216be55667b400
# skip: [37c2ac7872a9387542616f658d20ac25f5bdb32e] thp: compound_trans_order
git bisect skip 37c2ac7872a9387542616f658d20ac25f5bdb32e
# good: [6aa85a5ae610106d89e50c7e1f760c56d12f9bc4] omap4: 4430sdp: enable the ehci port on 4430SDP
git bisect good 6aa85a5ae610106d89e50c7e1f760c56d12f9bc4
# bad: [c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470] Linux 2.6.38-rc1
git bisect bad c56eb8fb6dccb83d9fe62fd4dc00c834de9bc470
# bad: [8dec00059ef1db9f58719186366b71c8afbc4d1e] Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6
git bisect bad 8dec00059ef1db9f58719186366b71c8afbc4d1e
# good: [786a5e15b613a9cee4fc9139fc3113a5ab0fde79] fs: d_validate fixes
git bisect good 786a5e15b613a9cee4fc9139fc3113a5ab0fde79
# good: [01539ba2a706ab7d35fc0667dff919ade7f87d63] Merge branch 'omap-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tmlind/linux-omap-2.6
git bisect good 01539ba2a706ab7d35fc0667dff919ade7f87d63
# bad: [357f54d6b38252737116a6d631f6ac28ded018ed] NFS fix the setting of exchange id flag
git bisect bad 357f54d6b38252737116a6d631f6ac28ded018ed
# bad: [611c96c8f728c4bcdbadaa2387942d3c0641cadf] nfs4: fix units bug causing hang on recovery
git bisect bad 611c96c8f728c4bcdbadaa2387942d3c0641cadf
# bad: [573c4e1ef53a6b891b73cc2257e1604da754a2e4] NFS: Simplify ->decode_dirent() calling sequence
git bisect bad 573c4e1ef53a6b891b73cc2257e1604da754a2e4
# bad: [499ff710b2fd3a03c8195c82340e5166eed04205] NFS: Remove unused old NFSv3 encoder functions
git bisect bad 499ff710b2fd3a03c8195c82340e5166eed04205
# good: [661ad4239a51a2169a366a227c68cf3b654ab936] NFS: Replace old NFSv2 decoder functions with xdr_stream-based ones
git bisect good 661ad4239a51a2169a366a227c68cf3b654ab936
# good: [2b061f9ef216b6d229b06267f188167fd6ab3d9b] lockd: Introduce new-style XDR functions for NLMv3
git bisect good 2b061f9ef216b6d229b06267f188167fd6ab3d9b
# bad: [ad96b5b5eae59696b97e207d730b8c8cfb9d4e42] NFS: Replace old NFSv3 encoder functions with xdr_stream-based ones
git bisect bad ad96b5b5eae59696b97e207d730b8c8cfb9d4e42
# good: [d9c407b138926132e1f93c01fb2dee50eb0bb615] NFS: Introduce new-style XDR encoding functions for NFSv3
git bisect good d9c407b138926132e1f93c01fb2dee50eb0bb615

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
