Return-Path: <SRS0=r/5G=R3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B32C0C43381
	for <linux-nfs@archiver.kernel.org>; Sun, 24 Mar 2019 21:34:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7F7E02083D
	for <linux-nfs@archiver.kernel.org>; Sun, 24 Mar 2019 21:34:23 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727137AbfCXVeW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 24 Mar 2019 17:34:22 -0400
Received: from youngberry.canonical.com ([91.189.89.112]:53361 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726317AbfCXVeW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Mar 2019 17:34:22 -0400
Received: from mail-pf1-f199.google.com ([209.85.210.199])
        by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
        (Exim 4.76)
        (envelope-from <matthew.ruffell@canonical.com>)
        id 1h8Al2-00016A-DO
        for linux-nfs@vger.kernel.org; Sun, 24 Mar 2019 21:34:20 +0000
Received: by mail-pf1-f199.google.com with SMTP id u8so7770274pfm.6
        for <linux-nfs@vger.kernel.org>; Sun, 24 Mar 2019 14:34:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=BBYKiRwdSqkJNhaTTgz9JXV8nM2yEJgzmL1+st9fvKg=;
        b=HESMWWzfT8R1xkButQ+ThmiDzeUVLxnBo0q3tkg61HG21dti3DrEnymIIpSr1ExASj
         7J2i0tkqfk+BepexxgWIiI7kZLAJDvOXH9KQAQKUx1AcwDsNSmTFEKhWxJ/WBIEM6DMM
         gpSAMtI7jAEDLRRHjLab7KSWsOJeHJYv7bTfl5DvHmK36Plqnz0XRu0tOSNtHtAnODsn
         lSuB/fQxyzM4pbW4T37TR+nArVZdGm1SnKcTHooASntbS5HkWh7Updlt8aJ10OT8EyY9
         U3iZ8xFIX6lABbgbh3r12j8CbMrp1qb2pzxZ34ogJ+kf3fzBlUBiECSVe8zEVda8xYwN
         Y2Hw==
X-Gm-Message-State: APjAAAXHChcEvKmQE2U4R/W/ecA+ybCy0CGJHfNITUKrK9mx+2eS2emZ
        LosF3jwbtc2YJYJ6ZUFjWbrOSzD3ivLN8TmMwDK1swxBFCG4FOLpAyq9A+s89DZTxJlytVmd9yI
        4Ulh9e++zWzwhynrwRri019vTd6UxIeL2uCLd5w==
X-Received: by 2002:a17:902:7b93:: with SMTP id w19mr21579216pll.141.1553463258833;
        Sun, 24 Mar 2019 14:34:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwivZhui9TMyhpiNoUvDV8oVR/DKKag0ljQ9BhhmlbLdOjLJX0RrVPx85IScrg0RSZ/yXCe/A==
X-Received: by 2002:a17:902:7b93:: with SMTP id w19mr21579206pll.141.1553463258702;
        Sun, 24 Mar 2019 14:34:18 -0700 (PDT)
Received: from localhost.localdomain (222-154-101-5-fibre.sparkbb.co.nz. [222.154.101.5])
        by smtp.gmail.com with ESMTPSA id i16sm20360598pgk.51.2019.03.24.14.34.16
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Mar 2019 14:34:18 -0700 (PDT)
From:   Matthew Ruffell <matthew.ruffell@canonical.com>
To:     linux-nfs@vger.kernel.org
Cc:     Matthew Ruffell <matthew.ruffell@canonical.com>
Subject: [PATCH] nfsiostat: replace 'list' reserved word
Date:   Mon, 25 Mar 2019 10:33:18 +1300
Message-Id: <20190324213318.18296-1-matthew.ruffell@canonical.com>
X-Mailer: git-send-email 2.19.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

list is a reserved word in python and should not be used as a variable
name. Changing list to devicelist for list_nfs_mounts()

Fixes: https://bugs.launchpad.net/ubuntu/+source/nfs-utils/+bug/1821261

Signed-off-by: Matthew Ruffell <matthew.ruffell@canonical.com>
---
 tools/nfs-iostat/nfs-iostat.py | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index 7cbe543..dec0e86 100644
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -493,20 +493,20 @@ def list_nfs_mounts(givenlist, mountstats):
        return a full list if the given list is empty -
        may return an empty list if none found
     """
-    list = []
+    devicelist = []
     if len(givenlist) > 0:
         for device in givenlist:
             stats = DeviceData()
             stats.parse_stats(mountstats[device])
             if stats.is_nfs_mountpoint():
-                list += [device]
+                devicelist += [device]
     else:
         for device, descr in mountstats.items():
             stats = DeviceData()
             stats.parse_stats(descr)
             if stats.is_nfs_mountpoint():
-                list += [device]
-    return list
+                devicelist += [device]
+    return devicelist
 
 def iostat_command(name):
     """iostat-like command for NFS mount points
-- 
2.19.1

