Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:50788 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752354Ab1CNM4f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Mar 2011 08:56:35 -0400
Received: by mail-iw0-f174.google.com with SMTP id 34so4886177iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 14 Mar 2011 05:56:35 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/12] SUNRPC: Remove obsolete comment
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 14 Mar 2011 08:56:33 -0400
Message-ID: <20110314125633.2413.17802.stgit@matisse.1015granger.net>
In-Reply-To: <20110314125204.2413.8870.stgit@matisse.1015granger.net>
References: <20110314125204.2413.8870.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The documenting comment at the top of net/sunrpc/clnt.c is out of
date.  We adopted BSD's RTO estimation mechanism years ago.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6111ea2..042e7da 100644
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

