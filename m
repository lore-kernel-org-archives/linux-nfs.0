Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:57374 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752362AbdLCOPs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 3 Dec 2017 09:15:48 -0500
Subject: Difficulties for compilation without extra optimisation
From: SF Markus Elfring <elfring@users.sourceforge.net>
To: kernel-janitors@vger.kernel.org, linux-kselftest@vger.kernel.org,
        linux-nfs@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>
References: <7f072f78-eef4-6d87-d233-cee71dac5a32@users.sourceforge.net>
Message-ID: <a2ac6d05-fdd6-82bb-075e-b7eb81b516fe@users.sourceforge.net>
Date: Sun, 3 Dec 2017 15:15:37 +0100
MIME-Version: 1.0
In-Reply-To: <7f072f78-eef4-6d87-d233-cee71dac5a32@users.sourceforge.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I came along some software modules where I suggested source code adjustments.

Example:
nfs/write: Use common error handling code in nfs_lock_and_join_requests()

https://lkml.org/lkml/2017/11/7/599
https://patchwork.kernel.org/patch/10047013/
https://lkml.kernel.org/r/<7f072f78-eef4-6d87-d233-cee71dac5a32@users.sourceforge.net>

I would like to check corresponding build results then without extra
optimisation applied by the compiler.
But I got surprised by error messages for a command like the following.

elfring@Sonne:~/Projekte/Linux/next-patched> my_cc=/usr/bin/gcc-7 && LANG=C make -j4 CC="${my_cc}" HOSTCC="${my_cc}" EXTRA_CFLAGS='-O0' allmodconfig fs/nfs/write.o
…
In file included from ./include/linux/compiler.h:58:0,
                 from ./include/uapi/linux/stddef.h:1,
                 from ./include/linux/stddef.h:4,
                 from ./include/uapi/linux/posix_types.h:4,
                 from ./include/uapi/linux/types.h:13,
                 from ./include/linux/types.h:5,
                 from fs/nfs/write.c:9:
./arch/x86/include/asm/jump_label.h: In function ‘trace_nfs_writeback_page_enter’:
./include/linux/compiler-gcc.h:275:38: warning: asm operand 0 probably doesn’t match constraints
 #define asm_volatile_goto(x...) do { asm goto(x); asm (""); } while (0)
…


How do you think about to improve this software situation anyhow?

Regards,
Markus
