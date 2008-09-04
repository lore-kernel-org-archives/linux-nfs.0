From: Scott Atchley <atchley-vV262kQ/Wyo@public.gmane.org>
Subject: XPRTRDMA max payload?
Date: Thu, 4 Sep 2008 11:00:02 -0400
Message-ID: <B520CA74-F8C7-4D93-BC99-0B784F31C1D9@myri.com>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1933 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751516AbYIDPAE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2008 11:00:04 -0400
Received: from scott-wlan.sw.myri.com (scott-wlan.sw.myri.com [172.31.162.6])
	by myri.com (8.13.7+Sun/8.13.7) with ESMTP id m84F03Ie021207
	for <linux-nfs@vger.kernel.org>; Thu, 4 Sep 2008 08:00:03 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I thought that the max payload for XPRTRDMA would be 1 MB. It seems to  
be set on the client to 23 KB (RPCRDMA_MAX_DATA_SEGS * PAGE_SIZE). The  
server, on the other hand, sets it to 1 MB (RPCSVC_MAXPAYLOAD_TCP).

If I try to mount with rdma with:

# mount.nfs host:/exports /mnt/test -o  
rdma,port=2050,rsize=1048576,wsize=1048576

It ignores the size parameters and /proc/mounts shows it is 32 KB.

Is there a way to increase it at loadtime or runtime or do I need to  
change RPCRDMA_MAX_DATA_SEGS and recompile?

Thanks,

Scott
