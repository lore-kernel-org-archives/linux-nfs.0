Return-Path: <SRS0=PH1c=P7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42AEAC282C0
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jan 2019 10:09:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 10C9320870
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jan 2019 10:09:16 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727227AbfAWKJP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Jan 2019 05:09:15 -0500
Received: from mx1.redhat.com ([209.132.183.28]:60274 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727069AbfAWKJP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 23 Jan 2019 05:09:15 -0500
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 26F3358E54
        for <linux-nfs@vger.kernel.org>; Wed, 23 Jan 2019 10:09:15 +0000 (UTC)
Received: from plambri-affligem.usersys.redhat.com (dhcp-135.gsslab.fab.redhat.com [10.33.9.135])
        by smtp.corp.redhat.com (Postfix) with ESMTP id AF4C767152
        for <linux-nfs@vger.kernel.org>; Wed, 23 Jan 2019 10:09:14 +0000 (UTC)
From:   Pierguido Lambri <plambri@redhat.com>
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] gssd: add verbosity options to the rpc.gssd man page
Date:   Wed, 23 Jan 2019 10:09:12 +0000
Message-Id: <20190123100912.8979-1-plambri@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Wed, 23 Jan 2019 10:09:15 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

It also adds the commented out entries in the nfs.conf
default file and references to the verbosity entries in
the gssd man page too.

Signed-off-by: Pierguido Lambri <plambri@redhat.com>
---
 nfs.conf             | 2 ++
 systemd/nfs.conf.man | 2 ++
 utils/gssd/gssd.man  | 8 ++++++++
 3 files changed, 12 insertions(+)

diff --git a/nfs.conf b/nfs.conf
index 5546109..a6f6f2d 100644
--- a/nfs.conf
+++ b/nfs.conf
@@ -9,6 +9,8 @@
 # debug=0
 #
 #[gssd]
+# Verbosity=0
+# RPC-Verbosity=0
 # use-memcache=0
 # use-machine-creds=1
 # use-gss-proxy=0
diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
index 699db3f..9b112cd 100644
--- a/systemd/nfs.conf.man
+++ b/systemd/nfs.conf.man
@@ -211,6 +211,8 @@ for details.
 .TP
 .B gssd
 Recognized values:
+.BR Verbosity ,
+.BR RPC-Verbosity ,
 .BR use-memcache ,
 .BR use-machine-creds ,
 .BR use-gss-proxy ,
diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index e620f0d..4f7bd60 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -305,6 +305,14 @@ section of the
 .I /etc/nfs.conf
 configuration file.  Values recognized include:
 .TP
+.B Verbosity
+Value which is equivalent to the number of
+.BR -v .
+.TP
+.B RPC-Verbosity
+Value which is equivalent to the number of
+.BR -r .
+.TP
 .B use-memcache
 A Boolean flag equivalent to
 .BR -M .
-- 
2.20.1

