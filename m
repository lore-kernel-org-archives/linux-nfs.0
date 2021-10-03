X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: by 2002:ac2:43cd:0:0:0:0:0 with SMTP id u13csp3163874lfl; Sun, 3 Oct
 2021 12:22:47 -0700 (PDT)
X-Google-Smtp-Source: ABdhPJyWRwphA3uw+f4+yqI7sH77FVtKU5RtRDP/VubTLSYtSQoLLz6Exho9xkgDqxl5wfz1CuRC
X-Received: by 2002:a05:6402:141:: with SMTP id
 s1mr13184454edu.317.1633288967017; Sun, 03 Oct 2021 12:22:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1633288967; cv=none; d=google.com;
 s=arc-20160816;
 b=IKFA4lOx5y5NicZMRl5dL8sbAOiuQndEmgLvuLIvr5w5ouLirjx/sJ5idaD0rJ9KbB
 J5DDF0u9RK9wBf/NrLu7+BrzU5tq9SS+mhWElhfVmPN0I/4x/NcCn8iLK6cU6K14c1g3
 vZReazYRcpBpaWaNN7egqmXgPXPpDgeNEBkPdJpv9aY5r1BpS/C0LZYkZACsVClTbK77
 7PQNOVh52CiSi3TMo1NO5pQZPIOeQMz0+ZrmkIw1jyiTnuVVFJ0A9XmN+hcIk/KBDOwJ
 WnDd/I0rioVue+YxmP1elRLUiK3w6EMI3MXr11G5XqlbGMTxrEk6VWhbnIxHafyWSO2H D+qA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com;
 s=arc-20160816; h=references:in-reply-to:message-id:date:subject:cc:to:from
 :delivered-to; bh=VFX7mcJmelNZkcGtRifMrydaq1RQePTWlfkaUPFu//s=;
 b=HlLJihAc1SPWwKLUAadZZFlHMLGEtPrVLDJqAOxF/gKSRyj3dKs/76QasrnRdYRPth
 OxOsqIt1BQHIIToLL48U0Pe+X9Zpie3s3w6HtY6M/T84PQ16cvDmWBVKfCEzXlNcVZ6C
 HuJUPFX5IB4h9uaKEzwOxreXP0asnSbTo4Np/CYXlLWe1O5510d3JAEtVA9jVnDrUzgi
 E4enebdQ/uFPAFQBqhTWX5o8HD6squjelj87LmMpkwkfUuSmRcyLF8ulvIJ09rhGFkud
 5NjfaBoDemm5d2WKUbe5LYuYgiGaB4jNIRsQFH94PgBDp8crzNFKWc4l8ZztI6XDM94d iLVw==
ARC-Authentication-Results: i=1; mx.google.com; spf=pass (google.com: domain
 gapps.redhat.com configured 207.211.31.81 as internal address)
 smtp.mailfrom=dwysocha@redhat.com
Return-Path: <dwysocha@redhat.com>
Received: from us-smtp-1.mimecast.com (us-smtp-2.mimecast.com.
 [207.211.31.81]) by mx.google.com with ESMTPS id
 b9si17128135ede.235.2021.10.03.12.22.46 for <dhowells@gapps.redhat.com>
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128); Sun, 03
 Oct 2021 12:22:47 -0700 (PDT)
Received-SPF: pass (google.com: domain gapps.redhat.com configured
 207.211.31.81 as internal address)
Authentication-Results: mx.google.com; spf=pass (google.com: domain
 gapps.redhat.com configured 207.211.31.81 as internal address)
 smtp.mailfrom=dwysocha@redhat.com
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-587-mt1C3JQBMxWXXFPS8ZPKLg-1; Sun, 03 Oct 2021 15:22:45 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com
 [10.5.11.15]) (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits)) (No
 client certificate requested) by mimecast-mx01.redhat.com (Postfix) with
 ESMTPS id 4BB965721D for <dhowells@gapps.redhat.com>; Sun,  3 Oct 2021
 19:22:44 +0000 (UTC)
Received: by smtp.corp.redhat.com (Postfix) id 47DA65F4EC; Sun,  3 Oct 2021
 19:22:44 +0000 (UTC)
Received: from dwysocha.rdu.csb (unknown [10.22.8.148]) by
 smtp.corp.redhat.com (Postfix) with ESMTPS id AC8F65F4E8; Sun,  3 Oct 2021
 19:22:43 +0000 (UTC)
From: Dave Wysochanski <dwysocha@redhat.com>
To: Trond Myklebust <trondmy@hammerspace.com>, Anna Schumaker
 <anna.schumaker@netapp.com>, David Howells <dhowells@redhat.com>
Cc: linux-cachefs@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH v1 1/7] NFS: Fixup patch 3/8 of fscache-iter-3 v2
Date: Sun,  3 Oct 2021 15:22:32 -0400
Message-Id: <1633288958-8481-2-git-send-email-dwysocha@redhat.com>
In-Reply-To: <1633288958-8481-1-git-send-email-dwysocha@redhat.com>
References: <1633288958-8481-1-git-send-email-dwysocha@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
List-Id: <linux-nfs.vger.kernel.org>
Content-Type: text/plain; charset="US-ASCII"

Handle failed return values of fscache_fallback_read_page() in
switch statement.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 fs/nfs/fscache.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index 5b0e78742444..d3efb8ba4fb7 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -345,11 +345,6 @@ int __nfs_readpage_from_fscache(struct inode *inode, struct page *page)
 	}
 
 	ret = fscache_fallback_read_page(nfs_i_fscache(inode), page);
-	if (ret < 0) {
-		dfprintk(FSCACHE, "NFS:    readpage_from_fscache: "
-			 "fscache_fallback_read_page failed ret = %d\n", ret);
-		return ret;
-	}
 
 	switch (ret) {
 	case 0: /* Read completed synchronously */
@@ -363,7 +358,7 @@ int __nfs_readpage_from_fscache(struct inode *inode, struct page *page)
 	case -ENODATA: /* page not in cache */
 		nfs_inc_fscache_stats(inode, NFSIOS_FSCACHE_PAGES_READ_FAIL);
 		dfprintk(FSCACHE,
-			 "NFS:    readpage_from_fscache %d\n", ret);
+			 "NFS:    readpage_from_fscache failed %d\n", ret);
 		SetPageChecked(page);
 		return 1;
 
-- 
1.8.3.1

