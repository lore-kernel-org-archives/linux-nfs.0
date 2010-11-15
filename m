Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42896 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756230Ab0KOA1r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 14 Nov 2010 19:27:47 -0500
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Mon, 15 Nov 2010 11:27:01 +1100
Subject: [PATCH 0/2] sunrpc: fix two server-side race problems.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20101115002634.19121.7027.stgit@notabene.brown>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi Bruce,
 I found these while trying to diagnose why a customer hit the
 	BUG_ON(xprt->xpt_pool != NULL);
 in svc_xprt_enqueue (in a 2.6.27 based kernel).  I don't think either
 of these actually explain the problem, but they seem to be bugs
 none-the-less.

NeilBrown


---

NeilBrown (2):
      sunrpc: svc_sock_names should hold ref to socket being closed.
      sunrpc: remove xpt_pool


 include/linux/sunrpc/svc_xprt.h |    1 -
 net/sunrpc/svc_xprt.c           |    6 ------
 net/sunrpc/svcsock.c            |   10 ++++++----
 3 files changed, 6 insertions(+), 11 deletions(-)

-- 
Signature

