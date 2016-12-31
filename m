Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:35236 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754666AbcLaQdF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 31 Dec 2016 11:33:05 -0500
Received: by mail-wj0-f196.google.com with SMTP id hb5so30862319wjc.2
        for <linux-nfs@vger.kernel.org>; Sat, 31 Dec 2016 08:33:04 -0800 (PST)
Received: from [192.168.0.29] (cor91-5-78-224-113-112.fbx.proxad.net. [78.224.113.112])
        by smtp.gmail.com with ESMTPSA id f76sm75651395wmd.15.2016.12.31.08.33.02
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 31 Dec 2016 08:33:02 -0800 (PST)
From: omega bk <omegabk@gmail.com>
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Subject: Client nfs hangs during failover.
Message-Id: <23F04B47-088F-4251-991F-EA8A02649049@gmail.com>
Date: Sat, 31 Dec 2016 17:33:01 +0100
To: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

This is my architecture

Nfs1 =E2=80=94=E2=80=94/drbd-pacemaker-corosync/nfs2


Web1 =E2=80=94=E2=80=94=E2=80=94=E2=80=94=E2=80=94 mount nfs share=20
Web2 =E2=80=94=E2=80=94=E2=80=94 =E2=80=94=E2=80=94mount nfs share=20

1) During failover VIP on pacemaker, I noticed my web1 and web2 hang on =
df -h or ls on nfsshare. For about 2 to 3 min.
2) if I set nfsver=3D4, I cannot perform a mount -a.  It only works on =
nfsver=3D3

All my servers are running on centos 7.3.

Could you guys, please help me?

PS: sorry for my bad English, I=E2=80=99m French.

Best regards,

Omega BK=
