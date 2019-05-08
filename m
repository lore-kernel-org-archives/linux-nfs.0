Return-Path: <SRS0=eudZ=TI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD172C04A6B
	for <linux-nfs@archiver.kernel.org>; Wed,  8 May 2019 13:05:26 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9203B21019
	for <linux-nfs@archiver.kernel.org>; Wed,  8 May 2019 13:05:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727042AbfEHNFZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 8 May 2019 09:05:25 -0400
Received: from mx1.redhat.com ([209.132.183.28]:38854 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726281AbfEHNFZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 May 2019 09:05:25 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6F283309B151
        for <linux-nfs@vger.kernel.org>; Wed,  8 May 2019 13:05:25 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-116-59.phx2.redhat.com [10.3.116.59])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 2B3715D9C8
        for <linux-nfs@vger.kernel.org>; Wed,  8 May 2019 13:05:25 +0000 (UTC)
From:   Steve Dickson <steved@redhat.com>
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] configure.ac: Turn off cast-function warnings
Date:   Wed,  8 May 2019 09:05:23 -0400
Message-Id: <20190508130523.14175-1-steved@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 08 May 2019 13:05:25 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The rpcgen generated code from .x files creates
a cast-function-type warning.

Due to the age and stability of the code
turning off the warning makes more sense
than re-writing the .x files.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 configure.ac | 1 +
 1 file changed, 1 insertion(+)

diff --git a/configure.ac b/configure.ac
index e89ca67..4e72790 100644
--- a/configure.ac
+++ b/configure.ac
@@ -592,6 +592,7 @@ my_am_cflags="\
  -Werror=parentheses \
  -Werror=aggregate-return \
  -Werror=unused-result \
+ -Wno-cast-function-type \
  -fno-strict-aliasing \
 "
 
-- 
2.20.1

