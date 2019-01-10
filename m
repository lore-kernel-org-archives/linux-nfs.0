Return-Path: <SRS0=3Jq2=PS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F7A5C43387
	for <linux-nfs@archiver.kernel.org>; Thu, 10 Jan 2019 20:12:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EBB5320665
	for <linux-nfs@archiver.kernel.org>; Thu, 10 Jan 2019 20:12:00 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730052AbfAJUMA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 10 Jan 2019 15:12:00 -0500
Received: from fieldses.org ([173.255.197.46]:48864 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729366AbfAJUMA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 10 Jan 2019 15:12:00 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 7F786315; Thu, 10 Jan 2019 15:11:59 -0500 (EST)
Date:   Thu, 10 Jan 2019 15:11:59 -0500
To:     "zhangxiaoxu (A)" <zhangxiaoxu5@huawei.com>
Cc:     anna.schumaker@netapp.com, trond.myklebust@hammerspace.com,
        linux-nfs@vger.kernel.org, Hou Tao <houtao1@huawei.com>,
        miaoxie@huawei.com, zhaohongjiang@huawei.com
Subject: Re: xfstest generic/089 failed on NFSv2
Message-ID: <20190110201159.GC15492@fieldses.org>
References: <c0072355-7300-85d9-6333-7c5e0009fc75@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c0072355-7300-85d9-6333-7c5e0009fc75@huawei.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 10, 2018 at 01:21:43AM +0800, zhangxiaoxu (A) wrote:
> I run the xfstest on nfsv2, the case generic/089 will failed with timeout sometimes.
> 
> The top of the stack always on 'nlmclnt_block' function.
> And the 'nlmclnt_lock' function will retry every 30s.
> So, the test case is killed by the timer and failed.
> 
> We open the nlm_debug, found that:
> The client send unlock message to server, and the server handle it correct.
> But no 'NLM_LCK_GRANTED' message send to the client.
> 
> The configuration about the xfstest and nfs server:
> 
> The local.config of the xfstest is:
> export FSTYP=nfs
> export TEST_DEV=192.168.240.61:/export/ext4/test
> export TEST_DIR=/nfs/test
> export SCRATCH_DEV=192.168.240.61:/export/ext4/scratch
> export SCRATCH_MNT=/nfs/scratch
> export NFS_MOUNT_OPTIONS="-o acl,rw,relatime,vers=2,lock"
> 
> The nfs server just export the share directory.
> 
> I don't know why this case is skip from https://wiki.linux-nfs.org/wiki/index.php/Xfstests
> If any problem about the fcntl(F_SETLKW) wait so long time?

I've seen intermittent generic/089 failures as well and haven't had the
time to track them down.  From your description it does sound like a
potentialy server bug.

--b.
