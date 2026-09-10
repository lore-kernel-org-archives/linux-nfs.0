Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0DF1C3AFD05
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 22:03:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789077807; cv=none; b=tWqJ4r+0gpBrUZBQNNNOK3Yg15dT5Wt+zSBf8brBcGXLe0TvoAzMPb6Bz+SnvFjRAuTBUrCtdpqtYlXmwkKaAB1cx5BV0Cro9H5QEfgF/n7jedQIsSMHpLVsRntlN/VLqxOmvYo/TTVSnFX8bEnQNoWbceHM3Ezq2uZ6ivgGS8I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789077807; c=relaxed/simple;
	bh=FTmu2WTi1pFMrKMqBY7MRxlnFnFl2qbqBXGXBVt9NZ8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=US3ysMSk99bi0WssokUXooj/jqmLZ+4pgJGt9aQ8T1229ZEqzi0ITsQhMdmjLa6ImCpI89GS264bYFRmaPJ3702+zicCi0MM7X6FUgn5mXhgVVsRcrsZVqeHdj9yya0EEK9LkdsrQUgOkPbOpr2dgT0e+/zNvy9rPBFckO99K14=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=ig3Swo1t; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="ig3Swo1t"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789077805;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=9H2HxtXUS0MPVMIb/0Te//nH4uEIUQeh+y78Jj5WqaY=;
	b=ig3Swo1tltKVbk9or5u7SATpE1xbP/fabHURNsshw9Xr/Jg44gj7I5BA6xMkBkMn+rxysT
	CR5p+PNqbvpDKPu5VlXhFPXPvgau8/0N30FrPE5yGqVKSIRhwZe0jV0dsiGwKQ7zI/B48W
	FxBNYeyGbfYiv5ghztFnuDHz5zqLLWU=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-168-wC1dGj2wNQGdi6pwM1zIBQ-1; Thu,
 10 Sep 2026 18:03:18 -0400
X-MC-Unique: wC1dGj2wNQGdi6pwM1zIBQ-1
X-Mimecast-MFC-AGG-ID: wC1dGj2wNQGdi6pwM1zIBQ_1789077796
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 009BB1955DD9;
	Thu, 10 Sep 2026 22:03:15 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.54])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 008331955D86;
	Thu, 10 Sep 2026 22:03:09 +0000 (UTC)
From: David Howells <dhowells@redhat.com>
To: Christian Brauner <christian@brauner.io>
Cc: David Howells <dhowells@redhat.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Matthew Wilcox <willy@infradead.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Stefan Metzmacher <metze@samba.org>,
	Eric Van Hensbergen <ericvh@kernel.org>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Ilya Dryomov <idryomov@gmail.com>,
	netfs@lists.linux.dev,
	linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	v9fs@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v12 3/5] cachefiles: Add a tracepoint to log insufficient space errors
Date: Thu, 10 Sep 2026 23:02:38 +0100
Message-ID: <20260910220242.2165023-4-dhowells@redhat.com>
In-Reply-To: <20260910220242.2165023-1-dhowells@redhat.com>
References: <20260910220242.2165023-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

Add a tracepoint to log insufficient space errors.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Marc Dionne <marc.dionne@auristor.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/cachefiles/io.c                | 15 +++++++++++----
 fs/cachefiles/namei.c             | 10 ++++++++--
 include/trace/events/cachefiles.h | 30 +++++++++++++++++++++++++++++-
 3 files changed, 48 insertions(+), 7 deletions(-)

diff --git a/fs/cachefiles/io.c b/fs/cachefiles/io.c
index dac48fdf85d1..4b3ceda17426 100644
--- a/fs/cachefiles/io.c
+++ b/fs/cachefiles/io.c
@@ -533,10 +533,14 @@ int __cachefiles_prepare_write(struct cachefiles_object *object,
 	 * space, we need to see if it's fully allocated.  If it's not, we may
 	 * want to cull it.
 	 */
-	if (cachefiles_has_space(cache, 0, *_len / PAGE_SIZE,
-				 cachefiles_has_space_check) == 0)
+	ret = cachefiles_has_space(cache, 0, *_len / PAGE_SIZE,
+				   cachefiles_has_space_check);
+	if (ret == 0)
 		return 0; /* Enough space to simply overwrite the whole block */
 
+	if (ret == -ENOBUFS)
+		trace_cachefiles_no_space(object, cachefiles_trace_write_nospace_2);
+
 	pos = cachefiles_inject_read_error();
 	if (pos == 0)
 		pos = vfs_llseek(file, start, SEEK_HOLE);
@@ -565,8 +569,11 @@ int __cachefiles_prepare_write(struct cachefiles_object *object,
 	return ret;
 
 check_space:
-	return cachefiles_has_space(cache, 0, *_len / PAGE_SIZE,
-				    cachefiles_has_space_for_write);
+	ret = cachefiles_has_space(cache, 0, *_len / PAGE_SIZE,
+				   cachefiles_has_space_for_write);
+	if (ret == -ENOBUFS)
+		trace_cachefiles_no_space(object, cachefiles_trace_write_nospace);
+	return ret;
 }
 
 static int cachefiles_prepare_write(struct netfs_cache_resources *cres,
diff --git a/fs/cachefiles/namei.c b/fs/cachefiles/namei.c
index 88955249a1a6..4780ce6dc830 100644
--- a/fs/cachefiles/namei.c
+++ b/fs/cachefiles/namei.c
@@ -117,8 +117,11 @@ struct dentry *cachefiles_get_directory(struct cachefiles_cache *cache,
 	if (d_is_negative(subdir)) {
 		ret = cachefiles_has_space(cache, 1, 0,
 					   cachefiles_has_space_for_create);
-		if (ret < 0)
+		if (ret < 0) {
+			if (ret == -ENOBUFS)
+				trace_cachefiles_no_space(NULL, cachefiles_trace_mkdir_nospace);
 			goto mkdir_error;
+		}
 
 		_debug("attempt mkdir");
 
@@ -487,8 +490,11 @@ static bool cachefiles_create_file(struct cachefiles_object *object)
 
 	ret = cachefiles_has_space(object->volume->cache, 1, 0,
 				   cachefiles_has_space_for_create);
-	if (ret < 0)
+	if (ret < 0) {
+		if (ret == -ENOBUFS)
+			trace_cachefiles_no_space(object, cachefiles_trace_create_nospace);
 		return false;
+	}
 
 	file = cachefiles_create_tmpfile(object);
 	if (IS_ERR(file))
diff --git a/include/trace/events/cachefiles.h b/include/trace/events/cachefiles.h
index 1938d51a9459..cd865c265c24 100644
--- a/include/trace/events/cachefiles.h
+++ b/include/trace/events/cachefiles.h
@@ -80,11 +80,13 @@ enum cachefiles_prepare_read_trace {
 };
 
 enum cachefiles_error_trace {
+	cachefiles_trace_create_nospace,
 	cachefiles_trace_fallocate_error,
 	cachefiles_trace_getxattr_error,
 	cachefiles_trace_link_error,
 	cachefiles_trace_lookup_error,
 	cachefiles_trace_mkdir_error,
+	cachefiles_trace_mkdir_nospace,
 	cachefiles_trace_notify_change_error,
 	cachefiles_trace_open_error,
 	cachefiles_trace_read_error,
@@ -97,6 +99,8 @@ enum cachefiles_error_trace {
 	cachefiles_trace_trunc_error,
 	cachefiles_trace_unlink_error,
 	cachefiles_trace_write_error,
+	cachefiles_trace_write_nospace,
+	cachefiles_trace_write_nospace_2,
 };
 
 #endif
@@ -161,11 +165,13 @@ enum cachefiles_error_trace {
 	E_(cachefiles_trace_read_seek_nxio,	"seek-enxio")
 
 #define cachefiles_error_traces						\
+	EM(cachefiles_trace_create_nospace,	"create-nospace")	\
 	EM(cachefiles_trace_fallocate_error,	"fallocate")		\
 	EM(cachefiles_trace_getxattr_error,	"getxattr")		\
 	EM(cachefiles_trace_link_error,		"link")			\
 	EM(cachefiles_trace_lookup_error,	"lookup")		\
 	EM(cachefiles_trace_mkdir_error,	"mkdir")		\
+	EM(cachefiles_trace_mkdir_nospace,	"mkdir-nospace")	\
 	EM(cachefiles_trace_notify_change_error, "notify_change")	\
 	EM(cachefiles_trace_open_error,		"open")			\
 	EM(cachefiles_trace_read_error,		"read")			\
@@ -177,7 +183,9 @@ enum cachefiles_error_trace {
 	EM(cachefiles_trace_tmpfile_error,	"tmpfile")		\
 	EM(cachefiles_trace_trunc_error,	"trunc")		\
 	EM(cachefiles_trace_unlink_error,	"unlink")		\
-	E_(cachefiles_trace_write_error,	"write")
+	EM(cachefiles_trace_write_error,	"write")		\
+	EM(cachefiles_trace_write_nospace,	"write-nospace")	\
+	E_(cachefiles_trace_write_nospace_2,	"write-nospace-2")
 
 
 /*
@@ -694,6 +702,26 @@ TRACE_EVENT(cachefiles_io_error,
 		      __entry->error)
 	    );
 
+TRACE_EVENT(cachefiles_no_space,
+	    TP_PROTO(struct cachefiles_object *obj, enum cachefiles_error_trace trace),
+
+	    TP_ARGS(obj, trace),
+
+	    TP_STRUCT__entry(
+		    __field(unsigned int,			obj)
+		    __field(enum cachefiles_error_trace,	trace)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->obj	= obj ? obj->debug_id : 0;
+		    __entry->trace	= trace;
+			   ),
+
+	    TP_printk("o=%08x %s",
+		      __entry->obj,
+		      __print_symbolic(__entry->trace, cachefiles_error_traces))
+	    );
+
 #endif /* _TRACE_CACHEFILES_H */
 
 /* This part must be outside protection */

