Received: from mail-oo1-f70.google.com (mail-oo1-f70.google.com [209.85.161.70])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 15C91379C48
	for <linux-nfs@vger.kernel.org>; Fri,  7 Aug 2026 07:38:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.70
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786088315; cv=none; b=DjlxMclEtKL1I3/gKGPOU1qKS3FuQNYzY8ixOlqaeOM+UQahHJs8NGJU7QyeWXJJMwfGIq2CkSiaDEeAUt2QbhKw7zMI7XJcw2V49CxdyPg9pq9M9X8ml9iMaB8ZQt8OOB08HP8e5DcAPcfmuSeue7m1JXPwPJwLGRnFatKK/BQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786088315; c=relaxed/simple;
	bh=HbB8HoAy5To05bJe2uOPZTb8pNaplfNx35gNG5Zv1X4=;
	h=MIME-Version:Date:In-Reply-To:Message-ID:Subject:From:To:
	 Content-Type; b=paFdQrUqt9acAsnduTnKApln9jzTvMtBFVPLdYZxrTnuVp7EW9RppRXuhdt3QbHsDzlNaowLoO/NbEPEfWiZ9YFdosohgnsdKWgewdDng5Y515SqJbHlxRh3Xj13p4YisnragdX6KFW1oTX41AwBNoBg+yxDQG6dcQqvVFljnMY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com; arc=none smtp.client-ip=209.85.161.70
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-oo1-f70.google.com with SMTP id 006d021491bc7-6ae41d34275so2339056eaf.3
        for <linux-nfs@vger.kernel.org>; Fri, 07 Aug 2026 00:38:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786088312; x=1786693112;
        h=content-type:to:from:subject:message-id:in-reply-to:date
         :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=zTLx6psb2Y6AIJXwnDryypZ4TGxHjwRmR6E9LTg9lgA=;
        b=I3mACDgk2k90XUin0zuIcA+xMgNHFi54DNpj87AzqOvdVKGEyeLEYon7mcTvekn5AA
         jRDlERmmwHn+OxVtc+yK3cgimf8mxjGojRgmaOKYOrOjGoF07krGQxZZAf3vY7Q7j3kZ
         llfpvOu5ILN6ZslrHiaWY6Z/BjKLzdyn2rzOV6SqYicNZQvNauSY8xVHN5SwgAYvE5D8
         zmMMwQvrmNMup+HJoDA2XUVXcDbq2uuymWugc3X8T3VNCg1D/OHMpdyDqMjAcIQ7cbQV
         qgk8SfafNXuZjb3SRBluJy4LLKiAKJmeWicnUPO390ROyMbQSEG5/Eql68WsLepl9eN6
         AI8w==
X-Forwarded-Encrypted: i=1; AHgh+Rp10bELZdtIfupTmgKK1bw+RsIOhuvvuBOJx0B04uuy1PO9cBgU2DbbjzWvZ02axAELI29l14NyatA=@vger.kernel.org
X-Gm-Message-State: AOJu0Yx7Z6eKDO0JtleFKuG+ytrPymykJzQ2yoaYxiEZC3E7/1HC5yjf
	hOinsxhp9XghsyoPr6apKvL3KKUQzGV5AgOMJlOGYF7TOXzw9V1Yuuhn28kNpY90p4vXMQq98Oy
	z97PMIJHdHxZyrWKjIFbnPZxwvBnMQtzgjM6dTvH2V3kmumaPv/4pHDsnvwc=
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Received: by 2002:a05:6820:188f:b0:6ae:52a7:1be3 with SMTP id
 006d021491bc7-6ae96f10c8cmr10374776eaf.20.1786088312097; Fri, 07 Aug 2026
 00:38:32 -0700 (PDT)
Date: Fri, 07 Aug 2026 00:38:32 -0700
In-Reply-To: <000000000000689a2b061ba29db3@google.com>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6a758b78.9c11d2ce.289b96.00a7.GAE@google.com>
Subject: Re: [syzbot] [nfs?] INFO: task hung in nfsd_nl_threads_get_doit
From: syzbot <syzbot+c0831b61d6ade1e2d098@syzkaller.appspotmail.com>
To: chuck.lever@oracle.com, dai.ngo@oracle.com, jlayton@kernel.org, 
	kolga@netapp.com, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
	neilb@suse.de, syzkaller-bugs@googlegroups.com, tom@talpey.com
Content-Type: text/plain; charset="UTF-8"

syzbot has found a reproducer for the following issue on:

HEAD commit:    364465ab19de Merge tag 'v7.2-rc6-smb3-server-fixes' of git..
git tree:       upstream
console output: https://syzkaller.appspot.com/x/log.txt?x=15980fb9580000
kernel config:  https://syzkaller.appspot.com/x/.config?x=4e38b15c29e6a1d9
dashboard link: https://syzkaller.appspot.com/bug?extid=c0831b61d6ade1e2d098
compiler:       Debian clang version 22.1.8 (++20260613092233+e80beda6e255-1~exp1~20260613092250.77), Debian LLD 22.1.8
C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=11f6cfb9580000

IMPORTANT: if you fix the issue, please add the following tag to the commit:
Reported-by: syzbot+c0831b61d6ade1e2d098@syzkaller.appspotmail.com

INFO: task syz-executor549:5964 blocked for more than 15 seconds.
      Not tainted syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz-executor549 state:D stack:27848 pid:5964  tgid:5961  ppid:5960   task_flags:0x400040 flags:0x00080000
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x17d9/0x56c0 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0x164/0x2b0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0x7bf/0x1550 kernel/locking/mutex.c:821
 nfsd_nl_threads_get_doit+0x1c0/0x790 fs/nfsd/nfsctl.c:1754
 genl_family_rcv_msg_doit+0x233/0x340 net/netlink/genetlink.c:1114
 genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
 genl_rcv_msg+0x614/0x7a0 net/netlink/genetlink.c:1209
 netlink_rcv_skb+0x226/0x4a0 net/netlink/af_netlink.c:2556
 genl_rcv+0x28/0x40 net/netlink/genetlink.c:1218
 netlink_unicast_kernel net/netlink/af_netlink.c:1319 [inline]
 netlink_unicast+0x7bb/0x940 net/netlink/af_netlink.c:1345
 netlink_sendmsg+0x813/0xb40 net/netlink/af_netlink.c:1900
 sock_sendmsg_nosec+0x13a/0x180 net/socket.c:775
 __sock_sendmsg net/socket.c:790 [inline]
 __sys_sendto+0x408/0x5a0 net/socket.c:2252
 __do_sys_sendto net/socket.c:2259 [inline]
 __se_sys_sendto net/socket.c:2255 [inline]
 __x64_sys_sendto+0xde/0x100 net/socket.c:2255
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7efe968188de
RSP: 002b:00007efe95fc0058 EFLAGS: 00000246 ORIG_RAX: 000000000000002c
RAX: ffffffffffffffda RBX: 00007efe95fc16c0 RCX: 00007efe968188de
RDX: 0000000000000014 RSI: 00007efe95fc00d0 RDI: 0000000000000005
RBP: 00007efe95fc00d0 R08: 00007efe95fc00c4 R09: 000000000000000c
R10: 0000000000000000 R11: 0000000000000246 R12: 00007efe95fc00c4
R13: 00007efe95fc01f0 R14: 00007ffddaf6a850 R15: 00007ffddaf6a938
 </TASK>
INFO: task syz-executor549:5965 blocked for more than 15 seconds.
      Not tainted syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz-executor549 state:D stack:27848 pid:5965  tgid:5961  ppid:5960   task_flags:0x400040 flags:0x00080000
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x17d9/0x56c0 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0x164/0x2b0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0x7bf/0x1550 kernel/locking/mutex.c:821
 nfsd_nl_threads_get_doit+0x1c0/0x790 fs/nfsd/nfsctl.c:1754
 genl_family_rcv_msg_doit+0x233/0x340 net/netlink/genetlink.c:1114
 genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
 genl_rcv_msg+0x614/0x7a0 net/netlink/genetlink.c:1209
 netlink_rcv_skb+0x226/0x4a0 net/netlink/af_netlink.c:2556
 genl_rcv+0x28/0x40 net/netlink/genetlink.c:1218
 netlink_unicast_kernel net/netlink/af_netlink.c:1319 [inline]
 netlink_unicast+0x7bb/0x940 net/netlink/af_netlink.c:1345
 netlink_sendmsg+0x813/0xb40 net/netlink/af_netlink.c:1900
 sock_sendmsg_nosec+0x13a/0x180 net/socket.c:775
 __sock_sendmsg net/socket.c:790 [inline]
 __sys_sendto+0x408/0x5a0 net/socket.c:2252
 __do_sys_sendto net/socket.c:2259 [inline]
 __se_sys_sendto net/socket.c:2255 [inline]
 __x64_sys_sendto+0xde/0x100 net/socket.c:2255
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7efe968188de
RSP: 002b:00007efe957bf058 EFLAGS: 00000246 ORIG_RAX: 000000000000002c
RAX: ffffffffffffffda RBX: 00007efe957c06c0 RCX: 00007efe968188de
RDX: 0000000000000014 RSI: 00007efe957bf0d0 RDI: 0000000000000006
RBP: 00007efe957bf0d0 R08: 00007efe957bf0c4 R09: 000000000000000c
R10: 0000000000000000 R11: 0000000000000246 R12: 00007efe957bf0c4
R13: 00007efe957bf1f0 R14: 00007ffddaf6a850 R15: 00007ffddaf6a938
 </TASK>
INFO: task syz-executor549:5966 blocked for more than 16 seconds.
      Not tainted syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz-executor549 state:D stack:27848 pid:5966  tgid:5961  ppid:5960   task_flags:0x400040 flags:0x00080000
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x17d9/0x56c0 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0x164/0x2b0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0x7bf/0x1550 kernel/locking/mutex.c:821
 nfsd_nl_threads_get_doit+0x1c0/0x790 fs/nfsd/nfsctl.c:1754
 genl_family_rcv_msg_doit+0x233/0x340 net/netlink/genetlink.c:1114
 genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
 genl_rcv_msg+0x614/0x7a0 net/netlink/genetlink.c:1209
 netlink_rcv_skb+0x226/0x4a0 net/netlink/af_netlink.c:2556
 genl_rcv+0x28/0x40 net/netlink/genetlink.c:1218
 netlink_unicast_kernel net/netlink/af_netlink.c:1319 [inline]
 netlink_unicast+0x7bb/0x940 net/netlink/af_netlink.c:1345
 netlink_sendmsg+0x813/0xb40 net/netlink/af_netlink.c:1900
 sock_sendmsg_nosec+0x13a/0x180 net/socket.c:775
 __sock_sendmsg net/socket.c:790 [inline]
 __sys_sendto+0x408/0x5a0 net/socket.c:2252
 __do_sys_sendto net/socket.c:2259 [inline]
 __se_sys_sendto net/socket.c:2255 [inline]
 __x64_sys_sendto+0xde/0x100 net/socket.c:2255
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7efe968188de
RSP: 002b:00007efe94fbe058 EFLAGS: 00000246 ORIG_RAX: 000000000000002c
RAX: ffffffffffffffda RBX: 00007efe94fbf6c0 RCX: 00007efe968188de
RDX: 0000000000000014 RSI: 00007efe94fbe0d0 RDI: 0000000000000007
RBP: 00007efe94fbe0d0 R08: 00007efe94fbe0c4 R09: 000000000000000c
R10: 0000000000000000 R11: 0000000000000246 R12: 00007efe94fbe0c4
R13: 00007efe94fbe1f0 R14: 00007ffddaf6a850 R15: 00007ffddaf6a938
 </TASK>
INFO: task syz-executor549:5967 blocked for more than 16 seconds.
      Not tainted syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz-executor549 state:D stack:27848 pid:5967  tgid:5961  ppid:5960   task_flags:0x400040 flags:0x00080000
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x17d9/0x56c0 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0x164/0x2b0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0x7bf/0x1550 kernel/locking/mutex.c:821
 nfsd_nl_threads_get_doit+0x1c0/0x790 fs/nfsd/nfsctl.c:1754
 genl_family_rcv_msg_doit+0x233/0x340 net/netlink/genetlink.c:1114
 genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
 genl_rcv_msg+0x614/0x7a0 net/netlink/genetlink.c:1209
 netlink_rcv_skb+0x226/0x4a0 net/netlink/af_netlink.c:2556
 genl_rcv+0x28/0x40 net/netlink/genetlink.c:1218
 netlink_unicast_kernel net/netlink/af_netlink.c:1319 [inline]
 netlink_unicast+0x7bb/0x940 net/netlink/af_netlink.c:1345
 netlink_sendmsg+0x813/0xb40 net/netlink/af_netlink.c:1900
 sock_sendmsg_nosec+0x13a/0x180 net/socket.c:775
 __sock_sendmsg net/socket.c:790 [inline]
 __sys_sendto+0x408/0x5a0 net/socket.c:2252
 __do_sys_sendto net/socket.c:2259 [inline]
 __se_sys_sendto net/socket.c:2255 [inline]
 __x64_sys_sendto+0xde/0x100 net/socket.c:2255
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7efe968188de
RSP: 002b:00007efe947bd058 EFLAGS: 00000246 ORIG_RAX: 000000000000002c
RAX: ffffffffffffffda RBX: 00007efe947be6c0 RCX: 00007efe968188de
RDX: 0000000000000014 RSI: 00007efe947bd0d0 RDI: 0000000000000008
RBP: 00007efe947bd0d0 R08: 00007efe947bd0c4 R09: 000000000000000c
R10: 0000000000000000 R11: 0000000000000246 R12: 00007efe947bd0c4
R13: 00007efe947bd1f0 R14: 00007ffddaf6a850 R15: 00007ffddaf6a938
 </TASK>
INFO: task syz-executor549:5968 blocked for more than 16 seconds.
      Not tainted syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz-executor549 state:D stack:27848 pid:5968  tgid:5961  ppid:5960   task_flags:0x400040 flags:0x00080000
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x17d9/0x56c0 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0x164/0x2b0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0x7bf/0x1550 kernel/locking/mutex.c:821
 nfsd_nl_threads_get_doit+0x1c0/0x790 fs/nfsd/nfsctl.c:1754
 genl_family_rcv_msg_doit+0x233/0x340 net/netlink/genetlink.c:1114
 genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
 genl_rcv_msg+0x614/0x7a0 net/netlink/genetlink.c:1209
 netlink_rcv_skb+0x226/0x4a0 net/netlink/af_netlink.c:2556
 genl_rcv+0x28/0x40 net/netlink/genetlink.c:1218
 netlink_unicast_kernel net/netlink/af_netlink.c:1319 [inline]
 netlink_unicast+0x7bb/0x940 net/netlink/af_netlink.c:1345
 netlink_sendmsg+0x813/0xb40 net/netlink/af_netlink.c:1900
 sock_sendmsg_nosec+0x13a/0x180 net/socket.c:775
 __sock_sendmsg net/socket.c:790 [inline]
 __sys_sendto+0x408/0x5a0 net/socket.c:2252
 __do_sys_sendto net/socket.c:2259 [inline]
 __se_sys_sendto net/socket.c:2255 [inline]
 __x64_sys_sendto+0xde/0x100 net/socket.c:2255
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7efe968188de
RSP: 002b:00007efe93fbc058 EFLAGS: 00000246 ORIG_RAX: 000000000000002c
RAX: ffffffffffffffda RBX: 00007efe93fbd6c0 RCX: 00007efe968188de
RDX: 0000000000000014 RSI: 00007efe93fbc0d0 RDI: 0000000000000009
RBP: 00007efe93fbc0d0 R08: 00007efe93fbc0c4 R09: 000000000000000c
R10: 0000000000000000 R11: 0000000000000246 R12: 00007efe93fbc0c4
R13: 00007efe93fbc1f0 R14: 00007ffddaf6a850 R15: 00007ffddaf6a938
 </TASK>
INFO: task syz-executor549:6028 blocked for more than 17 seconds.
      Not tainted syzkaller #0
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
task:syz-executor549 state:D stack:27232 pid:6028  tgid:5961  ppid:5960   task_flags:0x400140 flags:0x00080000
Call Trace:
 <TASK>
 context_switch kernel/sched/core.c:5510 [inline]
 __schedule+0x17d9/0x56c0 kernel/sched/core.c:7234
 __schedule_loop kernel/sched/core.c:7311 [inline]
 schedule+0x164/0x2b0 kernel/sched/core.c:7326
 schedule_preempt_disabled+0x13/0x30 kernel/sched/core.c:7383
 __mutex_lock_common kernel/locking/mutex.c:726 [inline]
 __mutex_lock+0x7bf/0x1550 kernel/locking/mutex.c:821
 nfsd_nl_listener_set_doit+0x135/0x1750 fs/nfsd/nfsctl.c:1964
 genl_family_rcv_msg_doit+0x233/0x340 net/netlink/genetlink.c:1114
 genl_family_rcv_msg net/netlink/genetlink.c:1194 [inline]
 genl_rcv_msg+0x614/0x7a0 net/netlink/genetlink.c:1209
 netlink_rcv_skb+0x226/0x4a0 net/netlink/af_netlink.c:2556
 genl_rcv+0x28/0x40 net/netlink/genetlink.c:1218
 netlink_unicast_kernel net/netlink/af_netlink.c:1319 [inline]
 netlink_unicast+0x7bb/0x940 net/netlink/af_netlink.c:1345
 netlink_sendmsg+0x813/0xb40 net/netlink/af_netlink.c:1900
 sock_sendmsg_nosec+0x13a/0x180 net/socket.c:775
 __sock_sendmsg net/socket.c:790 [inline]
 __sys_sendto+0x408/0x5a0 net/socket.c:2252
 __do_sys_sendto net/socket.c:2259 [inline]
 __se_sys_sendto net/socket.c:2255 [inline]
 __x64_sys_sendto+0xde/0x100 net/socket.c:2255
 do_syscall_x64 arch/x86/entry/syscall_64.c:63 [inline]
 do_syscall_64+0x174/0x580 arch/x86/entry/syscall_64.c:94
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7efe968188de
RSP: 002b:00007efe927b6148 EFLAGS: 00000246 ORIG_RAX: 000000000000002c
RAX: ffffffffffffffda RBX: 00007efe927ba6c0 RCX: 00007efe968188de
RDX: 0000000000000014 RSI: 00007efe927b81c0 RDI: 000000000000000c
RBP: 0000000000000000 R08: 00007efe927b61b4 R09: 000000000000000c
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000027
R13: 0000000000000011 R14: 00007ffddaf6a850 R15: 00007ffddaf6a938
 </TASK>

Showing all locks held in the system:
1 lock held by khungtaskd/31:
 #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: rcu_lock_acquire include/linux/rcupdate.h:300 [inline]
 #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: rcu_read_lock include/linux/rcupdate.h:840 [inline]
 #0: ffffffff8eb59c60 (rcu_read_lock){....}-{1:3}, at: debug_show_all_locks+0x2e/0x180 kernel/locking/lockdep.c:6775
2 locks held by getty/5379:
 #0: ffff8880332c20a0 (&tty->ldisc_sem){++++}-{0:0}, at: tty_ldisc_ref_wait+0x25/0x70 drivers/tty/tty_ldisc.c:243
 #1: ffffc9000322b2e8 (&ldata->atomic_read_lock){+.+.}-{4:4}, at: n_tty_read+0x45a/0x1360 drivers/tty/n_tty.c:2211
2 locks held by syz-executor549/5964:
 #0: ffffffff9009f8e8 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8ee8e6c0 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_threads_get_doit+0x1c0/0x790 fs/nfsd/nfsctl.c:1754
2 locks held by syz-executor549/5965:
 #0: ffffffff9009f8e8 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8ee8e6c0 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_threads_get_doit+0x1c0/0x790 fs/nfsd/nfsctl.c:1754
2 locks held by syz-executor549/5966:
 #0: ffffffff9009f8e8 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8ee8e6c0 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_threads_get_doit+0x1c0/0x790 fs/nfsd/nfsctl.c:1754
2 locks held by syz-executor549/5967:
 #0: ffffffff9009f8e8 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8ee8e6c0 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_threads_get_doit+0x1c0/0x790 fs/nfsd/nfsctl.c:1754
2 locks held by syz-executor549/5968:
 #0: ffffffff9009f8e8 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8ee8e6c0 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_threads_get_doit+0x1c0/0x790 fs/nfsd/nfsctl.c:1754
2 locks held by syz-executor549/5969:
 #0: ffffffff9009f8e8 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8ee8e6c0 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_listener_set_doit+0x135/0x1750 fs/nfsd/nfsctl.c:1964
2 locks held by syz-executor549/6028:
 #0: ffffffff9009f8e8 (cb_lock){++++}-{4:4}, at: genl_rcv+0x19/0x40 net/netlink/genetlink.c:1217
 #1: ffffffff8ee8e6c0 (nfsd_mutex){+.+.}-{4:4}, at: nfsd_nl_listener_set_doit+0x135/0x1750 fs/nfsd/nfsctl.c:1964

=============================================

NMI backtrace for cpu 1
CPU: 1 UID: 0 PID: 31 Comm: khungtaskd Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 07/24/2026
Call Trace:
 <TASK>
 dump_stack_lvl+0xe8/0x150 lib/dump_stack.c:120
 nmi_cpu_backtrace+0x274/0x2d0 lib/nmi_backtrace.c:122
 nmi_trigger_cpumask_backtrace+0x17a/0x380 lib/nmi_backtrace.c:65
 trigger_all_cpu_backtrace include/linux/nmi.h:162 [inline]
 __sys_info lib/sys_info.c:157 [inline]
 sys_info+0x135/0x170 lib/sys_info.c:165
 check_hung_uninterruptible_tasks kernel/hung_task.c:353 [inline]
 watchdog+0xfd7/0x1030 kernel/hung_task.c:561
 kthread+0x388/0x470 kernel/kthread.c:436
 ret_from_fork+0x514/0xb70 arch/x86/kernel/process.c:158
 ret_from_fork_asm+0x1a/0x30 arch/x86/entry/entry_64.S:245
 </TASK>
Sending NMI from CPU 1 to CPUs 0:
NMI backtrace for cpu 0
CPU: 0 UID: 0 PID: 0 Comm: swapper/0 Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 07/24/2026
RIP: 0010:pv_native_safe_halt+0xf/0x20 arch/x86/kernel/paravirt.c:64
Code: 0b 7d 02 c3 cc cc cc cc cc cc cc 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 f3 0f 1e fa 66 90 0f 00 2d 73 7e 16 00 fb f4 <e9> 4c 06 03 00 cc cc cc cc cc cc cc cc cc cc cc cc 90 90 90 90 90
RSP: 0018:ffffffff8e807de0 EFLAGS: 00000242
RAX: 00000000000dbf31 RBX: ffffffff819b533c RCX: 0000000080000001
RDX: 0000000000000001 RSI: ffffffff8e230b02 RDI: ffffffff8c4be280
RBP: ffffffff8e807eb8 R08: ffff8880b86338db R09: 1ffff110170c671b
R10: dffffc0000000000 R11: ffffed10170c671c R12: 0000000000000000
R13: 1ffffffff1d11de8 R14: 1ffffffff1d00fc4 R15: dffffc0000000000
FS:  0000000000000000(0000) GS:ffff888124f42000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00005643a21cea30 CR3: 000000000e946000 CR4: 00000000003526f0
Call Trace:
 <TASK>
 arch_safe_halt arch/x86/kernel/process.c:767 [inline]
 default_idle+0x9/0x20 arch/x86/kernel/process.c:768
 default_idle_call+0x72/0xb0 kernel/sched/idle.c:122
 cpuidle_idle_call kernel/sched/idle.c:199 [inline]
 do_idle+0x1cc/0x540 kernel/sched/idle.c:355
 cpu_startup_entry+0x43/0x60 kernel/sched/idle.c:454
 rest_init+0x2de/0x300 init/main.c:717
 start_kernel+0x392/0x3e0 init/main.c:1175
 x86_64_start_reservations+0x24/0x30 arch/x86/kernel/head64.c:310
 x86_64_start_kernel+0x137/0x1b0 arch/x86/kernel/head64.c:291
 common_startup_64+0x13e/0x157
 </TASK>


---
If you want syzbot to run the reproducer, reply with:
#syz test: git://repo/address.git branch-or-commit-hash
If you attach or paste a git patch, syzbot will apply it before testing.
