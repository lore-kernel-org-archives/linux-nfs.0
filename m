Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8489AECDE46
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 15:07:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 44B0E20848
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 15:07:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44B0E20848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727595AbeJYXkr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 19:40:47 -0400
Received: from mx1.redhat.com ([209.132.183.28]:24622 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727629AbeJYXkq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Oct 2018 19:40:46 -0400
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 5115530A3155
        for <linux-nfs@vger.kernel.org>; Thu, 25 Oct 2018 15:07:35 +0000 (UTC)
Received: from jumitche.remote.csb (unknown [10.33.36.123])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 040D54F7D;
        Thu, 25 Oct 2018 15:07:33 +0000 (UTC)
Message-ID: <1540480050.8177.2.camel@redhat.com>
Subject: [PATCH] nfs-utils: Allow setting of commented out values in nfs.conf
From:   Justin Mitchell <jumitche@redhat.com>
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc:     Steve Dickson <steved@redhat.com>
Date:   Thu, 25 Oct 2018 16:07:30 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Thu, 25 Oct 2018 15:07:35 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When using nfsconf tool to set values, allow it to uncomment a setting
it finds in the relevant section if it would otherwise have had to create
a new one.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/nfs/conffile.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 3845b94..713f81b 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -1830,6 +1830,8 @@ conf_write(const char *filename, const char *section, const char *arg,
 
 			/* this is the section we care about */
 			if (where != NULL && is_section(where->text, section, arg)) {
+				struct outbuffer *section_start = where;
+
 				/* is there an existing assignment */
 				while ((where = TAILQ_NEXT(where, link)) != NULL) {
 					if (is_tag(where->text, tag)) {
@@ -1838,6 +1840,26 @@ conf_write(const char *filename, const char *section, const char *arg,
 					}
 				}
 
+				/* no active assignment, but is there a commented one */
+				if (!found) {
+					where = section_start;
+					while ((where = TAILQ_NEXT(where, link)) != NULL) {
+						if (is_comment(where->text)) {
+							char *cline = where->text;
+							while (isspace(*cline)) cline++;
+
+							if (*cline != '#') continue;
+							cline++;
+
+							if (is_tag(cline, tag)) {
+								found = true;
+								break;
+							}
+						}
+					}
+				}
+
+				/* replace the located tag with an updated one */
 				if (found) {
 					struct outbuffer *prev = TAILQ_PREV(where, tailhead, link);
 					bool again = false;
-- 
1.8.3.1

