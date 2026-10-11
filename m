Received: from mail-oa1-f71.google.com (mail-oa1-f71.google.com [209.85.160.71])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0D2D6395AD3
	for <linux-nfs@vger.kernel.org>; Sun, 11 Oct 2026 06:54:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.71
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791701666; cv=none; b=Ef3ymlk9E4dDeZTlMQZMEgFscHi89B+O1NMElcGbRfH279EF0tx99YysXhv33Mch7NAiezif3QH5GkpTMChGBcnBgKGtC3z+r3mzMeuuwzFaWUUtu8//8h7pH1oDphMJiE1F/QdxxxTCuTqrf33XB2NJGmj1REHXj65nVJ0/dLs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791701666; c=relaxed/simple;
	bh=1zHjCZpEBXLAHFckqN0jJnIxtZ8o8D51gPCiLGzfbEQ=;
	h=MIME-Version:Date:Message-ID:Subject:From:To:Content-Type; b=hLdWcOZnL9EscGWyt93P03Ps95Wc1aXUuRxRXRTx6DXGfaJYLHU/D8yo1RU1lupCTkKdkHJUFx8gagcZ+EGkymUfv/QPdd/e8y+ITAPvOjz8FsmvtVZpF2IoeFJ5sIgeBfz7Ta/Ob+ai4YVX4WwEH40GO5Rm6PnRms6mXZSOvdI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.160.71
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oa1-f71.google.com with SMTP id 586e51a60fabf-464fb819ac5so1413924fac.1
        for <linux-nfs@vger.kernel.org>; Sat, 10 Oct 2026 23:54:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791701664; x=1792306464;
        h=content-type:to:from:subject:message-id:date:mime-version
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=MH8PLyqXhed2HbAQNHa2OspLGGBPys6BRDYg9XGjK+c=;
        b=cwVMExKc4unsgql7bzbr//PfxmAbixBFkCm6y1OqL6EYsd/WORCNLN8rAAFq44ikn8
         oN392OUK3DXgPopfYrb67Vfh8Efszt9uh1EYIIjnRNwJUDoyV0UUuV+3z1O6u4wB7NQQ
         xM1XoSf4iPrKt7bouNEvkbCJ4rcX0gQZ2oo7tKGWmURJiKX5R6T3t65kSEG719sl658O
         RbWagBCk4cSdYxAhMwVXpW+620WEa4EbhQ/5yl4I77hWAlCOyFndOMzD4j39LTGx0VJA
         yutGy/nzHZTK36UX8PpOy5NszxZPcYYGpZxd9F3AkdLk2qVz9Fst7ZEm83Z6piC3FipY
         vkDw==
X-Forwarded-Encrypted: i=1; AKwUvBzkMJ9X+8FxSKqoXpEwEoIyzd5oxuEEgQ+Jh5GXaJGEG/udoiSnD4JC7dT2fqmyBqICWK3xA6OSvLE=@vger.kernel.org
X-Gm-Message-State: AFq9FYJpCBQZq9ZHMwlI6V6nxBDO/PxMHhEXsBKufrdWFQe2EjUhlOo7
	JDZ2Ebu6p6VlS7Vx8jbZv28K/hdzYmx88F6VdwAavC3rxgoWgw2RYAQmjy2hAGTsXFKIn+hXBmh
	ffMdIQisJ487hlDqiAj15saQc8wdM3An2GV1F4UBSjVmRZUH8KF6H2SjihqY=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6808:4fce:b0:4e5:c2b4:33a9 with SMTP id
 5614622812f47-50c53ca2ae1mr6028911b6e.46.1791701664034; Sat, 10 Oct 2026
 23:54:24 -0700 (PDT)
Date: Sat, 10 Oct 2026 23:54:24 -0700
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6acb32a0.bbc4c7f9.15faa7.007c.GAE@google.com>
Subject: [syzbot] [net?] [nfs?] KASAN: null-ptr-deref Read in xprt_reserve
From: syzbot <syzbot+ae55a0fac80c73c938ac@syzkaller.appspotmail.com>
To: Dai.Ngo@oracle.com, anna@kernel.org, cel@kernel.org, davem@davemloft.net, 
	edumazet@kernel.org, horms@kernel.org, jlayton@kernel.org, kuba@kernel.org, 
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, neil@brown.name, 
	netdev@vger.kernel.org, okorniev@redhat.com, pabeni@redhat.com, 
	syzkaller-bugs@googlegroups.com, tom@talpey.com, trondmy@kernel.org
Content-Type: text/plain; charset="UTF-8"

Hello,

syzbot found the following issue on:

HEAD commit:    6c377d19d4a5 Merge tag 'ext4_for_linus-7.3-rc7' of git://g..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=1223300d580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=4118aaa2d227be26
dashboard link: https://syzkaller.appspot.com/bug?extid=ae55a0fac80c73c938ac
compiler:       Debian clang version 22.1.8 (++20260613092233+e80beda6e255-1~exp1~20260613092250.77), Debian LLD 22.1.8

Unfortunately, I don't have any reproducer for this issue yet.

Downloadable assets:
disk image: https://storage.googleapis.com/syzbot-assets/c5f7458da164/disk-6c377d19.raw.xz
vmlinux: https://storage.googleapis.com/syzbot-assets/8ae69062b78e/vmlinux-6c377d19.xz
kernel image: https://storage.googleapis.com/syzbot-assets/602017f8f9bb/bzImage-6c377d19.xz

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+ae55a0fac80c73c938ac@syzkaller.appspotmail.com

==================================================================
BUG: KASAN: null-ptr-deref in instrument_atomic_read include/linux/instrumented.h:82 [inline]
BUG: KASAN: null-ptr-deref in _test_bit include/asm-generic/bitops/instrumented-non-atomic.h:141 [inline]
BUG: KASAN: null-ptr-deref in xprt_throttle_congested net/sunrpc/xprt.c:1708 [inline]
BUG: KASAN: null-ptr-deref in xprt_reserve+0xe2/0x2c0 net/sunrpc/xprt.c:1948
Read of size 8 at addr 0000000000000628 by task syz.8.3118/20390

CPU: 1 UID: 0 PID: 20390 Comm: syz.8.3118 Tainted: G S           L      syzkaller #0 PREEMPT(full) 
Tainted: [S]=CPU_OUT_OF_SPEC, [L]=SOFTLOCKUP
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 08/26/2026
Call Trace:
 <TASK>
 dump_stack_lvl+0xe8/0x150 lib/dump_stack.c:120
 kasan_report+0x117/0x150 mm/kasan/report.c:595
 check_region_inline mm/kasan/generic.c:-1 [inline]
 kasan_check_range+0x264/0x2c0 mm/kasan/generic.c:200
 instrument_atomic_read include/linux/instrumented.h:82 [inline]
 _test_bit include/asm-generic/bitops/instrumented-non-atomic.h:141 [inline]
 xprt_throttle_congested net/sunrpc/xprt.c:1708 [inline]
 xprt_reserve+0xe2/0x2c0 net/sunrpc/xprt.c:1948
 __rpc_execute+0x526/0x1280 net/sunrpc/sched.c:947
 rpc_execute+0x1c1/0x390 net/sunrpc/sched.c:1023
 rpc_run_task+0x4a6/0x660 net/sunrpc/clnt.c:1269
 rpc_ping_noreply net/sunrpc/clnt.c:2944 [inline]
 rpc_create_xprt+0x452/0xa90 net/sunrpc/clnt.c:494
 rpc_create+0x649/0x900 net/sunrpc/clnt.c:619
 gssp_rpc_create net/sunrpc/auth_gss/gss_rpc_upcall.c:107 [inline]
 set_gssp_clnt+0x188/0x2d0 net/sunrpc/auth_gss/gss_rpc_upcall.c:131
 write_gssp+0x21e/0x310 net/sunrpc/auth_gss/svcauth_gss.c:1423
 pde_write fs/proc/inode.c:330 [inline]
 proc_reg_write+0x1e9/0x2e0 fs/proc/inode.c:342
 vfs_write+0x296/0xba0 fs/read_write.c:685
 ksys_write+0x150/0x270 fs/read_write.c:739
 do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
 do_syscall_64+0x166/0x520 arch/x86/entry/syscall_64.c:84
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f44e699e1d9
Code: ff c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 c7 c1 e8 ff ff ff f7 d8 64 89 01 48
RSP: 002b:00007f44e78be028 EFLAGS: 00000246 ORIG_RAX: 0000000000000001
RAX: ffffffffffffffda RBX: 00007f44e6c25fa0 RCX: 00007f44e699e1d9
RDX: 0000000000000001 RSI: 0000200000000300 RDI: 0000000000000005
RBP: 00007f44e6a35888 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007f44e6c26038 R14: 00007f44e6c25fa0 R15: 00007ffdb88808e8
 </TASK>
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
