Return-Path: <SRS0=laZk=C6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 490DAC4363C
	for <linux-nfs@archiver.kernel.org>; Mon, 21 Sep 2020 18:11:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id EBB7A20888
	for <linux-nfs@archiver.kernel.org>; Mon, 21 Sep 2020 18:11:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="vYmsN0Zg"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727297AbgIUSLI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 21 Sep 2020 14:11:08 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47562 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726436AbgIUSLI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Sep 2020 14:11:08 -0400
Received: from mail-il1-x144.google.com (mail-il1-x144.google.com [IPv6:2607:f8b0:4864:20::144])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 152D4C061755
        for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2020 11:11:08 -0700 (PDT)
Received: by mail-il1-x144.google.com with SMTP id x18so12246098ila.7
        for <linux-nfs@vger.kernel.org>; Mon, 21 Sep 2020 11:11:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=u6G0/ExctVKc+YDNRp4cf28JX+YNHpRm2DkkMOhosXI=;
        b=vYmsN0ZgQGqTIzkk8RKfB7O8M89vgl2Mg6OoZUwy3kgfJ9gStLwjmbnqc3eb/rNT0B
         v8xIo1nNeGKmuEyp5+jDrzNn7oAsjGlsgQfz7jUbsCuyiz4HnFAJS/di7IJ17Yv87Il7
         Jn4AHqZTOd/ENd3X/Q51iLNrcK1TROCbvSdCJr+sqFXZNcA7XSMqYOpD6cZOkaYVS9T4
         pfumZM/Zk8/dWg3sySeKSUCNAKR7CjTSWjMo4YVV/7fpmweZkZPzlbohG+I7ih8iCmCp
         u+R1l6GfpONGyNgWz6/H2VEdI/yED8ZZMz2OIjjUrgXgrLU2D1Y/Tw8/LYIQHWJndAs3
         YjZA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=u6G0/ExctVKc+YDNRp4cf28JX+YNHpRm2DkkMOhosXI=;
        b=BqTyF4DkC3W+injgSeqt/7hCJJs3QT3zpVjNHPKNyMkZ6juF04XGd4y8TSgJhDI/Pu
         1Xqg+h51KfhqEbKcyrY+lNclBHpBSJJ/dUAJihoKs7DM5IXAXTW3u0GsUmVyIWm71z4v
         nd6S1t8WabrfTwEsUMK/icwma3ZBYUq316VygOI3vROpii6XaGbUwG3rLXPG1G5zQzDL
         GRCE0Nm0Ag2DS4PwE2IESnLUMInDq2G93CTIc0ZaKdkIIWOUD7pbCVu2ZYvXnJ2oD5ZE
         IOvaaStCK2J65ypJSmP1jpzAad0kM/pGfmBznpdnfRte/kxqjMtumN3a9Jr2b7JWOfTz
         LqWA==
X-Gm-Message-State: AOAM5315bqOp/Vgr19wUexQaDwz0/S2RaF3vOkPxzQw5qzNE/ObELTa8
        EGvHK1+G+8en50GUjrjLtGN+FbCED5Q=
X-Google-Smtp-Source: ABdhPJwATUMuCLytq3YOgEAhNpCeoA8cCxksXg50Ot3UbeFF0Z08uaaY8Us0pJgAMyCh+4ZKyJPIEw==
X-Received: by 2002:a92:1303:: with SMTP id 3mr985473ilt.117.1600711867496;
        Mon, 21 Sep 2020 11:11:07 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id k1sm7419851ilq.59.2020.09.21.11.11.06
        (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2020 11:11:06 -0700 (PDT)
Sender: Chuck Lever <chucklever@gmail.com>
Received: from klimt.1015granger.net (klimt.1015granger.net [192.168.1.55])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id 08LIB5KD003851;
        Mon, 21 Sep 2020 18:11:05 GMT
Subject: [PATCH v2 03/27] NFSD: Add SPDX header for fs/nfsd/trace.c
From:   Chuck Lever <chuck.lever@oracle.com>
To:     bfields@fieldses.org, Bill.Baker@oracle.com
Cc:     linux-nfs@vger.kernel.org
Date:   Mon, 21 Sep 2020 14:11:05 -0400
Message-ID: <160071186572.1468.2754567155906522552.stgit@klimt.1015granger.net>
In-Reply-To: <160071167664.1468.1365570508917640511.stgit@klimt.1015granger.net>
References: <160071167664.1468.1365570508917640511.stgit@klimt.1015granger.net>
User-Agent: StGit/0.23
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Clean up.

The file was contributed in 2014 by Christoph Hellwig in commit
31ef83dc0538 ("nfsd: add trace events").

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/trace.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/trace.c b/fs/nfsd/trace.c
index 90967466a1e5..f008b95ceec2 100644
--- a/fs/nfsd/trace.c
+++ b/fs/nfsd/trace.c
@@ -1,3 +1,4 @@
+// SPDX-License-Identifier: GPL-2.0
 
 #define CREATE_TRACE_POINTS
 #include "trace.h"


