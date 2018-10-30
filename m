Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED55DC2BC61
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 08:49:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 970C920831
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 08:49:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="zhVDtX3k"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 970C920831
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726211AbeJ3RmF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 30 Oct 2018 13:42:05 -0400
Received: from mail.kernel.org ([198.145.29.99]:39172 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726189AbeJ3RmF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 Oct 2018 13:42:05 -0400
Received: from mail-lj1-f175.google.com (mail-lj1-f175.google.com [209.85.208.175])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 7846420831;
        Tue, 30 Oct 2018 08:49:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1540889372;
        bh=DgeLAD47P6b2STrA3ndjaKEOm9xmTaCkl5EkF4rOP54=;
        h=From:Date:Subject:To:From;
        b=zhVDtX3kMTANdLZdkegFIXlaM/zMZ+27qEQdCXfw6uHAlJ2lYMj+2UzOCkpR6EhLM
         7I4r3sUnWMsU9n5fm7bxhCM8QbAm4/T4GbZZIPnHRPtq47qCgu9FtqGt1G5/GFO5tR
         m/rbUHIlPr+2VPidz3RgFxpiW9BbHSu4+AkERkBA=
Received: by mail-lj1-f175.google.com with SMTP id f3-v6so10532094ljk.9;
        Tue, 30 Oct 2018 01:49:32 -0700 (PDT)
X-Gm-Message-State: AGRZ1gJJsaz+OODXZv/xP1UdHPeoGJI6zC29LREPiD4uiiivaMvfJOC8
        MofYByXO6ii2pVArtzyElQ+c6Hm4vyw1hA5aM3k=
X-Google-Smtp-Source: AJdET5d7b9k3071z3Svf18GImVV8Mi9pOloV729YjLKsNBhxEMLzygHOPn9uI2aEt2izI9PmCEkLtDZe9jAnDTzAyP4=
X-Received: by 2002:a2e:5d12:: with SMTP id r18-v6mr12351455ljb.89.1540889370521;
 Tue, 30 Oct 2018 01:49:30 -0700 (PDT)
MIME-Version: 1.0
From:   Krzysztof Kozlowski <krzk@kernel.org>
Date:   Tue, 30 Oct 2018 09:49:18 +0100
X-Gmail-Original-Message-ID: <CAJKOXPe2r22KURddxHDas_NVPdEETnzLEAtbQY3h=tjpF=KinQ@mail.gmail.com>
Message-ID: <CAJKOXPe2r22KURddxHDas_NVPdEETnzLEAtbQY3h=tjpF=KinQ@mail.gmail.com>
Subject: [BISECT] NFSv4 root boot failures on next (Merge remote-tracking
 branch 'vfs/for-next)
To:     Stephen Rothwell <sfr@canb.auug.org.au>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi all,

Since yesterdays next, all my boards booting from NFS root (NFSv4)
experience infinite warnings:

[ 210.199561] ------------[ cut here ]------------
[ 210.204169] WARNING: CPU: 1 PID: 191 at ../lib/iov_iter.c:1082
iov_iter_kvec+0x54/0x5c
[ 210.212048] Modules linked in:
[ 210.215094] CPU: 1 PID: 191 Comm: kworker/u9:1 Tainted: G W
4.19.0-next-20181029 #2
[ 210.224031] Hardware name: SAMSUNG EXYNOS (Flattened Device Tree)
[ 210.230097] Workqueue: xprtiod xs_stream_data_receive_workfn
[ 210.235745] [<c01122c8>] (unwind_backtrace) from [<c010e034>]
(show_stack+0x10/0x14)
[ 210.243475] [<c010e034>] (show_stack) from [<c0a5d3c0>] (dump_stack+0x98/0xc4)
[ 210.250675] [<c0a5d3c0>] (dump_stack) from [<c0126d90>] (__warn+0x10c/0x124)
[ 210.257701] [<c0126d90>] (__warn) from [<c0126ec0>]
(warn_slowpath_null+0x40/0x48)
[ 210.265256] [<c0126ec0>] (warn_slowpath_null) from [<c0481380>]
(iov_iter_kvec+0x54/0x5c)
[ 210.273422] [<c0481380>] (iov_iter_kvec) from [<c0934dd0>]
(xs_stream_data_receive+0x374/0xa20)
[ 210.282105] [<c0934dd0>] (xs_stream_data_receive) from [<c0146b3c>]
(process_one_work+0x230/0x794)
[ 210.291044] [<c0146b3c>] (process_one_work) from [<c01470d0>]
(worker_thread+0x30/0x508)
[ 210.299113] [<c01470d0>] (worker_thread) from [<c014d9e4>]
(kthread+0x138/0x168)
[ 210.306490] [<c014d9e4>] (kthread) from [<c01010b4>] (ret_from_fork+0x14/0x20)
[ 210.313689] Exception stack(0xedad5fb0 to 0xedad5ff8)
[ 210.318709] 5fa0: 00000000 00000000 00000000 00000000
[ 210.326886] 5fc0: 00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000
[ 210.335047] 5fe0: 00000000 00000000 00000000 00000000 00000013 00000000
[ 210.341737] irq event stamp: 259629
[ 210.345130] hardirqs last enabled at (259647): [<c0192c4c>]
console_unlock+0x47c/0x658
[ 210.353102] hardirqs last disabled at (259654): [<c0192894>]
console_unlock+0xc4/0x658
[ 210.361034] softirqs last enabled at (259670): [<c0102618>]
__do_softirq+0x4f0/0x5e4
[ 210.368887] softirqs last disabled at (259681): [<c012ef90>]
irq_exit+0x160/0x16c
[ 210.376303] ---[ end trace fc7bc7f30b280153 ]---

Full console log:
https://krzk.eu/#/builders/25/builds/891/steps/12/logs/serial0

Bisect pointed to:
first bad commit: [3ed975a4b424d84cb50cc76e17fe0b5ab4f16b14] Merge
remote-tracking branch 'vfs/for-next'

Some more details:
1. Arch ARM Linux
2. exynos_defconfig
  - All my Odroid boards (ARMv7, Exynos)
3. Custom VF50 defconfig
  - Toradex Colibri VF50 on Iris board
    ARMv7, UP, Cortext-A5, NXP VF500, 128 MB RAM, 128 MB NAND
    Systemd: v232
4. All boards boot from TFTP with NFS root (NFSv4)

Let me know if you need any more information or help in debugging.

Best regards,
Krzysztof
