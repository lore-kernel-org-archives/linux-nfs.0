Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga02-in.huawei.com ([119.145.14.65]:64987 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751538AbaBNIsp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Feb 2014 03:48:45 -0500
From: Wuqixuan <wuqixuan@huawei.com>
To: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Help to know the stable ver of nfsv4 for commercial app
Date: Fri, 14 Feb 2014 08:47:49 +0000
Message-ID: <BB7C62C2B0732E4DA93834A501E846456C8E98AE@szxema505-mbx.china.huawei.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Myklebust, Bfields, All, 

We are useing nfsv3 in 2.6.34.13 kernel for commucial use. For some reasons(such as security), has requirement to upgrade to nfsv4(still on 2.6.34.x kernel). We did two things: 

1. I passed through the git log of kernel.org of nfs, found after 2010(2.6.34 is released on May 2010, and no update on 2.6.34.x for nfs/nfsd), just for sampling, nfsd/nfs4proc.c has 460 commits while nfs/nfs3proc.c has only 38 commits. 

2. Just enable nfsv4 on 2.6.34.13, got problem(EIO) on just a simple open. Found it's because of one commit(https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=a2c0b9e291208f65221a0ad8a0c80a377707d480), simply remove this commit, now can simply use nfsv4 on 2.6.34.13. 

So we are worried about the stability of nfsv4 on 2.6.34.x. 
If any one has some idea or information about: 

    1. Whether nfsv4 (including nfs/nfs4/sunrpc) of 2.6.34.x is stable enough for commercial use or not. 
    2. If nfsv4 is not stable enough on 2.6.34.x, which version can we use , 3.10 ? or 3.12 ? 
    3. Is there any mature commercial application on nfsv4 on 2.6.34.x or before? Can tell some famous company or app name ?

    Any answer is helpful and welcome. 
    Thanks a lot. 

Best Regards!
Wuqixuan