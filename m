Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f175.google.com ([209.85.192.175]:41789 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753891Ab3I1PiM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Sep 2013 11:38:12 -0400
Received: by mail-pd0-f175.google.com with SMTP id q10so3801985pdj.6
        for <linux-nfs@vger.kernel.org>; Sat, 28 Sep 2013 08:38:11 -0700 (PDT)
MIME-Version: 1.0
From: Marc Meledandri <m.meledandri@gmail.com>
Date: Sat, 28 Sep 2013 11:37:40 -0400
Message-ID: <CACFbnrwWJz8her6a4PRn-a0sTF2ci2VY7xOdgRS3zhFpYfxfug@mail.gmail.com>
Subject: Re: Issues with a rather unusual configured NFS server
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/27/2013 08:06 PM, J. Bruce Fields wrote:
> On Tue, Aug 13, 2013 at 05:53:14PM -0400, bfields wrote:
>> On Mon, Aug 12, 2013 at 04:36:40PM +0200, Jan Kara wrote:
>>> On Sun 11-08-13 11:48:49, Toralf Förster wrote:
>>>> so that the server either crashes (if it is a user mode linux image) or at least its reboot functionality got broken
>>>> - if the NFS server is hammered with scary NFS calls using a fuzzy tool running at a remote NFS client under a non-privileged user id.
>>>>
>>>> It can re reproduced, if
>>>> - the NFS share is an EXT3 or EXT4 directory
>>>> - and it is created at file located at tempfs and mounted via loop device
>>>> - and the NFS server is forced to umount the NFS share
>>>> - and the server forced to restart the NSF service afterwards
>>>> - and trinity is used
>>>>
>>>> I could find a scenario for an automated bisect. 2 times it brought this commit
>>>> commit 68a3396178e6688ad7367202cdf0af8ed03c8727
>>>> Author: J. Bruce Fields <bfields@xxxxxxxxxx>
>>>> Date:   Thu Mar 21 11:21:50 2013 -0400
>>>>
>>>>     nfsd4: shut down more of delegation earlier
>>
>> Thanks for the report.  I think I see the problem--after this commit
>> nfs4_set_delegation() failures result in nfs4_put_delegation being
>> called, but nfs4_put_delegation doesn't free the nfs4_file that has
>> already been set by alloc_init_deleg().
>>
>> Let me think about how to fix that....
>
> Sorry for the slow response--can you check whether this fixes the
> problem?
>
Yes.

With the attached patch the problem can't be reproduced any longer with
the prepared test case and current git kernels.

> --b.
>
> commit 624a0ee0375940ce4aa36330b0b5a70af6d2b6f5
> Author: J. Bruce Fields <bfields@xxxxxxxxxx>
> Date:   Thu Aug 15 16:55:26 2013 -0400
>
>     nfsd4: fix leak of inode reference on delegation failure
>
>     This fixes a regression from 68a3396178e6688ad7367202cdf0af8ed03c8727
>     "nfsd4: shut down more of delegation earlier".
>
>     After that commit, nfs4_set_delegation() failures result in
>     nfs4_put_delegation being called, but nfs4_put_delegation doesn't free
>     the nfs4_file that has already been set by alloc_init_deleg().
>
>     This can result in an oops on later unmounting the exported filesystem.
>
>     Note also delaying the fi_had_conflict check we're able to return a
>     better error (hence give 4.1 clients a better idea why the delegation
>     failed; though note CONFLICT isn't an exact match here, as that's
>     supposed to indicate a current conflict, but all we know here is that
>     there was one recently).
>
>     Reported-by: Toralf Förster <toralf.foerster@xxxxxx>
>     Signed-off-by: J. Bruce Fields <bfields@xxxxxxxxxx>
>
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index eb9cf81..0874998 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -368,11 +368,8 @@ static struct nfs4_delegation *
>  alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct svc_fh *current_fh)
>  {
>   struct nfs4_delegation *dp;
> - struct nfs4_file *fp = stp->st_file;
>
>   dprintk("NFSD alloc_init_deleg\n");
> - if (fp->fi_had_conflict)
> - return NULL;
>   if (num_delegations > max_delegations)
>   return NULL;
>   dp = delegstateid(nfs4_alloc_stid(clp, deleg_slab));
> @@ -389,8 +386,7 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
>   INIT_LIST_HEAD(&dp->dl_perfile);
>   INIT_LIST_HEAD(&dp->dl_perclnt);
>   INIT_LIST_HEAD(&dp->dl_recall_lru);
> - get_nfs4_file(fp);
> - dp->dl_file = fp;
> + dp->dl_file = NULL;
>   dp->dl_type = NFS4_OPEN_DELEGATE_READ;
>   fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
>   dp->dl_time = 0;
> @@ -3044,22 +3040,35 @@ static int nfs4_setlease(struct nfs4_delegation *dp)
>   return 0;
>  }
>
> -static int nfs4_set_delegation(struct nfs4_delegation *dp)
> +static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
>  {
> - struct nfs4_file *fp = dp->dl_file;
> + int status;
>
> - if (!fp->fi_lease)
> - return nfs4_setlease(dp);
> + if (fp->fi_had_conflict)
> + return -EAGAIN;
> + get_nfs4_file(fp);
> + dp->dl_file = fp;
> + if (!fp->fi_lease) {
> + status = nfs4_setlease(dp);
> + if (status)
> + goto out_free;
> + return 0;
> + }
>   spin_lock(&recall_lock);
>   if (fp->fi_had_conflict) {
>   spin_unlock(&recall_lock);
> - return -EAGAIN;
> + status = -EAGAIN;
> + goto out_free;
>   }
>   atomic_inc(&fp->fi_delegees);
>   list_add(&dp->dl_perfile, &fp->fi_delegations);
>   spin_unlock(&recall_lock);
>   list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
>   return 0;
> +out_free:
> + put_nfs4_file(fp);
> + dp->dl_file = fp;
> + return status;
>  }
>
>  static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
> @@ -3134,7 +3143,7 @@ nfs4_open_delegation(struct net *net, struct svc_fh *fh,
>   dp = alloc_init_deleg(oo->oo_owner.so_client, stp, fh);
>   if (dp == NULL)
>   goto out_no_deleg;
> - status = nfs4_set_delegation(dp);
> + status = nfs4_set_delegation(dp, stp->st_file);
>   if (status)
>   goto out_free;
>

I was pointed at this thread by the linux-ext4 folks as relevant to my
issue on kernels in
the 3.10.x series. I see this commit was tagged for 3.12-rc2 on git,
and wondering if it will be
rebased for previous kernels? Maybe my issue (oops at shutdown) is
caused by something
else entirely? Thanks!

[183727.974779] EXT4-fs (dm-0): sb orphan head is 47193630
[183727.974864] sb_info orphan list:
[183727.974932]   inode dm-0:47193630 at ffff8802b98950f0: mode
100644, nlink 0, next 0
[183727.975039] ------------[ cut here ]------------
[183727.975108] kernel BUG at fs/ext4/super.c:804!
[183727.975177] invalid opcode: 0000 [#1] SMP
[183727.975341] Modules linked in: btrfs zlib_deflate ufs qnx4 hfsplus
hfs minix ntfs vfat msdos fat jfs xfs libcrc32c reiserfs ext3 jbd ext2
efivars cpuid fuse ecb pci_stub parport_pc ppdev lp parport
cpufreq_userspace cpufreq_stats cpufreq_conservative cpufreq_powersave
binfmt_misc nfsd auth_rpcgss oid_registry nfs_acl nfs lockd fscache
sunrpc usblp hid_microsoft dm_crypt dm_mod loop ecryptfs joydev
nvidia(PO) snd_hda_codec_realtek snd_hda_intel iTCO_wdt
iTCO_vendor_support snd_hda_codec mxm_wmi evdev snd_hwdep snd_pcm
snd_page_alloc coretemp snd_seq snd_timer snd_seq_device psmouse wmi
serio_raw snd i2c_i801 lpc_ich soundcore mfd_core i2c_core ehci_pci
ehci_hcd acpi_cpufreq mperf processor button thermal_sys ext4 crc16
jbd2 mbcache raid456 async_raid6_recov async_memcpy async_pq async_xor
async_tx xor raid6_pq md_mod sg sr_mod cdrom sd_mod crc_t10dif
hid_generic usbhid hid crc32c_intel ghash_clmulni_intel ahci libahci
libata scsi_mod aesni_intel xhci_hcd aes_x86_64 ablk_helper cryptd lrw
gf128mul glue_helper microcode usbcore usb_common e1000e ptp pps_core
[last unloaded: vboxdrv]
[183727.981527] CPU: 2 PID: 24609 Comm: umount Tainted: P           O
3.10.10+mfm #1
[183727.981614] Hardware name:                  /DZ68BC, BIOS
BCZ6810H.86A.0027.2011.1013.1636 10/13/2011
[183727.981703] task: ffff8803e7b06810 ti: ffff8803fffe0000 task.ti:
ffff8803fffe0000
[183727.981790] RIP: 0010:[<ffffffffa0209b62>]  [<ffffffffa0209b62>]
ext4_put_super+0x256/0x310 [ext4]
[183727.981933] RSP: 0018:ffff8803fffe1e78  EFLAGS: 00010287
[183727.982003] RAX: 0000000000000047 RBX: ffff88040de47000 RCX:
00000000d2a7d2a7
[183727.982088] RDX: 000000000000508c RSI: 0000000000000046 RDI:
ffffffff817a94a4
[183727.982174] RBP: ffff88040beb0800 R08: 0000000000000000 R09:
0000000000000100
[183727.982260] R10: 0000000000000100 R11: 0000000000000100 R12:
ffff88040de47200
[183727.982345] R13: ffff88040de47200 R14: ffff88040de47190 R15:
ffff8803fffe1f38
[183727.982432] FS:  00007fb64bfc17e0(0000) GS:ffff88041f500000(0000)
knlGS:0000000000000000
[183727.982519] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[183727.982590] CR2: 00007f3fd0af4f80 CR3: 00000002e46b5000 CR4:
00000000000407e0
[183727.982676] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[183727.982762] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[183727.982847] Stack:
[183727.982911]  ffff880300000000 ffff8803fffe1e78 ffff88040beb0800
ffff88040beb08a0
[183727.983190]  ffffffffa0228fb0 ffff88040ea052a0 ffff88040ea05280
ffffffff810f9415
[183727.983468]  ffff88041e59dbc0 0000000000000083 ffff88040ea05280
ffffffff810f94ab
[183727.983745] Call Trace:
[183727.983813]  [<ffffffff810f9415>] ? generic_shutdown_super+0x4d/0xc5
[183727.983885]  [<ffffffff810f94ab>] ? kill_block_super+0x1e/0x5f
[183727.983958]  [<ffffffff810f97b2>] ? deactivate_locked_super+0x1b/0x46
[183727.984030]  [<ffffffff8110e8b0>] ? SyS_umount+0x2d0/0x2f1
[183727.984102]  [<ffffffff8136b912>] ? system_call_fastpath+0x16/0x1b
[183727.984173] Code: c7 c7 04 1b 23 a0 49 8b 54 24 78 48 81 c6 20 03
00 00 89 04 24 31 c0 e8 de 72 15 e1 4d 8b 24 24 4d 39 ec 0f 84 6e ff
ff ff eb b7 <0f> 0b 48 8b bd 20 01 00 00 e8 b5 65 f1 e0 48 8b bb 50 02
00 00
[183727.987403] RIP  [<ffffffffa0209b62>] ext4_put_super+0x256/0x310 [ext4]
[183727.987525]  RSP <ffff8803fffe1e78>
[183727.987597] ---[ end trace eb19380900af1108 ]---
[183728.094179] EXT4-fs (sda2): re-mounted. Opts: (null)
[184000.112039] SysRq : Keyboard mode set to system default
[184001.631989] SysRq : Terminate All Tasks
[184269.335155] EXT4-fs (sda2): re-mounted. Opts: discard,errors=remount-ro
