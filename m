Return-Path: <SRS0=/9w8=WY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB077C3A5A1
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Aug 2019 07:10:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B169020828
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Aug 2019 07:10:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=pks.im header.i=@pks.im header.b="ebk9prBp";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="xamANkOE"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726441AbfH1HKh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 28 Aug 2019 03:10:37 -0400
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:60569 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726292AbfH1HKh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Aug 2019 03:10:37 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
        by mailout.nyi.internal (Postfix) with ESMTP id 5E96621B0E
        for <linux-nfs@vger.kernel.org>; Wed, 28 Aug 2019 03:10:36 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute1.internal (MEProxy); Wed, 28 Aug 2019 03:10:36 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=pks.im; h=from
        :to:cc:subject:date:message-id:in-reply-to:references
        :mime-version:content-transfer-encoding; s=fm1; bh=1d54FNDRbTuME
        hWLgxs6sn6X+kyM4FlE9PwhjBe0F6Y=; b=ebk9prBpjcpiH+QyA2UCWLoW+SzEK
        C2En8sCiQvEj+p8LmpGOC3nfelMBJe0B2aLaqRk1Rw64XpdK4WlGKcmpkYuKnrzR
        2gzoLA02tXHu+76oiWl15HFpZsaL9yy3WEBfaO8wnKaWKmamlKFZ5nNU/XTTrFbR
        ncPLTfBALtJglLWze0i0VRKSuwTncTQUOjVtwoHzyjVRb3e4V1VWy/9z2TTzduxv
        W1PHLC5s5RdIJDZJidQFaaxiRPMaKKFeOY7bA3OiOpzBjFLPAJglRzNx6hciyT3m
        jftOGKzcp0m5FMI4/PaEGUlDkqu4M6QgF/xI0NhYfgUsIKwsepzLZDw1w==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
        messagingengine.com; h=cc:content-transfer-encoding:date:from
        :in-reply-to:message-id:mime-version:references:subject:to
        :x-me-proxy:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
        fm3; bh=1d54FNDRbTuMEhWLgxs6sn6X+kyM4FlE9PwhjBe0F6Y=; b=xamANkOE
        LLQUyKPUna34hvKUoL8kVT6fDBB0TIuIybQWz9sAlEfxxmpdT+60FGPkdX0MGJeb
        toA9s/3uWBeTMlf0CL1FqBnO2z+N3eE6jBOSljYCoVTQqK1Xgu3zy/fcIjrh0orR
        eaPPh+AOY/K7zVO10eAKHHai1UbsPJ29qtM2/fbOZFi3VCoalGLlkjnIM/kS1pB3
        /F14D0gAwmZ4+6JpkM1t/ieo0hps9VULZci87zXT9K8BSpCM64t4+uTvAVv+Uw6f
        m5bYU4Makmn/UWpaNulUGL0bI0WNwfmsxPtnsNVtxD2pFwHdglhiyo41paJp+Vg5
        Dau2lL9hwNEvbQ==
X-ME-Sender: <xms:7ChmXVqbflwPZAoOnLg-lc3gIGyD_q-fNXFlsM6-NOPDHJ_CcoTrmw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduvddrudehledgudduiecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfgh
    necuuegrihhlohhuthemuceftddtnecunecujfgurhephffvufffkffojghfggfgsedtke
    ertdertddtnecuhfhrohhmpefrrghtrhhitghkucfuthgvihhnhhgrrhguthcuoehpshes
    phhkshdrihhmqeenucfkphepjeejrdduuddrudehhedrvdehheenucfrrghrrghmpehmrg
    hilhhfrhhomhepphhssehpkhhsrdhimhenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:7ChmXVXhzg1-dRfz1v23_CkrHaRGYCRM_bAC4MV-AVsCzhw7aeMf_w>
    <xmx:7ChmXaQ2c57qgfvuoQ4NTJWFBrH0jFcp6Gz6kf9_qo6qubAUgEqBnA>
    <xmx:7ChmXZR-xsyHjccmByFKrrQqaR3Gqqo4VhT0v5aN8MeRPjxEmGV9gg>
    <xmx:7ChmXfwWYqyviE7dEo8PJL7_1rMOa1qd1yCNuqL1UxCUH1M0DA84lA>
Received: from NSJAIL (x4d0b9bff.dyn.telefonica.de [77.11.155.255])
        by mail.messagingengine.com (Postfix) with ESMTPA id CCF7ED6005F
        for <linux-nfs@vger.kernel.org>; Wed, 28 Aug 2019 03:10:35 -0400 (EDT)
Received: from localhost (10.192.0.11 [10.192.0.11])
        by NSJAIL (OpenSMTPD) with ESMTPSA id e21ee48a (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256:NO);
        Wed, 28 Aug 2019 07:10:33 +0000 (UTC)
From:   Patrick Steinhardt <ps@pks.im>
To:     linux-nfs@vger.kernel.org
Cc:     Patrick Steinhardt <ps@pks.im>
Subject: [PATCH 1/6] Annotate unused fields with UNUSED
Date:   Wed, 28 Aug 2019 09:10:12 +0200
Message-Id: <724274b0bf9340bc11f6741759ce1e43b82de7be.1566976047.git.ps@pks.im>
X-Mailer: git-send-email 2.23.0
In-Reply-To: <cover.1566976047.git.ps@pks.im>
References: <cover.1566976047.git.ps@pks.im>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

There are some parameters that may be potentially unused. Add the UNUSED
macro to avoid any warnings.

Signed-off-by: Patrick Steinhardt <ps@pks.im>
---
 support/misc/xstat.c     | 3 ++-
 support/nfs/rpc_socket.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/support/misc/xstat.c b/support/misc/xstat.c
index 4c997eea..661e29e4 100644
--- a/support/misc/xstat.c
+++ b/support/misc/xstat.c
@@ -9,6 +9,7 @@
 #include <sys/sysmacros.h>
 #include <unistd.h>
 
+#include "nfslib.h"
 #include "xstat.h"
 
 #ifdef HAVE_FSTATAT
@@ -66,7 +67,7 @@ statx_stat_nosync(int fd, const char *pathname, struct stat *statbuf, int flags)
 #else
 
 static int
-statx_stat_nosync(int fd, const char *pathname, struct stat *statbuf, int flags)
+statx_stat_nosync(int UNUSED(fd), const char *UNUSED(pathname), struct stat *UNUSED(statbuf), int UNUSED(flags))
 {
 	errno = ENOSYS;
 	return -1;
diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
index bdf6d2f6..03048feb 100644
--- a/support/nfs/rpc_socket.c
+++ b/support/nfs/rpc_socket.c
@@ -41,6 +41,7 @@
 #include <rpc/pmap_prot.h>
 
 #include "sockaddr.h"
+#include "nfslib.h"
 #include "nfsrpc.h"
 
 #ifdef HAVE_LIBTIRPC
@@ -519,7 +520,7 @@ CLIENT *nfs_get_priv_rpcclient(const struct sockaddr *sap,
  * Returns program number of first name to be successfully looked
  * up, or the default program number if all lookups fail.
  */
-rpcprog_t nfs_getrpcbyname(const rpcprog_t program, const char *table[])
+rpcprog_t nfs_getrpcbyname(const rpcprog_t program, const char *UNUSED(table[]))
 {
 #ifdef HAVE_GETRPCBYNAME
 	struct rpcent *entry;
-- 
2.23.0

