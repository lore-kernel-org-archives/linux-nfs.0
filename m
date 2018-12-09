Return-Path: <SRS0=mp2p=OS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 000BFC07E85
	for <linux-nfs@archiver.kernel.org>; Sun,  9 Dec 2018 17:22:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 91D972081C
	for <linux-nfs@archiver.kernel.org>; Sun,  9 Dec 2018 17:22:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91D972081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726086AbeLIRWK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 9 Dec 2018 12:22:10 -0500
Received: from szxga04-in.huawei.com ([45.249.212.190]:16101 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726078AbeLIRWK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 9 Dec 2018 12:22:10 -0500
Received: from DGGEMS409-HUB.china.huawei.com (unknown [172.30.72.60])
        by Forcepoint Email with ESMTP id 1096561B5EC13;
        Mon, 10 Dec 2018 01:22:01 +0800 (CST)
Received: from [127.0.0.1] (10.184.189.120) by DGGEMS409-HUB.china.huawei.com
 (10.3.19.209) with Microsoft SMTP Server id 14.3.408.0; Mon, 10 Dec 2018
 01:21:55 +0800
From:   "zhangxiaoxu (A)" <zhangxiaoxu5@huawei.com>
To:     <anna.schumaker@netapp.com>, <trond.myklebust@hammerspace.com>,
        <linux-nfs@vger.kernel.org>, Hou Tao <houtao1@huawei.com>,
        <miaoxie@huawei.com>, <zhaohongjiang@huawei.com>
Subject: xfstest generic/089 failed on NFSv2
Message-ID: <c0072355-7300-85d9-6333-7c5e0009fc75@huawei.com>
Date:   Mon, 10 Dec 2018 01:21:43 +0800
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.0
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.184.189.120]
X-CFilter-Loop: Reflected
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi All,
I run the xfstest on nfsv2, the case generic/089 will failed with timeout sometimes.

The top of the stack always on 'nlmclnt_block' function.
And the 'nlmclnt_lock' function will retry every 30s.
So, the test case is killed by the timer and failed.

We open the nlm_debug, found that:
The client send unlock message to server, and the server handle it correct.
But no 'NLM_LCK_GRANTED' message send to the client.

The configuration about the xfstest and nfs server:

The local.config of the xfstest is:
export FSTYP=nfs
export TEST_DEV=192.168.240.61:/export/ext4/test
export TEST_DIR=/nfs/test
export SCRATCH_DEV=192.168.240.61:/export/ext4/scratch
export SCRATCH_MNT=/nfs/scratch
export NFS_MOUNT_OPTIONS="-o acl,rw,relatime,vers=2,lock"

The nfs server just export the share directory.

I don't know why this case is skip from https://wiki.linux-nfs.org/wiki/index.php/Xfstests
If any problem about the fcntl(F_SETLKW) wait so long time?





