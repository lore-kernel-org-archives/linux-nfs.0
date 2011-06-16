Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from blu0-omc3-s18.blu0.hotmail.com ([65.55.116.93]:3414 "EHLO
	blu0-omc3-s18.blu0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751479Ab1FPO6x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2011 10:58:53 -0400
Message-ID: <BLU0-SMTP135422B057EEE4C3CA3C9DEAB6A0@phx.gbl>
Date: Thu, 16 Jun 2011 22:52:12 +0800
From: =?gb2312?B?09q6xg==?= <haohaoweixiao@hotmail.com>
To: "linux-nfs" <linux-nfs@vger.kernel.org>
Subject: In the linux-all-2.6.38 of pnfs, why was pnfs_return_layout removed ?
Content-Type: text/plain; charset="gb2312"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Dear All,
	Dear All,
	I got one problem when testing the read performance of linux-all-2.6.38. I found that the speed was becoming slower with time.(300MB/s-->50MB/s).  Finally,I found the cause of the problem.	In __nfs4_close(), the "LAYOUT RETURN" operation was removed. So the size of  "layout_hash"  becomes bigger and bigger on the pnfs server side. Then more time is spent on searching in __layout_inode_find() function. I wonder why the pnfs_return_layout() in __nfs4_close() was removed ??

Regards,
    	Steven.

----------------------------------------------------------------------
SQUASHME: pnfs: revert layout recall/get/return synchronization 
authorBenny Halevy <bhalevy@panasas.com>
Thu, 24 Feb 2011 02:53:46 +0000 (18:53 -0800)
committerBenny Halevy <bhalevy@panasas.com>
Fri, 25 Mar 2011 08:25:57 +0000 (10:25 +0200)

For now, revert code attempting a "forget-less" client model to match
the pnfs-submit-wave4 forgetful model implementation in preparation
for porting the tree onto it.

Signed-off-by: Benny Halevy bhalevy@panasas.com

