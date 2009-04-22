From: James Pearson <james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Subject: Support for larger than 32Kb [rw]size in older 2.6 kernels?
Date: Wed, 22 Apr 2009 17:36:39 +0100
Message-ID: <49EF4797.2070402@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251]:53227 "EHLO
	moving-picture.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752317AbZDVRG4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 13:06:56 -0400
Received: from cassini.mpc.local ([172.16.15.37] helo=moving-picture.com)
	by moving-picture.com with esmtp (Exim 4.43)
	id 1LwfR9-0002gp-Bz
	for linux-nfs@vger.kernel.org; Wed, 22 Apr 2009 17:36:39 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We have a number of machines that use RHEL4 kernels that run 3rd party 
software/hardware that we can't upgrade to run on newer kernels.

I've managed (I think!) to backport the large [rw]size patch that went 
into 2.6.16 to the RHEL4 2.6.9 based kernels - taken from:

<http://www.linux-nfs.org/Linux-2.6.x/2.6.15/linux-2.6.15-30-large_wsize_support.dif>

Doing some simple tests over NFS using this patch seems to suggest that 
it works fine.

Although the NFS code between the two kernel is significantly different, 
  it was fairly straight forward to match up where the changes should go 
-  however, I don't pretend to fully understand the code, so is there 
anything that I should be aware of that might cause a problem? i.e. does 
larger [rw]size depend on anything else that that would have been added 
to the kernel since 2.6.9?

One thing that isn't in the RHEL4 is 'rpc_max_payload' - which is used 
as a check on the [rw]size - however, this appears not to be important 
as the maximum [rw]size I can get is 1Mb, which matches the max [rw]size 
with more recent kernels.

Thanks

James Pearson

