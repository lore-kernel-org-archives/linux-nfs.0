Return-Path: <SRS0=6MPh=RA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A204C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Feb 2019 20:25:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3882D20842
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Feb 2019 20:25:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="ORlwnw+y"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727100AbfBYUZ1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Feb 2019 15:25:27 -0500
Received: from hqemgate15.nvidia.com ([216.228.121.64]:5050 "EHLO
        hqemgate15.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727021AbfBYUZ1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Feb 2019 15:25:27 -0500
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
        id <B5c744f320002>; Mon, 25 Feb 2019 12:25:22 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 25 Feb 2019 12:25:26 -0800
X-PGP-Universal: processed;
        by hqpgpgate101.nvidia.com on Mon, 25 Feb 2019 12:25:26 -0800
Received: from [10.26.11.173] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Mon, 25 Feb
 2019 20:25:24 +0000
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-tegra <linux-tegra@vger.kernel.org>
From:   Jon Hunter <jonathanh@nvidia.com>
Subject: Regression: SUNRPC: Use poll() to fix up the socket requeue races
Message-ID: <95702994-6762-e42b-06ee-ae945c2137bd@nvidia.com>
Date:   Mon, 25 Feb 2019 20:25:21 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
        t=1551126322; bh=1x51BtUOIkPhsT36Av8f8BaMHTy41AAmuVe0tcm1gXM=;
        h=X-PGP-Universal:To:From:Subject:Message-ID:Date:User-Agent:
         MIME-Version:X-Originating-IP:X-ClientProxiedBy:Content-Type:
         Content-Language:Content-Transfer-Encoding;
        b=ORlwnw+yMe4q/NMvf6OGrIXW/pM83z7w+WgQqZHgMQ4oxr1zT9Z5QKSseLwwkUdk4
         sZu7ThGU7p5Nuh+rtTNlhgrsJR02NMiqk94DJw9WKxczrgbCAwgQdZexmd/7t+d8iB
         nKsGI9hrDIFf6/yrXnB+/jwgrw0xsxuUc29aztXABOm9xpNaFUnMdhFNcwknSlq1it
         kX2661LyT+Rt3bjd//DDUQyspMHL/1bZvS0fw9m5ii72FmHxASUoXl6NGfjM16zVaH
         +T2eSNpOtrcS7iLPa3vOKUeyLh/RIKLy0kB15QiY+78jxkX4cyLjO3e3eFhGMlCs/a
         0bcFSB1axrvzg==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond,

Starting in next-20190222 I have observed a regression with NFS causing
some of our boards to fail to boot. Bisect points to your commit ...

commit 0ffe86f48026b7f34db22d1004bc9992f0db8b33
Author: Trond Myklebust <trond.myklebust@hammerspace.com>
Date:   Wed Jan 30 14:51:26 2019 -0500

    SUNRPC: Use poll() to fix up the socket requeue races


After reverting this on top of -next I no longer see the problem. I have
not had chance to look any closer, but wanted to see if you had any
ideas what might be the problem.

Cheers
Jon
