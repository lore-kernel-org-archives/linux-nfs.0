Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hqemgate14.nvidia.com ([216.228.121.143]:1390 "EHLO
	hqemgate14.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742Ab3H0VQ7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Aug 2013 17:16:59 -0400
From: Mark Young <MYoung@nvidia.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Matt Craighead <mcraighead@nvidia.com>
Date: Tue, 27 Aug 2013 14:16:57 -0700
Subject: Issue found with kernel/net/sunrpc/xdr.c
Message-ID: <1FC56210173BB445BD77F608D6FB8D03620A9978B5@HQMAIL03.nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I was pointed to this mailing list by Brian Fields.

 We're currently seeing NFS data corruption, which we traced back to memory corruption that happens in the function _shift_data_right_pages in net/sunrpc/xdr.c.
 
 When we see the issue, we're running a 32bit os with systems running with more than 1GB of physical memory.   The errant behavior appears to be that two calls to kmap_atomic (on 32bit systems with highmem present) with the same physical address (on addresses within highmem)  will return two different vaddrs.    In our assessment, this confuses the memmove code into thinking that the two addresses are non-overlapping in spite of the fact that they are overlapping in physical space.  This, in turn, results in corruption.  
 
 A proposed solution to the problem would involve calling kmap_atomic only once in the case that the pgfrom and pgto are identical, and then re-using the resultant vaddr for both vto and vfrom.

Any insight on the issue or the proposed solution would be greatly appreciated.
-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
