Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.0 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNWANTED_LANGUAGE_BODY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF2A5C4360C
	for <linux-nfs@archiver.kernel.org>; Tue,  4 May 2021 10:27:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 936A1611AB
	for <linux-nfs@archiver.kernel.org>; Tue,  4 May 2021 10:27:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230319AbhEDK2B (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 May 2021 06:28:01 -0400
Received: from mga05.intel.com ([192.55.52.43]:42156 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S230411AbhEDK16 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 May 2021 06:27:58 -0400
IronPort-SDR: y/MddAkB9c4E5tYhHd94OllfGSu5Rjj8wfEFke2i5giwHJSk7f7VvRFFcaVO76H1nc2NzlsyHW
 fEaaPU/ZQF9w==
X-IronPort-AV: E=McAfee;i="6200,9189,9973"; a="283356661"
X-IronPort-AV: E=Sophos;i="5.82,272,1613462400"; 
   d="scan'208";a="283356661"
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga105.fm.intel.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 04 May 2021 03:27:03 -0700
IronPort-SDR: +93vyWUtVLx/Kw24slzitaouj13Yl5f3AFkayppKZl08mQUUF2+sh2J3SWIvSqV5PlFwOLOuXT
 zPUY+bPs8xeg==
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.82,272,1613462400"; 
   d="scan'208";a="539134283"
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga004.jf.intel.com with ESMTP; 04 May 2021 03:27:01 -0700
Received: by black.fi.intel.com (Postfix, from userid 1003)
        id EB401B08; Tue,  4 May 2021 13:27:17 +0300 (EEST)
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
Subject: [PATCH v2 13/14] nfsd: Avoid non-flexible API in seq_quote_mem()
Date:   Tue,  4 May 2021 13:26:47 +0300
Message-Id: <20210504102648.88057-14-andriy.shevchenko@linux.intel.com>
X-Mailer: git-send-email 2.30.2
In-Reply-To: <20210504102648.88057-1-andriy.shevchenko@linux.intel.com>
References: <20210504102648.88057-1-andriy.shevchenko@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The seq_escape_mem_ascii() is completely non-flexible and shouldn't be used.
Replace it with properly called seq_escape_mem().

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b517a8794400..cd5eac2ba054 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2351,7 +2351,7 @@ static struct nfs4_client *get_nfsdfs_clp(struct inode *inode)
 static void seq_quote_mem(struct seq_file *m, char *data, int len)
 {
 	seq_printf(m, "\"");
-	seq_escape_mem_ascii(m, data, len);
+	seq_escape_mem(m, data, len, ESCAPE_HEX | ESCAPE_NAP | ESCAPE_APPEND, "\"\\");
 	seq_printf(m, "\"");
 }
 
-- 
2.30.2

