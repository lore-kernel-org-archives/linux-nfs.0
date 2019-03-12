Return-Path: <SRS0=zOxf=RP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BFBCC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 14:36:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D531D2147C
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 14:36:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="TTKtQvj/"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726422AbfCLOgZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Mar 2019 10:36:25 -0400
Received: from mail-ua1-f66.google.com ([209.85.222.66]:37528 "EHLO
        mail-ua1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726365AbfCLOgY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Mar 2019 10:36:24 -0400
Received: by mail-ua1-f66.google.com with SMTP id x1so858921uaj.4
        for <linux-nfs@vger.kernel.org>; Tue, 12 Mar 2019 07:36:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=miFdhy+rO8WxIMwBaEPzHmmCuezdfROE2T9x9tjc+Q4=;
        b=TTKtQvj/AeviX2OSuIcv+gVeCZTL4wIenEA04/j/zm2GQCIzfW8qxecPIbi1BHDTbc
         bO2s5dcQ2j+iUd5A8/PExhKxV3SI+P45fP0mPVWrC54Smp9vA6WB4E/4lurCw8SKfYqJ
         a1IapJwaA+OMDkDkkJPQhHQUbcdeLq2XmfDZeytGNiey99v+T0Sgo38cvR1/nx+4MYXB
         YSScvehgKiqrkaVpb7r6MEfPBCy7Q5TECleQ83kodcAssq2BVpMZ4mBVU6f9qp6tMfrb
         3qM8SS/kIxKYo3E+KUrAyLdc7iidtT8xFTArzVRbhoMO+kdyRshzISbvQe0Rz/Y5ZByS
         FNyg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=miFdhy+rO8WxIMwBaEPzHmmCuezdfROE2T9x9tjc+Q4=;
        b=UOxxdlS9CzAcKqV4uvDi6SeQ3QXFObe45YLy79SccsM9+i3uasfRjvohGW3HbkA/4F
         KRq6mWd9nN3j5J/ab1pAel01Eazb51DpucE4DZ59Th9LeE+si6Uhw98GmLS7VKpiwhhC
         /8E+bqtO3FF9xiXd57ROsZxlB6jQH1cIVmXTiTca4DV+XGi+5G2VGXnhZXMopTCOMQcD
         NLpi157R6JUHVxCwfGUgq7t1fDhtUq3VL8UHDNojuWvecR6QeViyF+iiFLzCmfi8jfJI
         DlGohU10wX0GTS0kqW8jtobD83j2DRuNKNd4E5bfQL+hSCY2W3xqMhzkDS6cBtByHaol
         fPnw==
X-Gm-Message-State: APjAAAXC03Xy8ERP4kSTEDZwmGAH4HLdogQ4OIhVS1tR4JX4Ep3GMU7S
        w/Ve5wpJq/evYIPBNdUUIB5soyJ8zpyh0gFzqhiEXYvv
X-Google-Smtp-Source: APXvYqx7xHKIQxwmURn2eMjhQN7+wZW3neJsHIunDOFpQGqKxSr2tdIIcmm908ExvNDIX1kiqIOuaAUwVymR03nSkWs=
X-Received: by 2002:ab0:1848:: with SMTP id j8mr4838412uag.51.1552401383454;
 Tue, 12 Mar 2019 07:36:23 -0700 (PDT)
MIME-Version: 1.0
References: <CAN-5tyFt0j9g4iTzoT-HqzKLDvMqq+x1=PxWPBHzAd3seyaqcQ@mail.gmail.com>
 <69C7D007-BA4A-4711-8024-57B26F5BAE5E@oracle.com>
In-Reply-To: <69C7D007-BA4A-4711-8024-57B26F5BAE5E@oracle.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Tue, 12 Mar 2019 10:36:12 -0400
Message-ID: <CAN-5tyED+23WxH3z_yoEGaRaica8DMhKaO+pYOstbU7P=Y6whg@mail.gmail.com>
Subject: Re: oops on a sunrpc tracepoint
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Mar 12, 2019 at 10:33 AM Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>
> > On Mar 12, 2019, at 10:29 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
> >
> > Hi Chuck,
> >
> > Is this a known issue?
>
> Nope.

Ok.
Looks like anything to do with callback channeling trying to use the
trace_event_raw_event_xprt_transmit....
Here's another one:

localhost login: [  467.462259] BUG: unable to handle kernel NULL
pointer dereference at 0000000000000004
[  467.464411] #PF error: [normal kernel read fault]
[  467.465445] PGD 80000000728c1067 P4D 80000000728c1067 PUD 728c0067 PMD 0
[  467.466980] Oops: 0000 [#1] SMP PTI
[  467.467759] CPU: 0 PID: 3517 Comm: NFSv4 callback Not tainted 5.0.0-rc7+ #1
[  467.469393] Hardware name: VMware, Inc. VMware Virtual
Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
[  467.471840] RIP: 0010:trace_event_raw_event_xprt_transmit+0x7c/0xf0 [sunrpc]
[  467.473392] Code: f6 48 85 c0 74 4b 49 8b 94 24 98 00 00 00 48 89
e7 0f b7 92 e0 00 00 00 89 50 08 49 8b 94 24 98 00 00 00 48 8b 92 a8
00 00 00 <8b> 52 04 89 50 0c 41 8b 94 24 a8 00 00 00 0f ca 89 50 10 41
8b 94
[  467.477605] RSP: 0018:ffffabe7434fbcd0 EFLAGS: 00010282
[  467.478793] RAX: ffff99720fc3bce0 RBX: 0000000000000003 RCX: 0000000000000000
[  467.480409] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffabe7434fbcd0
[  467.482011] RBP: ffff99726f631948 R08: 0000000000000246 R09: 0000000000000000
[  467.483591] R10: 0000000070000000 R11: 0000000000000000 R12: ffff997277dfcc00
[  467.485226] R13: 0000000000000000 R14: 0000000000000000 R15: ffff99722fecdca8
[  467.486830] FS:  0000000000000000(0000) GS:ffff99727bc00000(0000)
knlGS:0000000000000000
[  467.488596] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  467.489931] CR2: 0000000000000004 CR3: 00000000270e6006 CR4: 00000000001606f0
[  467.491559] Call Trace:
[  467.492128]  xprt_transmit+0x303/0x3f0 [sunrpc]
[  467.493143]  ? rpc_task_need_encode+0x40/0x40 [sunrpc]
[  467.494328]  call_bc_transmit+0x49/0x170 [sunrpc]
[  467.495379]  __rpc_execute+0x7e/0x3f0 [sunrpc]
[  467.496451]  rpc_run_bc_task+0x78/0xd0 [sunrpc]
[  467.497467]  bc_svc_process+0x281/0x340 [sunrpc]
[  467.498507]  nfs41_callback_svc+0x130/0x1c0 [nfsv4]
[  467.499751]  ? remove_wait_queue+0x60/0x60
[  467.500686]  kthread+0xf5/0x130
[  467.501438]  ? nfs_callback_authenticate+0x50/0x50 [nfsv4]
[  467.502640]  ? kthread_bind+0x10/0x10
[  467.503454]  ret_from_fork+0x1f/0x30


>
>
> > [ 5087.845704] BUG: unable to handle kernel NULL pointer dereference
> > at 0000000000000004
> > [ 5087.848463] #PF error: [normal kernel read fault]
> > [ 5087.849852] PGD 0 P4D 0
> > [ 5087.850618] Oops: 0000 [#1] SMP PTI
> > [ 5087.851577] CPU: 0 PID: 5964 Comm: NFSv4 callback Not tainted 5.0.0-rc7+ #1
> > [ 5087.853388] Hardware name: VMware, Inc. VMware Virtual
> > Platform/440BX Desktop Reference Platform, BIOS 6.00 07/02/2015
> > [ 5087.860280] RIP: 0010:trace_event_raw_event_xprt_enq_xmit+0x6f/0xf0 [sunrpc]
> > [ 5087.862149] Code: 00 00 00 48 89 ee 48 89 e7 e8 7d 69 65 ef 48 85
> > c0 74 4a 41 0f b7 94 24 e0 00 00 00 48 89 e7 89 50 08 49 8b 94 24 a8
> > 00 00 00 <8b> 52 04 89 50 0c 49 8b 94 24 c0 00 00 00 8b 92 a8 00 00 00
> > 0f ca
> > [ 5087.866380] RSP: 0018:ffffc03c43297cf8 EFLAGS: 00010286
> > [ 5087.867797] RAX: ffff9ef936d134a0 RBX: 0000000000000003 RCX: 0000000000000000
> > [ 5087.869456] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffc03c43297cf8
> > [ 5087.871092] RBP: ffff9ef92f5b28f0 R08: 0000000000000246 R09: 0000000000000000
> > [ 5087.872767] R10: fffff11380b706c0 R11: 0000000000000000 R12: ffff9ef9338bda00
> > [ 5087.874659] R13: 0000000000000004 R14: ffff9ef932e813f0 R15: ffff9ef932e81000
> > [ 5087.876538] FS:  0000000000000000(0000) GS:ffff9ef93bc00000(0000)
> > knlGS:0000000000000000
> > [ 5087.879404] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > [ 5087.881202] CR2: 0000000000000004 CR3: 000000000f0f2002 CR4: 00000000001606f0
> > [ 5087.883331] Call Trace:
> > [ 5087.885770]  xprt_request_enqueue_transmit+0x2b6/0x4a0 [sunrpc]
> > [ 5087.887341]  ? rpc_task_need_encode+0x40/0x40 [sunrpc]
> > [ 5087.888710]  call_bc_transmit+0xd5/0x170 [sunrpc]
> > [ 5087.889880]  __rpc_execute+0x7e/0x3f0 [sunrpc]
> > [ 5087.891022]  rpc_run_bc_task+0x78/0xd0 [sunrpc]
> > [ 5087.892097]  bc_svc_process+0x281/0x340 [sunrpc]
> > [ 5087.895456]  nfs41_callback_svc+0x130/0x1c0 [nfsv4]
> > [ 5087.897018]  ? remove_wait_queue+0x60/0x60
> > [ 5087.898038]  kthread+0xf5/0x130
> > [ 5087.899531]  ? nfs_callback_authenticate+0x50/0x50 [nfsv4]
> > [ 5087.900912]  ? kthread_bind+0x10/0x10
> > [ 5087.902438]  ret_from_fork+0x1f/0x30
>
> --
> Chuck Lever
>
>
>
