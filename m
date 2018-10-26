Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FC26ECDE46
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:17:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 19E5E2064A
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:17:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="KMQ7sTta"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19E5E2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726565AbeJ0EzZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 00:55:25 -0400
Received: from mail-qk1-f193.google.com ([209.85.222.193]:37348 "EHLO
        mail-qk1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725965AbeJ0EzZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 00:55:25 -0400
Received: by mail-qk1-f193.google.com with SMTP id 131so1465523qkd.4
        for <linux-nfs@vger.kernel.org>; Fri, 26 Oct 2018 13:17:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=k6kHDi/G4VXAWe0Fwif0qGkn8F6UDS8N2NPKlrgg+Dk=;
        b=KMQ7sTtacNKuFpoOm5SR51+MNJM1aLGBt6yS7Z28YL57Re6wMX2iINYt94EXbACHiv
         Vwvw9wHsfS/IYT/KysUQgek5LcTO0qahsLMDB6Dr8s/BBAAbnlkE+nmCIgLy3/emzRlV
         afVjQsRCOudtiRWwimrtmF+CD0+Hts4q9H6rhb4MXBoF8FkI3Jx9G85e3z8FIt0x+guA
         1wfBWFLv0aqSvpXU79cW9FvqeIeakGU8mtLiSgo0CtjKMaCNn3Nj7gSJfxj+eAtCwu8v
         Q7/ilgyCUqaCcV51dM/AzuolG4zs9uiMLs6/ITwI0sI+QyLvuiaGKsYlTKhcJFJCQnD5
         MdJw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=k6kHDi/G4VXAWe0Fwif0qGkn8F6UDS8N2NPKlrgg+Dk=;
        b=fZmzTnJ5clnzBRxHVGY4gjhJlSpt/GlH6zs9OyyjaEeOzzwGoV+HXQAMG197/oIans
         6xvEqqnMd1yfZOVxWcROEkJdsEKfa9Vexp/nS8QzGtn2Z+yMeaCg2d3vWWN9tyQ9rTPQ
         JYYYD9Sm2bAfPChSPptqOra8nAII3o81yF859h4OHLfprS1pGKWqX6CbtNjNIDYoVHzr
         eMQdrakv1K40fujVuyzhIFRbULcbhgsCBiNbD7intPxW/maHL8ZI4Mo26gh4Ga/Z+VXW
         ECVnzCykPpT2u8Zu17oOts7u6yF+lNMOgqGOyzYOOCyy/X6/AEeQFcl0vk7fxcfgdrq5
         101Q==
X-Gm-Message-State: AGRZ1gKeD4Dfaj1HQwGD3+SlYEtSIvpDuCEfBxABghjaoSM+l22/Kd8x
        WWs1EoYK+jVUysLQU83wYkI=
X-Google-Smtp-Source: AJdET5eKWV0UWazQHU3QVE9L7e+ykuP11pJsyc99QdDIsudABWoytReRcFm/MfHLgQBAQbnWMncQTA==
X-Received: by 2002:a37:2b5b:: with SMTP id r88mr4569313qkh.336.1540585020567;
        Fri, 26 Oct 2018 13:17:00 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id i11-v6sm12303815qtc.96.2018.10.26.13.16.59
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Oct 2018 13:16:59 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] NFSv4: cleanup remove unused nfs4_xdev_fs_type
Date:   Fri, 26 Oct 2018 16:16:58 -0400
Message-Id: <20181026201658.36958-1-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

commit e8f25e6d6d19 "NFS: Remove the NFS v4 xdev mount function"
removed the last use of this.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/internal.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8357ff6..ecb6d43 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -395,7 +395,6 @@ int nfs_rename(struct inode *, struct dentry *,
 extern struct file_system_type nfs_fs_type;
 extern struct file_system_type nfs_xdev_fs_type;
 #if IS_ENABLED(CONFIG_NFS_V4)
-extern struct file_system_type nfs4_xdev_fs_type;
 extern struct file_system_type nfs4_referral_fs_type;
 #endif
 bool nfs_auth_info_match(const struct nfs_auth_info *, rpc_authflavor_t);
-- 
1.8.3.1

