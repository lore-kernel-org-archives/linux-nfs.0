From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/10] Next series of IPv6 patches for lockd
Date: Wed, 17 Sep 2008 11:17:13 -0500
Message-ID: <20080917161337.4963.74674.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:21570 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754022AbYIQQYV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2008 12:24:21 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Here are ten more IPv6 patches for lockd, as requested.  There are just
a handful of remaining minor IPv6 patches to finish enabling IPv6 in
lockd.  These can likely wait until we have a complete IPv6 user space
implementation.

Please consider these for 2.6.28.

---

Chuck Lever (10):
      lockd: Use "unsigned short" for lockd_up() "proto" argument
      lockd: IPv6 support for SM_MON / SM_UNMON
      lockd: struct nlm_reboot should contain a full socket address
      lockd: Remove unused fields in the nlm_reboot structure
      lockd: Add helper to sanity check incoming NOTIFY requests
      lockd: Adjust signature of nlm_host_rebooted to handle non-AF_INET
      lockd: change nlmclnt_grant() to take a "struct sockaddr *"
      lockd: Adjust nlmsvc_lookup_host() to accomodate AF_INET6 addresses
      lockd: Adjust nlmclnt_lookup_host() signature to accomodate non-AF_INET
      lockd: Support non-AF_INET addresses in nlm_lookup_host()


 fs/lockd/clntlock.c            |   10 +-
 fs/lockd/host.c                |  189 ++++++++++++++++++++++++++++------------
 fs/lockd/mon.c                 |   76 ++++++++++++----
 fs/lockd/svc.c                 |    5 -
 fs/lockd/svc4proc.c            |   18 +---
 fs/lockd/svcproc.c             |   18 +---
 fs/lockd/xdr.c                 |   30 ++++++
 fs/lockd/xdr4.c                |   29 +++++-
 include/linux/lockd/bind.h     |    2 
 include/linux/lockd/lockd.h    |   63 ++++++++++++-
 include/linux/lockd/sm_inter.h |    2 
 include/linux/lockd/xdr.h      |    5 -
 12 files changed, 315 insertions(+), 132 deletions(-)

-- 
Chuck Lever
