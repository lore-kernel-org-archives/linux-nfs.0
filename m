Return-Path: <SRS0=UO7P=6A=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AA42C38A2C
	for <linux-nfs@archiver.kernel.org>; Thu, 16 Apr 2020 22:15:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5DD8A221F9
	for <linux-nfs@archiver.kernel.org>; Thu, 16 Apr 2020 22:15:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1587075306;
	bh=L9CuUF9Eo7o6IB4MaJhkwj9cQWCykiYgn3y2kq3cvk0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=DEm+15nUIc8WE5rjbdM7VDKCDy3gMQndds26ZS7J/3cKN3+DBxhSVMfP3B8E9CZij
	 0+FfzE8kozxxyn+dy3HRu1LQNPkeKSicnYPHQqOws5HIxeJz2TjUUgeLoXS0xw0feN
	 Wl1TfSyikax3F5K/rFbD76aMKZ8bMx2g1vKHr82Q=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729187AbgDPWPE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 16 Apr 2020 18:15:04 -0400
Received: from mail.kernel.org ([198.145.29.99]:54222 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729197AbgDPWPD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Apr 2020 18:15:03 -0400
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id B3D982222D;
        Thu, 16 Apr 2020 22:15:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1587075303;
        bh=L9CuUF9Eo7o6IB4MaJhkwj9cQWCykiYgn3y2kq3cvk0=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=aVQWMFK7F8fCTBEprh63MlAN7vA3Jw2r/YgFA7Wiy7sJ8kXsoa8Kz53bppO4Sgz3h
         5te1SjBx+uewiNg2SIZyNValIhtJrF+rDtjMTkoM4ZHzyRg7f4TFYc/XJhOf9Mv25S
         bGUVvtz8hL7Sstfad/3GJLOKKiIc6lL2AT1qm/r8=
From:   trondmy@kernel.org
To:     Steve Dickson <SteveD@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 5/7] mountd: Ensure dump_to_cache() sets errno appropriately
Date:   Thu, 16 Apr 2020 18:12:50 -0400
Message-Id: <20200416221252.82102-6-trondmy@kernel.org>
X-Mailer: git-send-email 2.25.2
In-Reply-To: <20200416221252.82102-5-trondmy@kernel.org>
References: <20200416221252.82102-1-trondmy@kernel.org>
 <20200416221252.82102-2-trondmy@kernel.org>
 <20200416221252.82102-3-trondmy@kernel.org>
 <20200416221252.82102-4-trondmy@kernel.org>
 <20200416221252.82102-5-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

cache_write() will set errno if it returns -1, so that callers can
handle errors appropriately, however dump_to_cache() needs to do
so too.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 utils/mountd/cache.c | 19 +++++++++++++++----
 1 file changed, 15 insertions(+), 4 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 94e9e44b46b9..0f323226b12a 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -936,12 +936,13 @@ static void write_secinfo(char **bp, int *blen, struct exportent *ep, int flag_m
 
 }
 
-static int dump_to_cache(int f, char *buf, int buflen, char *domain,
+static int dump_to_cache(int f, char *buf, int blen, char *domain,
 			 char *path, struct exportent *exp, int ttl)
 {
 	char *bp = buf;
-	int blen = buflen;
 	time_t now = time(0);
+	size_t buflen;
+	ssize_t err;
 
 	if (ttl <= 1)
 		ttl = DEFAULT_TTL;
@@ -974,8 +975,18 @@ static int dump_to_cache(int f, char *buf, int buflen, char *domain,
 	} else
 		qword_adduint(&bp, &blen, now + ttl);
 	qword_addeol(&bp, &blen);
-	if (blen <= 0) return -1;
-	if (cache_write(f, buf, bp - buf) != bp - buf) return -1;
+	if (blen <= 0) {
+		errno = ENOBUFS;
+		return -1;
+	}
+	buflen = bp - buf;
+	err = cache_write(f, buf, buflen);
+	if (err < 0)
+		return err;
+	if ((size_t)err != buflen) {
+		errno = ENOSPC;
+		return -1;
+	}
 	return 0;
 }
 
-- 
2.25.2

