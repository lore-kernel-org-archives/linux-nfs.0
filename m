X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Google-Smtp-Source: ABdhPJwCc4uAI1NCAU3INCQoq0Z0FkWgz1HMDGLZ9/isqqaCS1ICTTYr2B8XQIIYbnvqteAajtIm
X-Received: by 2002:a50:bf4a:: with SMTP id g10mr13170184edk.11.1633288979511;
 Sun, 03 Oct 2021 12:22:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1633288979; cv=none; d=google.com;
 s=arc-20160816;
 b=fq8Sn+eE8zyrPRVTc+nFQpfwN4pDyr153GsSuz17OwMWcezmESHAV/nKY64BFeqmst
 Kp4jvu7VHX9326ASbx2P4rdUngeu4hooM6OR7VPiow6H1/iYtCTHnUqPs3mvvI0/Kh8k
 EwNC9oZF+NpQlTW/Ns48+W2kvkHGsAqUifeAeY1UbZziueQ/ncBdWEzZpxRrPm3IjFNk
 wsC8NZNmOMVQTthmHsZ/egYVyrhGMm3XufP5c5zdQ3KU6NoNkKxwqAqqpKtfLRrwe5AB
 r0kGpeHGPS4qxIcA/QhioipETJz8HC604QuqkFakjTk7wu5t9uUG1yz9jTkEO54BRuhJ NI2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com;
 s=arc-20160816; h=references:in-reply-to:message-id:date:subject:cc:to:from
 :delivered-to; bh=V45i+FwReE6kj3/yFzuyX5hCruxHTg+35FI4Ypm3l6I=;
 b=e3fU3Yyob8r6Q4MiRalft0mxVTn2Cdu1lQPXkQorTpLZgeQYn71mROdDBh3M7wdQof
 NjowLtPoogREuefNaqHBpv/KwISxvdu6Z6JJaPpEOLXgztz9k+vvrwP0k0p+OQDX5wDd
 JY2HrP9PxqOhwzi7tfbBxMfXe3wojGARnbTklqY9cEHBivFcKGtO8T6dBYazpqL/c+vQ
 PWuyJRE+u+xZWQV4KlhWSKm5B0qbrE3WkysKnQzxslrFZXQnmB4NOnPleCJ0g5kuDYZe
 LR0+v016ihOp02oTMVPXqRrzeR/K+Tgrg16CeY9UcvsJoI4snA3TLyIz6azrZUOoTX6p n9lA==
ARC-Authentication-Results: i=1; mx.google.com; spf=pass (google.com: domain
 gapps.redhat.com configured 205.139.110.120 as internal address)
 smtp.mailfrom=dwysocha@redhat.com
Return-Path: <dwysocha@redhat.com>
Received: from us-smtp-1.mimecast.com (us-smtp-delivery-1.mimecast.com.
 [205.139.110.120]) by mx.google.com with ESMTPS id
 j8si7044526eds.480.2021.10.03.12.22.59 for <dhowells@gapps.redhat.com>
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128); Sun, 03
 Oct 2021 12:22:59 -0700 (PDT)
Received-SPF: pass (google.com: domain gapps.redhat.com configured
 205.139.110.120 as internal address)
Authentication-Results: mx.google.com; spf=pass (google.com: domain
 gapps.redhat.com configured 205.139.110.120 as internal address)
 smtp.mailfrom=dwysocha@redhat.com
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-400-SItzs9vvMwOOGJdqXCxOng-1; Sun, 03 Oct 2021 15:22:45 -0400
X-MC-Unique: SItzs9vvMwOOGJdqXCxOng-1
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com
 [10.5.11.15]) (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits)) (No
 client certificate requested) by mimecast-mx01.redhat.com (Postfix) with
 ESMTPS id 10BD15721E for <dhowells@gapps.redhat.com>; Sun,  3 Oct 2021
 19:22:45 +0000 (UTC)
Received: by smtp.corp.redhat.com (Postfix) id 0CAE65F4EC; Sun,  3 Oct 2021
 19:22:45 +0000 (UTC)
Received: from dwysocha.rdu.csb (unknown [10.22.8.148]) by
 smtp.corp.redhat.com (Postfix) with ESMTPS id 72E9E5F4E9; Sun,  3 Oct 2021
 19:22:44 +0000 (UTC)
From: Dave Wysochanski <dwysocha@redhat.com>
To: Trond Myklebust <trondmy@hammerspace.com>, Anna Schumaker
 <anna.schumaker@netapp.com>, David Howells <dhowells@redhat.com>
Cc: linux-cachefs@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH v1 2/7] NFS: Use nfs_i_fscache() consistently within NFS
 fscache code
Date: Sun,  3 Oct 2021 15:22:33 -0400
Message-Id: <1633288958-8481-3-git-send-email-dwysocha@redhat.com>
In-Reply-To: <1633288958-8481-1-git-send-email-dwysocha@redhat.com>
References: <1633288958-8481-1-git-send-email-dwysocha@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
List-Id: <linux-nfs.vger.kernel.org>
Content-Type: text/plain; charset="US-ASCII"

The nfs_i_fscache() is the API defined to check whether fscache
is enabled on an NFS inode or not, so use it consistently through
the code.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 fs/nfs/fscache.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/fscache.h b/fs/nfs/fscache.h
index 679055720dae..f4deea2908e9 100644
--- a/fs/nfs/fscache.h
+++ b/fs/nfs/fscache.h
@@ -105,7 +105,7 @@ extern void __nfs_read_completion_to_fscache(struct nfs_pgio_header *hdr,
 static inline int nfs_readpage_from_fscache(struct inode *inode,
 					    struct page *page)
 {
-	if (NFS_I(inode)->fscache)
+	if (nfs_i_fscache(inode))
 		return __nfs_readpage_from_fscache(inode, page);
 	return -ENOBUFS;
 }
@@ -117,7 +117,7 @@ static inline int nfs_readpage_from_fscache(struct inode *inode,
 static inline void nfs_readpage_to_fscache(struct inode *inode,
 					   struct page *page)
 {
-	if (NFS_I(inode)->fscache)
+	if (nfs_i_fscache(inode))
 		__nfs_readpage_to_fscache(inode, page);
 }
 
@@ -126,7 +126,7 @@ static inline void nfs_readpage_to_fscache(struct inode *inode,
  */
 static inline void nfs_fscache_invalidate(struct inode *inode)
 {
-	fscache_invalidate(NFS_I(inode)->fscache);
+	fscache_invalidate(nfs_i_fscache(inode));
 }
 
 /*
@@ -134,7 +134,7 @@ static inline void nfs_fscache_invalidate(struct inode *inode)
  */
 static inline void nfs_fscache_wait_on_invalidate(struct inode *inode)
 {
-	fscache_wait_on_invalidate(NFS_I(inode)->fscache);
+	fscache_wait_on_invalidate(nfs_i_fscache(inode));
 }
 
 /*
-- 
1.8.3.1

