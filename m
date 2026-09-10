Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9194149B5A3
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 22:03:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789077816; cv=none; b=Ig9Ir5/l5Q29ePjVnfJYZEQ5EitIU/K8UETdQy0z9eWITuJ3E5PGnHLoFou1GRAvZ+DKYwb8M/pEjvvOaGBjHakzie8Riy6663IuBL4NI8wkXDt0CA5O8y/AXhqkAXpHXZjRP9869fcS0GDQDOSS5hCnSM/DrO9rLqTI++PZ30I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789077816; c=relaxed/simple;
	bh=7N71QSfXG/oEAXTPRExhYle1NWxzGUIUZP0hY0cvi58=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bMuC+ipOJ9Hj7Ntb47jKJUbMhD9iX9VtmWQONj3TN8BTcwfuHyO0wFhUSn56ZRh4B+xZqJKe88R9LAcfdEQkxTHac2QFd4V7Msj+cyKx0Wa7PncwGbSIp1fDzxd0xSMYOiOlKSRK15bXMDu8aOKKLYGEVhU2Z48/wz348S+cZIg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=NTTHdWK9; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="NTTHdWK9"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1789077813;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=4HeOV1ic1gSfi0+R6SuHSn3W0D1ksy23qGyWj8cUwq4=;
	b=NTTHdWK9UpSiZ2XUfDyRL7W+0hy/2S7xEgkPZzLgb1x/d78Smk4HVQOraXRAHvHkqHTh1f
	eKsdg4ZaCtehGylhmIldp5rYAAVq3gzMkDQrYwBlIVR8/QdReAmoiTtV9rt6EzJ4Ax8XWd
	KukGxfdpZBG99IVm8SIxdhRRlKcbHsU=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-209-YoGHpsZjN12awYFG8sOJ1Q-1; Thu,
 10 Sep 2026 18:03:32 -0400
X-MC-Unique: YoGHpsZjN12awYFG8sOJ1Q-1
X-Mimecast-MFC-AGG-ID: YoGHpsZjN12awYFG8sOJ1Q_1789077809
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id ABD481954B19;
	Thu, 10 Sep 2026 22:03:29 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.54])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id EC1DB18004D4;
	Thu, 10 Sep 2026 22:03:24 +0000 (UTC)
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
Subject: [PATCH v12 5/5] cachefiles: Preset the state xattr when creating a new file
Date: Thu, 10 Sep 2026 23:02:40 +0100
Message-ID: <20260910220242.2165023-6-dhowells@redhat.com>
In-Reply-To: <20260910220242.2165023-1-dhowells@redhat.com>
References: <20260910220242.2165023-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

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

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Marc Dionne <marc.dionne@auristor.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/cachefiles/internal.h |  1 +
 fs/cachefiles/namei.c    |  5 ++++
 fs/cachefiles/xattr.c    | 59 +++++++++++++++++++++++++++++++++++++++-
 3 files changed, 64 insertions(+), 1 deletion(-)

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
diff --git a/fs/cachefiles/namei.c b/fs/cachefiles/namei.c
index ca093840e577..ef656a319ede 100644
--- a/fs/cachefiles/namei.c
+++ b/fs/cachefiles/namei.c
@@ -450,6 +450,11 @@ struct file *cachefiles_create_tmpfile(struct cachefiles_object *object)
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

