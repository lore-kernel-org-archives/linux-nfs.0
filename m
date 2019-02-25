Return-Path: <SRS0=6MPh=RA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0C18C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Feb 2019 22:27:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9BCAB20842
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Feb 2019 22:27:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="dba/+Xl7"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726845AbfBYW1a (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Feb 2019 17:27:30 -0500
Received: from hqemgate14.nvidia.com ([216.228.121.143]:17030 "EHLO
        hqemgate14.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726575AbfBYW13 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Feb 2019 17:27:29 -0500
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
        id <B5c746bd80000>; Mon, 25 Feb 2019 14:27:36 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 25 Feb 2019 14:27:27 -0800
X-PGP-Universal: processed;
        by hqpgpgate101.nvidia.com on Mon, 25 Feb 2019 14:27:27 -0800
Received: from [10.26.11.173] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Mon, 25 Feb
 2019 22:27:25 +0000
Subject: Re: Regression: SUNRPC: Use poll() to fix up the socket requeue races
To:     Trond Myklebust <trondmy@hammerspace.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-tegra@vger.kernel.org" <linux-tegra@vger.kernel.org>
References: <95702994-6762-e42b-06ee-ae945c2137bd@nvidia.com>
 <ab485d7ba4f9603850b81e6c2242dc25026eabcb.camel@hammerspace.com>
From:   Jon Hunter <jonathanh@nvidia.com>
Message-ID: <88677895-7f89-ae1d-3060-819f4b04f530@nvidia.com>
Date:   Mon, 25 Feb 2019 22:27:22 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <ab485d7ba4f9603850b81e6c2242dc25026eabcb.camel@hammerspace.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
        t=1551133656; bh=I7MyxE+9hg3tFLUS914t6N0EdyIAW91f6NRmxSCzpU8=;
        h=X-PGP-Universal:Subject:To:References:From:Message-ID:Date:
         User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
         X-ClientProxiedBy:Content-Type:Content-Language:
         Content-Transfer-Encoding;
        b=dba/+Xl7tXsZYcIIa441F1nsvYM4ihG3CE+LVZ22tREmcuMjP0omgcNR/me37cYDS
         7Iuz2imibBmCPYwbq/TI7auedWVITIiFxA1U4GKW4sXPEk0okA6yfjgQ72Iiv63d4G
         pkzt132lNcVBdTYoALE/pnsf8XnnDaonECDsY1fgCgIVGkdBi8uimMGQqRsWVrQmJw
         KKSaLE8LlZq5ghWvHusTW5xjJiSUQi+UkqJdr5EYwENjKsr2J/locHCCFE+OgSNKVt
         mAsoeo9qbF3cLZotM254DjUpr+gLpBr5jO3Cqr6nHAxMg8K+baZelhCPif59jkqXqq
         g7WDvegzwOleg==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


On 25/02/2019 21:03, Trond Myklebust wrote:
> On Mon, 2019-02-25 at 20:25 +0000, Jon Hunter wrote:
>> Hi Trond,
>>
>> Starting in next-20190222 I have observed a regression with NFS
>> causing
>> some of our boards to fail to boot. Bisect points to your commit ...
>>
>> commit 0ffe86f48026b7f34db22d1004bc9992f0db8b33
>> Author: Trond Myklebust <trond.myklebust@hammerspace.com>
>> Date:   Wed Jan 30 14:51:26 2019 -0500
>>
>>     SUNRPC: Use poll() to fix up the socket requeue races
>>
>>
>> After reverting this on top of -next I no longer see the problem. I
>> have
>> not had chance to look any closer, but wanted to see if you had any
>> ideas what might be the problem.
>>
>> Cheers
>> Jon
> 
> What kind of boot is this? UDP or TCP? nfsroot? NFSv3 or NFSv4? 

This is nfsroot. I don't specify any particular NFS version from 
the kernel cmdline, but this is seen with ARM kernel configs
tegra_defconfig and multi_v7_defconfig. 

Looking at the logs I am seeing the following crash which appears
to point to UDP ...

[    8.032956] Unable to handle kernel NULL pointer dereference at virtual address 00000024
[    8.041137] pgd = (ptrval)
[    8.043858] [00000024] *pgd=00000000
[    8.047437] Internal error: Oops: 5 [#1] SMP ARM
[    8.052049] Modules linked in:
[    8.055104] CPU: 1 PID: 100 Comm: kworker/u9:2 Not tainted 5.0.0-rc7-next-20190222-g94a4752 #1
[    8.063699] Hardware name: NVIDIA Tegra SoC (Flattened Device Tree)
[    8.069960] Workqueue: xprtiod xs_udp_data_receive_workfn
[    8.075353] PC is at udp_poll+0x30/0x64
[    8.079178] LR is at udp_poll+0x10/0x64
[    8.083006] pc : [<c0d3be08>]    lr : [<c0d3bde8>]    psr: 20000113
[    8.089257] sp : e8963ea8  ip : 00000000  fp : 00001064
[    8.094471] r10: 00000000  r9 : e8963ef4  r8 : e8963efc
[    8.099687] r7 : e940db34  r6 : 00000000  r5 : e9d1c540  r4 : 00000345
[    8.106203] r3 : c0d3bdd8  r2 : e8908cc0  r1 : e8908cc0  r0 : e89089c0
[    8.112718] Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
[    8.119843] Control: 10c5387d  Table: 8020406a  DAC: 00000051
[    8.125579] Process kworker/u9:2 (pid: 100, stack limit = 0x(ptrval))
[    8.132008] Stack: (0xe8963ea8 to 0xe8964000)
[    8.136352] 3ea0:                   e940d800 e940db04 e89089c0 c0dcac04 fffffff5 00000000
[    8.144515] 3ec0: e88f4400 c0dcae80 e8963efc e8963ef4 e940da58 e940d800 c187c680 e8941b58
[    8.152681] 3ee0: 000010f0 e940da50 e940db44 00000000 e8963f44 fffffff5 00000000 00000000
[    8.160838] 3f00: e894247c ea203180 e940db34 ea3f5c00 e940db38 ea35e500 00000000 00000000
[    8.169001] 3f20: c188ef50 c035f21c ea3f5c00 ea3f5c00 e8962018 ea203180 ea3f5c00 ea3f5c18
[    8.177164] 3f40: e8962018 c188e91c ea203194 c1703d00 00000088 c035f548 e890d05c e8962000
[    8.185327] 3f60: ea200480 c1703d00 e890d05c e890d040 ea200480 00000000 e890d05c ea203180
[    8.193492] 3f80: c035f508 ea433ebc 00000000 c0364810 ea200480 c03646ec 00000000 00000000
[    8.201657] 3fa0: 00000000 00000000 00000000 c03010e8 00000000 00000000 00000000 00000000
[    8.209815] 3fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[    8.217979] 3fe0: 00000000 00000000 00000000 00000000 00000013 00000000 00000000 00000000
[    8.226154] [<c0d3be08>] (udp_poll) from [<c0dcac04>] (xs_poll_check_readable+0x30/0x70)
[    8.234241] [<c0dcac04>] (xs_poll_check_readable) from [<c0dcae80>] (xs_udp_data_receive_workfn+0x23c/0x2a0)
[    8.244062] [<c0dcae80>] (xs_udp_data_receive_workfn) from [<c035f21c>] (process_one_work+0x164/0x450)
[    8.253359] [<c035f21c>] (process_one_work) from [<c035f548>] (worker_thread+0x40/0x524)
[    8.261444] [<c035f548>] (worker_thread) from [<c0364810>] (kthread+0x124/0x154)
[    8.268834] [<c0364810>] (kthread) from [<c03010e8>] (ret_from_fork+0x14/0x2c)
[    8.276044] Exception stack(0xe8963fb0 to 0xe8963ff8)
[    8.281084] 3fa0:                                     00000000 00000000 00000000 00000000
[    8.289248] 3fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
[    8.297411] 3fe0: 00000000 00000000 00000000 00000000 00000013 00000000
[    8.304017] Code: e1510002 13844041 e3140040 0a000005 (e5962024) 
[    8.310129] ---[ end trace 52d5b8bca1dce72c ]---
[   19.321470] nfs: server 192.168.99.1 not responding, still trying
[   55.001474] nfs: server 192.168.99.1 not responding, still trying

Cheers
Jon
 

-- 
nvpublic
