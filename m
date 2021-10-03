X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Google-Smtp-Source: ABdhPJzTUmXDPzytkFQ9OlWQaXzFdLQM+fC8la66aV4JLYGQhi2I3R0jI1WmB71un4oa4mtN4nxJ
X-Received: by 2002:a50:8d85:: with SMTP id r5mr13079010edh.312.1633288971848;
 Sun, 03 Oct 2021 12:22:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1633288971; cv=none; d=google.com;
 s=arc-20160816;
 b=GnTsT5Y0R7JDa/sV/zsKbk5MC3pqeuUlAfMETvhEAMURWWEYISpkwnokheeUExAkT8
 IuzvlA+r158dm9Qwewg22UOlHoLY0RQAUFwRFN/NjYrGsArHGHmJzvVv2xEIQLPefyCC
 aTwQ5ZV5Vxy6xz6cEhWzZG2eY2Ky+AhylHXuk4kjmwxiqHtrCQladSQB0rLVY/YSPGVn
 ZqB/7DiCwvsKeSz8srRZxHF2nZYNSBeci6T7+fdmTOVoOVBI3/Eb83EPXeMLlLb/l/Lt
 EZ9MqW24bJWAZUIg04SoLPfUEBcJxsfD7M1R0roGwyLw7Tzmqvzon0UrE1JGVPqBmZQ9 rNng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com;
 s=arc-20160816; h=references:in-reply-to:message-id:date:subject:cc:to:from
 :delivered-to; bh=kqjMmaSSnAvy0QV6APgLBGfLig6kIaR6fSkxdiONH5s=;
 b=pd0DXuVBxqVDWAKkMq6UAObT3s2TzXvKjpAWW6M/1t315qrcy/qxQlyeqMZ8AB+kZL
 l+nmhqsfmWqYbrHrgjWR5Rzh4oOA6wPkq620zo9E57dOwGzAOMbRF/1zMd0Mlt2v2c2w
 G0thfJB6XUO1RfFMWCgOWErZtLQESpmqwAn8rMHfYM5uReoP75HeieyuzFxyZQkWz8Kg
 gehQNwjXP7798zMNCHpwtG8FwN0U5wH5Ywx605CobCWCJKaPQ6V7YtvpxTIbb04VJc6s
 4LFlM8o3/RY67+raQuElXvy7MLuG736UGoY5dUJmdXc/jthmNS8Wh9DaAVgdP/jUihlx 6Xgw==
ARC-Authentication-Results: i=1; mx.google.com; spf=pass (google.com: domain
 gapps.redhat.com configured 207.211.31.81 as internal address)
 smtp.mailfrom=dwysocha@redhat.com
Return-Path: <dwysocha@redhat.com>
Received: from us-smtp-1.mimecast.com (us-smtp-2.mimecast.com.
 [207.211.31.81]) by mx.google.com with ESMTPS id
 t17si21286044edd.346.2021.10.03.12.22.51 for <dhowells@gapps.redhat.com>
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128); Sun, 03
 Oct 2021 12:22:51 -0700 (PDT)
Received-SPF: pass (google.com: domain gapps.redhat.com configured
 207.211.31.81 as internal address)
Authentication-Results: mx.google.com; spf=pass (google.com: domain
 gapps.redhat.com configured 207.211.31.81 as internal address)
 smtp.mailfrom=dwysocha@redhat.com
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-349-pJuAUi8HMKuhwKxb9HE_iA-1; Sun, 03 Oct 2021 15:22:49 -0400
X-MC-Unique: pJuAUi8HMKuhwKxb9HE_iA-1
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com
 [10.5.11.15]) (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits)) (No
 client certificate requested) by mimecast-mx01.redhat.com (Postfix) with
 ESMTPS id BCA30802C87 for <dhowells@gapps.redhat.com>; Sun,  3 Oct 2021
 19:22:48 +0000 (UTC)
Received: by smtp.corp.redhat.com (Postfix) id B8AED5F4EC; Sun,  3 Oct 2021
 19:22:48 +0000 (UTC)
Received: from dwysocha.rdu.csb (unknown [10.22.8.148]) by
 smtp.corp.redhat.com (Postfix) with ESMTPS id 2A2E25F4E8; Sun,  3 Oct 2021
 19:22:48 +0000 (UTC)
From: Dave Wysochanski <dwysocha@redhat.com>
To: Trond Myklebust <trondmy@hammerspace.com>, Anna Schumaker
 <anna.schumaker@netapp.com>, David Howells <dhowells@redhat.com>
Cc: linux-cachefs@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH v1 7/7] NFS: Remove remaining usages of NFSDBG_FSCACHE
Date: Sun,  3 Oct 2021 15:22:38 -0400
Message-Id: <1633288958-8481-8-git-send-email-dwysocha@redhat.com>
In-Reply-To: <1633288958-8481-1-git-send-email-dwysocha@redhat.com>
References: <1633288958-8481-1-git-send-email-dwysocha@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
List-Id: <linux-nfs.vger.kernel.org>
Content-Type: text/plain; charset="US-ASCII"

The NFS fscache interface has removed all dfprintks so remove the
NFSDBG_FSCACHE defines.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 fs/nfs/fscache-index.c      | 2 --
 fs/nfs/fscache.c            | 2 --
 include/uapi/linux/nfs_fs.h | 2 +-
 3 files changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/nfs/fscache-index.c b/fs/nfs/fscache-index.c
index 4bd5ce736193..71bb4270641f 100644
--- a/fs/nfs/fscache-index.c
+++ b/fs/nfs/fscache-index.c
@@ -17,8 +17,6 @@
 #include "internal.h"
 #include "fscache.h"
 
-#define NFSDBG_FACILITY		NFSDBG_FSCACHE
-
 /*
  * Define the NFS filesystem for FS-Cache.  Upon registration FS-Cache sticks
  * the cookie for the top-level index object for NFS into here.  The top-level
diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index d199ee103dc6..016e6cb13d28 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -21,8 +21,6 @@
 #include "fscache.h"
 #include "nfstrace.h"
 
-#define NFSDBG_FACILITY                NFSDBG_FSCACHE
-
 static struct rb_root nfs_fscache_keys = RB_ROOT;
 static DEFINE_SPINLOCK(nfs_fscache_keys_lock);
 
diff --git a/include/uapi/linux/nfs_fs.h b/include/uapi/linux/nfs_fs.h
index 3afe3767c55d..caa8d2234958 100644
--- a/include/uapi/linux/nfs_fs.h
+++ b/include/uapi/linux/nfs_fs.h
@@ -52,7 +52,7 @@
 #define NFSDBG_CALLBACK		0x0100
 #define NFSDBG_CLIENT		0x0200
 #define NFSDBG_MOUNT		0x0400
-#define NFSDBG_FSCACHE		0x0800
+#define NFSDBG_UNUSED		0x0800 /* unused; was FSCACHE */
 #define NFSDBG_PNFS		0x1000
 #define NFSDBG_PNFS_LD		0x2000
 #define NFSDBG_STATE		0x4000
-- 
1.8.3.1

