Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.70
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794117149;
	b=NPTCzfwdGRfgIAleF0Iw21cyU3LNMF+mS6fECBwdpsOdweEJNwrJ5VL0D6G1FExO3so7
	 N+HhiVKKvFowqEFWkAo2e43RdqKHSZFQ2R8oXe3JwYLMIWZtbvS/g3qOBS3jkfxSIR8MQ
	 VCFm7mShtz4O7/PfNaEY6qsZnGw/ykLAHA/MGNR4H/EJTXcVVYTUyORudHPpnQW7HVV+9
	 fXO3Ve5s98ePz0UxRCGbM27W1qAnnJ5bI3gWwA665zmGHXcNwqzFOZZ5crPRlW+PXRzgf
	 PYcaeNOIWMdZESJz+uHL52z07TTAop1951kmNgWl2U7c07SxlIxUpo92hxV2f83P6kw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794117149;
	h=DMARC-Filter:Received:X-Google-DKIM-Signature:X-Forwarded-Encrypted:
	 X-Gm-Message-State:MIME-Version:X-Received:Date:In-Reply-To:
	 X-Google-Appengine-App-Id:X-Google-Appengine-App-Id-Alias:Message-ID:
	 Subject:From:To:Content-Type;
	bh=QJc37cJ/S1g5YDvC+KD7J+WHe+A8KLkh38XT8Ub/b9w=;
	b=joBrUo8DxsIFQcv1o0R7f8vNolS+d9NOjSJ86skDIs5w6CgbMoi7/sxNDh5mwL0E+qAP
	 coeO1RigpLspS88qWICE9fRotNkkNJBrluBmKUgAly9GucGx3ML3zo9n0r3nCDv5dcNio
	 Z5VNU7p/DMGtzzFYMI3LHXAopghMcRV0QPLpP/p2OQc+EjzzN/5RY3jP7R2lDjvnfTkLC
	 Z+w47O7OIJb+g8vEu8zXwR9ki3guw2ruHkyrBNW9lTws1lR8e3KNkMtgxCFOOXL5LpPiR
	 595N5p245xpM0GoL+2PaP/4TDbPnfKKRW0EKRTC2IeIZ66eH28wJ2VK/wTfRAq2nV4A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=fail header.from=syzkaller.appspotmail.com;
	spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
	arc=none smtp.remote-ip=209.85.210.70
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 66739606A31C
	for <linux-nfs@vger.kernel.org>; Sun,  8 Nov 2026 05:52:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 66739606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-ot1-f70.google.com with SMTP id 46e09a7af769-85ef7e83c5dso206386a34.2
        for <linux-nfs@vger.kernel.org>; Sat, 07 Nov 2026 21:52:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794117148; x=1794721948;
        h=content-type:to:from:subject:message-id:in-reply-to:date
         :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=QJc37cJ/S1g5YDvC+KD7J+WHe+A8KLkh38XT8Ub/b9w=;
        b=xrmQlKIbbMJBU6KgVaowHH3Cuq2pSL6k+8xG8yZ3bjWuGgdPU7BXjV75JD7eQNnU7B
         UIk4BNJZdPud4uXgSxo4WTuWPzr+CQbtYWfTosKjveKk1ggLtc1oHTb2T7vdALzNqiO6
         u0YYT+yrveO1ozDrIGNuu8ttvlHIxYA3yZURCe0AzWFu7MJzELzlufULm05VGp5ZP8AJ
         jh2nnU1ysFOuDN5RVkadBa1EccRjlyWJnfPp40a0GuJV9jMOf4YGs02hd5Rmeh97YuJq
         jA+KZUvrWKUpb8LZQQvEDrooP0nSQLNIR3uZsGP3d3vvpo4XrBuFEX1LFfe+PJTR4qBD
         y9WQ==
X-Forwarded-Encrypted: i=1; AKwUvBwyDe9CYIpl+LDU95M2oK0EoU8p6AsIKaMqZYd5GMYfbzaIWIKYnE1lF8e9ZugJM5eK4bOhtmtqFmI=@vger.kernel.org
X-Gm-Message-State: APuU4Z+hAZTglK5jo2BP5snSfzBytbaWmAmMgXk0GLQ3+5t8mFBhyqH5
	I6iqkODdHvULLISfRdhr2LBsXDr1QCsDuIf4mOn5SRf3o6hDq3vS7RI8uigi4PpRCfoDvXlNU3n
	2jD6ag8b2mLeGFORPnkZtPzc0MNlhPyLu2uxyF8RWc1cxu1Hm3mjN3Cr5xQY=
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-Received: by 2002:a05:6808:c125:b0:4f6:a430:1822 with SMTP id
 5614622812f47-568141ffe0fmr509756b6e.7.1794117148467; Sat, 07 Nov 2026
 21:52:28 -0800 (PST)
Date: Sat, 07 Nov 2026 21:52:28 -0800
In-Reply-To: <6aee17c4.8be4ead1.3b45e1.0199.GAE@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6af00e1c.5a668245.1aceb6.0005.GAE@google.com>
Subject: Re: [syzbot] [nfs?] [net?] WARNING in svc_destroy
From: syzbot <syzbot+8cbdf9aa6c281a4e6bbe@syzkaller.appspotmail.com>
To: anna@kernel.org, cel@kernel.org, dai.ngo@oracle.com, davem@davemloft.net, 
	edumazet@kernel.org, horms@kernel.org, jlayton@kernel.org, kuba@kernel.org, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, neil@brown.name, 
	netdev@vger.kernel.org, okorniev@redhat.com, pabeni@redhat.com, 
	syzkaller-bugs@googlegroups.com, tom@talpey.com, trondmy@kernel.org
Content-Type: text/plain; charset="UTF-8"

syzbot has found a reproducer for the following issue on:

HEAD commit:    d164c7d754f0 Merge tag 'devicetree-fixes-for-7.4-1' of git..
git tree:       git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
console output: https://syzkaller.appspot.com/x/log.txt?x=13ac11a1580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=1cf189394a856f11
dashboard link: https://syzkaller.appspot.com/bug?extid=8cbdf9aa6c281a4e6bbe
compiler:       gcc (Debian 14.2.0-19) 14.2.0, GNU ld (GNU Binutils for Debian) 2.44
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=1494d369580000

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
WARNING: net/sunrpc/svc.c:532 at svc_destroy+0x299/0x330 net/sunrpc/svc.c:532, CPU#1: syz-executor154/6024
Modules linked in:
CPU: 1 UID: 0 PID: 6024 Comm: syz-executor154 Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 11/06/2026
RIP: 0010:svc_destroy+0x29d/0x330 net/sunrpc/svc.c:532
Code: 48 b8 00 00 00 00 00 fc ff df 49 8b 5d 00 48 8d 7b 18 48 89 fa 48 c1 ea 03 80 3c 02 00 75 67 48 8d 3d e7 6d 77 07 48 8b 73 18 <67> 48 0f b9 3a e9 d0 fd ff ff 48 8b 7c 24 08 e8 7f 4d 85 f7 e9 a5
RSP: 0018:ffffc9000393f860 EFLAGS: 00010246
RAX: dffffc0000000000 RBX: ffffffff9040bf80 RCX: 0000000000000000
RDX: 1ffffffff20817f3 RSI: ffffffff8c37ebc0 RDI: ffffffff927b0660
RBP: 0000000000000000 R08: 00000000ffffffff R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000000 R12: ffff888020bcc000
R13: ffff8880274a0000 R14: ffff88802c3c4000 R15: ffffffff9cd624c0
FS:  000055556ff69400(0000) GS:ffff888122575000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000055fdb0009fd0 CR3: 00000000377ff000 CR4: 00000000003526f0
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
RIP: 0033:0x7fd324de7f1a
Code: 48 c7 c2 d8 ff ff ff f7 d8 64 89 02 b8 ff ff ff ff c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 40 00 49 89 ca b8 a5 00 00 00 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 c7 c1 d8 ff ff ff f7 d8 64 89 01 48
RSP: 002b:00007ffca5d506e8 EFLAGS: 00000246 ORIG_RAX: 00000000000000a5
RAX: ffffffffffffffda RBX: 0000000000000003 RCX: 00007fd324de7f1a
RDX: 00007fd324e4603f RSI: 00007fd324e45ffe RDI: 00007fd324e46044
RBP: 0000000000000004 R08: 00007ffca5d50760 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 00007fd324e45ffe
R13: 0000000000001789 R14: 0000000000000801 R15: 00007ffca5d50760
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
  1f:	48 8d 3d e7 6d 77 07 	lea    0x7776de7(%rip),%rdi        # 0x7776e0d
  26:	48 8b 73 18          	mov    0x18(%rbx),%rsi
* 2a:	67 48 0f b9 3a       	ud1    (%edx),%rdi <-- trapping instruction
  2f:	e9 d0 fd ff ff       	jmp    0xfffffe04
  34:	48 8b 7c 24 08       	mov    0x8(%rsp),%rdi
  39:	e8 7f 4d 85 f7       	call   0xf7854dbd
  3e:	e9                   	.byte 0xe9
  3f:	a5                   	movsl  %ds:(%rsi),%es:(%rdi)


---
If you want syzbot to run the reproducer, reply with:
#syz test: git://repo/address.git branch-or-commit-hash
If you attach or paste a git patch, syzbot will apply it before testing.
