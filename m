Return-Path: <SRS0=iyIL=YQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F4E7CA9EBB
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Oct 2019 23:58:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 63123207FD
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Oct 2019 23:58:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bfMFp1zE"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725852AbfJWX6P (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Oct 2019 19:58:15 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:35601 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2392795AbfJWX6P (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Oct 2019 19:58:15 -0400
Received: by mail-io1-f66.google.com with SMTP id t18so23078094iog.2
        for <linux-nfs@vger.kernel.org>; Wed, 23 Oct 2019 16:58:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nymVrAPiFMFWo6jqKaToF9wF79yeH0rY5WIe9SAR/I8=;
        b=bfMFp1zEhzYmHDGwjI8NJ9gD3o46yqKvh0LDk3b7+nlyfVwLOPVbsWLG12beTr0xGG
         z+oBuk7P9lZj6GL7rMg12nTlieP9jV6lTaUJvt4vOqlscJ71Orst9P3j9W4C/ViHyQVP
         mVt6esTk99uTC2VpcO88naR8Qiqr55wBCg3qt9jTmKI8kP0mCGA3UoSNHJmHNvKqPxPP
         M+aE6N5hdWhcW6eGcpcN+ACk0Saxuy22bdrOuoL21wfiJJD4LVlLWC2vgbt5FakZj6kF
         28AAn94H9PJhXelekct397lwYCCsUkcerG2ie6aWWVyh8+7AapplJZGH/ZOUlrsR0UyJ
         ljyA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=nymVrAPiFMFWo6jqKaToF9wF79yeH0rY5WIe9SAR/I8=;
        b=HWmVHAKaRQOpHM9SCOOzESD5coBdUDw/7ClAwdGe5ep6Rl9Ts6UD+k2dD9VOwcLPFO
         +E3u5UVgnALyYGpG5DlXGl2nNzzS7UMzP6RfBgP+ox8MF3+VBtrEXG030oSZz4Blof4/
         zP4NmfINLiwQaJ/YKwHJEhlNXF6UPIfT8ZJXe9SFqirYvmV2UOZKaAczbzEx1zmz8+tH
         UC6l0xYVBMgcCKR/FYDjX/a8WXMhKu/4Ufhgd6RMF9iU85bK7GzP+CZDsWsAPfoO47mF
         j+eQAmEbhJpZfpWTl5yUglUgbRb1cxh7A/OqJN0CfE2Vj+G+JcMj1zd2Jf8GQb3e32p9
         eV/w==
X-Gm-Message-State: APjAAAXh1fKVNKNyNGQXq2+GoVkGH7GM044HA8pi1iRK9TbWg1xAS377
        p6MGLyt3Dsm0ozo6CwZ9bd/UNIk=
X-Google-Smtp-Source: APXvYqzqvmxFPTUXRKTJTXEte3rCkk4c/ipWQMGu3tZGeSJQPAIvgEAEpEZZAt4duFuTfgzQBajUTg==
X-Received: by 2002:a05:6602:1216:: with SMTP id y22mr6567877iot.16.1571875093387;
        Wed, 23 Oct 2019 16:58:13 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id z18sm2405409iob.47.2019.10.23.16.58.12
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 23 Oct 2019 16:58:12 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 05/14] NFSv4: fail nfs4_refresh_delegation_stateid() when the delegation was revoked
Date:   Wed, 23 Oct 2019 19:55:51 -0400
Message-Id: <20191023235600.10880-6-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20191023235600.10880-5-trond.myklebust@hammerspace.com>
References: <20191023235600.10880-1-trond.myklebust@hammerspace.com>
 <20191023235600.10880-2-trond.myklebust@hammerspace.com>
 <20191023235600.10880-3-trond.myklebust@hammerspace.com>
 <20191023235600.10880-4-trond.myklebust@hammerspace.com>
 <20191023235600.10880-5-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the delegation was revoked, we don't want to retry the delegreturn.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/delegation.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 4bc40c27141b..f90c3cf82f8f 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -1179,6 +1179,7 @@ bool nfs4_refresh_delegation_stateid(nfs4_stateid *dst, struct inode *inode)
 	rcu_read_lock();
 	delegation = rcu_dereference(NFS_I(inode)->delegation);
 	if (delegation != NULL &&
+	    !test_bit(NFS_DELEGATION_REVOKED, &delegation->flags) &&
 	    nfs4_stateid_match_other(dst, &delegation->stateid)) {
 		dst->seqid = delegation->stateid.seqid;
 		return ret;
-- 
2.21.0

