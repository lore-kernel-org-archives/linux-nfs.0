Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:35883 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261Ab1EITXJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 15:23:09 -0400
Received: by yia27 with SMTP id 27so1910774yia.19
        for <linux-nfs@vger.kernel.org>; Mon, 09 May 2011 12:23:08 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/6] SUNRPC: Remove obsolete comment
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 09 May 2011 15:23:04 -0400
Message-ID: <20110509192304.16449.52561.stgit@matisse.1015granger.net>
In-Reply-To: <20110509191859.16449.73749.stgit@matisse.1015granger.net>
References: <20110509191859.16449.73749.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.  The documenting comment at the top of net/sunrpc/clnt.c is
out of date.  We adopted BSD's RTO estimation mechanism years ago.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index c0b03df..b84d739 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -13,10 +13,6 @@
  *	and need to be refreshed, or when a packet was damaged in transit.
  *	This may be have to be moved to the VFS layer.
  *
- *  NB: BSD uses a more intelligent approach to guessing when a request
- *  or reply has been lost by keeping the RTO estimate for each procedure.
- *  We currently make do with a constant timeout value.
- *
  *  Copyright (C) 1992,1993 Rick Sladkey <jrs@world.std.com>
  *  Copyright (C) 1995,1996 Olaf Kirch <okir@monad.swb.de>
  */

