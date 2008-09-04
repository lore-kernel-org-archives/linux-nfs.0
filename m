From: Jim Schutt <jaschut@sandia.gov>
Subject: Re: XPRTRDMA max payload?
Date: Thu, 4 Sep 2008 15:39:37 +0000 (UTC)
Message-ID: <loom.20080904T152400-181@post.gmane.org>
References: <B520CA74-F8C7-4D93-BC99-0B784F31C1D9@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:50067 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751436AbYIDPpJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2008 11:45:09 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1KbH14-0005v5-To
	for linux-nfs@vger.kernel.org; Thu, 04 Sep 2008 15:45:03 +0000
Received: from sahp4062.sandia.gov ([134.253.26.11])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2008 15:45:02 +0000
Received: from jaschut by sahp4062.sandia.gov with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2008 15:45:02 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Scott Atchley <atchley@...> writes:

> 
> Hi all,
> 
> I thought that the max payload for XPRTRDMA would be 1 MB. It seems to  
> be set on the client to 23 KB (RPCRDMA_MAX_DATA_SEGS * PAGE_SIZE). The  
> server, on the other hand, sets it to 1 MB (RPCSVC_MAXPAYLOAD_TCP).
> 
> If I try to mount with rdma with:
> 
> # mount.nfs host:/exports /mnt/test -o  
> rdma,port=2050,rsize=1048576,wsize=1048576
> 
> It ignores the size parameters and /proc/mounts shows it is 32 KB.
> 
> Is there a way to increase it at loadtime or runtime or do I need to  
> change RPCRDMA_MAX_DATA_SEGS and recompile?

That's the only way I was able to find to do it.

You'll want this patch also:
http://marc.info/?l=linux-nfs&m=121936891515202&w=2

There are some things on the stack dimensioned by
RPCRDMA_MAX_DATA_SEGS.  I've not encountered any
problems using 16 for RPCRDMA_MAX_DATA_SEGS,
but I've not tried anything bigger.

-- Jim


> 
> Thanks,
> 
> Scott
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@...
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 




