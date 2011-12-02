Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e33.co.us.ibm.com ([32.97.110.151]:58354 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932066Ab1LBSZo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Dec 2011 13:25:44 -0500
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Fri, 2 Dec 2011 11:25:43 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pB2IPWZW051188
	for <linux-nfs@vger.kernel.org>; Fri, 2 Dec 2011 11:25:36 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pB2IPWC0017266
	for <linux-nfs@vger.kernel.org>; Fri, 2 Dec 2011 11:25:32 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id pB2IPWTI017258
	for <linux-nfs@vger.kernel.org>; Fri, 2 Dec 2011 11:25:32 -0700
Date: Fri, 2 Dec 2011 12:25:32 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: overhaul of direct IO NFS code
Message-ID: <20111202182532.GA22611@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond, do you happen to have any patches regarding the rewrite you
mention below? We would love to test them or help in anyway we can.

Thanks, Malahal.

>> On Tue, Apr 12, 2011 at 11:49:29AM -0400, Trond Myklebust wrote:
>> 
>> What is the exact plan?  Split the direct I/O into two passes, one
>> to lock down the user pages and then a second one to send the pages
>> over the wire, which is shared with the writeback code?  If that's
>> the case it should naturally allow plugging in a scheme like Badari
>> to send pages from different iovecs in a single on the wire request -
>> after all page cache pages are non-continuous in virtual and physical
>> memory, too.
>
>You can't lock the user pages unfortunately: they may need to be faulted
>in.
>
>What I was thinking of doing is splitting out the code in the RPC
>callbacks that plays around with page flags and puts the pages on the
>inode's dirty list so that they don't get called in the case of
>O_DIRECT.
>I then want to attach the O_DIRECT pages to the nfsi->nfs_page_tree
>radix tree so that they can be tracked by the NFS layer. I'm assuming
>that nobody is going to be silly enough to require simultaneous writes
>via O_DIRECT to the same locations.
>Then we can feed the O_DIRECT pages into nfs_page_async_flush() so that
>they share the existing page cache write coalescing and pnfs code.
>
>The commit code will be easy to reuse too, since the requests are listed
>in the radix tree and so nfs_scan_list() can find and process them in
>the usual fashion.
>
>The main problem that I have yet to figure out is what to do if the
>server flags a reboot and the requests need to be resent. One option I'm
>looking into is using the aio 'kick handler' to resubmit the writes.
>Another may be to just resend directly from the nfsiod work queue.
>
>> When do you plan to release your read/write code re-write?  If it's
>> not anytime soon how is applying Badari's patch going to hurt?  Most
>> of it probably will get reverted with a complete rewrite, but at least
>> the logic to check which direct I/O iovecs can coalesced would stay
>> in the new world order.
>
>I'm hoping that I can do the rewrite fairly quickly once the resend
>problem is solved. It shouldn't be more than a couple of weeks of
>coding.

