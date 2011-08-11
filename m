Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:35362 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753888Ab1HKUym (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Aug 2011 16:54:42 -0400
Message-ID: <4E444184.9090109@panasas.com>
Date: Thu, 11 Aug 2011 13:54:28 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Chris Metcalf <cmetcalf@tilera.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Dean Hildebrand <dhildebz@umich.edu>
Subject: [PATCH v3] nfs: fix a minor do_div portability issue
References: <201108101803.p7AI36eV008484@farm-0023.internal.tilera.com> <4E42FFDC.9090103@panasas.com> <4E43D88A.3060303@tilera.com> <4E441F17.7090504@panasas.com> <201108111938.p7BJc44U012947@farm-0002.internal.tilera.com>
In-Reply-To: <201108111938.p7BJc44U012947@farm-0002.internal.tilera.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/11/2011 12:32 PM, Chris Metcalf wrote:
> This change modifies filelayout_get_dense_offset() to use the functions
> in math64.h and thus avoid a 32-bit platform compile error trying to
> use do_div() on an s64 type.
> 
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> Cc: Boaz Harrosh <bharrosh@panasas.com>

Thanks
Reviewed-by: Boaz Harrosh <bharrosh@panasas.com>

Just if you don't mind a name change. tmp => stripe_no
while at it.

---
From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH v3] nfs: fix a minor do_div portability issue


This change modifies filelayout_get_dense_offset() to use the functions
in math64.h and thus avoid a 32-bit platform compile error trying to
use do_div() on an s64 type.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
Reviewed-by: Boaz Harrosh <bharrosh@panasas.com>
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
 	u64 stripe_no;
+	u32 rem;
 
 	offset -= flseg->pattern_offset;
-	tmp = offset;
-	do_div(tmp, stripe_width);
+	stripe_no = div_u64(offset, stripe_width);
+	div_u64_rem(offset, flseg->stripe_unit, &rem);
 
-	return tmp * flseg->stripe_unit + do_div(offset, flseg->stripe_unit);
+	return stripe_no * flseg->stripe_unit + rem;
 }
 
 /* This function is used by the layout driver to calculate the
-- 1.6.5.2


