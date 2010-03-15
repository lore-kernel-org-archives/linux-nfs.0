From: steved@redhat.com
Subject: [PATCH 12/22] xdr: Add an export for the helper function write_bytes_to_xdr_buf()
Date: Mon, 15 Mar 2010 08:20:17 -0400
Message-ID: <1268655627-18712-13-git-send-email-steved@redhat.com>
References: <1268655627-18712-1-git-send-email-steved@redhat.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:41139 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964905Ab0CON0F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Mar 2010 09:26:05 -0400
Received: from [192.168.62.20] (helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1Nr9Hb-00009j-D5
	for linux-nfs@vger.kernel.org; Mon, 15 Mar 2010 08:20:31 -0400
In-Reply-To: <1268655627-18712-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 net/sunrpc/xdr.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 8bd690c..d17179b 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -761,6 +761,7 @@ int write_bytes_to_xdr_buf(struct xdr_buf *buf, unsigned int base, void *obj, un
 	__write_bytes_to_xdr_buf(&subbuf, obj, len);
 	return 0;
 }
+EXPORT_SYMBOL(write_bytes_to_xdr_buf);
 
 int
 xdr_decode_word(struct xdr_buf *buf, unsigned int base, u32 *obj)
-- 
1.6.6.1

