Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F09DC4360C
	for <linux-nfs@archiver.kernel.org>; Tue,  4 May 2021 18:08:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 4CE98613DB
	for <linux-nfs@archiver.kernel.org>; Tue,  4 May 2021 18:08:30 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232302AbhEDSJU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 May 2021 14:09:20 -0400
Received: from mga06.intel.com ([134.134.136.31]:23654 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S232340AbhEDSJP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 May 2021 14:09:15 -0400
IronPort-SDR: c6fUU7CZB4xOjZDtH/txRIu7j3hvim8iIzMnQvtiAjpYKCMQjU7EocNLA9OrRfg5nAqWY2sMU6
 7WOpanFb27IA==
X-IronPort-AV: E=McAfee;i="6200,9189,9974"; a="259327438"
X-IronPort-AV: E=Sophos;i="5.82,272,1613462400"; 
   d="scan'208";a="259327438"
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga104.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 04 May 2021 11:08:06 -0700
IronPort-SDR: 6MbDAXXNIOyXh4YlcR4bicmAxwiyVfOwmJ3NMlnyfgLTG0vHrxvVOoK9RbDAd7dlhd8JpCrNnl
 j2MVD0AWqjnA==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.82,272,1613462400"; 
   d="scan'208";a="607105009"
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga005.jf.intel.com with ESMTP; 04 May 2021 11:08:04 -0700
Received: by black.fi.intel.com (Postfix, from userid 1003)
        id AFA872E4; Tue,  4 May 2021 21:08:23 +0300 (EEST)
From:   Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To:     "J. Bruce Fields" <bfields@redhat.com>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Cc:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Andy Shevchenko <andy@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v3 03/15] lib/string_helpers: Drop indentation level in string_escape_mem()
Date:   Tue,  4 May 2021 21:08:07 +0300
Message-Id: <20210504180819.73127-4-andriy.shevchenko@linux.intel.com>
X-Mailer: git-send-email 2.30.2
In-Reply-To: <20210504180819.73127-1-andriy.shevchenko@linux.intel.com>
References: <20210504180819.73127-1-andriy.shevchenko@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The only one conditional is left on the upper level, move the rest
to the same level and drop indentation level. No functional changes.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 lib/string_helpers.c | 36 ++++++++++++++++++------------------
 1 file changed, 18 insertions(+), 18 deletions(-)

diff --git a/lib/string_helpers.c b/lib/string_helpers.c
index b10a18b4663b..e3ef9f86cc34 100644
--- a/lib/string_helpers.c
+++ b/lib/string_helpers.c
@@ -515,29 +515,29 @@ int string_escape_mem(const char *src, size_t isz, char *dst, size_t osz,
 		 * In these cases we just pass through a character to the
 		 * output buffer.
 		 */
-		if (is_dict && !strchr(only, c)) {
-			/* do nothing */
-		} else {
-			if (isprint(c) &&
-			    flags & ESCAPE_NP && escape_passthrough(c, &p, end))
-				continue;
+		if (is_dict && !strchr(only, c) &&
+					  escape_passthrough(c, &p, end))
+			continue;
 
-			if (flags & ESCAPE_SPACE && escape_space(c, &p, end))
-				continue;
+		if (isprint(c) &&
+		    flags & ESCAPE_NP && escape_passthrough(c, &p, end))
+			continue;
 
-			if (flags & ESCAPE_SPECIAL && escape_special(c, &p, end))
-				continue;
+		if (flags & ESCAPE_SPACE && escape_space(c, &p, end))
+			continue;
 
-			if (flags & ESCAPE_NULL && escape_null(c, &p, end))
-				continue;
+		if (flags & ESCAPE_SPECIAL && escape_special(c, &p, end))
+			continue;
 
-			/* ESCAPE_OCTAL and ESCAPE_HEX always go last */
-			if (flags & ESCAPE_OCTAL && escape_octal(c, &p, end))
-				continue;
+		if (flags & ESCAPE_NULL && escape_null(c, &p, end))
+			continue;
 
-			if (flags & ESCAPE_HEX && escape_hex(c, &p, end))
-				continue;
-		}
+		/* ESCAPE_OCTAL and ESCAPE_HEX always go last */
+		if (flags & ESCAPE_OCTAL && escape_octal(c, &p, end))
+			continue;
+
+		if (flags & ESCAPE_HEX && escape_hex(c, &p, end))
+			continue;
 
 		escape_passthrough(c, &p, end);
 	}
-- 
2.30.2

