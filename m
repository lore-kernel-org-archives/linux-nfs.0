Return-Path: <SRS0=OjhL=OU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B616FC5CFFE
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 19:09:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 840AB20870
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 19:09:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 840AB20870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726331AbeLKTJp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 11 Dec 2018 14:09:45 -0500
Received: from mx1.redhat.com ([209.132.183.28]:35380 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726329AbeLKTJp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Dec 2018 14:09:45 -0500
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 84208307D865
        for <linux-nfs@vger.kernel.org>; Tue, 11 Dec 2018 19:09:45 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 3F8B4608F7
        for <linux-nfs@vger.kernel.org>; Tue, 11 Dec 2018 19:09:45 +0000 (UTC)
From:   Steve Dickson <steved@redhat.com>
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsref: switch the way libraries are linked.
Date:   Tue, 11 Dec 2018 14:09:44 -0500
Message-Id: <20181211190944.71940-1-steved@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Tue, 11 Dec 2018 19:09:45 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Link the static libs before the dynamic libs allowing
the routines in the static libs to be defined
by the dynamic libs

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsref/Makefile.am | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/nfsref/Makefile.am b/utils/nfsref/Makefile.am
index 44edc83..2409dd0 100644
--- a/utils/nfsref/Makefile.am
+++ b/utils/nfsref/Makefile.am
@@ -27,9 +27,9 @@ noinst_HEADERS		= nfsref.h
 
 sbin_PROGRAMS		= nfsref
 nfsref_SOURCES		= add.c lookup.c nfsref.c remove.c
-LDADD			= $(LIBXML2) $(LIBCAP) \
-			  ../../support/nfs/libnfs.la \
-			  ../../support/junction/libjunction.la
+LDADD			= ../../support/nfs/libnfs.la \
+			  ../../support/junction/libjunction.la \
+			  $(LIBXML2) $(LIBCAP)
 
 man8_MANS		= nfsref.man
 
-- 
2.19.2

