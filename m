From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/18] kernel NSM support for IPv6 (take 2)
Date: Wed, 05 Nov 2008 12:19:18 -0500
Message-ID: <20081105171300.6773.40121.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:33818 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbYKERTk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:19:40 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Here are patches to implement IPv6 support for the kernel's NSM.
These are different enough from the last pass that you should look
these over again.  I've tried to respond to your previous comments,
and I've provided some additional clean up and enhancement.

I've tested these patches to ensure that NFSv2/v3 lock recovery over
IPv4 continues to work with lockd IPv6 support enabled (by a later
patch).

Please consider these for 2.6.29.

---

Chuck Lever (18):
      NSM: Move nsm_addr() to fs/lockd/mon.c
      NSM: Use same helpers in nsm_get_handle() and nsm_lookup_rebooted()
      NSM: factor nsm_handle initialization out of nsm_get_handle()
      NLM: Remove "create" argument from nsm_find()
      NSM: Remove include/linux/lockd/sm_inter.h
      NSM: Replace IP address as our nlm_reboot lookup key
      NSM: Add nsm_lookup() function
      NLM: Decode "priv" argument of NLMPROC_SM_NOTIFY as an opaque
      NLM: Change nlm_host_rebooted() to take a single nlm_reboot argument
      NSM: Generate "priv" argument to NSMPROC_MON when nsm_handle is created
      NSM: Move NSM program and procedure numbers to fs/lockd/mon.c
      NSM: Move NSM-related XDR data structures to lockd's xdr.h
      NSM: Move NSM-related function and variable declarations to lockd.h
      NSM: move nsm_create()
      NSM: Move nsm_find() to fs/lockd/mon.c
      NLM: Support IPv6 scope IDs in nlm_display_address()
      NSM: Support IPv6 version of mon_name
      NLM: nlm_privileged_requester() doesn't recognize mapped loopback address


 fs/lockd/clntproc.c            |    1 
 fs/lockd/host.c                |  162 +++++------------
 fs/lockd/mon.c                 |  379 ++++++++++++++++++++++++++++++++--------
 fs/lockd/svc.c                 |    1 
 fs/lockd/svc4proc.c            |   13 -
 fs/lockd/svcproc.c             |   13 -
 fs/lockd/svcsubs.c             |    1 
 fs/lockd/xdr.c                 |    5 -
 fs/lockd/xdr4.c                |    5 -
 include/linux/lockd/lockd.h    |   58 ++++--
 include/linux/lockd/sm_inter.h |   48 -----
 include/linux/lockd/xdr.h      |   15 +-
 12 files changed, 400 insertions(+), 301 deletions(-)
 delete mode 100644 include/linux/lockd/sm_inter.h

-- 
Chuck Lever
