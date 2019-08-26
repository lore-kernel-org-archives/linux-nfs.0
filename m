Return-Path: <SRS0=yNkr=WW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B7CCC3A5A1
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Aug 2019 00:39:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EA8E72080C
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Aug 2019 00:39:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726434AbfHZAjY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 25 Aug 2019 20:39:24 -0400
Received: from mail.cn.fujitsu.com ([183.91.158.132]:27338 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1726312AbfHZAjY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Aug 2019 20:39:24 -0400
X-IronPort-AV: E=Sophos;i="5.64,431,1559491200"; 
   d="scan'208";a="74253732"
Received: from unknown (HELO cn.fujitsu.com) ([10.167.33.5])
  by heian.cn.fujitsu.com with ESMTP; 26 Aug 2019 08:39:22 +0800
Received: from G08CNEXCHPEKD03.g08.fujitsu.local (unknown [10.167.33.85])
        by cn.fujitsu.com (Postfix) with ESMTP id EA3B44CE045C
        for <linux-nfs@vger.kernel.org>; Mon, 26 Aug 2019 08:39:17 +0800 (CST)
Received: from [10.167.226.33] (10.167.226.33) by
 G08CNEXCHPEKD03.g08.fujitsu.local (10.167.33.89) with Microsoft SMTP Server
 (TLS) id 14.3.439.0; Mon, 26 Aug 2019 08:39:35 +0800
Subject: Re: NFS issues about aio and dio test
From:   Su Yanjun <suyj.fnst@cn.fujitsu.com>
To:     <linux-nfs@vger.kernel.org>
CC:     <cuiyue-fnst@cn.fujitsu.com>
References: <975395cc-62f2-843f-cc71-82339b2869cd@cn.fujitsu.com>
Message-ID: <65ea4ea2-548f-1546-059a-af901bba2e87@cn.fujitsu.com>
Date:   Mon, 26 Aug 2019 08:37:41 +0800
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <975395cc-62f2-843f-cc71-82339b2869cd@cn.fujitsu.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
X-Originating-IP: [10.167.226.33]
X-yoursite-MailScanner-ID: EA3B44CE045C.ADA96
X-yoursite-MailScanner: Found to be clean
X-yoursite-MailScanner-From: suyj.fnst@cn.fujitsu.com
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Any ping?

在 2019/8/6 14:08, Su Yanjun 写道:
> Hi,
>
> When I tested xfstests generic/465 with NFS, there was something 
> unexpected.
>
> When memory of NFS server was 10G, test passed.
> But when memory of NFS server was 4G, test failed.
>
> Fail message was as below.
>     non-aio dio test
>     encounter an error: block 4 offset 0, content 62
>     aio-dio test
>     encounter an error: block 1 offset 0, content 62
>
> All of the NFS versions(v3 v4.0 v4.1 v4.2) have  this problem.
> Maybe something is wrong about NFS's I/O operation.
>
> Thanks in advance.
>
>
>
>
>
>
>


