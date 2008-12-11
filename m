From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/11] Replacement patches for NSM IPv6 support
Date: Thu, 11 Dec 2008 17:55:36 -0500
Message-ID: <20081211224543.21468.8939.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:22078 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759584AbYLKW4x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Dec 2008 17:56:53 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Here is a set of replacement patches for NSM IPv6 support.  This series
replaces the last 11 patches of the 27 I sent previously.  I've starred
the ones that have have changed since last Friday.

The others are included in case they may not fit over the changed
patches, but I don't expect them to be a problem.

---

Chuck Lever (11):
      lockd: Enable NLM use of AF_INET6
      NLM: Rewrite IPv4 privileged requester's check
      NLM: nlm_privileged_requester() doesn't recognize mapped loopback
		address
      NSM: Move nsm_create()
    * NSM: Move nsm_use_hostnames to mon.c
      NSM: Move nsm_addr() to fs/lockd/mon.c
      NSM: Remove include/linux/lockd/sm_inter.h
    * NSM: Replace IP address as our nlm_reboot lookup key
    * NSM: More clean up of nsm_get_handle()
    * NSM: Refactor nsm_handle creation into a helper function
      NLM: Remove "create" argument from nsm_find()


 fs/lockd/clntproc.c            |    1 
 fs/lockd/host.c                |    5 -
 fs/lockd/mon.c                 |  208 ++++++++++++++++++++++------------------
 fs/lockd/svc.c                 |   15 ++-
 fs/lockd/svc4proc.c            |    2 
 fs/lockd/svcproc.c             |    2 
 fs/lockd/svcsubs.c             |    1 
 fs/lockd/xdr.c                 |    1 
 fs/lockd/xdr4.c                |    1 
 include/linux/lockd/lockd.h    |   34 +++----
 include/linux/lockd/sm_inter.h |   16 ---
 include/linux/lockd/xdr.h      |    1 
 12 files changed, 146 insertions(+), 141 deletions(-)
 delete mode 100644 include/linux/lockd/sm_inter.h

-- 
Chuck Lever
