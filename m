Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 206.83.70.73.ptr.us.xo.net ([206.83.70.73]:40889 "EHLO
	king.tilera.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753328Ab1HKTiG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 15:38:06 -0400
Message-Id: <201108111938.p7BJc44U012947@farm-0002.internal.tilera.com>
From: Chris Metcalf <cmetcalf@tilera.com>
Date: Thu, 11 Aug 2011 15:32:25 -0400
Subject: [PATCH v2] nfs: fix a minor do_div portability issue
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Dean Hildebrand <dhildebz@umich.edu>
In-Reply-To: <4E441F17.7090504@panasas.com>
References: <201108101803.p7AI36eV008484@farm-0023.internal.tilera.com> <4E42FFDC.9090103@panasas.com> <4E43D88A.3060303@tilera.com> <4E441F17.7090504@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This change modifies filelayout_get_dense_offset() to use the functions
in math64.h and thus avoid a 32-bit platform compile error trying to
use do_div() on an s64 type.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/nfs/nfs4filelayout.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index e8915d4..3ecb14f 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -49,12 +49,13 @@ filelayout_get_dense_offset(struct nfs4_filelayout_segment *flseg,
 {
 	u32 stripe_width = flseg->stripe_unit * flseg->dsaddr->stripe_count;
 	u64 tmp;
+	u32 rem;
 
 	offset -= flseg->pattern_offset;
-	tmp = offset;
-	do_div(tmp, stripe_width);
+	tmp = div_u64(offset, stripe_width);
+	div_u64_rem(offset, flseg->stripe_unit, &rem);
 
-	return tmp * flseg->stripe_unit + do_div(offset, flseg->stripe_unit);
+	return tmp * flseg->stripe_unit + rem;
 }
 
 /* This function is used by the layout driver to calculate the
-- 
1.6.5.2

