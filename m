Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC337C43460
	for <linux-nfs@archiver.kernel.org>; Tue,  4 May 2021 10:27:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id BFCCF613B4
	for <linux-nfs@archiver.kernel.org>; Tue,  4 May 2021 10:27:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230470AbhEDK2D (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 May 2021 06:28:03 -0400
Received: from mga18.intel.com ([134.134.136.126]:14062 "EHLO mga18.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S230412AbhEDK17 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 May 2021 06:27:59 -0400
IronPort-SDR: oJZYBbPS/zeFQE3gcP/c1mWWKW0Lct6g+aT7Rs3AJ5bAmPY6wxQhZFiVrEkeBcDOCZ2j7NCZ64
 2/d7ubtT4f8g==
X-IronPort-AV: E=McAfee;i="6200,9189,9973"; a="185417085"
X-IronPort-AV: E=Sophos;i="5.82,272,1613462400"; 
   d="scan'208";a="185417085"
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga106.jf.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 04 May 2021 03:27:03 -0700
IronPort-SDR: zc6JCr3F/BuypAWcjCvhFIgGX2Kl8HkBin5YMTx/ANJMHxsJT7wFCejKMh33TM/5xQvtLG/1WI
 S/SOMr4eXLtQ==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.82,272,1613462400"; 
   d="scan'208";a="468452652"
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga001.jf.intel.com with ESMTP; 04 May 2021 03:27:01 -0700
Received: by black.fi.intel.com (Postfix, from userid 1003)
        id AE9E3934; Tue,  4 May 2021 13:27:17 +0300 (EEST)
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
Subject: [PATCH v2 08/14] lib/test-string_helpers: Get rid of trailing comma in terminators
Date:   Tue,  4 May 2021 13:26:42 +0300
Message-Id: <20210504102648.88057-9-andriy.shevchenko@linux.intel.com>
X-Mailer: git-send-email 2.30.2
In-Reply-To: <20210504102648.88057-1-andriy.shevchenko@linux.intel.com>
References: <20210504102648.88057-1-andriy.shevchenko@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Terminators by definition shouldn't accept anything behind.
Make them robust by removing trailing commas.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 lib/test-string_helpers.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/test-string_helpers.c b/lib/test-string_helpers.c
index 079fb12d59cc..3e2def9ccfac 100644
--- a/lib/test-string_helpers.c
+++ b/lib/test-string_helpers.c
@@ -136,7 +136,7 @@ static const struct test_string_2 escape0[] __initconst = {{
 		.flags = ESCAPE_SPACE | ESCAPE_HEX,
 	},{
 		/* terminator */
-	}},
+	}}
 },{
 	.in = "\\h\\\"\a\e\\",
 	.s1 = {{
@@ -150,7 +150,7 @@ static const struct test_string_2 escape0[] __initconst = {{
 		.flags = ESCAPE_SPECIAL | ESCAPE_HEX,
 	},{
 		/* terminator */
-	}},
+	}}
 },{
 	.in = "\eb \\C\007\"\x90\r]",
 	.s1 = {{
@@ -201,7 +201,7 @@ static const struct test_string_2 escape0[] __initconst = {{
 		.flags = ESCAPE_NP | ESCAPE_HEX,
 	},{
 		/* terminator */
-	}},
+	}}
 },{
 	/* terminator */
 }};
@@ -217,7 +217,7 @@ static const struct test_string_2 escape1[] __initconst = {{
 		.flags = ESCAPE_HEX,
 	},{
 		/* terminator */
-	}},
+	}}
 },{
 	.in = "\\h\\\"\a\e\\",
 	.s1 = {{
@@ -225,7 +225,7 @@ static const struct test_string_2 escape1[] __initconst = {{
 		.flags = ESCAPE_OCTAL,
 	},{
 		/* terminator */
-	}},
+	}}
 },{
 	.in = "\eb \\C\007\"\x90\r]",
 	.s1 = {{
@@ -233,7 +233,7 @@ static const struct test_string_2 escape1[] __initconst = {{
 		.flags = ESCAPE_OCTAL,
 	},{
 		/* terminator */
-	}},
+	}}
 },{
 	/* terminator */
 }};
-- 
2.30.2

