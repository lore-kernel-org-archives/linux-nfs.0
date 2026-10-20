Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.219.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792533833;
	b=4OApMo0dYtpoI4kj/zCF0SZpYTaPy9/V01uDMLuSXs5F0M5sS6gYL/F3mLyG6H9yVIU/
	 BlG0zPjP4nEQGsm9NoI5xpeubeLk72ogSNMtKzIcBmcXUCMuS43gPqOyHqNoN8y+f7uRx
	 4j27lEd/4TPyWByQ8nISZi5SfFEzEPWstWamfMHj3I03jW6LFaZsoz7WgxaR+wdVNTXum
	 gs7//bKOlF+ksdAwdgQoCD+3pnu2vmGoIXP5N3NmBXRhb45rb2oJ8QfAooR1ENq+B6h5F
	 iKI4ME9taJmTKI+OBqyKGlVnj64nHQIuPGZHsQ6ia0SvqWitfvsF3Cjh+HzPnxOEEtA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792533833;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:Sender:From:
	 X-Google-Original-From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=7y3NOM7xqvWmL65AFq+ZWC79CgE7opPLQwAIectARfc=;
	b=s8fAyMCf+r0291pVSa203I9KnvjdjMEq9IYajmsjfNSdoqwpRkRaPQdGtwuMzu7QePTl
	 DLn1mwwvsmeRD3NXZP+udI96JutU7+q8P50HdD2zHeKB2hMT00+1OR1tcMi6YJrzFBJm/
	 XODO9xMh14Y2YUaa3sdMQGCqyd2tiqkpiTjo8E2EbiL7XOgrIb22w4XVy2oMnBRSkBnGP
	 HbB5qf5X4bctWVbryrPB0o1GSayxSfmKrwRzysfI/WD4zBpqKUHUnGXBiESZltfkKtmHV
	 ehP+CvKQs2Pcb2UWzahb9eS8vw+4xPbhsFp7J41sPjmdNhRdV0VjGvkLek7+EUcQIQg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=e7v4dX4R;
	arc=none smtp.remote-ip=209.85.219.47
Received: from mail-qv1-f47.google.com (mail-qv1-f47.google.com [209.85.219.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1BED6606A324
	for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2026 22:03:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1BED6606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=e7v4dX4R
Received: by mail-qv1-f47.google.com with SMTP id 6a1803df08f44-91ba8fcc684so1307306d6.3
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2026 15:03:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1792533832; x=1793138632; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=7y3NOM7xqvWmL65AFq+ZWC79CgE7opPLQwAIectARfc=;
        b=e7v4dX4RkKze3IRJFHlD90GiiRunjf1dW7R0ovnU+GL0YUvG5uNrO6oe7nd8vkHp1d
         ctyvI/jFJ6jCQ+EsmGNt9g9uXCJayx5vTOHlB0/45prHxEnD01+WxzIuTZ9oKFA0Je7B
         xJolL9Gu2l+kSm7jYJvJfA20olJm6WWRpHH7XHyh6uLzWntCtpCmcq4HaN0MkHR2DqXA
         l0w4btT6vddD/K6vPrJWBxM98p8iiNa1cksHwaZQwwnUtDC/hGh5q+iP9tfRDHGYNdqe
         tqdrfSxhuf5O/ugDKxdhepK5xgcERJbyZZFD0Wipn9BQXiH1MJ9Iqhwi/936FbfaUMUT
         38pw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792533832; x=1793138632;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=7y3NOM7xqvWmL65AFq+ZWC79CgE7opPLQwAIectARfc=;
        b=gwnMJboGJJmF9qTm3IPhMQtRayV5qwLkGqwArNTjLOo4VTBjZ++KSQFP4H6BexNp+D
         +lKMz7/eub3VNYuOn9DeP+kaXFoYD5yROywQMqjiYHFOtxYnjMOSW+L3ic/+Lem/+gB1
         go7I2RlEC7F5FO/VFaca1DOc/NvM1RdvBpHPxh+3PH/MwBUwppznHsrpP6oPT1sPQE3A
         xCwBToFLTnQXfqz1zxMAxWIqZcwC7c3Uiu6pNFiVPjtUmY+xIwgCR9tY2DHK4iHI9Q5N
         ICyLg15zwCs7DbSBzmQCqwWW2L73/8kkOw3Hmo8g22NcEMUtUDBTZsiOdoslWiKaAX8e
         b72A==
X-Gm-Message-State: AFq9FYKm2AnVm+YzSLRAF3cWS/PDXb3te7bgimdTT8GEkjYm64nrLTHw
	sSl+UM5ZqnKbqCgLezgIMeA3vQuFqg9CpJfXvk5ci3+HJ3/Ckfpku7Vt4TPiYiRxZJI=
X-Gm-Gg: AYBFou27NivChwlXYfy5plVnm5rwGaE/95LhKOji+V7zuyR+ulQbyl5wRBx3IcWK3j4
	TwO1zOVdzDxDqkLpMvB+fQODx+LuGercvvV6JMmw2wrEDPzcSjm0u/++ewU1J7bXNHDluv2L4lU
	OZtH1lMSg+v8eZkrmFostjSPaOh9cm0PuiQRXjgzw2ocG0oMtaSSLpU9RUdpVQz9Cr7q5e5RgnJ
	9F9Wbj6D16tyhqUvIr5Y87TGnn7Uw0uyR9W0GDbShzNsfoI/SjrQozCBxbchqEnv2tkObBdQI/Y
	kI64imAKtB5UAR+ULfcCVDBPN+/Y2Ny6m4GqKRn3rnKZtFwtoti1Ze/KlS6ar9RralontI22AZw
	ifV7Rua9ZgMigpHGhU9bUyaHWHoABsfj6vMvGD99JYP219KwPA77/hbs6pjfkzufgN4a+XVTCwW
	dvGJQXfRwaL92YTlxKHc8dy4J+ZsdIuHoK2IOnQC3a0rO1RrwB4A5/gwHMm45lGgxI0gP19479M
	c1Z/ejzg9Qbdn5Fbf8jW+WaUlamC8QhPsERzjlbRMGxWheWz/Kw87Iuk/9YBQSpawOIr2Mp5Q==
X-Received: by 2002:a05:6214:1bcd:b0:917:a2ba:e481 with SMTP id 6a1803df08f44-91c12edd30fmr2833036d6.15.1792533831883;
        Tue, 20 Oct 2026 15:03:51 -0700 (PDT)
Received: from localhost (pool-68-160-167-46.bstnma.fios.verizon.net. [68.160.167.46])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-91c10b70c43sm8732996d6.10.2026.10.20.15.03.51
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Oct 2026 15:03:51 -0700 (PDT)
Sender: Mike Snitzer <mike.snitzer@hammerspace.com>
From: Mike Snitzer <snitzer@hammerspace.com>
X-Google-Original-From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Matthew Wilcox <willy@infradead.org>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH v7 2/5] mm: add folio_mark_dropbehind() to mark a folio dropbehind and account it
Date: Tue, 20 Oct 2026 18:03:43 -0400
Message-ID: <20261020220346.28020-3-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261020220346.28020-1-snitzer@kernel.org>
References: <20261020220346.28020-1-snitzer@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A folio allocated by an RWF_DONTCACHE write is marked dropbehind before
it is dirtied, so folio_account_dirtied() adds it to WB_DONTCACHE_DIRTY
and folio_clear_dirty_for_io() or folio_account_cleaned() subtracts it
when it is cleaned.  Nothing marks a folio that already exists.  A
caller that sets PG_dropbehind on a folio that is already dirty
unbalances the counter: the clean subtracts what was never added, and
once the counter goes negative, wb_stat_sum() reads it as zero and the
DONTCACHE writeback kick stops writing anything back for every writer
on that bdi_writeback.

Add folio_mark_dropbehind(), the inverse of the clear in
__filemap_get_folio_mpol(): with the folio locked, mark it and, if it is
dirty, add it to WB_DONTCACHE_DIRTY.  The folio lock orders this
against dirtying and against folio_clear_dirty_for_io().  A concurrent
lookup without FGP_DONTCACHE that clears the flag again subtracts what
this added.

The name follows folio_set_dirty() and folio_mark_dirty(): the first
only sets PG_dirty, the second also accounts the dirty folio.
folio_set_dropbehind() likewise only sets PG_dropbehind, and
folio_mark_dropbehind() also accounts it in WB_DONTCACHE_DIRTY.

A later commit uses it in NFSD to drop a page shared by two misaligned
WRITEs once both have written it.

Cc: Jeff Layton <jlayton@kernel.org>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Matthew Wilcox (Oracle) <willy@infradead.org>
Cc: linux-mm@kvack.org
Assisted-by: LLM
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 include/linux/pagemap.h |  1 +
 mm/filemap.c            | 31 +++++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 0adfa6605653..3012bd95812a 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -1310,6 +1310,7 @@ void end_page_writeback(struct page *page);
 void folio_end_writeback(struct folio *folio);
 void folio_end_writeback_no_dropbehind(struct folio *folio);
 void folio_end_dropbehind(struct folio *folio);
+void folio_mark_dropbehind(struct folio *folio);
 void folio_wait_stable(struct folio *folio);
 void __folio_mark_dirty(struct folio *folio, struct address_space *, int warn);
 void folio_account_cleaned(struct folio *folio, struct bdi_writeback *wb);
diff --git a/mm/filemap.c b/mm/filemap.c
index 00fd89cf6f55..ed7e4dbea653 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1644,6 +1644,37 @@ void folio_end_dropbehind(struct folio *folio)
 }
 EXPORT_SYMBOL_GPL(folio_end_dropbehind);
 
+/**
+ * folio_mark_dropbehind - mark an existing folio dropbehind
+ * @folio: the folio, locked by the caller
+ *
+ * Mark @folio so that the writeback that cleans it drops it.  A folio that
+ * is already dirty is added to WB_DONTCACHE_DIRTY, as folio_account_dirtied()
+ * would have added it had it been marked when dirtied, so that the clean
+ * that subtracts it leaves the counter balanced.
+ */
+void folio_mark_dropbehind(struct folio *folio)
+{
+	struct address_space *mapping = folio->mapping;
+
+	VM_WARN_ON_ONCE_FOLIO(!folio_test_locked(folio), folio);
+
+	if (folio_test_dropbehind(folio))
+		return;
+	folio_set_dropbehind(folio);
+	if (mapping && folio_test_dirty(folio) &&
+	    mapping_can_writeback(mapping)) {
+		struct inode *inode = mapping->host;
+		struct bdi_writeback *wb;
+		struct wb_lock_cookie cookie = {};
+
+		wb = unlocked_inode_to_wb_begin(inode, &cookie);
+		wb_stat_mod(wb, WB_DONTCACHE_DIRTY, folio_nr_pages(folio));
+		unlocked_inode_to_wb_end(inode, &cookie);
+	}
+}
+EXPORT_SYMBOL_GPL(folio_mark_dropbehind);
+
 /**
  * folio_end_writeback_no_dropbehind - End writeback against a folio.
  * @folio: The folio.
-- 
2.52.0

