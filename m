Return-Path: <SRS0=AYid=AY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E174FC433ED
	for <linux-nfs@archiver.kernel.org>; Mon, 13 Jul 2020 16:34:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C53C82065F
	for <linux-nfs@archiver.kernel.org>; Mon, 13 Jul 2020 16:34:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="FNMbxNbt"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730682AbgGMQep (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 13 Jul 2020 12:34:45 -0400
Received: from us-smtp-delivery-1.mimecast.com ([205.139.110.120]:20760 "EHLO
        us-smtp-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1730033AbgGMQep (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2020 12:34:45 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1594658083;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=o4oUojr5NHsycfbNOi5qrHI5NK95AfoUtSwAFHR3zOA=;
        b=FNMbxNbtK7/Q0xJL6eXAe7XDAfouqwHs01KAL4+9zSBCwxGJ9h13Xeqin7xzwYOuHm+jRw
        mYenZCTKzjpTM+uKJYQgPJXqSMyTnLQqBnsaDmH7DFvG7VlDYX+CmDhpoqDG0g/87RbL1w
        +gDP9wweotAAjNLlYSPXKn/tWyEaJ4w=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-366-w8veJSKFOBOGwEzjpT7jhA-1; Mon, 13 Jul 2020 12:34:42 -0400
X-MC-Unique: w8veJSKFOBOGwEzjpT7jhA-1
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 4D165800597;
        Mon, 13 Jul 2020 16:34:40 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-112-113.rdu2.redhat.com [10.10.112.113])
        by smtp.corp.redhat.com (Postfix) with ESMTP id DB6DB72AC3;
        Mon, 13 Jul 2020 16:34:34 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
        Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
        Kingdom.
        Registered in England and Wales under Company Registration No. 3798903
Subject: [PATCH 21/32] cachefiles: Round the cachefile size up to DIO block
 size
From:   David Howells <dhowells@redhat.com>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Steve French <sfrench@samba.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Matthew Wilcox <willy@infradead.org>
Cc:     Jeff Layton <jlayton@redhat.com>,
        Dave Wysochanski <dwysocha@redhat.com>, dhowells@redhat.com,
        linux-cachefs@redhat.com, linux-afs@lists.infradead.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        ceph-devel@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Date:   Mon, 13 Jul 2020 17:34:34 +0100
Message-ID: <159465807406.1376674.8117873071279426760.stgit@warthog.procyon.org.uk>
In-Reply-To: <159465784033.1376674.18106463693989811037.stgit@warthog.procyon.org.uk>
References: <159465784033.1376674.18106463693989811037.stgit@warthog.procyon.org.uk>
User-Agent: StGit/0.22
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Round the size of a cachefile up to DIO block size so that we can always
read back the last partial page of a file using direct I/O.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/cachefiles/interface.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/fs/cachefiles/interface.c b/fs/cachefiles/interface.c
index de4fb41103a6..054d5cc794b5 100644
--- a/fs/cachefiles/interface.c
+++ b/fs/cachefiles/interface.c
@@ -184,6 +184,17 @@ static void cachefiles_update_object(struct fscache_object *_object)
 			cachefiles_remove_object_xattr(cache, object->dentry);
 			goto out;
 		}
+
+		object_size = round_up(object_size, CACHEFILES_DIO_BLOCK_SIZE);
+		_debug("trunc %llx -> %llx", i_size_read(d_inode(object->dentry)), object_size);
+		if (i_size_read(d_inode(object->dentry)) < object_size) {
+			ret = vfs_truncate(&path, object_size);
+			if (ret < 0) {
+				cachefiles_io_error_obj(object, "Trunc-to-dio-size failed");
+				cachefiles_remove_object_xattr(cache, object->dentry);
+				goto out;
+			}
+		}
 	}
 
 	cachefiles_set_object_xattr(object, XATTR_REPLACE);
@@ -354,6 +365,7 @@ static int cachefiles_attr_changed(struct cachefiles_object *object)
 	int ret;
 
 	ni_size = object->fscache.cookie->object_size;
+	ni_size = round_up(ni_size, CACHEFILES_DIO_BLOCK_SIZE);
 
 	_enter("{OBJ%x},[%llu]",
 	       object->fscache.debug_id, (unsigned long long) ni_size);
@@ -422,6 +434,7 @@ static void cachefiles_invalidate_object(struct fscache_object *_object)
 			     struct cachefiles_cache, cache);
 
 	ni_size = object->fscache.cookie->object_size;
+	ni_size = round_up(ni_size, CACHEFILES_DIO_BLOCK_SIZE);
 
 	_enter("{OBJ%x},[%llu]",
 	       object->fscache.debug_id, (unsigned long long)ni_size);


