Return-Path: <SRS0=//lM=OE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3B31C43441
	for <linux-nfs@archiver.kernel.org>; Sun, 25 Nov 2018 06:17:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6BC4220865
	for <linux-nfs@archiver.kernel.org>; Sun, 25 Nov 2018 06:17:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jr/qia6e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BC4220865
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727248AbeKYRHn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 25 Nov 2018 12:07:43 -0500
Received: from mail-lj1-f195.google.com ([209.85.208.195]:40686 "EHLO
        mail-lj1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727245AbeKYRHn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Nov 2018 12:07:43 -0500
Received: by mail-lj1-f195.google.com with SMTP id n18-v6so13715151lji.7;
        Sat, 24 Nov 2018 22:17:22 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=NtGVn51kqdBCBYo/gCk1GBNdRgZNVjTXeAiZ8A7i4Qc=;
        b=jr/qia6eSOG6GVm17mXGOSemA122PAuoBivtmZ3bC6Otqe4B52fzcRiAyiVqJMoHDf
         hve20M5+PVoGtJnHm6FG3JRwVSxpu7AIgRRnp3iqx0iuPgbZZ+rDL9KaqjnR5igtJgdo
         PmiA5O3SVampAP67+cPWSnGkTlpcZs+BtzR2lmE76cqTyMQ51Nk0LR+VaBGdRq2tRkt+
         vs+Jch9KlXcIHJv02GISxXUYUkyX5WYkANWx75dXTkScnVzt8IjXZ9XlzgA6dTaQons6
         9ZJQ4ozg0zhTaAhibQoM45b+CsH9/bo8b9qmn6dm1AkDYK3cE53UF1GFj2JQhrCXqwrq
         LcxA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to:cc;
        bh=NtGVn51kqdBCBYo/gCk1GBNdRgZNVjTXeAiZ8A7i4Qc=;
        b=F1bz4ya/1Uv30UZ5DQhXxchIuQSdHiMXIwfi942Ea/Urap6KgdYkXkQtJldTVQQzxn
         kr3ISX4VxYPlvVAlEjB9OrjJHTvp4sGQwFjzRWyzhasngBukS026cjfCbyIfBSui5BNT
         VW99MiTfbnNasbuPSs1ZvbNljZkbwmUwK7JleNHhBL4ymHVOWvCBI7dWg8Nk9wxhqp1U
         D6Q+GnSmtLoF9aMiXLnxOm8ZjJou8xI0+iHD9fvGINBYtc2grz97YS45HXu9qvkjXWBC
         9viujBpcP1766H4YpLn97Cr9/wI4W4vs9Hf3mQuLpbs7DxKOgWbLDVdmvWBz8J32jrTw
         Wl+Q==
X-Gm-Message-State: AA+aEWYgWUNPEHGykNcPm9j/Rn1g4tlwwwRvB8NNxmJxKMFDjAu4qXF2
        IvB37phD8xwQh53E3fWTVY8kb4s7wgpormmICNI=
X-Google-Smtp-Source: AFSGD/XJ+Cd0cgkug/BqY+RJx3IkVWlEcIFX4FzQtBCJtUjMbYFL7vyf78pMhkj8SyX7rC+BLQbXrHGwqAy/oMamzCM=
X-Received: by 2002:a2e:8989:: with SMTP id c9-v6mr13703096lji.124.1543126641107;
 Sat, 24 Nov 2018 22:17:21 -0800 (PST)
MIME-Version: 1.0
From:   Anatoly Trosinenko <anatoly.trosinenko@gmail.com>
Date:   Sun, 25 Nov 2018 09:17:10 +0300
Message-ID: <CAE5jQCcNCcLX_UvhHFe7BmxE010ULbchd1WN7pDbE2enK-pDZg@mail.gmail.com>
Subject: NFSd: NULL-dereference when writing to v4_end_grace when server is
 not yet started
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello,

When manually exploring the kernel NFSd feature, I have stumbled upon
a NULL-dereference when writing to v4_end_grace when server is not yet
started.

How to reproduce with kvm-xfstests:

1) Checkout fresh master Linux branch (tested with commit e195ca6cb)
2) Copy x84_64-config-4.14 to .config, then enable NFS server v4 and build
3) From `kvm-xfstests shell`:

root@kvm-xfstests:~# mount none /proc/fs/nfsd -t nfsd
root@kvm-xfstests:~# echo Y > /proc/fs/nfsd/v4_end_grace
[   11.986359] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000000
[   11.987187] PGD 800000007af97067 P4D 800000007af97067 PUD 78e9d067 PMD 0
[   11.987774] Oops: 0000 [#1] SMP PTI
[   11.988087] CPU: 0 PID: 281 Comm: bash Not tainted
4.20.0-rc3-xfstests-00306-ge195ca6cb6f #1
[   11.988808] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.11.1-1ubuntu1 04/01/2014
[   11.989575] RIP: 0010:__list_del_entry_valid+0x25/0x90
[   11.990019] Code: c3 0f 1f 40 00 48 b9 00 01 00 00 00 00 ad de 48
8b 07 48 8b 57 08 48 39 c8 74 26 48 b9 00 02 00 00 00 00 ad de 48 39
ca 74 2e <48> 8b 32 48 39 fe 75 3a 48 8b 50 08 48 39 f2 75 48 b8 01 00
00 00
[   11.991610] RSP: 0018:ffffa7d8c088fde8 EFLAGS: 00010207
[   11.992066] RAX: 0000000000000000 RBX: ffff9ac7bc10ec28 RCX: dead000000000200
[   11.992678] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff9ac7bc10ec28
[   11.993291] RBP: ffffa7d8c088fe20 R08: 0000000000000000 R09: 0000000000000001
[   11.993902] R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000002
[   11.994583] R13: ffff9ac7bd8a9e00 R14: ffff9ac7ba56d008 R15: 0000000000000000
[   11.995226] FS:  0000000000000000(0000) GS:ffff9ac7bfc00000(0063)
knlGS:00000000f7d76700
[   11.996018] CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
[   11.996514] CR2: 0000000000000000 CR3: 0000000078c94005 CR4: 0000000000360ef0
[   11.997126] Call Trace:
[   11.997346]  locks_end_grace+0x1d/0x50
[   11.997675]  write_v4_end_grace+0xe7/0x1b0
[   11.998033]  ? nfsctl_transaction_write+0x80/0x80
[   11.998440]  nfsctl_transaction_write+0x45/0x80
[   11.998835]  __vfs_write+0x36/0x1a0
[   11.999141]  ? rcu_read_lock_sched_held+0x6c/0x80
[   11.999550]  ? rcu_sync_lockdep_assert+0x2e/0x60
[   11.999955]  ? __sb_start_write+0x147/0x1b0
[   12.000320]  ? vfs_write+0x161/0x1a0
[   12.000634]  vfs_write+0xba/0x1a0
[   12.000927]  ksys_write+0x52/0xc0
[   12.001220]  do_fast_syscall_32+0x97/0x2d0
[   12.001578]  entry_SYSENTER_compat+0x81/0x93
[   12.001951] CR2: 0000000000000000
[   12.002243] ---[ end trace 4137b5fb8d67f6b5 ]---
[   12.002645] RIP: 0010:__list_del_entry_valid+0x25/0x90
[   12.003089] Code: c3 0f 1f 40 00 48 b9 00 01 00 00 00 00 ad de 48
8b 07 48 8b 57 08 48 39 c8 74 26 48 b9 00 02 00 00 00 00 ad de 48 39
ca 74 2e <48> 8b 32 48 39 fe 75 3a 48 8b 50 08 48 39 f2 75 48 b8 01 00
00 00
[   12.004682] RSP: 0018:ffffa7d8c088fde8 EFLAGS: 00010207
[   12.005133] RAX: 0000000000000000 RBX: ffff9ac7bc10ec28 RCX: dead000000000200
[   12.005746] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff9ac7bc10ec28
[   12.006360] RBP: ffffa7d8c088fe20 R08: 0000000000000000 R09: 0000000000000001
[   12.006974] R10: 0000000000000001 R11: 0000000000000000 R12: 0000000000000002
[   12.007587] R13: ffff9ac7bd8a9e00 R14: ffff9ac7ba56d008 R15: 0000000000000000
[   12.008206] FS:  0000000000000000(0000) GS:ffff9ac7bfc00000(0063)
knlGS:00000000f7d76700
[   12.008898] CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
[   12.009394] CR2: 0000000000000000 CR3: 0000000078c94005 CR4: 0000000000360ef0
[   12.010004] BUG: sleeping function called from invalid context at
include/linux/percpu-rwsem.h:34
[   12.010765] in_atomic(): 1, irqs_disabled(): 1, pid: 281, name: bash
[   12.011311] INFO: lockdep is turned off.
[   12.011652] irq event stamp: 19366
[   12.012025] hardirqs last  enabled at (19365): [<ffffffff89189da6>]
get_page_from_freelist+0x2c6/0x1660
[   12.012862] hardirqs last disabled at (19366): [<ffffffff890015f4>]
trace_hardirqs_off_thunk+0x1a/0x1c
[   12.013658] softirqs last  enabled at (18228): [<ffffffff89c0032f>]
__do_softirq+0x32f/0x440
[   12.014413] softirqs last disabled at (18221): [<ffffffff8908c806>]
irq_exit+0xa6/0xe0
[   12.015091] CPU: 0 PID: 281 Comm: bash Tainted: G      D
4.20.0-rc3-xfstests-00306-ge195ca6cb6f #1
[   12.015934] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.11.1-1ubuntu1 04/01/2014
[   12.016751] Call Trace:
[   12.017056]  dump_stack+0x67/0x90
[   12.017348]  ___might_sleep.cold.14+0x9f/0xaf
[   12.017728]  exit_signals+0x1c/0x200
[   12.018041]  do_exit+0xac/0xb00
[   12.018319]  ? ksys_write+0x52/0xc0
[   12.018626]  rewind_stack_do_exit+0x17/0x20
[   12.019006] note: bash[281] exited with preempt_count 1

Best regards
Anatoly
