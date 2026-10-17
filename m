Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 669EC3BBA04
	for <linux-nfs@vger.kernel.org>; Sat, 17 Oct 2026 20:28:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.198
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792268909; cv=none; b=CywxjrC4T3gnUos/DsJNHg1IQ+r4wGh22llOw/u4pOU8VqB+QtXKPLa/jG0lvkzs137enLlvWBXou+qArCbT69u05Angm/1FabDe5uHscorhsPm8rfu3LghM6RCuv7Ta6JlRki9rBEIBr451Z9JA+YTnEpn557QJ+QNbrL1xh4I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792268909; c=relaxed/simple;
	bh=hWwmmV3uV+P/bzhQqeF76PHirBaXE5WHG2aDbo/DgYs=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=PXQuuwy+zrCQuPrtJ9OfrfZoO31Keco2BJlLyeAHoxvloaWv021r2xzd/XKQ77tF2HTV5ZML++rbrXXm+/5fKuzqA671a9wqgdaNwXOnhBamr8S63ARQKwfPix3Mjy1Xg1CEC0sCT5VBC0eCIdhnSJcT7PWf6mQSGKrWNYjG72I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.167.198
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oi1-f198.google.com with SMTP id 5614622812f47-4eb0b989f0eso1850491b6e.0
        for <linux-nfs@vger.kernel.org>; Sat, 17 Oct 2026 13:28:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792268907; x=1792873707;
        h=content-type:to:from:subject:message-id:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=U8WxjB+w0mnPjNGQrRvGjmMDMeu/m1i53eRrElOUPBA=;
        b=QLFDGvpPN9FK9HURrMzLPwjg8k1k3FhsYLJIzhgqlHDgd8wgF2wvJdXsSjY6tMnrPT
         aBapEzOCn3T7TlgXK+GOSRf/i7G9qexIDS5agVv+tQ3TeU5JO8DRfM5SvdOdjPO0doul
         Xr8bZXfdAaEGauDbzHvfMqLBhIp4p6HKvqUmJ+0nvYJZd3kmjGPtK5T35yHXXxTEJhvd
         FH06QIV+O2PBKGQgVT0PaplnK2XxAvHONcxWYUpTCez8bBBvZGQpaRJ5EaDkY9brqcfl
         iFTaOx9q94weFcPpFu0R4vhBxMS8pUkkCLtdDT09BpkWBJ7NLeXORaqIlFILT/H0QHZH
         uG5Q==
X-Forwarded-Encrypted: i=1; AKwUvBzYx1qeTt1FNv5QWJjodsRWecXBSqWazbmrOgky/w5XXS41/PF3akayUBKQi5a7ay/pWPfDohknJgU=@vger.kernel.org
X-Gm-Message-State: AFq9FYJSUrpruEdlqgMl5VxTcGirmFit8Dn2rtiX81AKpHkjEbSnAeNj
	BqJdAopc2A+C7DllDqvNQHxd+nS+5Y25E4oyqPQ5T62WIb+YSkf2DaGOmSuRdZbLHiV5WksjnfD
	xRu0rZajDxpWnr+JNXIwk2HOQlM5DJTHMv53Ia3pgXq3u8Dd1aOsier32kyA=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6808:6d92:b0:4b8:4703:db93 with SMTP id
 5614622812f47-536ff59a6demr4240758b6e.28.1792268907392; Sat, 17 Oct 2026
 13:28:27 -0700 (PDT)
Date: Sat, 17 Oct 2026 13:28:27 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6ad3da6b.7f4e89eb.3d59aa.00a0.GAE@google.com>
Subject: [syzbot] [nfs?] KASAN: slab-out-of-bounds Read in nfsd
From: syzbot <syzbot+561b859d032c8bf2fb53@syzkaller.appspotmail.com>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
	syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    58161ead29e5 Merge tag 'drm-fixes-2026-10-17' of https://g..
git tree:       git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
console output: https://syzkaller.appspot.com/x/log.txt?x=12e68d99580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=b38d39c45202f4fa
dashboard link: https://syzkaller.appspot.com/bug?extid=561b859d032c8bf2fb53
compiler:       Debian clang version 22.1.8 (1~deb13u4), Debian LLD 22.1.8
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=16e68d99580000

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+561b859d032c8bf2fb53@syzkaller.appspotmail.com

==================================================================
BUG: KASAN: slab-out-of-bounds in nfsd+0x118/0xbc0 fs/nfsd/nfssvc.c:894
Read of size 8 at addr ffff88802d423f50 by task nfsd/5988

CPU: 1 UID: 0 PID: 5988 Comm: nfsd Not tainted syzkaller #0 PREEMPT_{RT,(full)} 
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 10/07/2026
Call Trace:
 <TASK>
 dump_stack_lvl+0xe8/0x150 lib/dump_stack.c:120
 print_address_description+0x55/0x1e0 mm/kasan/report.c:378
 print_report+0x58/0x70 mm/kasan/report.c:482
 kasan_report+0x117/0x150 mm/kasan/report.c:595
 nfsd+0x118/0xbc0 fs/nfsd/nfssvc.c:894
 kthread+0x38b/0x470 kernel/kthread.c:436
 ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
 ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
 </TASK>

Allocated by task 5934:
 kasan_save_stack mm/kasan/common.c:57 [inline]
 kasan_save_track+0x3e/0x80 mm/kasan/common.c:78
 poison_kmalloc_redzone mm/kasan/common.c:409 [inline]
 __kasan_kmalloc+0x93/0xb0 mm/kasan/common.c:426
 kasan_kmalloc include/linux/kasan.h:263 [inline]
 __kmalloc_cache_noprof+0x3d5/0x680 mm/slub.c:5563
 _kmalloc_noprof include/linux/slab.h:991 [inline]
 _kzalloc_noprof include/linux/slab.h:1312 [inline]
 __svc_create+0x63/0xa50 net/sunrpc/svc.c:400
 svc_create_pooled+0x8f/0x470 net/sunrpc/svc.c:501
 nfsd_create_serv+0x55f/0x840 fs/nfsd/nfssvc.c:622
 __write_ports_addfd fs/nfsd/nfsctl.c:744 [inline]
 __write_ports fs/nfsd/nfsctl.c:812 [inline]
 write_ports+0x6a2/0xd20 fs/nfsd/nfsctl.c:868
 nfsctl_transaction_write+0x112/0x160 fs/nfsd/nfsctl.c:114
 vfs_write+0x29f/0xbb0 fs/read_write.c:685
 ksys_write+0x156/0x270 fs/read_write.c:739
 do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
 do_syscall_64+0x166/0x520 arch/x86/entry/syscall_64.c:84
 entry_SYSCALL_64_after_hwframe+0x77/0x7f

The buggy address belongs to the object at ffff88802d423c00
 which belongs to the cache kmalloc-512 of size 512
The buggy address is located 376 bytes to the right of
 allocated 472-byte region [ffff88802d423c00, ffff88802d423dd8)

The buggy address belongs to the physical page:
page: refcount:0 mapcount:0 mapping:0000000000000000 index:0xffff88802d422c00 pfn:0x2d420
head: order:2 mapcount:0 entire_mapcount:0 nr_pages_mapped:0 pincount:0
flags: 0x80000000000240(workingset|head|node=0|zone=1)
page_type: f5(slab)
raw: 0080000000000240 ffff88813ffbec80 ffffea0000ffe510 ffffea0000f5cc10
raw: ffff88802d422c00 0000000000100004 00000000f5000000 0000000000000000
head: 0080000000000240 ffff88813ffbec80 ffffea0000ffe510 ffffea0000f5cc10
head: ffff88802d422c00 0000000000100004 00000000f5000000 0000000000000000
head: 0080000000000002 ffffffffffffff01 00000000ffffffff 00000000ffffffff
head: 0000000000000000 0000000000000000 00000000ffffffff 0000000000000004
page dumped because: kasan: bad access detected
page_owner tracks the page as allocated
page last allocated via order 2, migratetype Unmovable, gfp_mask 0xd20c0(__GFP_IO|__GFP_FS|__GFP_NOWARN|__GFP_NORETRY|__GFP_COMP|__GFP_NOMEMALLOC), pid 5628, tgid 5628 (syz-executor), ts 153551232384
 set_page_owner include/linux/page_owner.h:33 [inline]
 post_alloc_hook+0x1f9/0x250 mm/page_alloc.c:1871
 prep_new_page mm/page_alloc.c:1879 [inline]
 get_page_from_freelist+0x2591/0x2600 mm/page_alloc.c:3943
 __alloc_frozen_pages_noprof+0x230/0x5c0 mm/page_alloc.c:5436
 alloc_slab_page mm/slub.c:3347 [inline]
 allocate_slab+0x7d/0x620 mm/slub.c:3462
 new_slab mm/slub.c:3513 [inline]
 refill_objects+0x2d8/0x350 mm/slub.c:7418
 refill_sheaf mm/slub.c:2885 [inline]
 __pcs_replace_empty_main+0x339/0x690 mm/slub.c:4774
 alloc_from_pcs mm/slub.c:4850 [inline]
 slab_alloc_node mm/slub.c:4984 [inline]
 __do_kmalloc_node mm/slub.c:5413 [inline]
 __kmalloc_noprof+0x54b/0x790 mm/slub.c:5439
 _kmalloc_noprof include/linux/slab.h:995 [inline]
 _kzalloc_noprof include/linux/slab.h:1312 [inline]
 ops_init+0x7b/0x5d0 net/core/net_namespace.c:127
 setup_net+0x118/0x350 net/core/net_namespace.c:443
 copy_net_ns+0x53b/0x780 net/core/net_namespace.c:582
 create_new_namespaces+0x3f0/0x6b0 kernel/nsproxy.c:132
 unshare_nsproxy_namespaces+0x149/0x190 kernel/nsproxy.c:234
 ksys_unshare+0x5d8/0x970 kernel/fork.c:3307
 __do_sys_unshare kernel/fork.c:3375 [inline]
 __se_sys_unshare kernel/fork.c:3373 [inline]
 __x64_sys_unshare+0x38/0x50 kernel/fork.c:3373
 do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
 do_syscall_64+0x166/0x520 arch/x86/entry/syscall_64.c:84
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
page last free pid 5408 tgid 5408 ts 110508801022 stack trace:
 reset_page_owner include/linux/page_owner.h:26 [inline]
 __free_pages_prepare mm/page_alloc.c:1418 [inline]
 __free_frozen_pages+0xf8e/0x1070 mm/page_alloc.c:2962
 __slab_free+0x250/0x2a0 mm/slub.c:5823
 qlink_free mm/kasan/quarantine.c:163 [inline]
 qlist_free_all+0x99/0x100 mm/kasan/quarantine.c:179
 kasan_quarantine_reduce+0x148/0x160 mm/kasan/quarantine.c:286
 __kasan_slab_alloc+0x22/0x80 mm/kasan/common.c:361
 kasan_slab_alloc include/linux/kasan.h:253 [inline]
 slab_post_alloc_hook mm/slub.c:4683 [inline]
 slab_alloc_node mm/slub.c:4996 [inline]
 __do_kmalloc_node mm/slub.c:5413 [inline]
 __kmalloc_noprof+0x3b9/0x790 mm/slub.c:5439
 _kmalloc_noprof include/linux/slab.h:995 [inline]
 tomoyo_add_entry security/tomoyo/common.c:2166 [inline]
 tomoyo_supervisor+0xc53/0x1560 security/tomoyo/common.c:2238
 tomoyo_audit_env_log security/tomoyo/environ.c:37 [inline]
 tomoyo_env_perm+0x151/0x1f0 security/tomoyo/environ.c:64
 tomoyo_environ security/tomoyo/domain.c:673 [inline]
 tomoyo_find_next_domain+0x1334/0x1a90 security/tomoyo/domain.c:889
 tomoyo_bprm_check_security+0x11c/0x180 security/tomoyo/tomoyo.c:102
 security_bprm_check+0x85/0x240 security/security.c:820
 search_binary_handler fs/exec.c:1769 [inline]
 exec_binprm fs/exec.c:1811 [inline]
 bprm_execve+0x881/0x1590 fs/exec.c:1867
 do_execveat_common+0x4f4/0x670 fs/exec.c:1965
 __do_sys_execve fs/exec.c:2038 [inline]
 __se_sys_execve fs/exec.c:2032 [inline]
 __x64_sys_execve+0x97/0xc0 fs/exec.c:2032
 do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
 do_syscall_64+0x166/0x520 arch/x86/entry/syscall_64.c:84
 entry_SYSCALL_64_after_hwframe+0x77/0x7f

Memory state around the buggy address:
 ffff88802d423e00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff88802d423e80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>ffff88802d423f00: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
                                                 ^
 ffff88802d423f80: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
 ffff88802d424000: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
==================================================================


---
This report is generated by a bot. It may contain errors.
See https://goo.gl/tpsmEJ for more information about syzbot.
syzbot engineers can be reached at syzkaller@googlegroups.com.

syzbot will keep track of this issue. See:
https://goo.gl/tpsmEJ#status for how to communicate with syzbot.

If the report is already addressed, let syzbot know by replying with:
#syz fix: exact-commit-title

If you want syzbot to run the reproducer, reply with:
#syz test: git://repo/address.git branch-or-commit-hash
If you attach or paste a git patch, syzbot will apply it before testing.

If you want to overwrite report's subsystems, reply with:
#syz set subsystems: new-subsystem
(See the list of subsystem names on the web dashboard)

If the report is a duplicate of another one, reply with:
#syz dup: exact-subject-of-another-report

If you want to undo deduplication, reply with:
#syz undup
