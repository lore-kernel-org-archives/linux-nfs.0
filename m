From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/6] SLAB-ify nlm_host cache
Date: Wed, 05 Nov 2008 16:51:58 -0500
Message-ID: <20081105215042.16549.50065.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:62341 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbYKEVwM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 16:52:12 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here's a set of patches to change the NLM host cache to use a slab.
It might be nice to combine this with the patches to split the cache.

---

Chuck Lever (6):
      NLM: Documenting comments for public host cache functions
      NLM: Create a SLAB/SLUB cache for nlm_host entries
      NLM: Move nlm_host initialization into a helper
      NLM: Add expiry timeout helper
      NLM: Add rebind timeout helper
      NLM: Always set host->h_rpcclnt to NULL after shutting down RPC client


 fs/lockd/host.c             |  264 +++++++++++++++++++++++++++----------------
 fs/lockd/svc.c              |   12 +-
 include/linux/lockd/lockd.h |    2 
 3 files changed, 177 insertions(+), 101 deletions(-)

-- 
Chuck Lever
