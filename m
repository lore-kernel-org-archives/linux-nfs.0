Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0455F495AE1
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 10:23:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791455026; cv=none; b=jXxS4iKqiGqvlPT41pIHPivOAd4zzj/3kBvI8qMCX2A9vfzEs5ae/LfpvuiCd7R1jZgeEwW0sMg83JNTvhhpZUIUGT7o4+NVD4IdCLR9llbXh76ft/HutaX5uHJzBxs6jDxNQOm318k/gUVQMpPmhcgKIwd84/bMmtQEJ57EWpo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791455026; c=relaxed/simple;
	bh=6GyF1Qs2NrtzBugt1e5sO6ALNJ5D++PSKU21Is7l8uQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=uKM6CWPe1e9tOxVlrxxluA2vllqQRJlbRhqOPvMFY1Nc8YH4VzKBli9ftz2YurAyRXNcaqH3IGT5DV99SXaZB0tL9oGs8b+aJv3AphivDC94EpMtw1NK/4oQsVqP78OHT2tTBClR7/ZgQPA1jHxP75xOzQFZ3gO8xOL+iZverko=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=NrWDPhZH; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="NrWDPhZH"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1791455023;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=GfI0PS/fuAM4RwKYrzKwOpR/JriKawbIJsigwnS1DDI=;
	b=NrWDPhZHkwHDm7uRl6X6xsNI7iUEFYVflioeVbxB00AvT5l4OII2F2CzxrEaQP8V1b2yEf
	pRFqHHOn5f57RAv80NDZff5Rwwi0RTOmeclUCMv9vDo1L0aAxEXT8lcOR7lusvjD9lGGtW
	VCRwsqJg40rAKc5pif4AwafSlNVrvn8=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-7-IqlkI06EOFadOX6Q1XaEVA-1; Thu, 8
 Oct 2026 10:23:42 +0000
X-MC-Unique: IqlkI06EOFadOX6Q1XaEVA-1
X-Mimecast-MFC-AGG-ID: IqlkI06EOFadOX6Q1XaEVA_1791455020
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 53C18180A98A;
	Thu,  8 Oct 2026 10:23:40 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.90])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id F2AA41800446;
	Thu,  8 Oct 2026 10:23:34 +0000 (UTC)
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
Subject: [PATCH v17 5/8] netfs: Provide a func to load the readahead buffers into a bvecq chain
Date: Thu,  8 Oct 2026 11:22:49 +0100
Message-ID: <20261008102253.1003776-6-dhowells@redhat.com>
In-Reply-To: <20261008102253.1003776-1-dhowells@redhat.com>
References: <20261008102253.1003776-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

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
index cfbc5f3fd660..99e9c02296ec 100644
--- a/fs/netfs/bvecq.c
+++ b/fs/netfs/bvecq.c
@@ -609,3 +609,63 @@ size_t bvecq_slice(struct bvecq_pos *pos, size_t max_size,
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
index 6a50bba8b23a..cb198ad01c8f 100644
--- a/include/linux/bvecq.h
+++ b/include/linux/bvecq.h
@@ -77,6 +77,7 @@ void bvecq_pos_advance(struct bvecq_pos *pos, size_t amount);
 ssize_t bvecq_zero(struct bvecq_pos *pos, size_t amount);
 size_t bvecq_slice(struct bvecq_pos *pos, size_t max_size,
 		   unsigned int max_slots, unsigned int *_nr_slots);
+ssize_t bvecq_load_from_ra(struct bvecq_pos *pos, struct readahead_control *ractl);
 
 /**
  * bvecq_alloc_buffer - Allocate a bvecq chain and populate with buffers

