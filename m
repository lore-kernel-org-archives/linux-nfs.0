From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/6] First set of patches for 2.6.29
Date: Mon, 01 Dec 2008 13:57:25 -0500
Message-ID: <20081201185108.10600.21700.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:30760 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbYLAS6Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2008 13:58:25 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches add some IPv6 support to the Linux kernel's NSM upcall
implementation, and address a couple of shortcomings in the existing
NLM/NSM implementation.

I'd like you to consider these for 2.6.29.

There are 40 more patches I have queued for 2.6.29 that finish IPv6
support in the NSM upcall implementation, enable IPv6 for lockd, and
finish and enable IPv6 support in NFSD.

---

Chuck Lever (6):
      NSM: Serialize SM_MON and SM_UNMON upcalls
      NLM: Clean up nsm_monitor() call
      NLM: Clean up nsm_monitor() call
      NSM: Support IPv6 version of mon_name
      NLM: Support IPv6 scope IDs in nlm_display_address()
      NLM: Remove address eye-catcher buffers from nlm_host


 fs/lockd/host.c                |   53 ++++++++++--------
 fs/lockd/mon.c                 |  120 +++++++++++++++++++++-------------------
 include/linux/lockd/lockd.h    |   21 ++++++-
 include/linux/lockd/sm_inter.h |    2 -
 4 files changed, 109 insertions(+), 87 deletions(-)

-- 
Chuck Lever
