Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 389B643BDBE
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 14:42:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787582552; cv=none; b=bDQIfJkImYaZWbaD+QikcH7L8v8y/+dikSQaDmcYTlgreteAl/O+60r87KJ63qdlN3Xn01SkkvKrT2+SB/i4MfQhI5AZCxoJwjI96TDrFvsWUIrV4nS4a8h/q1Y5eMItlI5H32N+VRy7wKRY17ZjFw/0nnBxJlVChMqSj2n0Uvk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787582552; c=relaxed/simple;
	bh=QrVxkC1qUai+LkpCyw0Tz6tntuP4Wpe1tMlKeqdSWwU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=BQdE19aKeabZbp1pugu/8rki4EH8xaM7dLs1eQIK/NqvcsEqGmXEfFCdrbFaxyEiV8wVQjCLdVYyHsjJNLDY79Zrbg8ILw5Sjq7KX7fGPOj4MnD8g5e1fUmxx4scabhGLncpfEME18cqCchO4WKS/SqPDX6Gkr+I/sJZj1bJDeA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=iLk4uY7k; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="iLk4uY7k"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1787582549;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=hoJL241RSoxtycntHxJVxwYZyJBhwGJRmdZEHBFJJr0=;
	b=iLk4uY7km82gfjnKThZ/g3ItfI+JSt6IqqpgSKrBEXSUtSu2oc48BI7k77FAlweebLi8rx
	k2ehw0Dw+SPJVfnmNfiqBC4uyVCI9DsAl55Ec9pdrcdlfoAwHIAtAgbshyn6dCFvFgcVmP
	ToHxTr+/X0W6ZUIgphzHqR8OpQCvcc4=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-586-wqArccvqNnWhMmpYhyITZg-1; Mon,
 24 Aug 2026 10:42:23 -0400
X-MC-Unique: wqArccvqNnWhMmpYhyITZg-1
X-Mimecast-MFC-AGG-ID: wqArccvqNnWhMmpYhyITZg_1787582539
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 69BE31977535;
	Mon, 24 Aug 2026 14:42:19 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.15])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 09DC330002ED;
	Mon, 24 Aug 2026 14:42:12 +0000 (UTC)
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
Subject: [PATCH v10 04/35] cachefiles: Fix potential UAF/KASAN warning
Date: Mon, 24 Aug 2026 15:40:57 +0100
Message-ID: <20260824144130.759997-5-dhowells@redhat.com>
In-Reply-To: <20260824144130.759997-1-dhowells@redhat.com>
References: <20260824144130.759997-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

Currently, trace_cachefiles_coherency() is being passed a pointer to a
__be64 lain over the coherency data in struct cachefiles_xattr so that it
can display the first 8 bytes.  However, the data is of variable length and
could even be 0 bytes.  This could lead to a UAF or KASAN warning.

Fix this by making sure the buffer has room for at least 8 bytes and that
those 8 bytes are pre-cleared.

Further, those bytes are not 8-byte aligned, so fix the tracepoint to
extract the data as four 2-byte words (they are 2-byte aligned) and
reassemble the __be64.  The compiler will convert this into a single 8-byte
load where the CPU supports it.

Fixes: 229105e5cfd9 ("cachefiles: Add auxiliary data trace")
Link: https://sashiko.dev/#/patchset/20260810144746.574036-1-dhowells%40redhat.com
Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara <pc@manguebit.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/cachefiles/xattr.c             | 16 ++++++++--------
 include/trace/events/cachefiles.h | 19 +++++++++++++++++--
 2 files changed, 25 insertions(+), 10 deletions(-)

diff --git a/fs/cachefiles/xattr.c b/fs/cachefiles/xattr.c
index f8ae78b3f7b6..92990cfdcca7 100644
--- a/fs/cachefiles/xattr.c
+++ b/fs/cachefiles/xattr.c
@@ -13,6 +13,7 @@
 #include <linux/quotaops.h>
 #include <linux/xattr.h>
 #include <linux/slab.h>
+#include <linux/unaligned.h>
 #include "internal.h"
 
 #define CACHEFILES_COOKIE_TYPE_DATA 1
@@ -50,7 +51,7 @@ int cachefiles_set_object_xattr(struct cachefiles_object *object)
 
 	_enter("%x,#%d", object->debug_id, len);
 
-	buf = kmalloc(sizeof(struct cachefiles_xattr) + len, GFP_KERNEL);
+	buf = kmalloc(sizeof(struct cachefiles_xattr) + min(len, sizeof(__be64)), GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
 
@@ -60,6 +61,7 @@ int cachefiles_set_object_xattr(struct cachefiles_object *object)
 	buf->content		= object->content_info;
 	if (test_bit(FSCACHE_COOKIE_LOCAL_WRITE, &object->cookie->flags))
 		buf->content	= CACHEFILES_CONTENT_DIRTY;
+	put_unaligned_be64(0, (__be64 *)buf->data);
 	if (len > 0)
 		memcpy(buf->data, fscache_get_aux(object->cookie), len);
 
@@ -77,8 +79,7 @@ int cachefiles_set_object_xattr(struct cachefiles_object *object)
 		trace_cachefiles_vfs_error(object, file_inode(file), ret,
 					   cachefiles_trace_setxattr_error);
 		trace_cachefiles_coherency(object, file_inode(file)->i_ino,
-					   be64_to_cpup((__be64 *)buf->data),
-					   buf->content,
+					   buf->data, buf->content,
 					   cachefiles_coherency_set_fail);
 		if (ret != -ENOMEM)
 			cachefiles_io_error_obj(
@@ -86,8 +87,7 @@ int cachefiles_set_object_xattr(struct cachefiles_object *object)
 				"Failed to set xattr with error %d", ret);
 	} else {
 		trace_cachefiles_coherency(object, file_inode(file)->i_ino,
-					   be64_to_cpup((__be64 *)buf->data),
-					   buf->content,
+					   buf->data, buf->content,
 					   cachefiles_coherency_set_ok);
 	}
 
@@ -110,9 +110,10 @@ int cachefiles_check_auxdata(struct cachefiles_object *object, struct file *file
 	int ret = -ESTALE;
 
 	tlen = sizeof(struct cachefiles_xattr) + len;
-	buf = kmalloc(tlen, GFP_KERNEL);
+	buf = kmalloc(sizeof(struct cachefiles_xattr) + min(len, sizeof(__be64)), GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
+	put_unaligned_be64(0, (__be64 *)buf->data);
 
 	xlen = cachefiles_inject_read_error();
 	if (xlen == 0)
@@ -148,8 +149,7 @@ int cachefiles_check_auxdata(struct cachefiles_object *object, struct file *file
 
 out:
 	trace_cachefiles_coherency(object, file_inode(file)->i_ino,
-				   be64_to_cpup((__be64 *)buf->data),
-				   buf->content, why);
+				   buf->data, buf->content, why);
 	kfree(buf);
 	return ret;
 }
diff --git a/include/trace/events/cachefiles.h b/include/trace/events/cachefiles.h
index 9259bc71049e..927338f8fe85 100644
--- a/include/trace/events/cachefiles.h
+++ b/include/trace/events/cachefiles.h
@@ -372,7 +372,7 @@ TRACE_EVENT(cachefiles_rename,
 TRACE_EVENT(cachefiles_coherency,
 	    TP_PROTO(struct cachefiles_object *obj,
 		     ino_t ino,
-		     u64 disk_aux,
+		     const void *disk_aux,
 		     enum cachefiles_content content,
 		     enum cachefiles_coherency_trace why),
 
@@ -389,12 +389,27 @@ TRACE_EVENT(cachefiles_coherency,
 			     ),
 
 	    TP_fast_assign(
+		    union {
+			    __be16 s[4];
+			    __be64 ll;
+		    } x;
+
 		    __entry->obj	= obj->debug_id;
 		    __entry->why	= why;
 		    __entry->content	= content;
 		    __entry->ino	= ino;
 		    __entry->aux	= be64_to_cpup((__be64 *)obj->cookie->inline_aux);
-		    __entry->disk_aux	= disk_aux;
+
+		    /* cachefiles_xattr::data is not 64-byte aligned. */
+		    if (disk_aux) {
+			    x.s[0] = ((__be16 *)disk_aux)[0];
+			    x.s[1] = ((__be16 *)disk_aux)[1];
+			    x.s[2] = ((__be16 *)disk_aux)[2];
+			    x.s[3] = ((__be16 *)disk_aux)[3];
+			    __entry->disk_aux = be64_to_cpu(x.ll);
+		    } else {
+			    __entry->disk_aux = 0;
+		    }
 			   ),
 
 	    TP_printk("o=%08x %s B=%llx c=%u aux=%llx dsk=%llx",

