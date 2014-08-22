Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f171.google.com ([209.85.223.171]:60174 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbaHVTKw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2014 15:10:52 -0400
Received: by mail-ie0-f171.google.com with SMTP id at1so7026848iec.30
        for <linux-nfs@vger.kernel.org>; Fri, 22 Aug 2014 12:10:52 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] sunrpc: fix byte-swapping of displayed XID
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Fri, 22 Aug 2014 15:10:50 -0400
Message-ID: <20140822191050.3883.53374.stgit@klimt.1015granger.net>
In-Reply-To: <20140822190835.3883.7581.stgit@klimt.1015granger.net>
References: <20140822190835.3883.7581.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xprt_lookup_rqst() and bc_send_request() display a byte-swapped XID,
but receive_cb_reply() does not.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svcsock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index c24a8ff..6ed8729 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1036,7 +1036,7 @@ static int receive_cb_reply(struct svc_sock *svsk, struct svc_rqst *rqstp)
 			"%s: Got unrecognized reply: "
 			"calldir 0x%x xpt_bc_xprt %p xid %08x\n",
 			__func__, ntohl(calldir),
-			bc_xprt, xid);
+			bc_xprt, ntohl(xid));
 		return -EAGAIN;
 	}
 

