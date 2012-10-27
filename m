Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f174.google.com ([209.85.210.174]:49206 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932Ab2J0MTi convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2012 08:19:38 -0400
Received: by mail-ia0-f174.google.com with SMTP id y32so2820324iag.19
        for <linux-nfs@vger.kernel.org>; Sat, 27 Oct 2012 05:19:38 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 27 Oct 2012 20:19:38 +0800
Message-ID: <CAOAMTYQ_9bPjCtobC9kfUJrgiT8hx7FsMXoi5ZgWo+P1qjDb0g@mail.gmail.com>
Subject: WARNING: at linux/fs/inode.c:280 drop_nlink
From: Ricky Ng-Adam <rngadam@lophilo.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A one time warning after quite a bit of usage with no other problems:

------------[ cut here ]------------
WARNING: at /home/rngadam/lophilo/linux/fs/inode.c:280 drop_nlink+0x54/0x60()
Modules linked in: ipt_REDIRECT xt_tcpudp iptable_nat nf_nat
nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack ip_tables x_tables
snd_atmel_ac97c snd_ac97_codec ac97_bus snd_pcm snd_page_alloc
snd_timer snd soundcore lophilo(O) ipv6 autofs4
[<c000dfdc>] (unwind_backtrace+0x0/0xf0) from [<c0017784>]
(warn_slowpath_common+0x4c/0x64)
[<c0017784>] (warn_slowpath_common+0x4c/0x64) from [<c00177b8>]
(warn_slowpath_null+0x1c/0x24)
[<c00177b8>] (warn_slowpath_null+0x1c/0x24) from [<c00a9084>]
(drop_nlink+0x54/0x60)
[<c00a9084>] (drop_nlink+0x54/0x60) from [<c0131268>]
(nfs_dentry_iput+0x38/0x50)
[<c0131268>] (nfs_dentry_iput+0x38/0x50) from [<c00a67b0>] (d_kill+0x9c/0xec)
[<c00a67b0>] (d_kill+0x9c/0xec) from [<c00a6cf0>] (dput+0x78/0x134)
[<c00a6cf0>] (dput+0x78/0x134) from [<c0095128>] (fput+0x194/0x238)
[<c0095128>] (fput+0x194/0x238) from [<c0092380>] (filp_close+0x68/0x80)
[<c0092380>] (filp_close+0x68/0x80) from [<c001ab88>]
(put_files_struct+0xb4/0xd8)
[<c001ab88>] (put_files_struct+0xb4/0xd8) from [<c001ad1c>]
(do_exit+0x134/0x72c)
[<c001ad1c>] (do_exit+0x134/0x72c) from [<c001b59c>] (do_group_exit+0x40/0xac)
[<c001b59c>] (do_group_exit+0x40/0xac) from [<c001b618>]
(__wake_up_parent+0x0/0x18)
---[ end trace 3bda0ec3b276e040 ]---

client:

Linux lophilo 3.4.4+ #34 Sat Oct 6 16:28:57 CST 2012 armv5tejl GNU/Linux

server:

Linux rngadam-think 3.5.0-17-generic #28-Ubuntu SMP Tue Oct 9 19:32:08
UTC 2012 i686 i686 i686 GNU/Linux

# exportfs -v
/home/rngadam/lophilo.nfs
<world>(rw,async,wdelay,no_root_squash,no_subtree_check)
/home/rngadam/lophilo
<world>(rw,wdelay,root_squash,all_squash,no_subtree_check,anonuid=0,anongid=0)

seems to have occurred while a bunch of faiilng lstat on long paths
were going on:

stat { [Error: ENOENT, lstat
'/home/lophilo/lophilo/lmc/users/rngadam/lophilojs-example.git/client/code/colorpicker/img/colorpicker/img/colorpicker/img/colorpicker/js/colorpicker/css/colorpicker']
  errno: 34,
  code: 'ENOENT',
  path: '/home/lophilo/lophilo/lmc/users/rngadam/lophilojs-example.git/client/code/colorpicker/img/colorpicker/img/colorpicker/img/colorpicker/js/colorpicker/css/colorpicker'
}

--
伍思力 | Ricky Ng-Adam | Lophilo Ltd | http://lophilo.com | (+86)186-2126-2521
