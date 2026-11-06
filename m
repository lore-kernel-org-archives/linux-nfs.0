Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.167.200
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793988550;
	b=vZjefur5AhGGycH2slzkFt2mHxND9LEhzk0op6Cp6/hrY1LZKIdHW0+STlW6eCOwVSUJ
	 NZ5lzh8y2p3nH49d2sYaahFc7xbhstUVepN8p2FX3awo0+3WTGTB5FZWXU8Kgv326KlGR
	 +sUDmJQS5/EN7qaavq1vGFQ2Z1i7dwnsG+3y8lL6U4SCEpS4Uf7bvQz6saN6WyIOYliNd
	 AGzNFEV79VYcK8ZRIeZ06P7ctYzQmbmCDzaaLtl1RQTnV90G3V9o5we2fq7UMLdhkmVCe
	 th9xrplKC7OOmfufpvgbzWy+tRRXWnCbDYeEfpmJPQ2O/kZMnlnVvZ2WtSJGFmYe9AA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793988550;
	h=DMARC-Filter:Received:X-Google-DKIM-Signature:X-Forwarded-Encrypted:
	 X-Gm-Message-State:MIME-Version:X-Received:Date:
	 X-Google-Appengine-App-Id:X-Google-Appengine-App-Id-Alias:Message-ID:
	 Subject:From:To:Content-Type;
	bh=tHsWuUqZawgO/+5zHIysVA31VVEjDt03dHJYlp7sVuw=;
	b=0TKcX1kJyMlmAzD0kHbFmkkBhEx5wu4EdZ22IcUwmO/wHfDp9zDhvLjdN9p6fdAl5l2x
	 5Lf5CRohZHzZrZWxN9NOcDxerB1fcKPtMxFVeqeL+oExMKFNR4EEcazZKPFvDhkzBTxBz
	 OBZ+cO/EwuGq6Xn+pfgH9Kq7ODer8SWw5cKU9654q/N3dEsAHJPd/EphTkV45oPnJHTha
	 b+/X4WyMgFVxbiej11F2aXL8on9lbtm8SfSdWP7a+eaT4MHQwTeBrpVco2eQ9Kf5ovemJ
	 lykm9Tt3ISvVoZpsNLxBlm9D7gbu3vmfqtYGPeFl93olKexJiFsPaBjxBn7PKkrZMZA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=fail header.from=syzkaller.appspotmail.com;
	spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
	arc=none smtp.remote-ip=209.85.167.200
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB0D5606A32C
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 18:09:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AB0D5606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oi1-f200.google.com with SMTP id 5614622812f47-4ab4f652f9bso632103b6e.0
        for <linux-nfs@vger.kernel.org>; Fri, 06 Nov 2026 10:09:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793988548; x=1794593348;
        h=content-type:to:from:subject:message-id:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=tHsWuUqZawgO/+5zHIysVA31VVEjDt03dHJYlp7sVuw=;
        b=DPqLYDCqIJjrVHbm7NPORATNil4VdPV8zDuXmBHWrliUX06sadPqi7RSU50gbXcrVz
         AhFplHt8dJZh3fVdCpRdyaF6SAAtdVMJM/hZk5ty4+vC0poPEp9yIWk4o3D5UCdYHO+C
         bwLSV2mRvjSqouf7M6pQGHSnseotHH8kWdob62bhfxood0epPZPOP6lLASodiuIvtbYE
         H50KGEy6jgjW4XFoiCz3aSCNjLN1l8/VSIVTOvhtNTqOqKuFVa3ZNWvXvaKRkwHXbFUA
         O9IpyMABMJn0YkLNMKXQSIUOHIdxQwkvQedFGngAOAmhBLJxg4Fp0J6M+QcSQIJGQzaP
         SvyA==
X-Forwarded-Encrypted: i=1; AKwUvBz9y75jqMxVbZPiT/z9xUDAuQojlHMokJI6Qq6/7DJCavhke/JlD5IRp9nADy3UF2DlbeopD0+0/Jo=@vger.kernel.org
X-Gm-Message-State: APuU4Z+DzblcnMx13i5i5Aaf+RniyEWvImnytwJDkLqsgwl/EM5dr1jr
	nIv/cCNT8ykU964FSE/qvJbKbv+abkNvReWQJ+5jzfNHJNvzGKGsizenpyzjCtMpru5EJGFuR3G
	gs1vF1m0HKlJxOP9LgPdIhNFXTEzk7RLmwr2wbDZzbe1zrWfLE/OPbrqlWh4=
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-Received: by 2002:a05:6808:c298:b0:55b:f8c9:298e with SMTP id
 5614622812f47-567e1047884mr2818860b6e.25.1793988548779; Fri, 06 Nov 2026
 10:09:08 -0800 (PST)
Date: Fri, 06 Nov 2026 10:09:08 -0800
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6aee17c4.8be4ead1.3b45e1.0199.GAE@google.com>
Subject: [syzbot] [net?] [nfs?] WARNING in svc_destroy
From: syzbot <syzbot+8cbdf9aa6c281a4e6bbe@syzkaller.appspotmail.com>
To: Dai.Ngo@oracle.com, anna@kernel.org, cel@kernel.org, davem@davemloft.net, 
	edumazet@kernel.org, horms@kernel.org, jlayton@kernel.org, kuba@kernel.org, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, neil@brown.name, 
	netdev@vger.kernel.org, okorniev@redhat.com, pabeni@redhat.com, 
	syzkaller-bugs@googlegroups.com, tom@talpey.com, trondmy@kernel.org
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    05441d697f7f Merge tag 'cocci-7.4-rc1' of git://git.kernel..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=14721d2d580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=1cf189394a856f11
dashboard link: https://syzkaller.appspot.com/bug?extid=8cbdf9aa6c281a4e6bbe
compiler:       gcc (Debian 14.2.0-19) 14.2.0, GNU ld (GNU Binutils for Debian) 2.44

Unfortunately, I don't have any reproducer for this issue yet.

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/e8f55ecc1d55/disk-05441d69.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/db66972c51fd/vmlinux-05441d69.xz
kernel image: https://storage.googleapis.com/syzbot-assets/6628bc03aa4a/bzImage-05441d69.xz

AI-generated root cause summary:
In fs/nfs/callback.c, nfs4_callback_up_net() first initializes an IPv4 TCP
listener transport via svc_xprt_create(..., PF_INET, ...), which links the
transport onto serv->sv_permsocks. When a subsequent call to
svc_xprt_create(..., PF_INET6, ...) fails with an error other than
-EAFNOSUPPORT, nfs4_callback_up_net() returns the error immediately without
tearing down the existing IPv4 transport. As a result, nfs_callback_up() unwinds
on error and calls xprt_svc_destroy_nullify_bc() -> svc_destroy(), which
triggers the WARN_ONCE(!list_empty(&serv->sv_permsocks)) warning because the
IPv4 transport is still attached to the service, and subsequently frees the
service while leaving the active listener with a dangling pointer.

full analysis:  https://syzkaller.appspot.com/x/ai_root_cause?x=8cbdf9aa6c281a4e6bbe

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+8cbdf9aa6c281a4e6bbe@syzkaller.appspotmail.com

NFS: callback service start failed
------------[ cut here ]------------
SVC: permsocks remain for NFSv4 callback
WARNING: net/sunrpc/svc.c:532 at svc_destroy+0x299/0x330 net/sunrpc/svc.c:532, CPU#1: syz.2.321/6994
Modules linked in:
CPU: 1 UID: 0 PID: 6994 Comm: syz.2.321 Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 10/15/2026
RIP: 0010:svc_destroy+0x29d/0x330 net/sunrpc/svc.c:532
Code: 48 b8 00 00 00 00 00 fc ff df 49 8b 5d 00 48 8d 7b 18 48 89 fa 48 c1 ea 03 80 3c 02 00 75 67 48 8d 3d 17 5e 78 07 48 8b 73 18 <67> 48 0f b9 3a e9 d0 fd ff ff 48 8b 7c 24 08 e8 bf 13 86 f7 e9 a5
RSP: 0018:ffffc900042af860 EFLAGS: 00010246
RAX: dffffc0000000000 RBX: ffffffff9040ba80 RCX: ffffc900063d9000
RDX: 1ffffffff2081753 RSI: ffffffff8c37e800 RDI: ffffffff927aee30
RBP: 0000000000000000 R08: 00000000ffffffff R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000000 R12: ffff888035744000
R13: ffff888055f04c00 R14: ffff88802de30000 R15: ffffffff9cd5b540
FS:  00007ff81118f6c0(0000) GS:ffff88812257c000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000110c29af61 CR3: 0000000056a04000 CR4: 00000000003526f0
Call Trace:
 <TASK>
 nfs_callback_up+0x511/0xad0 fs/nfs/callback.c:236
 nfs4_init_callback fs/nfs/nfs4client.c:327 [inline]
 nfs4_init_client_minor_version fs/nfs/nfs4client.c:379 [inline]
 nfs4_init_client+0x236/0x420 fs/nfs/nfs4client.c:429
 nfs_get_client+0xf38/0x1230 fs/nfs/client.c:467
 nfs4_set_client+0x3f6/0x640 fs/nfs/nfs4client.c:763
 nfs4_init_server.isra.0+0x5be/0xf80 fs/nfs/nfs4client.c:1014
 nfs4_create_server+0x185/0x2b0 fs/nfs/nfs4client.c:1063
 nfs4_try_get_tree+0x93/0x140 fs/nfs/nfs4super.c:228
 nfs_get_tree+0xa61/0x1440 fs/nfs/fs_context.c:1621
 vfs_get_tree+0x92/0x320 fs/super.c:1881
 fc_mount fs/namespace.c:1282 [inline]
 do_new_mount_fc fs/namespace.c:3910 [inline]
 do_new_mount fs/namespace.c:3986 [inline]
 path_mount+0x7d0/0x2850 fs/namespace.c:4337
 do_mount fs/namespace.c:4350 [inline]
 __do_sys_mount fs/namespace.c:4565 [inline]
 __se_sys_mount fs/namespace.c:4542 [inline]
 __x64_sys_mount+0x293/0x310 fs/namespace.c:4542
 do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
 do_syscall_64+0x123/0x790 arch/x86/entry/syscall_64.c:84
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7ff81039fb19
Code: ff c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 c7 c1 e8 ff ff ff f7 d8 64 89 01 48
RSP: 002b:00007ff81118f028 EFLAGS: 00000246 ORIG_RAX: 00000000000000a5
RAX: ffffffffffffffda RBX: 00007ff810625fa0 RCX: 00007ff81039fb19
RDX: 0000200000000480 RSI: 0000200000000440 RDI: 0000200000000400
RBP: 00007ff810437b70 R08: 00002000000004c0 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007ff810626038 R14: 00007ff810625fa0 R15: 00007ffd2a563db8
 </TASK>
----------------
Code disassembly (best guess):
   0:	48 b8 00 00 00 00 00 	movabs $0xdffffc0000000000,%rax
   7:	fc ff df
   a:	49 8b 5d 00          	mov    0x0(%r13),%rbx
   e:	48 8d 7b 18          	lea    0x18(%rbx),%rdi
  12:	48 89 fa             	mov    %rdi,%rdx
  15:	48 c1 ea 03          	shr    $0x3,%rdx
  19:	80 3c 02 00          	cmpb   $0x0,(%rdx,%rax,1)
  1d:	75 67                	jne    0x86
  1f:	48 8d 3d 17 5e 78 07 	lea    0x7785e17(%rip),%rdi        # 0x7785e3d
  26:	48 8b 73 18          	mov    0x18(%rbx),%rsi
* 2a:	67 48 0f b9 3a       	ud1    (%edx),%rdi <-- trapping instruction
  2f:	e9 d0 fd ff ff       	jmp    0xfffffe04
  34:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
  39:	e8 bf 13 86 f7       	call   0xf78613fd
  3e:	e9                   	.byte 0xe9
  3f:	a5                   	movsl  %ds:(%rsi),%es:(%rdi)


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
