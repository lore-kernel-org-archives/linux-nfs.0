From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 13/22] xdr: Add an export for the helper function write_bytes_to_xdr_buf()
Date: Wed, 14 Apr 2010 13:36:49 -0400
Message-ID: <1271266618-26016-14-git-send-email-Trond.Myklebust@netapp.com>
References: <1271266618-26016-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-3-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-4-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-5-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-6-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-7-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-8-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-9-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-10-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-11-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-12-git-send-email-Trond.Myklebust@netapp.com>
 <1271266618-26016-13-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48907 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756554Ab0DNRhU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Apr 2010 13:37:20 -0400
Received: from localhost.localdomain (pd07336a.hq.netapp.com [10.58.61.110] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3EHawK9021574
	for <linux-nfs@vger.kernel.org>; Wed, 14 Apr 2010 10:37:06 -0700 (PDT)
In-Reply-To: <1271266618-26016-13-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Signed-off-by: Steve Dickson <steved@redhat.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 net/sunrpc/xdr.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 2763fde..a1f82a8 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -762,6 +762,7 @@ int write_bytes_to_xdr_buf(struct xdr_buf *buf, unsigned int base, void *obj, un
 	__write_bytes_to_xdr_buf(&subbuf, obj, len);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(write_bytes_to_xdr_buf);
 
 int
 xdr_decode_word(struct xdr_buf *buf, unsigned int base, u32 *obj)
-- 
1.6.6.1

