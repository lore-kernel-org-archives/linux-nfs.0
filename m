Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.70
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795547746;
	b=1iuANb3vPguY9uK5m4m7U9DfdskSGGHGYu8BTYGQe9DVRw1CM8ftE1eoeazHP4+J5rag
	 JXy31w7CzHhWx143v6XLsZb9Xbea9ZE8cBQqbNVW5IE6BeRhXlvMCNyR0vXsN3Pl9PmS8
	 OwhURJRsGuD1tgdyXAeNmuHaRKtqDfmx9gzIA1uo9gcQe0zKwvsIv4Wdm/goG9IgubqSW
	 70sNf61tkT3iZ3AdUunGLfQ4J+OOxvxri1iLfWBtxVCkuaPD0hCcH3pW0Ytqo4vp7Uwk4
	 RLb8aTEQYIBpoUHglP6P4sgA8gD10QK/1StVggxfxYNVVbh22DqF72dE4imyVKF9QZg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795547746;
	h=DMARC-Filter:Received:X-Google-DKIM-Signature:X-Forwarded-Encrypted:
	 X-Gm-Message-State:MIME-Version:X-Received:Date:In-Reply-To:
	 X-Google-Appengine-App-Id:X-Google-Appengine-App-Id-Alias:Message-ID:
	 Subject:From:To:Cc:Content-Type;
	bh=iVaX5nAlkBKMSj8rUpfeIOl3ibSmoRV5kmxp9WpM+9Y=;
	b=Oa1EkC9tmOQp5iYDiiz/PZlg8i8P1078KBAFPQOaGOiDS5bAmT/xYWNEjmJUXCH6RD0s
	 RZgdc3MsCXeW90baYdipVIQ+HbgZX2qodQ8H0hFM+vliv/Y+efMzYF7GrowzEQIZcTOdB
	 619JmiM842GiyUVHsoAtFRGHpf56Xjv4rbWqjxxJ2/rAkwnqp4fyBGRjqSnEV9SKGwhRS
	 NlV9AOSgE9GRxwRc2CUSK9k9QDkLWAWNB9NMLgjUWSjBWG5n6fqKFRyX70IKqHrpKv8WL
	 EU1t8nhBVV3l4dOXSZzgWmLpKjq7/3xO8+cUPfwAwTLR2S4s1e9BOn+OcBvGXHO06WQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=fail header.from=syzkaller.appspotmail.com;
	spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com;
	arc=none smtp.remote-ip=209.85.210.70
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CF059606A331
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 19:15:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CF059606A331
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=syzkaller.appspotmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=M3KW2WVRGUFZ5GODRSRYTGD7.apphosting.bounces.google.com
Received: by mail-ot1-f70.google.com with SMTP id 46e09a7af769-83edc5c5ae9so5039928a34.1
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 11:15:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795547745; x=1796152545;
        h=content-type:cc:to:from:subject:message-id:in-reply-to:date
         :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=iVaX5nAlkBKMSj8rUpfeIOl3ibSmoRV5kmxp9WpM+9Y=;
        b=P8djCdBnCDQV5vy0X8Plhjxzzwre3sqZ1qOtAHJiFDMvj82E8nB5sM5Vl9fWczHB07
         AVgOZxkO/4gviTJy7qaciFGL3HcmGAKVAjooWfMGbmvO8nw7oavE0F3ouxfkvl7zogC7
         PqSlURqNVQmVipdGlDP52whsdbiDO+D7p91apFYHyYNdIoFKf36Z8yPFMaL1qeKqIWSY
         6tdRqfzKMelCcHPTcOK19govO3EtUiEBuSKxGB6Ww/QxNWXr34CTg5LVxZxX8ng5CRQ8
         vVLgYHtFhjs+byJTZBsW3rvo1WOC3NZqHLnawGwj+XeP+ooKiaHMReuL15s5tvQ32kwS
         tjVg==
X-Forwarded-Encrypted: i=1; AL+hErHi1QKO8GRql3fzMIUTUgrvVm/Ur+fAJs3DN2TiEslLienBMMf/HoxMTOS6Liwwnw2QlCaNHcybskk=@vger.kernel.org
X-Gm-Message-State: APuU4Z/s4ql7VkWRivlhGt2rToR5S9UogggCDc5xCVIHpKmq8HsrA7/6
	8FdL+GTREJ9VQtMcotX9b+wbkYdwmcfTZJN44qDgelqLK2e0rcDmx8fTSiMqe7jyqwobmPpv1uL
	u7D+8bp+3aSJsj9gl6IRHoICoyGzNZ9/rd2jPS8bYGoyecOVIX9CrmzCeHk8=
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-Received: by 2002:a05:6808:4488:b0:4d6:90f3:74ad with SMTP id
 5614622812f47-57a0b644678mr16259886b6e.45.1795547744778; Tue, 24 Nov 2026
 11:15:44 -0800 (PST)
Date: Tue, 24 Nov 2026 11:15:44 -0800
In-Reply-To: <20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de>
X-Google-Appengine-App-Id: s~syzkaller
X-Google-Appengine-App-Id-Alias: syzkaller
Message-ID: <6b05e260.e1ffc79a.44bf.0000.GAE@google.com>
Subject: [syzbot ci] Re: mm: GUP dirty + ->release_folio() fixes
From: syzbot ci <syzbot+ci6dc3bd0a53405de7@syzkaller.appspotmail.com>
To: akpm@linux-foundation.org, axelrasmussen@google.com, baohua@kernel.org, 
	baolin.wang@linux.alibaba.com, baoquan.he@linux.dev, david@kernel.org, 
	dev.jain@arm.com, hannes@cmpxchg.org, jack@suse.cz, jhubbard@nvidia.com, 
	kas@kernel.org, kasong@tencent.com, lance.yang@linux.dev, liam@infradead.org, 
	linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, 
	ljs@kernel.org, mhocko@kernel.org, mhocko@suse.com, nico.pache@linux.dev, 
	peterx@redhat.com, pfalcato@suse.de, qi.zheng@linux.dev, rppt@kernel.org, 
	ryan.roberts@arm.com, shakeel.butt@linux.dev, stable@vger.kernel.org, 
	surenb@google.com, usama.arif@linux.dev, vbabka@kernel.org, 
	weixugc@google.com, willy@infradead.org, yuanchu@google.com, ziy@nvidia.com
Cc: syzbot@lists.linux.dev, syzkaller-bugs@googlegroups.com
Content-Type: text/plain; charset="UTF-8"

syzbot ci has tested the following series

[v1] mm: GUP dirty + ->release_folio() fixes
https://lore.kernel.org/all/20261119-gup-dirty-what-v1-0-236d69f25c24@suse.de
* [PATCH RFC 1/5] mm/khugepaged: fix filemap_release_folio() interaction with GUP dirty
* [PATCH RFC 2/5] mm/huge_memory: fix filemap_release_folio() interaction with GUP dirty
* [PATCH RFC 3/5] mm/vmscan: avoid releasing FS metadata for !FOLL_PIN gup folios
* [PATCH RFC 4/5] mm/vmscan: be more careful when releasing FS metadata if buffer_heads_over_limit
* [PATCH RFC 5/5] mm/filemap: refuse releasing maybe_dma_pinned folios

and found the following issue:
WARNING in filemap_release_folio

Full report is available here:
https://ci.syzbot.org/series/852fc6fd-04c3-494d-a18d-4072753d5c47

***

WARNING in filemap_release_folio

tree:      linux-next
URL:       https://kernel.googlesource.com/pub/scm/linux/kernel/git/next/linux-next
base:      bb7a206a3ffb0992b3600205b7cf2bcbd228d339
arch:      amd64
compiler:  Debian clang version 22.1.8 (1~deb13u4), Debian LLD 22.1.8
config:    https://ci.syzbot.org/builds/789b8ec7-0fce-48b1-bd3f-130fad443c68/config
syz repro: https://ci.syzbot.org/findings/b27d3479-eda0-470a-a735-8bde8b489eea/syz_repro

 __do_sys_exit_group kernel/exit.c:1134 [inline]
 __se_sys_exit_group kernel/exit.c:1132 [inline]
 __x64_sys_exit_group+0x3f/0x40 kernel/exit.c:1132
 x64_sys_call+0x18c6/0x18d0 arch/x86/include/generated/asm/syscalls_64.h:232
 do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
 do_syscall_64+0x171/0x540 arch/x86/entry/syscall_64.c:89
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
------------[ cut here ]------------
1
WARNING: mm/filemap.c:4574 at filemap_release_folio+0x579/0x6a0 mm/filemap.c:4574, CPU#1: syz.0.32/5940
Modules linked in:
CPU: 1 UID: 0 PID: 5940 Comm: syz.0.32 Not tainted syzkaller #0 PREEMPT(full) 
Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS 1.16.2-debian-1.16.2-1 04/01/2014
RIP: 0010:filemap_release_folio+0x579/0x6a0 mm/filemap.c:4574
Code: 89 df 48 83 c4 10 5b 41 5c 41 5d 41 5e 41 5f 5d e9 2c 88 58 00 e8 47 76 b7 ff 48 89 df 48 c7 c6 a0 82 39 8c e8 e8 74 16 ff 90 <0f> 0b 90 e9 00 fc ff ff e8 2a 76 b7 ff 48 89 df e8 a2 26 00 00 41
RSP: 0000:ffffc90003486d78 EFLAGS: 00010246
RAX: d29da7cf2dd17300 RBX: ffffea0006c30400 RCX: 0000000000000046
RDX: 0000000000000000 RSI: ffffffff8e935905 RDI: ffff8881720f1e00
RBP: dffffc0000000000 R08: ffffffff9014c6eb R09: 1ffffffff20298dd
R10: dffffc0000000000 R11: fffffbfff20298de R12: 0000000000000001
R13: ffffea0006c30408 R14: 1ffffd4000d86080 R15: 1ffffd4000d86081
FS:  00007f9243ca06c0(0000) GS:ffff8882a7801000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 00007fb8ff871a20 CR3: 000000016d7f6000 CR4: 00000000000006f0
Call Trace:
 <TASK>
 collapse_file mm/khugepaged.c:2426 [inline]
 collapse_pmd+0x389d/0x6bd0 mm/khugepaged.c:2869
 collapse_single_pmd+0x1c74/0x36b0 mm/khugepaged.c:2921
 madvise_collapse+0x3e7/0x920 mm/khugepaged.c:3313
 madvise_vma_behavior+0xffe/0x4cb0 mm/madvise.c:1390
 madvise_walk_vmas+0x57d/0xb70 mm/madvise.c:1742
 madvise_do_behavior+0x385/0x540 mm/madvise.c:1937
 do_madvise+0x327/0x3a0 mm/madvise.c:2035
 __do_sys_madvise mm/madvise.c:2044 [inline]
 __se_sys_madvise mm/madvise.c:2042 [inline]
 __x64_sys_madvise+0xa6/0xc0 mm/madvise.c:2042
 do_syscall_x64 arch/x86/entry/syscall_64.c:61 [inline]
 do_syscall_64+0x171/0x540 arch/x86/entry/syscall_64.c:89
 entry_SYSCALL_64_after_hwframe+0x77/0x7f
RIP: 0033:0x7f9242da8fd9
Code: ff c3 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 48 89 f8 48 89 f7 48 89 d6 48 89 ca 4d 89 c2 4d 89 c8 4c 8b 4c 24 08 0f 05 <48> 3d 01 f0 ff ff 73 01 c3 48 c7 c1 e8 ff ff ff f7 d8 64 89 01 48
RSP: 002b:00007f9243ca0028 EFLAGS: 00000246 ORIG_RAX: 000000000000001c
RAX: ffffffffffffffda RBX: 00007f9243026180 RCX: 00007f9242da8fd9
RDX: 0000000000000019 RSI: 000000000060005f RDI: 0000200000000000
RBP: 00007f9242e37fed R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000246 R12: 0000000000000000
R13: 00007f9243026218 R14: 00007f9243026180 R15: 00007fff1d17f228
 </TASK>


***

If these findings have caused you to resend the series or submit a
separate fix, please add the following tag to your commit message:
  Tested-by: syzbot@syzkaller.appspotmail.com

---
This report is generated by a bot. It may contain errors.
syzbot ci engineers can be reached at syzkaller@googlegroups.com.
