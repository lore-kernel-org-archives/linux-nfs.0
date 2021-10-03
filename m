X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: by 2002:ac2:43cd:0:0:0:0:0 with SMTP id u13csp3163904lfl; Sun, 3 Oct
 2021 12:22:49 -0700 (PDT)
X-Google-Smtp-Source: ABdhPJyNzXIzct2iahF89NxQvUKOo/bJzzY0iVD/M+N7eHvUAyK5xltGkKYEdHT2NeQlNFzUSRum
X-Received: by 2002:a05:6402:2689:: with SMTP id
 w9mr13015703edd.188.1633288969613; Sun, 03 Oct 2021 12:22:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1633288969; cv=none; d=google.com;
 s=arc-20160816;
 b=q7e6bGx9p7E23IeciPr03Hw///KRy9Ti+QZmaB5e1LfrmZioo1bOzNQz8lkMNAJWHR
 DlbpMEpozcdcJeC4/O50X75uNoN81wrhoNTIq4nDRRemUallZHVJ6UbMWhdsPygNU49Q
 HCJsjAB7/0oeRVw1orVuB4uX0T3dZi/SUSixvxZ6R4PF/mq75ud2SI5mhYmQTf68oXpI
 22vN4LUAtvsuc8uP2mBekuP3ucKkxJ05JOo1r8sYk4YRGc8pToEm1vjPfq0da6k9/+y6
 iHRkkErybOa2g/aIekoiXX3E7WsQGIOwcKS8XLz9fqjcdqj3vON0rg4pu7mnVIaOaaQ1 biiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com;
 s=arc-20160816; h=references:in-reply-to:message-id:date:subject:cc:to:from
 :delivered-to; bh=ORB+H2bU1QTNjo7EsF4jvSBFjqD5wbS+47EdJ3RUBzg=;
 b=zbp6aKHeTh/kpbUZexAdpxTKgNGoxBXCdIwkxK8dKvWr7Ow6/iclYhePNSyylo8XEy
 JgnxD3XWoiwdJjU902MBik8zcQ01lQk13CDlyJhRASslLNjDA7NjNw3GIC6Ofml4hUDZ
 fCslLgBXR8CS5ueCC+V77nwGIcbvIZHQ6gE0gO4dZrUGLnJhNO9t2+tAoDBJuXNnn/bq
 ybunlXbWMamGOYr/WQ/QyqK1krcBaYwy0zKegl4Ljimg2KcIoprNZj/b1Y/mJfl5YRZa
 37Ci1i6OzqurSFWKmfthuSXTdnfPK4wUHS2OOytdhpcVbUKQFyk7WkcRlnyL78E6ftFC 2F7w==
ARC-Authentication-Results: i=1; mx.google.com; spf=pass (google.com: domain
 gapps.redhat.com configured 207.211.31.120 as internal address)
 smtp.mailfrom=dwysocha@redhat.com
Return-Path: <dwysocha@redhat.com>
Received: from us-smtp-1.mimecast.com (us-smtp-delivery-1.mimecast.com.
 [207.211.31.120]) by mx.google.com with ESMTPS id
 og14si15184498ejc.176.2021.10.03.12.22.49 for <dhowells@gapps.redhat.com>
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128); Sun, 03
 Oct 2021 12:22:49 -0700 (PDT)
Received-SPF: pass (google.com: domain gapps.redhat.com configured
 207.211.31.120 as internal address)
Authentication-Results: mx.google.com; spf=pass (google.com: domain
 gapps.redhat.com configured 207.211.31.120 as internal address)
 smtp.mailfrom=dwysocha@redhat.com
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-239-ou0H2_s6OIerPBlWDDy4sw-1; Sun, 03 Oct 2021 15:22:47 -0400
X-MC-Unique: ou0H2_s6OIerPBlWDDy4sw-1
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com
 [10.5.11.15]) (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits)) (No
 client certificate requested) by mimecast-mx01.redhat.com (Postfix) with
 ESMTPS id 8A07F19057A9 for <dhowells@gapps.redhat.com>; Sun,  3 Oct 2021
 19:22:46 +0000 (UTC)
Received: by smtp.corp.redhat.com (Postfix) id 86A4A5F4EC; Sun,  3 Oct 2021
 19:22:46 +0000 (UTC)
Received: from dwysocha.rdu.csb (unknown [10.22.8.148]) by
 smtp.corp.redhat.com (Postfix) with ESMTPS id ECA0A5F4E8; Sun,  3 Oct 2021
 19:22:45 +0000 (UTC)
From: Dave Wysochanski <dwysocha@redhat.com>
To: Trond Myklebust <trondmy@hammerspace.com>, Anna Schumaker
 <anna.schumaker@netapp.com>, David Howells <dhowells@redhat.com>
Cc: linux-cachefs@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH v1 4/7] NFS: Convert NFS fscache enable/disable dfprintks to
 tracepoints
Date: Sun,  3 Oct 2021 15:22:35 -0400
Message-Id: <1633288958-8481-5-git-send-email-dwysocha@redhat.com>
In-Reply-To: <1633288958-8481-1-git-send-email-dwysocha@redhat.com>
References: <1633288958-8481-1-git-send-email-dwysocha@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
List-Id: <linux-nfs.vger.kernel.org>
Content-Type: text/plain; charset="US-ASCII"

Convert the enable / disable NFS fscache dfprintks to tracepoints.
Utilize the existing NFS inode trace event class, which allows us
to keep the same output format to other NFS inode tracepoints.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 fs/nfs/fscache.c  | 5 +++--
 fs/nfs/nfstrace.h | 2 ++
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index 8f17fda5b8c9..a2b517846787 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -19,6 +19,7 @@
 #include "internal.h"
 #include "iostat.h"
 #include "fscache.h"
+#include "nfstrace.h"
 
 #define NFSDBG_FACILITY		NFSDBG_FSCACHE
 
@@ -314,11 +315,11 @@ void nfs_fscache_open_file(struct inode *inode, struct file *filp)
 	nfs_fscache_update_auxdata(&auxdata, inode);
 
 	if (inode_is_open_for_write(inode)) {
-		dfprintk(FSCACHE, "NFS: nfsi 0x%p disabling cache\n", nfsi);
+		trace_nfs_disable_fscache_inode(inode);
 		clear_bit(NFS_INO_FSCACHE, &nfsi->flags);
 		fscache_disable_cookie(cookie, &auxdata, true);
 	} else {
-		dfprintk(FSCACHE, "NFS: nfsi 0x%p enabling cache\n", nfsi);
+		trace_nfs_enable_fscache_inode(inode);
 		fscache_enable_cookie(cookie, &auxdata, i_size_read(inode),
 				      nfs_fscache_can_enable, inode);
 		if (fscache_cookie_enabled(cookie))
diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index 8a224871be74..b4177f57f69b 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -209,6 +209,8 @@
 DEFINE_NFS_INODE_EVENT(nfs_fsync_enter);
 DEFINE_NFS_INODE_EVENT_DONE(nfs_fsync_exit);
 DEFINE_NFS_INODE_EVENT(nfs_access_enter);
+DEFINE_NFS_INODE_EVENT(nfs_enable_fscache_inode);
+DEFINE_NFS_INODE_EVENT(nfs_disable_fscache_inode);
 
 TRACE_EVENT(nfs_access_exit,
 		TP_PROTO(
-- 
1.8.3.1

