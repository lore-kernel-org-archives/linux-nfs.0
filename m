Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FCBFC197A0
	for <linux-nfs@archiver.kernel.org>; Mon, 20 Nov 2023 18:53:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229676AbjKTSx6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 20 Nov 2023 13:53:58 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:37226 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232057AbjKTSx5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Nov 2023 13:53:57 -0500
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 12B32C8
        for <linux-nfs@vger.kernel.org>; Mon, 20 Nov 2023 10:53:54 -0800 (PST)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7C840C433C7;
        Mon, 20 Nov 2023 18:53:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1700506433;
        bh=eGyIrNTj7pbOO2tlVeH6Wc8JZexBe7MgisoSTCCEAJw=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=QFpxbFrMwhDnLBkp46leVaankL73P1Zih9x7iJo4WVr5aUffOF2/b0XOos7Fg941n
         HNGVPxUAyshjrTo9J9QlrVf3Ty+iIhWRqwLJtr9jjfcj6yIfRirq9hBHS6pB17DD17
         +y7Uk8/wENPpMLnvrfSh9zY0ihlYWMaWf+aGZ1R2Xmil49EuzrTEfGGQqXOZ4YmFuM
         kdE/TCXiYXwqNjy9bxqY8CDAjbTL/CMgRfxvR2WMoi65zTr8tsH88xzEcPUZi4OBO7
         /5mrILosPOp5pPTgKRP/MBotJ1QTj7d3QWAZjwm6Qi8ULzI0pZ9BS7Tt/oiQ3hqQK9
         JIo6Vefwal4Rw==
Subject: [PATCH RFC 3/5] nfsref: Remove unneeded #include in
 utils/nfsref/nfsref.c
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>
Date:   Mon, 20 Nov 2023 13:53:52 -0500
Message-ID: <170050643249.123525.7457995133948275163.stgit@manet.1015granger.net>
In-Reply-To: <170050610386.123525.8429348635736141592.stgit@manet.1015granger.net>
References: <170050610386.123525.8429348635736141592.stgit@manet.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

Neil Brown says:
> The only thing that was interesting is that nfsref.c includes
> sys/capability.h, and I didn't have libcap declared as BuildRequires.
> The ./configure script didn't complain that libcap was missing - instead
> the build failed.
>
> Other places in nfs-utils that include capability.h protect it with
> #ifdef HAVE_SYS_CAPABILITY_H
>
> If nfsref.c followed that pattern I wouldn't have received an error.
> But then I wouldn't have added a dependency on libcap.
> Do I really want libcap??  I don't know.
> But I cannot see where nfsref.c uses libcap or prctl.  So maybe
> those includes aren't needed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/nfsref/nfsref.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/utils/nfsref/nfsref.c b/utils/nfsref/nfsref.c
index 7f97d01f55ca..aa8414b425fb 100644
--- a/utils/nfsref/nfsref.c
+++ b/utils/nfsref/nfsref.c
@@ -24,8 +24,6 @@
  */
 
 #include <sys/types.h>
-#include <sys/capability.h>
-#include <sys/prctl.h>
 #include <sys/stat.h>
 
 #include <stdbool.h>


