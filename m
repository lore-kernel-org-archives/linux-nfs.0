Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DABB03F106D
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 05:53:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.199
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791525206; cv=none; b=goj1NY54ZixxYTj3fy9w9xFpDZiT3zzodewYdm/R2zoy1Y/HBZOO1gsU+MDgMqjJSmOobr8bN9IUlNBhhyK5rPGJkWSpYcQU2cNobpZZltCra+hAk4fvNNEF7QDlxY3Ft8XLM4iE/mdv60QHZDw4jUJGjRooExp1xuFzoaIwRhs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791525206; c=relaxed/simple;
	bh=io/4IKNtEDA2/qvWB2ZPzzWfvdGJiZfVEQAOr1a159c=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=qQSienTr3I622a5xvisROlLId9lvExfPT7UoS7y23o2ZSKGfHxBFSF4A2NVlJF9eXOKO75RleuntdFJXvRdP7WvjCIpExdaapv+tK2g+5MZ/giBY8lGXPWkafKitVF9u/i40rZYvMgGFRaBgS3/4awF5OVbqoUBeQxr0rshDsnE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.167.199
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oi1-f199.google.com with SMTP id 5614622812f47-4ea2c058e67so8868959b6e.1
        for <linux-nfs@vger.kernel.org>; Thu, 08 Oct 2026 22:53:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791525204; x=1792130004;
        h=content-type:to:from:subject:message-id:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=kKKvmFfZwsqrfM3PYHPrEGRSmIXlY77Q19PAO1JkExw=;
        b=oDVIGqeIYoFUKK3cuBA0O/0tGmAw8dnhpPQmP+jUrwGYzzF32uNiORajmy21aVCkDM
         jedZd61x30BrJMloi2MjbXj/TSQwcXiIiRNvMFp2xj3dFL7lm3KRycoZBXlIvJrk85Um
         8O+l7tgRm7dzBCb4YDpyBo9Bz/AhPySB3hnINm7vkay74l5tvTGyU/EJ+P3e+3SCDAJI
         7NIRsibpwBv304OajePElHkj5abyVleNBjvYpuAedo/Fcozn4KHloInjr7cjB9Jdy9SW
         IVC3rWPAq5apDFKKXh/Ee/XayWQp9q+KKnnsemUCQsZIKxjN4ONi0AcBc5SDe2VSuhlQ
         fv/g==
X-Forwarded-Encrypted: i=1; AKwUvBz3geNLX8MeIL5jOvYxFD3HxDpXvRCIuUDzVPF7D/dR9S0cB8x6I5vcSIDwIIGhXn0qsdsdlU2HzSE=@vger.kernel.org
X-Gm-Message-State: AFuF++nmBCIHJIO5Kjp4lj4NJdjHx1bJ4Iota5coUIKg/KHBDp86xFf7
	MWnx2Vv5peClJ8fRYnieIvdnvDBBPwFkwHnla06s/TWGACEnf8xB6Uf9j8+9yY4YZifBlD0DdEY
	OnT7cBBpzJfEp2ayRAdfJklw11RZP3RRwf3FKl6yROtqEMgCBpWJT38pfH84=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6808:50a2:b0:4e8:bce4:9924 with SMTP id
 5614622812f47-50c53c99978mr811082b6e.25.1791525203840; Thu, 08 Oct 2026
 22:53:23 -0700 (PDT)
Date: Thu, 08 Oct 2026 22:53:23 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6ac88153.bbc4c7f9.15faa7.000d.GAE@google.com>
Subject: [syzbot] [nfs?] KASAN: slab-use-after-free Read in add_to_unconfirmed
From: syzbot <syzbot+9c7b9c5f6dd1d470b605@syzkaller.appspotmail.com>
To: Dai.Ngo@oracle.com, cel@kernel.org, jlayton@kernel.org, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, neil@brown.name, 
	okorniev@redhat.com, syzkaller-bugs@googlegroups.com, tom@talpey.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    6addb4f38557 Merge tag 'edac_urgent_for_v7.3_rc6' of git:/..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=113b17f5580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=23e5acac5c98285f
dashboard link: https://syzkaller.appspot.com/bug?extid=9c7b9c5f6dd1d470b605
compiler:       Debian clang version 22.1.8 (++20260613092233+e80beda6e255-1~exp1~20260613092250.77), Debian LLD 22.1.8

Unfortunately, I don't have any reproducer for this issue yet.

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/484fafd2304b/disk-6addb4f3.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/3a897e82997f/vmlinux-6addb4f3.xz
kernel image: https://storage.googleapis.com/syzbot-assets/57fc9f6de4c3/bzImage-6addb4f3.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+9c7b9c5f6dd1d470b605@syzkaller.appspotmail.com

==================================================================
BUG: KASAN: slab-use-after-free in list_add include/linux/list.h:192 [inline]
BUG: KASAN: slab-use-after-free in add_to_unconfirmed+0x367/0x8c0 fs/nfsd/nfs4state.c:3993
Read of size 8 at addr ffff888076b91860 by task nfsd/7883

CPU: 0 UID: 0 PID: 7883 Comm: nfsd Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 08/26/2026
Call Trace:
 <TASK>
 dump_stack_lvl+0xe8/0x150 lib/dump_stack.c:120
 print_address_description+0x55/0x1e0 mm/kasan/report.c:378
 print_report+0x58/0x70 mm/kasan/report.c:482
 kasan_report+0x117/0x150 mm/kasan/report.c:595
 list_add include/linux/list.h:192 [inline]
 add_to_unconfirmed+0x367/0x8c0 fs/nfsd/nfs4state.c:3993
 nfsd4_exchange_id+0xc21/0x1350 fs/nfsd/nfs4state.c:4407
 nfsd4_proc_compound+0x145a/0x25b0 fs/nfsd/nfs4proc.c:3313
 nfsd_dispatch+0x33d/0x9b0 fs/nfsd/nfssvc.c:1038
 svc_process_common+0x1173/0x18c0 net/sunrpc/svc.c:1527
 svc_process+0x290/0x710 net/sunrpc/svc.c:1682
 svc_handle_xprt net/sunrpc/svc_xprt.c:886 [inline]
 svc_recv+0x2525/0x3280 net/sunrpc/svc_xprt.c:968
 nfsd+0x3a5/0xbb0 fs/nfsd/nfssvc.c:919
 kthread+0x38b/0x480 kernel/kthread.c:436
 ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
 ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
 </TASK>

Allocated by task 7644:
 kasan_save_stack mm/kasan/common.c:57 [inline]
 kasan_save_track+0x3e/0x80 mm/kasan/common.c:78
 poison_kmalloc_redzone mm/kasan/common.c:409 [inline]
 __kasan_kmalloc+0x93/0xb0 mm/kasan/common.c:426
 kasan_kmalloc include/linux/kasan.h:263 [inline]
 __kmalloc_cache_noprof+0x321/0x600 mm/slub.c:5563
 _kmalloc_noprof include/linux/slab.h:991 [inline]
 nfs4_state_create_net fs/nfsd/nfs4state.c:9736 [inline]
 nfs4_state_start_net+0x10c/0x1180 fs/nfsd/nfs4state.c:9834
 nfsd_startup_net fs/nfsd/nfssvc.c:391 [inline]
 nfsd_svc+0x481/0x710 fs/nfsd/nfssvc.c:775
 write_threads+0x434/0x610 fs/nfsd/nfsctl.c:438
 nfsctl_transaction_write+0x10f/0x160 fs/nfsd/nfsctl.c:114
 vfs_write+0x296/0xba0 fs/read_write.c:685
 ksys_write+0x150/0x270 fs/read_write.c:739
 do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
 do_syscall_64+0x166/0x520 arch/x86/entry/syscall_64.c:84
 entry_SYSCALL_64_after_hwframe+0x77/0x7f

Freed by task 6123:
 kasan_save_stack mm/kasan/common.c:57 [inline]
 kasan_save_track+0x3e/0x80 mm/kasan/common.c:78
 kasan_save_free_info+0x40/0x50 mm/kasan/generic.c:584
 poison_slab_object mm/kasan/common.c:264 [inline]
 __kasan_slab_free+0x5c/0x80 mm/kasan/common.c:296
 kasan_slab_free include/linux/kasan.h:235 [inline]
 slab_free_hook mm/slub.c:2748 [inline]
 slab_free mm/slub.c:6509 [inline]
 kfree+0x1c5/0x650 mm/slub.c:6802
 nfs4_state_destroy_net fs/nfsd/nfs4state.c:9823 [inline]
 nfs4_state_shutdown_net+0x774/0xa00 fs/nfsd/nfs4state.c:9908
 nfsd_shutdown_net fs/nfsd/nfssvc.c:421 [inline]
 nfsd_destroy_serv+0x25d/0x450 fs/nfsd/nfssvc.c:534
 nfsd_shutdown_threads+0x8c/0xd0 fs/nfsd/nfssvc.c:591
 nfsd_umount+0x41/0x60 fs/nfsd/nfsctl.c:1372
 deactivate_locked_super+0xbe/0x110 fs/super.c:586
 cleanup_mnt+0x3d3/0x460 fs/namespace.c:1317
 task_work_run+0x1d9/0x270 kernel/task_work.c:233
 resume_user_mode_work include/linux/resume_user_mode.h:50 [inline]
 __exit_to_user_mode_loop kernel/entry/common.c:70 [inline]
 exit_to_user_mode_loop+0x204/0x770 kernel/entry/common.c:101
 __exit_to_user_mode_prepare include/linux/irq-entry-common.h:207 [inline]
 syscall_exit_to_user_mode_prepare include/linux/irq-entry-common.h:230 [inline]
 syscall_exit_to_user_mode include/linux/entry-common.h:343 [inline]
 do_syscall_64+0x328/0x520 arch/x86/entry/syscall_64.c:89
 entry_SYSCALL_64_after_hwframe+0x77/0x7f

The buggy address belongs to the object at ffff888076b91800
 which belongs to the cache kmalloc-256 of size 256
The buggy address is located 96 bytes inside of
 freed 256-byte region [ffff888076b91800, ffff888076b91900)

The buggy address belongs to the physical page:
page: refcount:0 mapcount:0 mapping:0000000000000000 index:0xffff888076b90000 pfn:0x76b90
head: order:1 mapcount:0 entire_mapcount:0 nr_pages_mapped:0 pincount:0
flags: 0xfff00000000240(workingset|head|node=0|zone=1|lastcpupid=0x7ff)
page_type: f5(slab)
raw: 00fff00000000240 ffff88801b041b40 ffffea0001e86410 ffffea00014c3b90
raw: ffff888076b90000 000000000010000a 00000000f5000000 0000000000000000
head: 00fff00000000240 ffff88801b041b40 ffffea0001e86410 ffffea00014c3b90
head: ffff888076b90000 000000000010000a 00000000f5000000 0000000000000000
head: 00fff00000000001 ffffffffffffff81 00000000ffffffff 00000000ffffffff
head: ffffffffffffffff 0000000000000000 00000000ffffffff 0000000000000002
page dumped because: kasan: bad access detected
page_owner tracks the page as allocated
page last allocated via order 1, migratetype Unmovable, gfp_mask 0xd20c0(__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC), pid 5615, tgid 5615 (syz-executor), ts 88616580147
 set_page_owner include/linux/page_owner.h:33 [inline]
 post_alloc_hook+0x1f9/0x250 mm/page_alloc.c:1871
 prep_new_page mm/page_alloc.c:1879 [inline]
 get_page_from_freelist+0x2209/0x2280 mm/page_alloc.c:3943
 __alloc_frozen_pages_noprof+0x217/0x5a0 mm/page_alloc.c:5436
 alloc_slab_page mm/slub.c:3347 [inline]
 allocate_slab+0x7d/0x620 mm/slub.c:3462
 new_slab mm/slub.c:3513 [inline]
 refill_objects+0x2d5/0x350 mm/slub.c:7418
 refill_sheaf mm/slub.c:2885 [inline]
 __pcs_replace_empty_main+0x2c8/0x6c0 mm/slub.c:4774
 alloc_from_pcs mm/slub.c:4850 [inline]
 slab_alloc_node mm/slub.c:4984 [inline]
 __do_kmalloc_node mm/slub.c:5413 [inline]
 __kmalloc_noprof+0x47b/0x720 mm/slub.c:5439
 _kmalloc_noprof include/linux/slab.h:995 [inline]
 _kzalloc_noprof include/linux/slab.h:1312 [inline]
 new_dir fs/proc/proc_sysctl.c:965 [inline]
 get_subdir fs/proc/proc_sysctl.c:1009 [inline]
 sysctl_mkdir_p fs/proc/proc_sysctl.c:1319 [inline]
 __register_sysctl_table+0xc02/0x1370 fs/proc/proc_sysctl.c:1394
 neigh_sysctl_register+0x9b1/0xa90 net/core/neighbour.c:3932
 devinet_sysctl_register+0xad/0x200 net/ipv4/devinet.c:2782
 inetdev_init+0x29e/0x4d0 net/ipv4/devinet.c:291
 inetdev_event+0x307/0x15e0 net/ipv4/devinet.c:1590
 notifier_call_chain+0x1a5/0x3d0 kernel/notifier.c:85
 call_netdevice_notifiers_extack net/core/dev.c:2313 [inline]
 call_netdevice_notifiers net/core/dev.c:2327 [inline]
 register_netdevice+0x18a4/0x1eb0 net/core/dev.c:11584
 macvlan_common_newlink+0x12e5/0x1a50 drivers/net/macvlan.c:1575
 rtnl_newlink_create+0x305/0x7b0 net/core/rtnetlink.c:3974
page last free pid 5615 tgid 5615 ts 88569600911 stack trace:
 reset_page_owner include/linux/page_owner.h:26 [inline]
 __free_pages_prepare mm/page_alloc.c:1418 [inline]
 __free_frozen_pages+0xc93/0xd90 mm/page_alloc.c:2962
 __slab_free+0x274/0x2c0 mm/slub.c:5823
 qlink_free mm/kasan/quarantine.c:163 [inline]
 qlist_free_all+0x99/0x100 mm/kasan/quarantine.c:179
 kasan_quarantine_reduce+0x148/0x160 mm/kasan/quarantine.c:286
 __kasan_slab_alloc+0x22/0x80 mm/kasan/common.c:361
 kasan_slab_alloc include/linux/kasan.h:253 [inline]
 slab_post_alloc_hook mm/slub.c:4683 [inline]
 slab_alloc_node mm/slub.c:4996 [inline]
 kmem_cache_alloc_node_noprof+0x354/0x610 mm/slub.c:5068
 __alloc_skb+0x1db/0x7a0 net/core/skbuff.c:704
 alloc_skb include/linux/skbuff.h:1384 [inline]
 nlmsg_new include/net/netlink.h:1055 [inline]
 netlink_ack+0x136/0xb30 net/netlink/af_netlink.c:2512
 netlink_rcv_skb+0x2a4/0x4a0 net/netlink/af_netlink.c:2581
 netlink_unicast_kernel net/netlink/af_netlink.c:1338 [inline]
 netlink_unicast+0x7bd/0x940 net/netlink/af_netlink.c:1364
 netlink_sendmsg+0x813/0xb40 net/netlink/af_netlink.c:1919
 sock_sendmsg_nosec+0x13a/0x180 net/socket.c:800
 __sock_sendmsg net/socket.c:815 [inline]
 __sys_sendto+0x408/0x5a0 net/socket.c:2281
 __do_sys_sendto net/socket.c:2288 [inline]
 __se_sys_sendto net/socket.c:2284 [inline]
 __x64_sys_sendto+0xde/0x100 net/socket.c:2284
 do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
 do_syscall_64+0x166/0x520 arch/x86/entry/syscall_64.c:84
 entry_SYSCALL_64_after_hwframe+0x77/0x7f

Memory state around the buggy address:
 ffff888076b91700: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff888076b91780: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>ffff888076b91800: fa fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                                       ^
 ffff888076b91880: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff888076b91900: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
==================================================================


---
This report is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this issue. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.

If the report is already addressed, let syzbot know by replying with:
#syz fix: exact-commit-title

If you want to overwrite report's subsystems, reply with:
#syz set subsystems: new-subsystem
(See the list of subsystem names on the web dashboard)

If the report is a duplicate of another one, reply with:
#syz dup: exact-subject-of-another-report

If you want to undo deduplication, reply with:
#syz undup
