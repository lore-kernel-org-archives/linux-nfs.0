Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-he1eur01on0133.outbound.protection.outlook.com ([104.47.0.133]:38784
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751881AbdJPIt7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 16 Oct 2017 04:49:59 -0400
Reply-To: skinsbursky@virtuozzo.com
To: linux-nfs@vger.kernel.org
Cc: Sergey Lysanov <Sergey.Lysanov@acronis.com>,
        Stanislav Kinsbursky <skinsbursky@virtuozzo.com>
From: Stanislav Kinsburskiy <skinsbursky@virtuozzo.com>
Subject: [RFC} NFS client issue with exclusive creation when server died in
 the middle
Message-ID: <31f5b837-3e74-753b-2ebd-135c8aaef96f@virtuozzo.com>
Date: Mon, 16 Oct 2017 10:49:51 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

We discovered an issue with NFSv4.0 mount.
Server has crashed (or killed by OOM; it was Ganesha) on exclusive open-create operation after file was actually created, but no response was send to the client.
Server was restarted (with grace period), and next clients attempt to create a file after server is ready fails with EEXIST.
This is, probably, because for each open request client creates opendata and puts new jiffies value as the verifier (in nfs4_opendata_alloc) in the request.
Does it sound like a client issue?

Thanks in advance,
Stanislav Kinsburskii


