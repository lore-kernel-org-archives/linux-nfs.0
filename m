Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:49131 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751496Ab0JGEaP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Oct 2010 00:30:15 -0400
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Thu, 07 Oct 2010 15:29:46 +1100
Subject: [PATCH 0/2] revised sunrpc deferral patches
Cc: linux-nfs@vger.kernel.org
Message-ID: <20101007042637.26629.60300.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Bruce,
  Here is the incremental clean-up as requested, plus I've fixed the
  problem I found with the cache_limit_deferers patch.
  I think that'll do for now.
  I cannot think of any better way to do what lockd does with
  deferrals, so I think we need to keep deferrals after all.

Thanks,
NeilBrown


---

NeilBrown (2):
      sunrpc: Simplify cache_defer_req and related functions.
      sunrpc/cache: centralise handling of size limit on deferred list.


 net/sunrpc/cache.c |  110 +++++++++++++++++++++++++++-------------------------
 1 files changed, 58 insertions(+), 52 deletions(-)

-- 
Signature

