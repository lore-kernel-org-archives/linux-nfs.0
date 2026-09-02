Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 589FE47F786
	for <linux-nfs@vger.kernel.org>; Wed,  2 Sep 2026 17:38:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788370742; cv=none; b=DwHxiGXoY/qhqi5kdtaEwhU9cpis8lwPFLnpUvl9JaVE8vkqOhdI/hsi2tAwKHRQF8X59KjOwjRkJLgEoqVRzzoWJCJ4f+uLp7+60fmo8qaSplE1uz6JKOr6bBxpFcmzdztd1VAbEYN8Jj6LPHLAlSYT83zBrDJLTAzAotTEjlw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788370742; c=relaxed/simple;
	bh=XC9HZCdrIBllcRkCYBgFcJkGf7MKy8VVFi78dyv5/ik=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=OKD7euNw7EvQF4EyAoPTTTN0F4JWNy/2JGXf++TrA8pXyptPsCowWDL7SzQP5UQmYE+UX9n71NKDwP/0M5ArMd3XXPQS3dow6LPdcQxw1F6tuVi2aLXEuAUBfRJ6E0dw6PCpa68bOO2TqtWbCZg7Rcp/uS1LdEU8RFMCyI+K0h4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=gicA2nvV; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="gicA2nvV"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788370737;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=SbbONJHaUDhDkGGWK9BkP7IsF+RViURMz0/NQExnPJo=;
	b=gicA2nvVY/wvO6H3poKJhpkEAFlEuJz5/MmFVsvT0R19rK2NaOiquPOmPgH74eDQXoczIB
	nnY19MFsGo4XVsGeFcBPjyWAZFkmqiRrLZ+9d/DsbqDhGyOEdl6ghT3qEweR2hCa51vtct
	sjd3Mp6HHwmtySo4qREAJMo8CEBozlY=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-694-8jYihk-xMcWohK_zZMUEbw-1; Wed,
 02 Sep 2026 13:38:53 -0400
X-MC-Unique: 8jYihk-xMcWohK_zZMUEbw-1
X-Mimecast-MFC-AGG-ID: 8jYihk-xMcWohK_zZMUEbw_1788370730
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 9A41E195604B;
	Wed,  2 Sep 2026 17:38:50 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.158])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id B35D11955F02;
	Wed,  2 Sep 2026 17:38:44 +0000 (UTC)
From: David Howells <dhowells@redhat.com>
To: Paulo Alcantara <pc@manguebit.org>
Cc: David Howells <dhowells@redhat.com>,
	Christian Brauner <christian@brauner.io>,
	Matthew Wilcox <willy@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	Jens Axboe <axboe@kernel.dk>,
	Leon Romanovsky <leon@kernel.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
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
	linux-erofs@lists.ozlabs.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v11 36/36] cachefiles: Preset the state xattr when creating a new file
Date: Wed,  2 Sep 2026 18:33:48 +0100
Message-ID: <20260902173350.3468672-37-dhowells@redhat.com>
In-Reply-To: <20260902173350.3468672-1-dhowells@redhat.com>
References: <20260902173350.3468672-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

With a really small cache, cachefiles is likely to see a lot of writes
hitting ENOSPC - and this can include setxattr that sets the state xattr on
a cachefile - but we don't really want to successfully fill a cache file
only to have to scrap it because we can't set the xattr.

Instead, preset the xattr when we create the tmpfile we're going to use,
and scrap the file at that point if we get ENOSPC.  Only if setxattr
succeeds do we allow data to be written to the file.

Note that there is a potential performance loss in that writes to the cache
have to be delayed until this is completed - but we do the tmpfile/setxattr
in parallel, starting when the file is opened and only have to wait once
writeback occurs.

Further, a new tracepoint, cachefiles_no_space, has been added to log ENOSPC
events, along with a couple of subreq traces to log failure detection in
netfslib.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Marc Dionne <marc.dionne@auristor.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/cachefiles/internal.h          |  1 +
 fs/cachefiles/io.c                | 23 ++++++++----
 fs/cachefiles/namei.c             | 15 ++++++--
 fs/cachefiles/xattr.c             | 59 ++++++++++++++++++++++++++++++-
 include/trace/events/cachefiles.h | 30 +++++++++++++++-
 include/trace/events/netfs.h      |  2 ++
 6 files changed, 120 insertions(+), 10 deletions(-)

diff --git a/fs/cachefiles/internal.h b/fs/cachefiles/internal.h
index b2605111fd56..664be64ab538 100644
--- a/fs/cachefiles/internal.h
+++ b/fs/cachefiles/internal.h
@@ -283,6 +283,7 @@ void cachefiles_withdraw_volume(struct cachefiles_volume *volume);
 /*
  * xattr.c
  */
+int cachefiles_preset_object_xattr(struct cachefiles_object *object, struct file *file);
 extern int cachefiles_set_object_xattr(struct cachefiles_object *object);
 extern int cachefiles_check_auxdata(struct cachefiles_object *object,
 				    struct file *file);
diff --git a/fs/cachefiles/io.c b/fs/cachefiles/io.c
index a1580385d5fb..73c8ba01a9e2 100644
--- a/fs/cachefiles/io.c
+++ b/fs/cachefiles/io.c
@@ -672,10 +672,14 @@ int __cachefiles_prepare_write(struct cachefiles_object *object,
 	 * space, we need to see if it's fully allocated.  If it's not, we may
 	 * want to cull it.
 	 */
-	if (cachefiles_has_space(cache, 0, *_len / cache->bsize,
-				 cachefiles_has_space_check) == 0)
+	ret = cachefiles_has_space(cache, 0, *_len / cache->bsize,
+				   cachefiles_has_space_check);
+	if (ret == 0)
 		return 0; /* Enough space to simply overwrite the whole block */
 
+	if (ret == -ENOBUFS)
+		trace_cachefiles_no_space(object, cachefiles_trace_write_nospace_2);
+
 	pos = cachefiles_inject_read_error();
 	if (pos == 0)
 		pos = vfs_llseek(file, start, SEEK_HOLE);
@@ -704,8 +708,11 @@ int __cachefiles_prepare_write(struct cachefiles_object *object,
 	return ret;
 
 check_space:
-	return cachefiles_has_space(cache, 0, *_len / cache->bsize,
-				    cachefiles_has_space_for_write);
+	ret = cachefiles_has_space(cache, 0, *_len / cache->bsize,
+				   cachefiles_has_space_for_write);
+	if (ret == -ENOBUFS)
+		trace_cachefiles_no_space(object, cachefiles_trace_write_nospace);
+	return ret;
 }
 
 static int cachefiles_prepare_write_old(struct netfs_cache_resources *cres,
@@ -757,10 +764,14 @@ static int cachefiles_issue_write(struct netfs_io_subrequest *subreq)
 	       wreq->debug_id, subreq->debug_index, start, start + len - 1);
 
 	if (!cachefiles_cres_file(cres)) {
-		if (!fscache_wait_for_operation(cres, FSCACHE_WANT_WRITE))
+		if (!fscache_wait_for_operation(cres, FSCACHE_WANT_WRITE)) {
+			trace_netfs_sreq(subreq, netfs_sreq_trace_cache_waitfail);
 			return -ENOBUFS;
-		if (!cachefiles_cres_file(cres))
+		}
+		if (!cachefiles_cres_file(cres)) {
+			trace_netfs_sreq(subreq, netfs_sreq_trace_cache_nofile);
 			return -ENOBUFS;
+		}
 	}
 
 	ret = netfs_prepare_write_buffer(subreq, BIO_MAX_VECS);
diff --git a/fs/cachefiles/namei.c b/fs/cachefiles/namei.c
index a30df0f91e5e..ef656a319ede 100644
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
 
@@ -447,6 +450,11 @@ struct file *cachefiles_create_tmpfile(struct cachefiles_object *object)
 		pr_notice("Cache does not support read_iter and write_iter\n");
 		goto err_unuse;
 	}
+
+	/* Preallocate space for the xattr. */
+	ret = cachefiles_preset_object_xattr(object, file);
+	if (ret < 0)
+		goto err_unuse;
 out:
 	cachefiles_end_secure(cache, saved_cred);
 	object->content_info = CACHEFILES_CONTENT_ALL;
@@ -470,8 +478,11 @@ static bool cachefiles_create_file(struct cachefiles_object *object)
 
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
diff --git a/fs/cachefiles/xattr.c b/fs/cachefiles/xattr.c
index 551a3b0069c2..8ebb713482e3 100644
--- a/fs/cachefiles/xattr.c
+++ b/fs/cachefiles/xattr.c
@@ -34,6 +34,57 @@ struct cachefiles_vol_xattr {
 	__u8	data[];		/* netfs volume coherency data */
 } __packed;
 
+/*
+ * Preset the state xattr on a cache file to allocate space for it.
+ */
+int cachefiles_preset_object_xattr(struct cachefiles_object *object, struct file *file)
+{
+	struct cachefiles_xattr *buf;
+	struct dentry *dentry = file->f_path.dentry;
+	unsigned int len = object->cookie->aux_len;
+	int ret;
+
+	buf = kzalloc(sizeof(struct cachefiles_xattr) + min(len, sizeof(__be64)), GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	buf->type		= CACHEFILES_COOKIE_TYPE_DATA;
+	buf->content		= CACHEFILES_CONTENT_DIRTY;
+
+	ret = cachefiles_inject_write_error();
+	if (ret == 0) {
+		ret = mnt_want_write_file(file);
+		if (ret == 0) {
+			ret = vfs_setxattr(&nop_mnt_idmap, dentry,
+					   cachefiles_xattr_cache, buf,
+					   sizeof(struct cachefiles_xattr) + len, 0);
+			mnt_drop_write_file(file);
+		}
+	}
+	if (ret < 0) {
+		trace_cachefiles_vfs_error(object, file_inode(file), ret,
+					   cachefiles_trace_setxattr_error);
+		trace_cachefiles_coherency(object, file_inode(file)->i_ino,
+					   object->object_size,
+					   buf->data, buf->content,
+					   cachefiles_coherency_set_fail);
+		switch (ret) {
+		case -ENOMEM:
+		case -ENOSPC:
+			break;
+		default:
+			cachefiles_io_error_obj(
+				object,
+				"Failed to set xattr with error %d", ret);
+			break;
+		}
+	}
+
+	kfree(buf);
+	_leave(" = %d", ret);
+	return ret;
+}
+
 /*
  * set the state xattr on a cache file
  */
@@ -82,10 +133,16 @@ int cachefiles_set_object_xattr(struct cachefiles_object *object)
 		trace_cachefiles_coherency(object, file_inode(file)->i_ino,
 					   object_size, buf->data, buf->content,
 					   cachefiles_coherency_set_fail);
-		if (ret != -ENOMEM)
+		switch (ret) {
+		case -ENOMEM:
+			break;
+		case -ENOSPC:
+		default:
 			cachefiles_io_error_obj(
 				object,
 				"Failed to set xattr with error %d", ret);
+			break;
+		}
 	} else {
 		trace_cachefiles_coherency(object, file_inode(file)->i_ino,
 					   object_size, buf->data, buf->content,
diff --git a/include/trace/events/cachefiles.h b/include/trace/events/cachefiles.h
index 61007729e55f..a19233e8ae78 100644
--- a/include/trace/events/cachefiles.h
+++ b/include/trace/events/cachefiles.h
@@ -85,11 +85,13 @@ enum cachefiles_prepare_read_trace {
 
 enum cachefiles_error_trace {
 	cachefiles_trace_alignment_error,
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
@@ -102,6 +104,8 @@ enum cachefiles_error_trace {
 	cachefiles_trace_trunc_error,
 	cachefiles_trace_unlink_error,
 	cachefiles_trace_write_error,
+	cachefiles_trace_write_nospace,
+	cachefiles_trace_write_nospace_2,
 };
 
 #endif
@@ -171,11 +175,13 @@ enum cachefiles_error_trace {
 
 #define cachefiles_error_traces						\
 	EM(cachefiles_trace_alignment_error,	"align")		\
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
@@ -187,7 +193,9 @@ enum cachefiles_error_trace {
 	EM(cachefiles_trace_tmpfile_error,	"tmpfile")		\
 	EM(cachefiles_trace_trunc_error,	"trunc")		\
 	EM(cachefiles_trace_unlink_error,	"unlink")		\
-	E_(cachefiles_trace_write_error,	"write")
+	EM(cachefiles_trace_write_error,	"write")		\
+	EM(cachefiles_trace_write_nospace,	"write-nospace")	\
+	E_(cachefiles_trace_write_nospace_2,	"write-nospace-2")
 
 
 /*
@@ -707,6 +715,26 @@ TRACE_EVENT(cachefiles_io_error,
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
diff --git a/include/trace/events/netfs.h b/include/trace/events/netfs.h
index f43a212e4a79..8dad2211a2d7 100644
--- a/include/trace/events/netfs.h
+++ b/include/trace/events/netfs.h
@@ -102,8 +102,10 @@
 	EM(netfs_sreq_trace_abandoned,		"ABNDN")	\
 	EM(netfs_sreq_trace_add_donations,	"+DON ")	\
 	EM(netfs_sreq_trace_added,		"ADD  ")	\
+	EM(netfs_sreq_trace_cache_nofile,	"CA-!F")	\
 	EM(netfs_sreq_trace_cache_nowrite,	"CA-NW")	\
 	EM(netfs_sreq_trace_cache_prepare,	"CA-PR")	\
+	EM(netfs_sreq_trace_cache_waitfail,	"CA-!W")	\
 	EM(netfs_sreq_trace_cache_write,	"CA-WR")	\
 	EM(netfs_sreq_trace_cancel,		"CANCL")	\
 	EM(netfs_sreq_trace_clear,		"CLEAR")	\

