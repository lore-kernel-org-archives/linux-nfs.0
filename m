From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/7] Replacements for last week's patches
Date: Fri, 03 Oct 2008 12:49:58 -0400
Message-ID: <20081003162856.10198.20451.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:40636 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753062AbYJCQwH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 12:52:07 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

Here's a patch series to replace the patches you reviewed earlier this
week.  I've addressed the issues you mentioned in your review comments,
and dropped the NSM-related patches that treat the 16-byte opaque as an
address, as discussed.

The last patches I intend to submit for 2.6.28 will address the lack of
a client-side UDP lockd listener.  I will propose a fix later today in
a subsequent patch series.

---

Chuck Lever (7):
      lockd: Remove unused fields in the nlm_reboot structure
      lockd: Add helper to sanity check incoming NOTIFY requests
      lockd: change nlmclnt_grant() to take a "struct sockaddr *"
      lockd: Adjust nlmsvc_lookup_host() to accomodate AF_INET6 addresses
      lockd: Adjust nlmclnt_lookup_host() signature to accomodate non-AF_INET
      lockd: Support non-AF_INET addresses in nlm_lookup_host()
      NLM: Convert nlm_lookup_host() to use a single argument


 fs/lockd/clntlock.c         |   10 +--
 fs/lockd/host.c             |  161 +++++++++++++++++++++++++++++++------------
 fs/lockd/svc4proc.c         |    8 +-
 fs/lockd/svcproc.c          |    8 +-
 fs/lockd/xdr.c              |    2 -
 fs/lockd/xdr4.c             |    2 -
 include/linux/lockd/lockd.h |   56 +++++++++++++--
 include/linux/lockd/xdr.h   |    2 -
 8 files changed, 176 insertions(+), 73 deletions(-)

-- 
Chuck Lever
