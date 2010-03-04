From: Mi Jinlong <mijinlong@cn.fujitsu.com>
Subject: [RFC] SUNRPC connect timeout case network request delay
Date: Thu, 04 Mar 2010 18:12:50 +0800
Message-ID: <4B8F87A2.5080509@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "Trond.Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53544 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754339Ab0CDKLm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Mar 2010 05:11:42 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

When I use the nfs at RHEL with kernel-2.6.31 and nfs-utils-1.2.0, 
I got a problem, but i don't sure.

The process:

Step1: [22:40:9] Open file /mnt/nfs/file(OK)
Step2: [22:40:9] Lock file
       [22:40:9] Lock file success
Step3: [22:40:9] Reboot the nfs server
       If reboot success, put <enter> to continue
Step4: [22:42:16] Write data to file
       [22:42:16] Write data success
Step5: [22:42:16] Unlock file
       [22:46:30] Unlock file success.
Step6: [22:46:30] Close file /mnt/nfs/file
       [22:46:30] Close fiel /mnt/nfs/file success

The problem is at step5, unlock file takes 4 min, it's a long time than expected.
When traceing the kernel, I find SUNRPC call call_connect timeout many times, 
one timeout is 1min.

I think it's a problem of kernel, but i don't know why, can someone help me ?

thanks,
Mi Jinlong

