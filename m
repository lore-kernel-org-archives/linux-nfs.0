From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/7] More IPv6 support for lockd
Date: Wed, 03 Sep 2008 14:35:31 -0400
Message-ID: <20080903183411.16867.33715.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:50989 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756179AbYICSiP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2008 14:38:15 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Here's the next set of IPv6-related patches for lockd.  Please consider these
for 2.6.28.

---

Chuck Lever (7):
      lockd: Update nsm_find() to support non-AF_INET addresses
      lockd: Combine __nsm_find() and nsm_find().
      lockd: Support AF_INET6 when hashing addresses in nlm_lookup_host
      lockd: Teach nlm_cmp_addr() to support AF_INET6 addresses
      NSM: Use sockaddr_storage for sm_addr field
      lockd: Use sockaddr_storage for h_saddr field
      lockd: Use sockaddr_storage + length for h_addr field


 fs/lockd/clntlock.c         |    3 +
 fs/lockd/host.c             |  115 ++++++++++++++++++++++++++++---------------
 fs/lockd/mon.c              |    2 -
 fs/lockd/svcsubs.c          |    2 -
 include/linux/lockd/lockd.h |   79 +++++++++++++++++++++++++++---
 5 files changed, 149 insertions(+), 52 deletions(-)

-- 
Chuck Lever
