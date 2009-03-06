From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/2] Fix NLM GRANT on IPv6-enabled kernels
Date: Fri, 06 Mar 2009 14:08:37 -0500
Message-ID: <20090306190613.17892.26458.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:57417 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754754AbZCFTKI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Mar 2009 14:10:08 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

Here are a couple of patches suitable for 2.6.29 that attempt to
address the NLM GRANT address family matching problem.

I've passed these by the Connectathon locking suite on the client but
otherwise I don't believe I have a test case that exercises the GRANT
callback.

---

Chuck Lever (2):
      NLM: Fix GRANT callback address comparison when IPv6 is enabled
      NLM: Shrink the IPv4-only version of nlm_cmp_addr()


 fs/lockd/clntlock.c         |   51 ++++++++++++++++++++++++++++++++++++++++++-
 include/linux/lockd/lockd.h |    8 +++++++
 2 files changed, 58 insertions(+), 1 deletions(-)

-- 
Chuck Lever
