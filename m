Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:37557 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758696Ab1DYSnZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Apr 2011 14:43:25 -0400
Received: by mail-iw0-f174.google.com with SMTP id 34so2050043iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 25 Apr 2011 11:43:25 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/15] SUNRPC: Remove obsolete comment
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 25 Apr 2011 14:43:20 -0400
Message-ID: <20110425184320.5669.71301.stgit@matisse.1015granger.net>
In-Reply-To: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
References: <20110425183405.5669.52507.stgit@matisse.1015granger.net>
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
index ad0b6ea..2d4f8c5 100644
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

