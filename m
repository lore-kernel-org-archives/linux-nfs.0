Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.7 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAAFCC4320E
	for <linux-nfs@archiver.kernel.org>; Fri, 20 Aug 2021 16:39:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C125A61152
	for <linux-nfs@archiver.kernel.org>; Fri, 20 Aug 2021 16:39:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231318AbhHTQkC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 20 Aug 2021 12:40:02 -0400
Received: from mail.kernel.org ([198.145.29.99]:51876 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S232238AbhHTQkB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Aug 2021 12:40:01 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id DCCF86113B;
        Fri, 20 Aug 2021 16:39:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1629477563;
        bh=AQp3LFjVqKf+6JCOVIRxYIEow6Xf7ZVVgy0fQLP+rqs=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=klDFyswU0boWi00o6qUlSahmi0csj5mCM8t6hXOT7WFWvkJjCI6/fvT1e4LIFg+NP
         w/gpXH6t+ho1dN5rgnSMFVG+KtnPoF8x4gevB5zkkcihq3FHZF/ZfUuTG8Qf6bUtRd
         M2glGFTawn8h9sJkUXKrUPfGky7SfkCm5IwBFI1Mq5KdPAvdzQX9HM2TZ38hJvLjCl
         IE7V1B/lQuQZB4UPlh74b1BoESZKCKEZwDeZaa2Y/+CTZlxXGYOz5neUK16BiA0UGF
         b86XwnJO1mYOUZxuUhjWwm8TAVr8x3pW64Scv4WrEGwmZEf5xwGhO82Adjj5g1SNzs
         IoMprsQc5PY2g==
From:   Jeff Layton <jlayton@kernel.org>
To:     torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Cc:     ebiederm@xmission.com, david@redhat.com, willy@infradead.org,
        linux-nfs@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-doc@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
        linux-afs@lists.infradead.org, cluster-devel@redhat.com,
        ocfs2-devel@oss.oracle.com, linux-mm@kvack.org,
        akpm@linux-foundation.org, luto@kernel.org, bfields@fieldses.org,
        rostedt@goodmis.org, stable@vger.kernel.org
Subject: [PATCH v3 1/2] fs: warn about impending deprecation of mandatory locks
Date:   Fri, 20 Aug 2021 12:39:18 -0400
Message-Id: <20210820163919.435135-2-jlayton@kernel.org>
X-Mailer: git-send-email 2.31.1
In-Reply-To: <20210820163919.435135-1-jlayton@kernel.org>
References: <20210820163919.435135-1-jlayton@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

We've had CONFIG_MANDATORY_FILE_LOCKING since 2015 and a lot of distros
have disabled it. Warn the stragglers that still use "-o mand" that
we'll be dropping support for that mount option.

Cc: stable@vger.kernel.org
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/namespace.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index ab4174a3c802..2279473d0d6f 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1716,8 +1716,12 @@ static inline bool may_mount(void)
 }
 
 #ifdef	CONFIG_MANDATORY_FILE_LOCKING
-static inline bool may_mandlock(void)
+static bool may_mandlock(void)
 {
+	pr_warn_once("======================================================\n"
+		     "WARNING: the mand mount option is being deprecated and\n"
+		     "         will be removed in v5.15!\n"
+		     "======================================================\n");
 	return capable(CAP_SYS_ADMIN);
 }
 #else
-- 
2.31.1

