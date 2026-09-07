Received: from mail-oo1-f71.google.com (mail-oo1-f71.google.com [209.85.161.71])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8514551356A
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 17:44:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.71
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788803082; cv=none; b=CzUYREqI04ezaJyZl9EAV6vEEmczhDw72P+8lTZZ9MpUvul+hbfP8mJz8FsDn0VDdJOeRIW8yn2UcpnSHV4w5XLW9pUUtMYk2QXgGL5+cdQblW5UmPNaVXZp+Y7OdBZoO+lzJTfGPWybHcrnNTUlwahDfxNExpqxbrQ/ugFKWXU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788803082; c=relaxed/simple;
	bh=dwXjejFJv5tlGv0J9+LLUDtwO8cNaUkpx0laAJuUUYQ=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=Z/xGVQSSGV5+xFBZ/XFi4zw+l0vp9XUCI6R2P2pC8kivOrGBPK0mP6WT0EEVQGfI041BBnwDS8ecCQPCO1eAIazDEmjfts2BfspZ0WHZvhtrEoTbIJ+8ZK6WOuqhMEK3xtQwoKzp5yn22n9Ai5u37z4WGNtdVEymI/DiOib0ep8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.161.71
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oo1-f71.google.com with SMTP id 006d021491bc7-6b361b477f1so2184755eaf.2
        for <linux-nfs@vger.kernel.org>; Mon, 07 Sep 2026 10:44:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788803079; x=1789407879;
        h=content-type:to:from:subject:message-id:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=2sjhS0G73w55DIgrkwQ0bKZaVvOoELn/wH46qXVmfI8=;
        b=scuP5OecXAZ9jEiDLtaQfsoC0VJB342CgWSWoXWjSDL1eB6DO7zVUNEFXgyDw6BOhq
         6MBnQNynnuF5fZzuQbwuotxwpbHTBXbt1Jxa4eAD4IoUGPVwU4tw6ojvhPiTIhaTwZJF
         ehUBW+BPZvwftppFS+D9iBNIG6q6kpTNrx0bs8cpErXWLWxvPlhg9X+e9+ou5BOqCSUE
         nGnPeJFAw1kbEQe9b+F+vy08v/sN50RVo8hXKHDrNMG445jHw4ew0pTnyvz0j9HibAwE
         1WnIhk4y5D4Y4v7oRI3KuYetzy3D/zqBC2jStKEWMNCMa+lb+SGi971Oy/Tb4vo440KH
         shPA==
X-Forwarded-Encrypted: i=1; AKwUvBxerhWTzlQDb5eoRKt+Kx+qKvh2m+qAWUkFcQ/KNShm9FpQmtGjfFvtoJdIzSPRNvUqYrAO1huo0wg=@vger.kernel.org
X-Gm-Message-State: AFuF++kr+jN0axbNUIoYUQ9XyNRduCErQLwnApxphNP6qcEMCXcsNgY9
	oOjLP9bZW8FT78ORNGXBvmi85VDdvML9PJbgbB5rE3oBSCLTHIjvH1vappVyODRccIB4PFXL+1W
	f1cdQu3RJ1IHjtjoSEy/JxzfS9S8NjD6AbdIRHuXBJAeYzWqXT6fTOLZTvts=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6820:218:b0:6b7:46e9:9703 with SMTP id
 006d021491bc7-6b746e9a293mr11894807eaf.51.1788803079355; Mon, 07 Sep 2026
 10:44:39 -0700 (PDT)
Date: Mon, 07 Sep 2026 10:44:39 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6a9ef807.2bb5a69c.24b23c.0007.GAE@google.com>
Subject: [syzbot] [nfs?] [net?] KASAN: vmalloc-out-of-bounds Read in rpc_queue_upcall
From: syzbot <syzbot+d5c77cabf7a3492aa650@syzkaller.appspotmail.com>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
	netdev@vger.kernel.org, syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    df2908090cda Linux 7.3-rc2
git tree:       git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
console output: https://syzkaller.appspot.com/x/log.txt?x=1416cc8e580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=8c5c3949d762a91f
dashboard link: https://syzkaller.appspot.com/bug?extid=d5c77cabf7a3492aa650
compiler:       gcc (Debian 14.2.0-19) 14.2.0, GNU ld (GNU Binutils for Debian) 2.44
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=14daa071580000

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+d5c77cabf7a3492aa650@syzkaller.appspotmail.com

 vmalloc memory
list_add corruption. prev->next should be next (ffff8880358a6c00), but was 0000000000000000. (prev=ffffc90003cbfa10).
------------[ cut here ]------------
kernel BUG at lib/list_debug.c:32!
Oops: invalid opcode: 0000 [#1] SMP KASAN NOPTI
CPU: 2 UID: 0 PID: 5997 Comm: syz-executor965 Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS 1.16.3-debian-1.16.3-2 04/01/2014
RIP: 0010:__list_add_valid_or_report+0xfb/0x130 lib/list_debug.c:32
Code: b8 00 00 00 00 00 fc ff df 48 c1 ea 03 80 3c 02 00 75 3d 49 8b 55 00 4c 89 e9 48 89 de 48 c7 c7 c0 12 62 8c e8 d6 35 ee fb 90 <0f> 0b 4c 89 e7 e8 bb 38 4b fd e9 3a ff ff ff 4c 89 ef e8 ae 38 4b
RSP: 0018:ffffc90003cbf938 EFLAGS: 00010282
RAX: 0000000000000075 RBX: ffff8880358a6c00 RCX: 0000000000000000
RDX: 0000000000000075 RSI: ffffffff81ea06f9 RDI: fffff52000797f18
RBP: ffffc90003cbfa10 R08: 0000000000000007 R09: 0000000000000000
R10: 8000000000000001 R11: 0000000000000001 R12: ffff8880358a6c08
R13: ffffc90003cbfa10 R14: ffff8880358a6c08 R15: ffffc90003cbfa10
FS:  00007f6eeac506c0(0000) GS:ffff8880d5d5d000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fbbfc3d4000 CR3: 0000000026a53000 CR4: 0000000000352ef0
Call Trace:
 <TASK>
 __list_add_valid include/linux/list.h:104 [inline]
 __list_add include/linux/list.h:169 [inline]
 list_add_tail include/linux/list.h:206 [inline]
 rpc_queue_upcall+0x2ff/0x530 net/sunrpc/rpc_pipe.c:142
 __cld_pipe_upcall fs/nfsd/nfs4recover.c:668 [inline]
 cld_pipe_upcall fs/nfsd/nfs4recover.c:691 [inline]
 nfsd4_cld_grace_start fs/nfsd/nfs4recover.c:1305 [inline]
 nfsd4_cld_tracking_init+0x85a/0x10f0 fs/nfsd/nfs4recover.c:1494
 nfsd4_client_tracking_init+0xe5/0x1c0 fs/nfsd/nfs4recover.c:1941
 nfs4_state_start_net.cold+0xb7/0x480 fs/nfsd/nfs4state.c:9838
 nfsd_startup_net fs/nfsd/nfssvc.c:391 [inline]
 nfsd_svc+0x54a/0x7d0 fs/nfsd/nfssvc.c:775
 write_threads+0x316/0x600 fs/nfsd/nfsctl.c:438
 nfsctl_transaction_write+0x106/0x1a0 fs/nfsd/nfsctl.c:114
 vfs_write+0x2aa/0x1050 fs/read_write.c:685
 ksys_write+0x12a/0x250 fs/read_write.c:739
 do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
 do_syscall_64+0x123/0x790 arch/x86/entry/syscall_64.c:84
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f6eeaca601e
Code: 08 0f 85 f5 e2 ff ff 49 89 fb 48 89 f0 48 89 d7 48 89 ce 4c 89 c2 4d 89 ca 4c 8b 44 24 08 4c 8b 4c 24 10 4c 89 5c 24 08 0f 05 <c3> 90 41 57 41 56 4d 89 c6 41 55 4d 89 cd 41 54 55 53 48 83 ec 08
RSP: 002b:00007f6eeac501a8 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 00007f6eeac506c0 RCX: 00007f6eeaca601e
RDX: 0000000000000002 RSI: 00007f6eeacf10e4 RDI: 0000000000000003
RBP: 0000000000000021 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: ffffffffffffffd0
R13: 0000000000000000 R14: 00007ffe260d9b80 R15: 00007ffe260d9c68
 </TASK>
Modules linked in:
---[ end trace 0000000000000000 ]---
RIP: 0010:__list_add_valid_or_report+0xfb/0x130 lib/list_debug.c:32
Code: b8 00 00 00 00 00 fc ff df 48 c1 ea 03 80 3c 02 00 75 3d 49 8b 55 00 4c 89 e9 48 89 de 48 c7 c7 c0 12 62 8c e8 d6 35 ee fb 90 <0f> 0b 4c 89 e7 e8 bb 38 4b fd e9 3a ff ff ff 4c 89 ef e8 ae 38 4b
RSP: 0018:ffffc90003cbf938 EFLAGS: 00010282
RAX: 0000000000000075 RBX: ffff8880358a6c00 RCX: 0000000000000000
RDX: 0000000000000075 RSI: ffffffff81ea06f9 RDI: fffff52000797f18
RBP: ffffc90003cbfa10 R08: 0000000000000007 R09: 0000000000000000
R10: 8000000000000001 R11: 0000000000000001 R12: ffff8880358a6c08
R13: ffffc90003cbfa10 R14: ffff8880358a6c08 R15: ffffc90003cbfa10
FS:  00007f6eeac506c0(0000) GS:ffff8880d5d5d000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fbbfc3d4000 CR3: 0000000026a53000 CR4: 0000000000352ef0


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
