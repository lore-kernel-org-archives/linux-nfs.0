Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e7.ny.us.ibm.com ([32.97.182.137]:35619 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752829Ab2BFSLI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Feb 2012 13:11:08 -0500
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 6 Feb 2012 13:11:07 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 0514A38C807C
	for <linux-nfs@vger.kernel.org>; Mon,  6 Feb 2012 13:11:04 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q16IB3VQ225472
	for <linux-nfs@vger.kernel.org>; Mon, 6 Feb 2012 13:11:03 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q16IB3v2006634
	for <linux-nfs@vger.kernel.org>; Mon, 6 Feb 2012 16:11:03 -0200
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q16IB3pv006526
	for <linux-nfs@vger.kernel.org>; Mon, 6 Feb 2012 16:11:03 -0200
Date: Mon, 6 Feb 2012 12:11:02 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Check for beginning '/' in the mount path
Message-ID: <20120206181102.GA9086@us.ibm.com>
References: <1328233332-26020-1-git-send-email-malahal@us.ibm.com>
 <4F2BC1C0.8070900@panasas.com>
 <20120203231623.442fefde@notabene.brown>
 <20120203142945.GA31805@us.ibm.com>
 <4F2E620F.5090100@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F2E620F.5090100@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boaz Harrosh [bharrosh@panasas.com] wrote:
> I think that both fixes to umount are important for future/backward
> compatibility with Kernel, And general code resilience. 
> 
> But some kind sole should fix both breakages in /proc/mounts, for
> sure.  Would you know how to fix it?

I guess, fixing the umount is needed and it is easy. I will send a fix.

The kernel side is not as easy! The NFS4 mounts the root first then the
exported path using subtree_mount() which seem to remove the actual
string and replace it with a real path. We can save the devname
somewhere and get it into nfs_show_devname(), but I am not sure that
works.

Thanks, Malahal.

