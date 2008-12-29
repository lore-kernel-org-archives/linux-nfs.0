From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/5] recent patches conflict with Harvey's printf formatters
Date: Mon, 29 Dec 2008 17:20:07 -0500
Message-ID: <20081229221603.28005.42498.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:64602 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753483AbYL2WVW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Dec 2008 17:21:22 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

I pulled from Linus's tree today, and found that Harvey's IP address print
formatters have already been merged.  I had conflicts with some of the NSM
IPv6 patches I've already sent you that use the old NIP macros.

Here are the conflicting patches, updated to use Harvey's new formatters.
You may have already done some of this work to merge your NFSD tree into
linux-next, but I did update at least one patch description.

I have already updated the NFSD patches that are still pending, so you'll
get those changes when I resend that series.

---

Chuck Lever (5):
      NSM: Move nsm_find() to fs/lockd/mon.c
      NSM: Support IPv6 version of mon_name
      NLM: Add helper to handle IPv4 addresses
      NLM: Support IPv6 scope IDs in nlm_display_address()
      NLM: Remove AF_UNSPEC arm in nlm_display_address()


 fs/lockd/clntproc.c            |    6 -
 fs/lockd/host.c                |  121 ------------
 fs/lockd/mon.c                 |  411 +++++++++++++++++++++++++++++-----------
 include/linux/lockd/lockd.h    |   25 ++
 include/linux/lockd/sm_inter.h |   31 ---
 5 files changed, 322 insertions(+), 272 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
