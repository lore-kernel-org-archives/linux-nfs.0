Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ch1ehsobe003.messaging.microsoft.com ([216.32.181.183]:5702
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S967556Ab3DRPkO convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Apr 2013 11:40:14 -0400
Received: from mail7-ch1 (localhost [127.0.0.1])	by mail7-ch1-R.bigfish.com
 (Postfix) with ESMTP id 6F6423E0405	for <linux-nfs@vger.kernel.org>; Thu, 18
 Apr 2013 15:40:12 +0000 (UTC)
Received: from CH1EHSMHS014.bigfish.com (snatpool2.int.messaging.microsoft.com
 [10.43.68.235])	by mail7-ch1.bigfish.com (Postfix) with ESMTP id 8F63A60049
	for <linux-nfs@vger.kernel.org>; Thu, 18 Apr 2013 15:40:10 +0000 (UTC)
From: "Stoltenberg, Matthew" <matthew.stoltenberg@tekcomms.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: sunrpc problem on large machine
Date: Thu, 18 Apr 2013 15:40:05 +0000
Message-ID: <ECF9200F7F201C4CB1319E966C6B7AA716178904@US-PLNO-EXM01-P.global.tektronix.net>
References: <ECF9200F7F201C4CB1319E966C6B7AA716176519@US-PLNO-EXM01-P.global.tektronix.net>
In-Reply-To: <ECF9200F7F201C4CB1319E966C6B7AA716176519@US-PLNO-EXM01-P.global.tektronix.net>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Looking at some of the kernel code, I found that auth_domain_find in
> fs/nfsd/export.c around line 514 is returning NULL.

I added code some printks to auth_domain_lookup() in net/sunrpc/svcauth.c to printk every time loop of hlist_for_each_entry and it's not printing anything so it doesn't look like the write to /proc/net/rpc/auth.unix.ip/channel by exportfs is having any effect.  My off the wall guess is that it's related to NUMA somehow, but I have no way to validate this idea.  Besides, I feel like many other things would be broken if NUMA wasn't working correctly.

> I'm at a complete loss because this exact setup (same kernel exactly, same
> exports, everything) is working on a separate machine.  The only difference is
> the underlying hardware.  My kernel config is attached.

Is there anything else I can add?  Only thing I can think of that I left out is that this is an ext3 filesystem.

