X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Google-Smtp-Source: ABdhPJxwgP3qzwLRJ7qCW1WC2iB9ZCjvUwgNLpzLUVp50SyY6AwaBwiJlu1iRQhOAay98sMEoy5r
X-Received: by 2002:a17:906:15cf:: with SMTP id
 l15mr12411280ejd.568.1633288970677; Sun, 03 Oct 2021 12:22:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1633288970; cv=none; d=google.com;
 s=arc-20160816;
 b=cpiBiQOiMpuqLUVvWwSXY6SW7paSfjGgKuLpUPwZQ7p6alFwRYcP9UUun8am5Eyh3e
 gmNhCJJ7NDGRW2k+DJ95zl8gFUAx9di6sTzw6obnOndijqLHerPWDbrMrtblYirB/0Wx
 BCH7w8RjGj4xcow7s77t9ikBMGSpDoOW6s3XZecZb3T+0GS/uKNHefrbc2WB4Ki7flUV
 5wxJUBE98/rCgvLuKRCKE791tUWA6Q8zZK72FQpvUAOfmL+XrJQKtalolB9nJn52IQwr
 PW/B8Nmmkd5uk07OCPeiDDN8UJ0kJGRvIKWFZLkBhaGJOjj1aV1NwQcYSfmY2Amq8I9P C4EQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com;
 s=arc-20160816; h=references:in-reply-to:message-id:date:subject:cc:to:from
 :delivered-to; bh=PHVcg8GMk9x4oxIrNE/0LfJJOUWVeUcw1BVqh9eyRow=;
 b=efoGdwTJZwBywPj74D3LE73DzQ4R/P37RiHT5BYLB2/w7RBlg+lHGBh8n3yiV23sXi
 nWpO/YlvWg5IlccQYK/RfYFfBU+wPkdYYpebNGTSlZwK/FZ/nb2mDUveEjSwblplgy6I
 D7gvIlK7VNYrOYcP8/0YTOjOIJsgmC5CX86wRifQrM4Kw00xgNkGUT2mm8iR19SvP74b
 dvkfKDcJjXi2sBbL3Ks5FzGQM9yWpa5dBGuIeDjmnQ90ObPTlPTnFDssYWnGUw04RscE
 QjVNKb4pcgmCoxe6U1poKcxUjZi/UuLHQsFnIq7Q58GdcyVwSdrCo2iZMficR0yslDUT KbzQ==
ARC-Authentication-Results: i=1; mx.google.com; spf=pass (google.com: domain
 gapps.redhat.com configured 205.139.110.120 as internal address)
 smtp.mailfrom=dwysocha@redhat.com
Return-Path: <dwysocha@redhat.com>
Received: from us-smtp-1.mimecast.com (us-smtp-delivery-1.mimecast.com.
 [205.139.110.120]) by mx.google.com with ESMTPS id
 13si16146770ejf.489.2021.10.03.12.22.50 for <dhowells@gapps.redhat.com>
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128); Sun, 03
 Oct 2021 12:22:50 -0700 (PDT)
Received-SPF: pass (google.com: domain gapps.redhat.com configured
 205.139.110.120 as internal address)
Authentication-Results: mx.google.com; spf=pass (google.com: domain
 gapps.redhat.com configured 205.139.110.120 as internal address)
 smtp.mailfrom=dwysocha@redhat.com
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-174-trvlQj1INPy0xw_GNCijTw-1; Sun, 03 Oct 2021 15:22:48 -0400
X-MC-Unique: trvlQj1INPy0xw_GNCijTw-1
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com
 [10.5.11.15]) (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits)) (No
 client certificate requested) by mimecast-mx01.redhat.com (Postfix) with
 ESMTPS id 07EEC5721D for <dhowells@gapps.redhat.com>; Sun,  3 Oct 2021
 19:22:48 +0000 (UTC)
Received: by smtp.corp.redhat.com (Postfix) id 044295F4EC; Sun,  3 Oct 2021
 19:22:48 +0000 (UTC)
Received: from dwysocha.rdu.csb (unknown [10.22.8.148]) by
 smtp.corp.redhat.com (Postfix) with ESMTPS id 6B0895F4E8; Sun,  3 Oct 2021
 19:22:47 +0000 (UTC)
From: Dave Wysochanski <dwysocha@redhat.com>
To: Trond Myklebust <trondmy@hammerspace.com>, Anna Schumaker
 <anna.schumaker@netapp.com>, David Howells <dhowells@redhat.com>
Cc: linux-cachefs@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH v1 6/7] NFS: Remove remaining dfprintks related to fscache
 cookies
Date: Sun,  3 Oct 2021 15:22:37 -0400
Message-Id: <1633288958-8481-7-git-send-email-dwysocha@redhat.com>
In-Reply-To: <1633288958-8481-1-git-send-email-dwysocha@redhat.com>
References: <1633288958-8481-1-git-send-email-dwysocha@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
List-Id: <linux-nfs.vger.kernel.org>
Content-Type: text/plain; charset="US-ASCII"

The fscache cookie APIs including fscache_acquire_cookie() and
fscache_relinquish_cookie() now have very good tracing.  Thus,
there is no real need for dfprintks in the NFS fscache interface.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 fs/nfs/fscache.c | 14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index 1db1e298b915..d199ee103dc6 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -21,7 +21,7 @@
 #include "fscache.h"
 #include "nfstrace.h"
 
-#define NFSDBG_FACILITY		NFSDBG_FSCACHE
+#define NFSDBG_FACILITY                NFSDBG_FSCACHE
 
 static struct rb_root nfs_fscache_keys = RB_ROOT;
 static DEFINE_SPINLOCK(nfs_fscache_keys_lock);
@@ -86,8 +86,6 @@ void nfs_fscache_get_client_cookie(struct nfs_client *clp)
 					      &key, len,
 					      NULL, 0,
 					      clp, 0, true);
-	dfprintk(FSCACHE, "NFS: get client cookie (0x%p/0x%p)\n",
-		 clp, clp->fscache);
 }
 
 /*
@@ -95,9 +93,6 @@ void nfs_fscache_get_client_cookie(struct nfs_client *clp)
  */
 void nfs_fscache_release_client_cookie(struct nfs_client *clp)
 {
-	dfprintk(FSCACHE, "NFS: releasing client cookie (0x%p/0x%p)\n",
-		 clp, clp->fscache);
-
 	fscache_relinquish_cookie(clp->fscache, NULL, false);
 	clp->fscache = NULL;
 }
@@ -191,8 +186,6 @@ void nfs_fscache_get_super_cookie(struct super_block *sb, const char *uniq, int
 					       sizeof(key->key) + ulen,
 					       NULL, 0,
 					       nfss, 0, true);
-	dfprintk(FSCACHE, "NFS: get superblock cookie (0x%p/0x%p)\n",
-		 nfss, nfss->fscache);
 	return;
 
 non_unique:
@@ -211,9 +204,6 @@ void nfs_fscache_release_super_cookie(struct super_block *sb)
 {
 	struct nfs_server *nfss = NFS_SB(sb);
 
-	dfprintk(FSCACHE, "NFS: releasing superblock cookie (0x%p/0x%p)\n",
-		 nfss, nfss->fscache);
-
 	fscache_relinquish_cookie(nfss->fscache, NULL, false);
 	nfss->fscache = NULL;
 
@@ -270,8 +260,6 @@ void nfs_fscache_clear_inode(struct inode *inode)
 	struct nfs_inode *nfsi = NFS_I(inode);
 	struct fscache_cookie *cookie = nfs_i_fscache(inode);
 
-	dfprintk(FSCACHE, "NFS: clear cookie (0x%p/0x%p)\n", nfsi, cookie);
-
 	nfs_fscache_update_auxdata(&auxdata, inode);
 	fscache_relinquish_cookie(cookie, &auxdata, false);
 	nfsi->fscache = NULL;
-- 
1.8.3.1

