Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A0C4C04EB8
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:58:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4FAF720881
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:58:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FAF720881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725850AbeLCA6y (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 19:58:54 -0500
Received: from mx2.suse.de ([195.135.220.15]:43064 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725785AbeLCA6y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 2 Dec 2018 19:58:54 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 38D0EADC8;
        Mon,  3 Dec 2018 00:58:48 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Steve Dickson <SteveD@RedHat.com>
Date:   Mon, 03 Dec 2018 11:58:24 +1100
Subject: [PATCH 1/3] nfs.conf: allow empty assignments.
Cc:     Justin Mitchell <jumitche@rehat.com>, linux-nfs@vger.kernel.org
Message-ID: <154379870495.3215.5548604122736274107.stgit@noble>
In-Reply-To: <154379862296.3215.11174339731963464375.stgit@noble>
References: <154379862296.3215.11174339731963464375.stgit@noble>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

A recent commit caused an error message (but didn't actually
trigger an error) for a config file line like:

  foo =

There is no good reason to treat this as an error, and we (SUSE) have
established practice of expecting these to be accepted.
Specifically "/etc/nfs.conf" includes "/etc/sysconfig/nfs" which
contains lots of empty definitions.

So remove the error message.

Fixes: 1c2c18806800 ("nfs.conf: Removed buffer overruns")
Signed-off-by: NeilBrown <neilb@suse.com>
---
 support/nfs/conffile.c      |    5 -----
 tests/nfsconf/01-errors.exp |    1 -
 2 files changed, 6 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 0e39aca6b468..77c5790c893c 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -405,11 +405,6 @@ conf_parse_line(int trans, char *line, const char *filename, int lineno, char **
 			  "missing tag in assignment", filename, lineno);
 		return;
 	}
-	if (*val == '\0') {
-		xlog_warn("config error at %s:%d: "
-			  "missing value in assignment", filename, lineno);
-		return;
-	}
 
 	if (strcasecmp(line, "include")==0) {
 		/* load and parse subordinate config files */
diff --git a/tests/nfsconf/01-errors.exp b/tests/nfsconf/01-errors.exp
index 2bf1b8c7f65b..0b985b46267e 100644
--- a/tests/nfsconf/01-errors.exp
+++ b/tests/nfsconf/01-errors.exp
@@ -4,7 +4,6 @@ nfsconf: config error at 01-errors.conf:10: non-matched ']', ignoring until next
 nfsconf: config error at 01-errors.conf:11: ignoring line not in a section
 nfsconf: config error at 01-errors.conf:14: line not empty and not an assignment
 nfsconf: config error at 01-errors.conf:15: missing tag in assignment
-nfsconf: config error at 01-errors.conf:16: missing value in assignment
 nfsconf: config error at 01-errors.conf:18: unmatched quotes
 [four]
  four = foo = bar


