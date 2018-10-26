Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1326CECDE44
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 23:24:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CAE9020834
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 23:24:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=rasmusvillemoes.dk header.i=@rasmusvillemoes.dk header.b="gpMOQnDo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAE9020834
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=rasmusvillemoes.dk
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728937AbeJ0IDU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 04:03:20 -0400
Received: from mail-ed1-f66.google.com ([209.85.208.66]:46915 "EHLO
        mail-ed1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728923AbeJ0IDU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 04:03:20 -0400
Received: by mail-ed1-f66.google.com with SMTP id v18-v6so2635364edq.13
        for <linux-nfs@vger.kernel.org>; Fri, 26 Oct 2018 16:24:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=rasmusvillemoes.dk; s=google;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=i+E/PSGhpII+gSHX5M/fv1bX1dhF7uVIKEiKrt5mVV8=;
        b=gpMOQnDoB52MBcmWplNQFoZB2fbbbu+eDRVqSQQmP9NjnObm1sQy53DGZSGLJfMgT2
         FqPdb3DXS6ocD7zX8qyO1F6/ZlQoLNAwynCnXP2nWb3NQ9g4StwOGiV+HK55ARRbkBuZ
         dWcW3F0hW1aY1w1nLR8VAzaDesx9fVl68Y5A4=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=i+E/PSGhpII+gSHX5M/fv1bX1dhF7uVIKEiKrt5mVV8=;
        b=tUJEHfum5olm07geOXWJC6+4cTBQ0mvArLrTz9ac/2PagpWN2mzXmFinKerwTRdTzA
         SXV8LsC32vWOqdFSfAn2Cbe/zaCJ9O4aPgpPWO8b6+toCvSK6X4yeV+96NK2UjVvkThn
         ZTvMB/HHhrw0UKVa04hK761GJKudjmJ7QUoRit8xq6eogRghUZQqbqGEwCzmdI6YVA5S
         T3GuZhNykf/uSdWj9rnVqZLvGlvrqbxuMuQSIdKSLjFQ7KtvhwzhG5wRJpiIeok/MHNk
         MQTZ0SjbpUS2bPVKQTvM1USfGx8LvJJDTkVNhvfKVJ2aDA+FOGNEAWTFhRYZ/dtyKbBZ
         kjiw==
X-Gm-Message-State: AGRZ1gIachvQXy0/MwwN1Fj0Z4xYjlcdw4hyfVzVrXAeTCYVqc/eu1hn
        L+qpj27ts6AHBP/1d3T9NCCZNg==
X-Google-Smtp-Source: AJdET5dNogwnAzUAURno/NURjVdv2H1zlyj6zuNlPodjuDNzAciHKwQXqk2LYu2gXA3hamcRwHRPFA==
X-Received: by 2002:a17:906:4ed9:: with SMTP id i25-v6mr585893ejv.75.1540596259125;
        Fri, 26 Oct 2018 16:24:19 -0700 (PDT)
Received: from prevas-ravi.waoo.dk (dhcp-5-186-114-252.cgn.ip.fibianet.dk. [5.186.114.252])
        by smtp.gmail.com with ESMTPSA id o13-v6sm3986746edc.95.2018.10.26.16.24.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 26 Oct 2018 16:24:18 -0700 (PDT)
From:   Rasmus Villemoes <linux@rasmusvillemoes.dk>
To:     Kees Cook <keescook@chromium.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        linux-nfs@vger.kernel.org
Cc:     linux-kernel@vger.kernel.org,
        Rasmus Villemoes <linux@rasmusvillemoes.dk>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
Subject: [RFC PATCH 6/7] nfs: use fmtcheck() in root_nfs_data
Date:   Sat, 27 Oct 2018 01:24:08 +0200
Message-Id: <20181026232409.16100-7-linux@rasmusvillemoes.dk>
X-Mailer: git-send-email 2.19.1.6.gbde171bbf5
In-Reply-To: <20181026232409.16100-1-linux@rasmusvillemoes.dk>
References: <20171108223020.24487-1-linux@rasmusvillemoes.dk>
 <20181026232409.16100-1-linux@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

tmp is initially the string "/tftpboot/%s", but it may be changed from
the calls to root_nfs_parse_options. While an nfsroot= command line
option can probably be trusted (or the user gets to keep both pieces),
it's also possible for contents to come via a BOOTP option.

Do a sanity check of fmt to ensure it doesn't contain odd printf
specifiers that would make snprintf go off into the weeds. The lack of
the FMTCHECK_NO_EXTRA_ARGS flag (i.e., the last 0 argument) means we
allow either no specifiers or precisely one occurrence of %s in tmp.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 fs/nfs/nfsroot.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index effaa4247b91..71db0149eb49 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -261,7 +261,7 @@ static int __init root_nfs_data(char *cmdline)
 	 * mess into nfs_root_device.
 	 */
 	len = snprintf(nfs_export_path, sizeof(nfs_export_path),
-				tmp, utsname()->nodename);
+				fmtcheck(tmp, "%s", 0), utsname()->nodename);
 	if (len >= (int)sizeof(nfs_export_path))
 		goto out_devnametoolong;
 	len = snprintf(nfs_root_device, sizeof(nfs_root_device),
-- 
2.19.1.6.gbde171bbf5

