From: Philipp Matthias Hahn <pmhahn@titan.lahn.de>
Subject: OOPS: NFSv4 2.6.20.3 nfs_update_inode+0xb9/0x60f
Date: Wed, 14 Mar 2007 14:25:15 +0100
Message-ID: <20070314132515.GA3394@titan.lahn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HRTTs-00070C-RM
	for nfs@lists.sourceforge.net; Wed, 14 Mar 2007 06:25:30 -0700
Received: from ip-svs-1.informatik.uni-oldenburg.de ([134.106.12.126]
	helo=schlidder.svs.informatik.uni-oldenburg.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HRTTp-0005Zu-R4
	for nfs@lists.sourceforge.net; Wed, 14 Mar 2007 06:25:28 -0700
Received: from walker.pmhahn.de (walker.svs.informatik.uni-oldenburg.de
	[134.106.22.73])
	by schlidder.svs.informatik.uni-oldenburg.de (Postfix) with ESMTP id
	8893254061
	for <nfs@lists.sourceforge.net>; Wed, 14 Mar 2007 14:25:16 +0100 (CET)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hello!

While unmounting a NFSv4 filesystem on a 2.6.20.3 client, I got the
following oops. Disassembly follows after that.

BUG: unable to handle kernel NULL pointer dereference at virtual address 00000008
 printing eip:
e05d037a
*pde = 00000000
Oops: 0000 [#1]
PREEMPT
Modules linked in: rpcsec_gss_krb5 auth_rpcgss nfs lockd nfs_acl sunrpc i915 drm rfcomm l2cap ipv6 tun autofs4 deflate zlib_deflate twofish twofish_common serpent blowfish des cbc ecb blkcipher aes xcbc sha256 sha1 crypto_null af_key dm_snapshot dm_mirror dm_mod uinput hdaps hci_usb bluetooth 8250_pci ipw2200 snd_intel8x0 snd_pcm_oss snd_mixer_oss ieee80211 ieee80211_crypt snd_intel8x0m snd_ac97_codec ac97_bus snd_pcm snd_timer snd ehci_hcd sdhci mmc_core firmware_class irda uhci_hcd intel_agp agpgart 8250_pnp 8250 serial_core i2c_i801 usbcore crc_ccitt soundcore snd_page_alloc
CPU:    0
EIP:    0060:[<e05d037a>]    Not tainted VLI
EFLAGS: 00010246   (2.6.20.3-laptop #1)
EIP is at nfs_update_inode+0xb9/0x60f [nfs]
eax: 00000000   ebx: 000081a4   ecx: c2bca66c   edx: 00008000
esi: def98c80   edi: d5b880b0   ebp: c5938dac   esp: c5938d58
ds: 007b   es: 007b   ss: 0068
Process umount (pid: 4540, ti=c5938000 task=d2a1d030 task.ti=c5938000)
Stack: 00000000 d2a1d030 c012ba2c c5938d84 c5938d84 00000000 c48a74a8 00000004
       c6eaa080 00000002 c5938db4 00000000 c5938d90 c012299a 00000000 c2bca544
       c2bca66c 00000000 d5b880b0 c2bca544 c2bca66c c5938dc4 e05d0298 00000000
Call Trace:
 [<c0103a9b>] show_trace_log_lvl+0x19/0x2e
 [<c0103b65>] show_stack_log_lvl+0xa1/0xa9
 [<c0103d50>] show_registers+0x1a0/0x2e4
 [<c010400c>] die+0x107/0x200
 [<c030e59e>] do_page_fault+0x45c/0x53e
 [<c030cd84>] error_code+0x74/0x7c
 [<e05d0298>] nfs_post_op_update_inode+0x39/0x62 [nfs]
 [<e05e0fd6>] _nfs4_proc_delegreturn+0x111/0x122 [nfs]
 [<e05e101d>] nfs4_proc_delegreturn+0x36/0x73 [nfs]
 [<e05ea0c8>] nfs_do_return_delegation+0x12/0x21 [nfs]
 [<e05ea1c1>] __nfs_inode_return_delegation+0xc4/0xd2 [nfs]
 [<e05cbf9b>] nfs_dentry_iput+0x16/0x43 [nfs]
 [<c016ec9b>] shrink_dcache_for_umount_subtree+0x1f5/0x259
 [<c016ed38>] shrink_dcache_for_umount+0x39/0x46
 [<c0160610>] generic_shutdown_super+0x17/0xea
 [<c0160f33>] kill_anon_super+0xc/0x48
 [<e05d1904>] nfs_kill_super+0xf/0x19 [nfs]
 [<c0160495>] deactivate_super+0x4c/0x5e
 [<c01730fa>] mntput_no_expire+0x55/0x93
 [<c01742ea>] expire_mount_list+0x9e/0xd1
 [<c0174482>] shrink_submounts+0x2a/0x5b
 [<e05d136a>] nfs_umount_begin+0xd/0xf [nfs]
 [<c0173681>] do_umount+0x9b/0x194
 [<c01737d7>] sys_umount+0x5d/0x6f
 [<c0173801>] sys_oldumount+0x18/0x1a
 [<c0102de8>] syscall_call+0x7/0xb
 =======================
Code: 5a 6a 89 c8 25 00 f0 00 00 89 da 81 e2 00 f0 00 00 39 c2 0f 85 e3 04 00 00 8b 4d ec 8b 81 98 00 00 00 8b b0 6c 01 00 00 8b 40 38 <3b> 48 08 75 5b 8d 5e 74 8b 57 48 8d 47 44 89 45 dc 8b 47 44 89
EIP: [<e05d037a>] nfs_update_inode+0xb9/0x60f [nfs] SS:ESP 0068:c5938d58
 <6>note: umount[4540] exited with preempt_count 1


fs/nfs/inode.o:     file format elf32-i386
Disassembly of section .text:
00001539 <nfs_update_inode>:
nfs_update_inode():
fs/nfs/inode.c:932
        server = NFS_SERVER(inode);
    15e0:       8b 4d ec                mov    0xffffffec(%ebp),%ecx
    15e3:       8b 81 98 00 00 00       mov    0x98(%ecx),%eax
    15e9:       8b b0 6c 01 00 00       mov    0x16c(%eax),%esi
fs/nfs/inode.c:954
        /* Update the fsid if and only if this is the root directory */
        if (inode == inode->i_sb->s_root->d_inode
    15ef:       8b 40 38                mov    0x38(%eax),%eax
    15f2:       3b 48 08                cmp    0x8(%eax),%ecx
                                               ^^^^^^^^^ HERE!
    15f5:       75 5b                   jne    1652 <nfs_update_inode+0x119>

Any advice?

BYtE
Philipp
-- 
  / /  (_)__  __ ____  __ Philipp Hahn
 / /__/ / _ \/ // /\ \/ /
/____/_/_//_/\_,_/ /_/\_\ pmhahn@titan.lahn.de

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
