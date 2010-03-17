From: steved@redhat.com
Subject: [PATCH 13/23] xdr: Add an export for the helper function write_bytes_to_xdr_buf()
Date: Wed, 17 Mar 2010 13:02:58 -0400
Message-ID: <1268845388-9516-14-git-send-email-steved@redhat.com>
References: <1268845388-9516-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:43419 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754522Ab0CQR0G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Mar 2010 13:26:06 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1NrweG-0003fC-Jx
	for linux-nfs@vger.kernel.org; Wed, 17 Mar 2010 13:03:12 -0400
In-Reply-To: <1268845388-9516-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 net/sunrpc/xdr.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 8bd690c..3f3e0eb 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -761,6 +761,7 @@ int write_bytes_to_xdr_buf(struct xdr_buf *buf, unsigned int base, void *obj, un
 	__write_bytes_to_xdr_buf(&subbuf, obj, len);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(write_bytes_to_xdr_buf);
 
 int
 xdr_decode_word(struct xdr_buf *buf, unsigned int base, u32 *obj)
-- 
1.6.6.1

