Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:35725 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbbBWPog (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Feb 2015 10:44:36 -0500
Date: Mon, 23 Feb 2015 18:44:19 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Wang YanQing <udknight@gmail.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [patch] groups: integer underflow in groups_alloc()
Message-ID: <20150223154419.GA2542@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is called from rsc_parse() with a use controlled value.  Say for
example that "gidsetsize" is negative, then we could end up allocating
less than sizeof(struct group_info) leading to memory corruption.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
I copied the NGROUPS_MAX limit from the surrounding code, I'm not
absolutely that it's the correct limit to use.

diff --git a/kernel/groups.c b/kernel/groups.c
index 664411f..e9341b3 100644
--- a/kernel/groups.c
+++ b/kernel/groups.c
@@ -18,6 +18,9 @@ struct group_info *groups_alloc(int gidsetsize)
 	int nblocks;
 	int i;
 
+	if ((unsigned)gidsetsize > NGROUPS_MAX)
+		return NULL;
+
 	nblocks = (gidsetsize + NGROUPS_PER_BLOCK - 1) / NGROUPS_PER_BLOCK;
 	/* Make sure we always allocate at least one indirect block pointer */
 	nblocks = nblocks ? : 1;
