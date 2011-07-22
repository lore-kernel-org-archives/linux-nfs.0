Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:23859 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754238Ab1GVNRo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jul 2011 09:17:44 -0400
From: Ian Campbell <ian.campbell@citrix.com>
To: netdev@vger.kernel.org, linux-nfs@vger.kernel.org
CC: Ian Campbell <ian.campbell@citrix.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org
Subject: [PATCH 02/13] mm: use const struct page for r/o page-flag accessor methods
Date: Fri, 22 Jul 2011 14:17:22 +0100
Message-ID: <1311340653-19336-2-git-send-email-ian.campbell@citrix.com>
In-Reply-To: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

In a subsquent patch I have a const struct page in my hand...

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: linux-kernel@vger.kernel.org
---
 include/linux/page-flags.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 6081493..7d632cc 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -135,7 +135,7 @@ enum pageflags {
  * Macros to create function definitions for page flags
  */
 #define TESTPAGEFLAG(uname, lname)					\
-static inline int Page##uname(struct page *page) 			\
+static inline int Page##uname(const struct page *page) 			\
 			{ return test_bit(PG_##lname, &page->flags); }
 
 #define SETPAGEFLAG(uname, lname)					\
@@ -173,7 +173,7 @@ static inline int __TestClearPage##uname(struct page *page)		\
 	__SETPAGEFLAG(uname, lname)  __CLEARPAGEFLAG(uname, lname)
 
 #define PAGEFLAG_FALSE(uname) 						\
-static inline int Page##uname(struct page *page) 			\
+static inline int Page##uname(const struct page *page) 			\
 			{ return 0; }
 
 #define TESTSCFLAG(uname, lname)					\
-- 
1.7.2.5

