X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Google-Smtp-Source: ABdhPJzlrzGOKmdlq4Ch/EaXIjrzO3ey5v2E6di/uRjXlP7rMvXYZw8qiryCnovTD1GoPuP6TNai
X-Received: by 2002:a50:bb67:: with SMTP id y94mr5507892ede.308.1633288970102;
 Sun, 03 Oct 2021 12:22:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1633288970; cv=none; d=google.com;
 s=arc-20160816;
 b=J1Sfimy1l1XbBplpNh2j55DVRv5hJwLBF1ZmUwyf5WV7c5lI3lat4ZPWfL+cl7PAYl
 hcomHhfVtK89vqQ545v9iaDvWuGGIYRm8YUsVMlTimuN52g4Mper+8K4moJG6qbRkPLn
 X7SNeuhY/LvmCsCZKyiWyKormJgJCIBjBBL/zhlB1BYsBdKVxWKbwS2kvhmwZqOy9WSh
 NwpzPRLMbviHUhFOnbwTe7kQCKC+qYPjDKJMgo5Dukh/NkU5lpRKO/Iqn2hwp5LIULm1
 uxDecD7nDSCJ51h9PRM2KhQDFz0NT/jkLpGiMihzLw7/GnYQXNCF8byH3fAW6ug2qXh8 bNaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com;
 s=arc-20160816; h=references:in-reply-to:message-id:date:subject:cc:to:from
 :delivered-to; bh=jMg9PWvIQ2bIc6cR3eaTN3UnePphLQ+I+R3S612riW4=;
 b=b1Vw49Zx470Fybgo9bA7ui58InhRR8TvVljgRMpGCdmF90ZeR+ZgEXt+VpP6MYK8+2
 XNQessNYC5PGKx9Z3ULNcClFeOJ10UssOJ5SRt2nXHOAnzI1vttVrSxfNYFgNOYFdlJT
 7Oi0cFnhCIFuHLzECZX8zpB57iRFcMMu/J8wIay/QKbHj6tOEgA0+39k00UBu46O3J6w
 2pbeR7UKX58l44pl7JP8fvOP+pLcCA5+LRK88tnyRbfE2oM5KQD0mF+kzfECcz6cN7yL
 EWkdu2j5o80E2KQ7T9Hj+kYeXZBlncL4Uo+X0ETPnEn0WPpO9QNi1ewh7LZgnTMTB9dx XlnQ==
ARC-Authentication-Results: i=1; mx.google.com; spf=pass (google.com: domain
 gapps.redhat.com configured 205.139.110.61 as internal address)
 smtp.mailfrom=dwysocha@redhat.com
Return-Path: <dwysocha@redhat.com>
Received: from us-smtp-1.mimecast.com (us-smtp-2.mimecast.com.
 [205.139.110.61]) by mx.google.com with ESMTPS id
 d17si1932025ejt.635.2021.10.03.12.22.49 for <dhowells@gapps.redhat.com>
 (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128); Sun, 03
 Oct 2021 12:22:50 -0700 (PDT)
Received-SPF: pass (google.com: domain gapps.redhat.com configured
 205.139.110.61 as internal address)
Authentication-Results: mx.google.com; spf=pass (google.com: domain
 gapps.redhat.com configured 205.139.110.61 as internal address)
 smtp.mailfrom=dwysocha@redhat.com
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-404-Qdcch_QPMQephA8kDkUqKw-1; Sun, 03 Oct 2021 15:22:48 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com
 [10.5.11.15]) (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits)) (No
 client certificate requested) by mimecast-mx01.redhat.com (Postfix) with
 ESMTPS id 492051084684 for <dhowells@gapps.redhat.com>; Sun,  3 Oct 2021
 19:22:47 +0000 (UTC)
Received: by smtp.corp.redhat.com (Postfix) id 457355F4EC; Sun,  3 Oct 2021
 19:22:47 +0000 (UTC)
Received: from dwysocha.rdu.csb (unknown [10.22.8.148]) by
 smtp.corp.redhat.com (Postfix) with ESMTPS id ABC775F4E9; Sun,  3 Oct 2021
 19:22:46 +0000 (UTC)
From: Dave Wysochanski <dwysocha@redhat.com>
To: Trond Myklebust <trondmy@hammerspace.com>, Anna Schumaker
 <anna.schumaker@netapp.com>, David Howells <dhowells@redhat.com>
Cc: linux-cachefs@redhat.com, linux-nfs@vger.kernel.org
Subject: [PATCH v1 5/7] NFS: Replace dfprintks in favor of tracepoints in
 fscache IO paths
Date: Sun,  3 Oct 2021 15:22:36 -0400
Message-Id: <1633288958-8481-6-git-send-email-dwysocha@redhat.com>
In-Reply-To: <1633288958-8481-1-git-send-email-dwysocha@redhat.com>
References: <1633288958-8481-1-git-send-email-dwysocha@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
List-Id: <linux-nfs.vger.kernel.org>
Content-Type: text/plain; charset="US-ASCII"

Most of fscache and other NFS IO paths are now using tracepoints,
so remove the dfprintks in these code paths and replace with a couple
tracepoints to track page IO.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 fs/nfs/fscache.c  | 22 +++----------
 fs/nfs/nfstrace.h | 97 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 101 insertions(+), 18 deletions(-)

diff --git a/fs/nfs/fscache.c b/fs/nfs/fscache.c
index a2b517846787..1db1e298b915 100644
--- a/fs/nfs/fscache.c
+++ b/fs/nfs/fscache.c
@@ -335,22 +335,17 @@ int __nfs_readpage_from_fscache(struct inode *inode, struct page *page)
 {
 	int ret;
 
-	dfprintk(FSCACHE,
-		 "NFS: readpage_from_fscache(fsc:%p/p:%p(i:%lx f:%lx)/0x%p)\n",
-		 nfs_i_fscache(inode), page, page->index, page->flags, inode);
-
 	if (PageChecked(page)) {
-		dfprintk(FSCACHE, "NFS:    readpage_from_fscache: PageChecked\n");
 		ClearPageChecked(page);
 		return 1;
 	}
 
+	trace_nfs_fscache_page_event_read(inode, page);
 	ret = fscache_fallback_read_page(nfs_i_fscache(inode), page);
+	trace_nfs_fscache_page_event_read_done(inode, page, ret);
 
 	switch (ret) {
 	case 0: /* Read completed synchronously */
-		dfprintk(FSCACHE,
-			 "NFS:    readpage_from_fscache: read successful\n");
 		nfs_inc_fscache_stats(inode, NFSIOS_FSCACHE_PAGES_READ_OK);
 		SetPageUptodate(page);
 		return 0;
@@ -358,13 +353,10 @@ int __nfs_readpage_from_fscache(struct inode *inode, struct page *page)
 	case -ENOBUFS: /* inode not in cache */
 	case -ENODATA: /* page not in cache */
 		nfs_inc_fscache_stats(inode, NFSIOS_FSCACHE_PAGES_READ_FAIL);
-		dfprintk(FSCACHE,
-			 "NFS:    readpage_from_fscache failed %d\n", ret);
 		SetPageChecked(page);
 		return 1;
 
 	default:
-		dfprintk(FSCACHE, "NFS:    readpage_from_fscache %d\n", ret);
 		nfs_inc_fscache_stats(inode, NFSIOS_FSCACHE_PAGES_READ_FAIL);
 		SetPageChecked(page);
 	}
@@ -378,15 +370,9 @@ void __nfs_readpage_to_fscache(struct inode *inode, struct page *page)
 {
 	int ret;
 
-	dfprintk(FSCACHE,
-		 "NFS: readpage_to_fscache(fsc:%p/p:%p(i:%lx f:%lx))\n",
-		 nfs_i_fscache(inode), page, page->index, page->flags);
-
+	trace_nfs_fscache_page_event_write(inode, page);
 	ret = fscache_fallback_write_page(nfs_i_fscache(inode), page);
-
-	dfprintk(FSCACHE,
-		 "NFS:     readpage_to_fscache: p:%p(i:%lu f:%lx) ret %d\n",
-		 page, page->index, page->flags, ret);
+	trace_nfs_fscache_page_event_write_done(inode, page, ret);
 
 	if (ret != 0) {
 		nfs_inc_fscache_stats(inode, NFSIOS_FSCACHE_PAGES_WRITTEN_FAIL);
diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index b4177f57f69b..662dddc2eb96 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -880,6 +880,103 @@
 		)
 );
 
+DECLARE_EVENT_CLASS(nfs_fscache_page_event,
+		TP_PROTO(
+			const struct inode *inode,
+			const struct page *page
+		),
+
+		TP_ARGS(inode, page),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+			__field(loff_t, offset)
+			__field(u32, count)
+		),
+
+		TP_fast_assign(
+			const struct nfs_inode *nfsi = NFS_I(inode);
+			const struct nfs_fh *fh = &nfsi->fh;
+
+			__entry->offset = page->index << PAGE_SHIFT;
+			__entry->count = 4096;
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = nfsi->fileid;
+			__entry->fhandle = nfs_fhandle_hash(fh);
+		),
+
+		TP_printk(
+			"fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"offset=%lld count=%u",
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			(long long)__entry->offset, __entry->count
+		)
+);
+
+DECLARE_EVENT_CLASS(nfs_fscache_page_event_done,
+		TP_PROTO(
+			const struct inode *inode,
+			const struct page *page,
+			int error
+		),
+
+		TP_ARGS(inode, page, error),
+
+		TP_STRUCT__entry(
+			__field(int, error)
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+			__field(loff_t, offset)
+			__field(u32, count)
+		),
+
+		TP_fast_assign(
+			const struct nfs_inode *nfsi = NFS_I(inode);
+			const struct nfs_fh *fh = &nfsi->fh;
+
+			__entry->offset = page->index << PAGE_SHIFT;
+			__entry->count = 4096;
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = nfsi->fileid;
+			__entry->fhandle = nfs_fhandle_hash(fh);
+			__entry->error = error;
+		),
+
+		TP_printk(
+			"fileid=%02x:%02x:%llu fhandle=0x%08x "
+			"offset=%lld count=%u error=%d",
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle,
+			(long long)__entry->offset, __entry->count,
+			__entry->error
+		)
+);
+#define DEFINE_NFS_FSCACHE_PAGE_EVENT(name) \
+	DEFINE_EVENT(nfs_fscache_page_event, name, \
+			TP_PROTO( \
+				const struct inode *inode, \
+				const struct page *page \
+			), \
+			TP_ARGS(inode, page))
+#define DEFINE_NFS_FSCACHE_PAGE_EVENT_DONE(name) \
+	DEFINE_EVENT(nfs_fscache_page_event_done, name, \
+			TP_PROTO( \
+				const struct inode *inode, \
+				const struct page *page, \
+				int error \
+			), \
+			TP_ARGS(inode, page, error))
+DEFINE_NFS_FSCACHE_PAGE_EVENT(nfs_fscache_page_event_read);
+DEFINE_NFS_FSCACHE_PAGE_EVENT_DONE(nfs_fscache_page_event_read_done);
+DEFINE_NFS_FSCACHE_PAGE_EVENT(nfs_fscache_page_event_write);
+DEFINE_NFS_FSCACHE_PAGE_EVENT_DONE(nfs_fscache_page_event_write_done);
+
 TRACE_EVENT(nfs_initiate_read,
 		TP_PROTO(
 			const struct nfs_pgio_header *hdr
-- 
1.8.3.1

