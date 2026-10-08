Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 291E3423EA2
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 07:44:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791445485; cv=none; b=sH0r5AYiPyFiaOzS14+uGm2NilH1IuVgKHQSjl4hakoj1cEs7TfKeLZFy294TqCtBkHlEalC3cL2bWnsFCXCXy0VyeboH6QwEt/hu41r1UHHBkEg9XYnA5qomrqySsq4mScsKAs29As5yuS6dzTFnniodCVzfJRhjAO20/E9KWk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791445485; c=relaxed/simple;
	bh=LUl1NfqirDMmY+jIGjOHK7lzd7LicySj5Z6J0kxGk2Y=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=AAIz2bSdngBZM2ssvj9gphVhuCirGj1+NeJEeXv7MjgVP7pgl2i3S2iTraR4rXBgBviDvREQTyDvnUj4DePKUxYC33gzvsVhxQHZyWGDXeF0CeWsyLp7YtDfJSNe261U1kXm0EW+zC/zf0clBWCrFlMh6Kd+rPhHNNCXrHd5fSE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=HhyJeOvL; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="HhyJeOvL"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1791445482;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=LwqBZdLWcYG6WaSkppN9W5jwXqEttH4mtKS7IFlMI1o=;
	b=HhyJeOvLNL9Nz/oKRrgao0e/pk5AAuCDJaUH+Y2BS9qO1weV0yEpjhNhmpsT2j81lq0FOp
	WP05XM/i4vOpwPiqqFvYDmZV4dMhnT+DMaSaGXsr8Gc424REUmI6WeUwR9X7LVD/TL2eNk
	LfFsCq/arU6EyXM6SCaopU+2+8/K2ic=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-220-be6tkRzIOTGnTblClneLqA-1; Thu,
 08 Oct 2026 03:44:35 -0400
X-MC-Unique: be6tkRzIOTGnTblClneLqA-1
X-Mimecast-MFC-AGG-ID: be6tkRzIOTGnTblClneLqA_1791445473
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id C8ADE195FD18;
	Thu,  8 Oct 2026 07:44:32 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.90])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 743E21956040;
	Thu,  8 Oct 2026 07:44:27 +0000 (UTC)
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
Subject: [PATCH v15 5/8] netfs: Provide a func to load the readahead buffers into a bvecq chain
Date: Thu,  8 Oct 2026 08:43:41 +0100
Message-ID: <20261008074346.936909-6-dhowells@redhat.com>
In-Reply-To: <20261008074346.936909-1-dhowells@redhat.com>
References: <20261008074346.936909-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

In netfslib, provide a function to load the readahead buffers into a bvecq
chain by preallocating the bvecq chain and then iterating directly over the
pagecache to extract all the folios.  This builds on the preceding patch to
note the folio count in the readahead_control struct.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Paulo Alcantara <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/netfs/bvecq.c      | 60 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/bvecq.h |  1 +
 2 files changed, 61 insertions(+)

diff --git a/fs/netfs/bvecq.c b/fs/netfs/bvecq.c
index d0e2b9ccda3e..7c6f519856b9 100644
--- a/fs/netfs/bvecq.c
+++ b/fs/netfs/bvecq.c
@@ -603,3 +603,63 @@ size_t bvecq_slice(struct bvecq_pos *pos, size_t max_size,
 	pos->offset = offset;
 	return size;
 }
+
+/**
+ * bvecq_load_from_ra - Allocate a bvecq chain and load from readahead
+ * @pos: Blank position object to attach the new chain to.
+ * @ractl: The readahead control context.
+ *
+ * Decant the set of folios to be read from the readahead context into a bvecq
+ * chain.  Each folio occupies one bio_vec element.
+ *
+ * Return: Amount of data loaded or -ENOMEM on allocation failure.
+ */
+ssize_t bvecq_load_from_ra(struct bvecq_pos *pos, struct readahead_control *ractl)
+{
+	XA_STATE(xas, &ractl->mapping->i_pages, ractl->_index);
+	struct folio *folio;
+	struct bvecq *bq;
+	unsigned int slot = 0;
+	size_t loaded = 0;
+
+	bq = bvecq_alloc_chain(ractl->_nr_folios, GFP_KERNEL, false);
+	if (!bq)
+		return -ENOMEM;
+
+	pos->bvecq  = bq;
+	pos->slot   = 0;
+	pos->offset = 0;
+
+	rcu_read_lock();
+
+	xas_for_each(&xas, folio, ractl->_index + ractl->_nr_pages - 1) {
+		size_t len;
+
+		if (xas_retry(&xas, folio))
+			continue;
+		VM_BUG_ON_FOLIO(!folio_test_locked(folio), folio);
+
+		len = folio_size(folio);
+		bvec_set_folio(&bq->bv[slot], folio, len, 0);
+		loaded += len;
+		slot++;
+		trace_netfs_folio(folio, netfs_folio_trace_read);
+
+		if (slot >= bq->max_slots) {
+			bvecq_filled_to(bq, slot);
+			bq = bq->next;
+			if (!bq)
+				break;
+			slot = 0;
+		}
+	}
+
+	rcu_read_unlock();
+
+	if (bq)
+		bvecq_filled_to(bq, slot);
+
+	ractl->_index += ractl->_nr_pages;
+	ractl->_nr_pages = 0;
+	return loaded;
+}
diff --git a/include/linux/bvecq.h b/include/linux/bvecq.h
index 484c787a50f9..030eef05f728 100644
--- a/include/linux/bvecq.h
+++ b/include/linux/bvecq.h
@@ -77,6 +77,7 @@ void bvecq_pos_advance(struct bvecq_pos *pos, size_t amount);
 ssize_t bvecq_zero(struct bvecq_pos *pos, size_t amount);
 size_t bvecq_slice(struct bvecq_pos *pos, size_t max_size,
 		   unsigned int max_slots, unsigned int *_nr_slots);
+ssize_t bvecq_load_from_ra(struct bvecq_pos *pos, struct readahead_control *ractl);
 
 /**
  * bvecq_alloc_buffer - Allocate a bvecq chain and populate with buffers

