Return-Path: <SRS0=zOxf=RP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA591C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 14:30:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 503CF2147C
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 14:30:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="kmkETVnB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726255AbfCLOaB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Mar 2019 10:30:01 -0400
Received: from mail-vk1-f196.google.com ([209.85.221.196]:38932 "EHLO
        mail-vk1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726192AbfCLOaB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Mar 2019 10:30:01 -0400
Received: by mail-vk1-f196.google.com with SMTP id i68so694437vke.6
        for <linux-nfs@vger.kernel.org>; Tue, 12 Mar 2019 07:30:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:from:date:message-id:subject:to:cc;
        bh=EJnx3DVBz9P/NYsmlT0ljxFEHZxZE5bYtQ1ZXcySoDw=;
        b=kmkETVnBS6o/uIhlFZ5nrGuqU14vllAUaq1M3yBZ+2j2K7Gfijaia5yR1T7msuaHck
         UZB+IREo7r4h/SzLEaAEjhLQJLYsxtTthf9vgzElAHXnhFgpTztY3iJ4S+MM6GYwP254
         5TBGH7Qe7oTjkDwx5wj5lVd6rpkMy6VAkFcpNSZJ6s9DKnD5wtWctAem0axurrICcIJU
         rP2Xw2tzwBr94dKLZY2IKCoXLXBcLJkEOorGMuvhUGBQxc23MOzch3YTYDmJDkdnhBV/
         UfNdSeCYx2PGyr1ugeQed0/xVZRAEC5yPQhawmRTW61pEQd7CpjwPsLK6EU21as7l79Q
         I1Wg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to:cc;
        bh=EJnx3DVBz9P/NYsmlT0ljxFEHZxZE5bYtQ1ZXcySoDw=;
        b=hGoN1KJKkMXyPYdb62HSS585wmV86CjDG+FBBLqLKG+ooiEgoKyfGDIkfkkCgL1cEV
         I5FvgP268QZHjDWzyu+oCR/qZ7e/FF3FXNdGEfuPf2tfr1qqS+5sZnUcike7Rl2Zqx3o
         /Xr/qXY3lZiaeKXOJNwZAa6tZYorZsNinRDZj2lxJzKWJD5GUYHtpxGOLw+7tqLA2yxL
         dDYbp7GrGXOo2v7PCv0IL4g8Fb14j0NNBt/Ve8iD4/gkMq0aUNhAMbhLlVSwGkZ1LCkq
         KU/UY1VF41Dmm2VR19JQWdxD2sCPcMWVKAJI6Ogas/h77ZHOCs7sQ+SClMKt8IQEZlKz
         Hq7Q==
X-Gm-Message-State: APjAAAUJLU0fVITfX/e1aP4giGHKiAscWbvQkS8pKIDI/yvn9JeQmlr8
        ZDnEyGHJWdaW9pvJeGzeRJmnACcbNcijbFxmvcY=
X-Google-Smtp-Source: APXvYqw+fSAnVf/GBFBGiwIXM6uF5XjWKDMJSS5hqhdkoeX6gS5gkAQmqWtBBeRPxR8cyLDvD8E9DOj/UXtLT8BcaR8=
X-Received: by 2002:a1f:682:: with SMTP id 124mr20175402vkg.34.1552401000169;
 Tue, 12 Mar 2019 07:30:00 -0700 (PDT)
MIME-Version: 1.0
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Tue, 12 Mar 2019 10:29:49 -0400
Message-ID: <CAN-5tyFt0j9g4iTzoT-HqzKLDvMqq+x1=PxWPBHzAd3seyaqcQ@mail.gmail.com>
Subject: oops on a sunrpc tracepoint
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Chuck,

Is this a known issue?

[ 5087.845704] BUG: unable to handle kernel NULL pointer dereference
at 0000000000000004
[ 5087.848463] #PF error: [normal kernel read fault]
[ 5087.849852] PGD 0 P4D 0
[ 5087.850618] Oops: 0000 [#1] SMP PTI
[ 5087.851577] CPU: 0 PID: 5964 Comm: NFSv4 callback Not tainted 5.0.0-rc7+ #1
[ 5087.853388] Hardware name: VMware, Inc. VMware Virtual
Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[ 5087.860280] RIP: 0010:trace_event_raw_event_xprt_enq_xmit+0x6f/0xf0 [sunrpc]
[ 5087.862149] Code: 00 00 00 48 89 ee 48 89 e7 e8 7d 69 65 ef 48 85
c0 74 4a 41 0f b7 94 24 e0 00 00 00 48 89 e7 89 50 08 49 8b 94 24 a8
00 00 00 <8b> 52 04 89 50 0c 49 8b 94 24 c0 00 00 00 8b 92 a8 00 00 00
0f ca
[ 5087.866380] RSP: 0018:ffffc03c43297cf8 EFLAGS: 00010286
[ 5087.867797] RAX: ffff9ef936d134a0 RBX: 0000000000000003 RCX: 0000000000000000
[ 5087.869456] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffc03c43297cf8
[ 5087.871092] RBP: ffff9ef92f5b28f0 R08: 0000000000000246 R09: 0000000000000000
[ 5087.872767] R10: fffff11380b706c0 R11: 0000000000000000 R12: ffff9ef9338bda00
[ 5087.874659] R13: 0000000000000004 R14: ffff9ef932e813f0 R15: ffff9ef932e81000
[ 5087.876538] FS:  0000000000000000(0000) GS:ffff9ef93bc00000(0000)
knlGS:0000000000000000
[ 5087.879404] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 5087.881202] CR2: 0000000000000004 CR3: 000000000f0f2002 CR4: 00000000001606f0
[ 5087.883331] Call Trace:
[ 5087.885770]  xprt_request_enqueue_transmit+0x2b6/0x4a0 [sunrpc]
[ 5087.887341]  ? rpc_task_need_encode+0x40/0x40 [sunrpc]
[ 5087.888710]  call_bc_transmit+0xd5/0x170 [sunrpc]
[ 5087.889880]  __rpc_execute+0x7e/0x3f0 [sunrpc]
[ 5087.891022]  rpc_run_bc_task+0x78/0xd0 [sunrpc]
[ 5087.892097]  bc_svc_process+0x281/0x340 [sunrpc]
[ 5087.895456]  nfs41_callback_svc+0x130/0x1c0 [nfsv4]
[ 5087.897018]  ? remove_wait_queue+0x60/0x60
[ 5087.898038]  kthread+0xf5/0x130
[ 5087.899531]  ? nfs_callback_authenticate+0x50/0x50 [nfsv4]
[ 5087.900912]  ? kthread_bind+0x10/0x10
[ 5087.902438]  ret_from_fork+0x1f/0x30
