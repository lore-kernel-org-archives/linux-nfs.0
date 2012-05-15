Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:44257 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932428Ab2EOMUa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 08:20:30 -0400
Date: Tue, 15 May 2012 08:20:28 -0400
From: Jim Rees <rees@umich.edu>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: ANNOUNCE: nfs-utils-1.2.6 released.
Message-ID: <20120515122028.GA25625@umich.edu>
References: <4FB159DA.2070800@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FB159DA.2070800@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If you're going to use the block layout driver, you'll also want to apply
this patch on top of 1.2.6 to prevent your log from filling with garbage.

>From 76e9f814b0c6a9ef996b14123780bb39f448cafb Mon Sep 17 00:00:00 2001
From: Jim Rees <rees@umich.edu>
Date: Tue, 27 Mar 2012 10:18:39 -0400
Subject: [PATCH 1/2] remove pretty_sig()

This really only works against EMC servers.  There is at least one server
that returns unprintable signatures, which fill the log with garbage (the
spec does not mandate printable signatures).  It could be made more generic,
for example by checking each byte for isprint().  But the signatures are
really only of interest to developers, not admins, so it seems better to
just remove it.

Signed-off-by: Jim Rees <rees@umich.edu>
---
 utils/blkmapd/device-process.c |   29 -----------------------------
 1 file changed, 29 deletions(-)

diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
index 652a7a8..5fe3dff 100644
--- a/utils/blkmapd/device-process.c
+++ b/utils/blkmapd/device-process.c
@@ -49,28 +49,6 @@
 
 #include "device-discovery.h"
 
-static char *pretty_sig(char *sig, uint32_t siglen)
-{
-	static char rs[100];
-	uint64_t sigval;
-	unsigned int i;
-
-	if (siglen <= sizeof(sigval)) {
-		sigval = 0;
-		for (i = 0; i < siglen; i++)
-			sigval |= ((unsigned char *)sig)[i] << (i * 8);
-		sprintf(rs, "0x%0llx", (unsigned long long) sigval);
-	} else {
-		if (siglen > sizeof rs - 4) {
-			siglen = sizeof rs - 4;
-			sprintf(&rs[siglen], "...");
-		} else
-			rs[siglen] = '\0';
-		memcpy(rs, sig, siglen);
-	}
-	return rs;
-}
-
 uint32_t *blk_overflow(uint32_t * p, uint32_t * end, size_t nbytes)
 {
 	uint32_t *q = p + ((nbytes + 3) >> 2);
@@ -109,9 +87,6 @@ static int decode_blk_signature(uint32_t **pp, uint32_t * end,
 		 * for mapping, then thrown away.
 		 */
 		comp->bs_string = (char *)p;
-		BL_LOG_INFO("%s: si_comps[%d]: bs_length %d, bs_string %s\n",
-			    __func__, i, siglen,
-			    pretty_sig(comp->bs_string, siglen));
 		p += ((siglen + 3) >> 2);
 	}
 	*pp = p;
@@ -152,10 +127,6 @@ read_cmp_blk_sig(struct bl_disk *disk, int fd, struct bl_sig_comp *comp)
 	}
 
 	ret = memcmp(sig, comp->bs_string, siglen);
-	if (!ret)
-		BL_LOG_INFO("%s: %s sig %s at %lld\n", __func__, dev_name,
-			    pretty_sig(sig, siglen),
-			    (long long)comp->bs_offset);
 
  out:
 	if (sig)
-- 
1.7.9.5

