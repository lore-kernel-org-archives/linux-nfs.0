Return-Path: <SRS0=Ptm/=RD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D2E7C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Feb 2019 10:10:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1B03F2183F
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Feb 2019 10:10:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732220AbfB1KKG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Feb 2019 05:10:06 -0500
Received: from out30-45.freemail.mail.aliyun.com ([115.124.30.45]:60842 "EHLO
        out30-45.freemail.mail.aliyun.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1730388AbfB1KKG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Feb 2019 05:10:06 -0500
X-Alimail-AntiSpam: AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04427;MF=jiufei.xue@linux.alibaba.com;NM=1;PH=DS;RN=5;SR=0;TI=SMTPD_---0TLYIJtD_1551348603;
Received: from ali-186590e05fa3.local(mailfrom:jiufei.xue@linux.alibaba.com fp:SMTPD_---0TLYIJtD_1551348603)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 28 Feb 2019 18:10:03 +0800
From:   Jiufei Xue <jiufei.xue@linux.alibaba.com>
Subject: [bug report] task hang while testing xfstests generic/323
To:     bfields@fieldses.org
Cc:     Anna.Schumaker@Netapp.com, trond.myklebust@primarydata.com,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Joseph Qi <joseph.qi@linux.alibaba.com>
Message-ID: <fa8ca171-b260-3e5a-d69c-13f263f5bb9c@linux.alibaba.com>
Date:   Thu, 28 Feb 2019 18:10:03 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.3.3
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

when I tested xfstests/generic/323 with NFSv4.1 and v4.2, the task
changed to zombie occasionally while a thread is hanging with the
following stack:

[<0>] rpc_wait_bit_killable+0x1e/0xa0 [sunrpc]
[<0>] nfs4_do_close+0x21b/0x2c0 [nfsv4]
[<0>] __put_nfs_open_context+0xa2/0x110 [nfs]
[<0>] nfs_file_release+0x35/0x50 [nfs]
[<0>] __fput+0xa2/0x1c0
[<0>] task_work_run+0x82/0xa0
[<0>] do_exit+0x2ac/0xc20
[<0>] do_group_exit+0x39/0xa0
[<0>] get_signal+0x1ce/0x5d0
[<0>] do_signal+0x36/0x620
[<0>] exit_to_usermode_loop+0x5e/0xc2
[<0>] do_syscall_64+0x16c/0x190
[<0>] entry_SYSCALL_64_after_hwframe+0x44/0xa9
[<0>] 0xffffffffffffffff

Since commit 12f275cdd163(NFSv4: Retry CLOSE and DELEGRETURN on
NFS4ERR_OLD_STATEID), the client will retry to close the file when
stateid generation number in client is lower than server. 

The original intention of this commit is retrying the operation while
racing with an OPEN. However, in this case the stateid generation remains
mismatch forever.

Any suggestions?

Thanks,
Jiufei
