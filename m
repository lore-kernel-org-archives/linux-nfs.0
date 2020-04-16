Return-Path: <SRS0=UO7P=6A=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7156FC352BE
	for <linux-nfs@archiver.kernel.org>; Thu, 16 Apr 2020 22:15:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 4E40B22245
	for <linux-nfs@archiver.kernel.org>; Thu, 16 Apr 2020 22:15:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1587075305;
	bh=0gdPE40FK1apLhWsEYvg0xL+rWdC2zhl3BTc08Bc+tQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=PpEjbN0C1S0mfC4wcoeE9o8loWmixkajEWFwCJ9p/ImfZpUiPRbKYGW+ateL3xrHe
	 Apa5f1axBzNEe4RoOuhGZF7HHhJzYTKZkqIax0A7oQfSHqihRj/Yjqv4e1p19kpgfR
	 gVVwxn2760Lby6ytztABhqHdJTXovVw4TypQvbu8=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729197AbgDPWPE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 16 Apr 2020 18:15:04 -0400
Received: from mail.kernel.org ([198.145.29.99]:54210 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729164AbgDPWPC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 16 Apr 2020 18:15:02 -0400
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 31F3D2220A;
        Thu, 16 Apr 2020 22:15:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1587075302;
        bh=0gdPE40FK1apLhWsEYvg0xL+rWdC2zhl3BTc08Bc+tQ=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=fcyjMcELf+I8QOQ+03XECuu3PdVmz44ZtrovCBYkFItOiUkK7oeooz+/KIhoUl9dU
         jf1hXuBjQhsRh9SBCSQ/A6I5oKyPvdVt0apsWOYZBgr3WD36YEeypOcXKUmfNs/wSD
         OGUAusQMSiEA4Ji2egxgNT8idQvVXWmzY8BtCHZM=
From:   trondmy@kernel.org
To:     Steve Dickson <SteveD@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 4/7] Fix autoconf probe for 'struct nfs_filehandle'
Date:   Thu, 16 Apr 2020 18:12:49 -0400
Message-Id: <20200416221252.82102-5-trondmy@kernel.org>
X-Mailer: git-send-email 2.25.2
In-Reply-To: <20200416221252.82102-4-trondmy@kernel.org>
References: <20200416221252.82102-1-trondmy@kernel.org>
 <20200416221252.82102-2-trondmy@kernel.org>
 <20200416221252.82102-3-trondmy@kernel.org>
 <20200416221252.82102-4-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

It was failing because fcntl.h is not one of the standard
includes.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 configure.ac | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 00b32800c526..df88e58fd0d4 100644
--- a/configure.ac
+++ b/configure.ac
@@ -531,7 +531,12 @@ AC_TYPE_PID_T
 AC_TYPE_SIZE_T
 AC_HEADER_TIME
 AC_STRUCT_TM
-AC_CHECK_TYPES([struct file_handle])
+AC_CHECK_TYPES([struct file_handle], [], [], [[
+		#define _GNU_SOURCE
+		#include <sys/types.h>
+		#include <sys/stat.h>
+		#include <fcntl.h>
+	]])
 
 dnl *************************************************************
 dnl Check for functions
-- 
2.25.2

