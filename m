From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/17] First set of patches for 2.6.29 (take 2)
Date: Thu, 04 Dec 2008 14:19:35 -0500
Message-ID: <20081204191113.8039.76714.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:20973 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067AbYLDTUP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 14:20:15 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Thanks for the careful review.

Here's the second take of the patches I sent Monday.  I think I've
addressed your concerns, and have split most of these patches into
several smaller ones to facilitate review.  Enough details have
changed that it would be worth a second close inspection.

Again, these patches add partial support for IPv6 to the kernel's
NSM upcall implementation, and introduce various minor clean-ups
and bug fixes.  I'd like them to be considered for 2.6.29.

---

Chuck Lever (17):
      NSM: Check result of SM_UNMON upcall
      NLM: Move the public declaration of nsm_unmonitor() to lockd.h
      NSM: Release nsmhandle in nlm_destroy_host
      NLM: Move the public declaration of nsm_monitor() to lockd.h
      NSM: Make sure to return an error if the SM_MON call result is not zero
      NSM: Remove BUG_ON() in nsm_monitor()
      NLM: Remove redundant printk() in nlmclnt_lock()
      NSM: Use sm_name instead of h_name in nsm_monitor() and nsm_unmonitor()
      NSM: Support IPv6 version of mon_name
      NSM: Use modern style for sm_name field in nsm_handle
      NSM: convert printk(KERN_DEBUG) to a dprintk()
      NSM: Use C99 structure initializer to initialize nsm_args
      NLM: Add helper to handle IPv4 addresses
      NLM: Support IPv6 scope IDs in nlm_display_address()
      NLM: Remove AF_UNSPEC arm in nlm_display_address()
      NLM: Remove address eye-catcher buffers from nlm_host
      NLM: Use modern style for pointer fields in nlm_host


 fs/lockd/clntproc.c            |    6 +--
 fs/lockd/host.c                |   52 ++++++++++++----------
 fs/lockd/mon.c                 |   96 ++++++++++++++++++++--------------------
 include/linux/lockd/lockd.h    |   29 ++++++++----
 include/linux/lockd/sm_inter.h |    2 -
 5 files changed, 98 insertions(+), 87 deletions(-)

-- 
Chuck Lever
