Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794936043;
	b=b2tnuGGbxkndPooWTJatUtPJT3eKbIAylcYOpd49KkH1lm7UZm/d4vkwtoaWcZjwWAUy
	 klFveyIRN+HLl9IqnSawBh6J5VuGZGIo/3HDSTLkNkxZt3yr2mcdFo12RPWS1dPaP626i
	 2zeV0FXmH2sac9YxLacoehdhg+uAK1gy5HtcEDctPsTiATP0PGZ8/ssgZ9kZKPQzbUYD1
	 gJ1jT1dpvmdQ0Qfi156FcGXs46cKjUXIzCLIarIln6vKn4ixrMJmZF6nhj+70+/TEtErC
	 Ato0WszOhBnBYE7R+agRn/1n1AMIDqJFU++HEP2ezdJdAq2Q8BqMfcZqENZ6xOmDNsw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794936043;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=PhNajVV4YOAVa6HzjBax5Vzcm0CeXg6v0Uflf51EUrc=;
	b=C12ridxXCsFxzQO1Zq9wV2OVgajk/2uJZO3onVtXn+s8hgNfKlARHfqCiXSvgPKPWvbI
	 vKdkwouY8Rh+0oRnviHOhqFkf+Fwzwb4u+hb9gXJ4C6A1i3z5K7E0PjlTXA3flVPaSJCK
	 uiIOeO4VOowpBBoFW3DCC6YwTLslsS0nh7mPIxqSnH8MyJCFraPQZtT3M/h3a1YZTJSI9
	 877JfhVWXVHogRZ6XtgtJExWh9Knpb+c68465TEpLreBtGX6gxyKx4AlQkQuWtpy3JRi5
	 8x+CJ/fv2Td8IxkpKGlpDlAAvgfnCgA6lbTqAGtIIp3RFDUEm+W96Q0bILF3trr545Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=CSmuMVcc;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7106B606A885
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 17:20:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 7106B606A885
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=CSmuMVcc
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794936041;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=PhNajVV4YOAVa6HzjBax5Vzcm0CeXg6v0Uflf51EUrc=;
	b=CSmuMVcchrwGN1GRWOtn9pQ7kxhs+dxpD5ZM4wLpgwwG7Pgub3onL7ucZFbYNvvA8dQSe1
	hHzygjV8m8W8CNgkAcdwUogLl5o0shFSNDGefJ/0iwmTHFOX6H8tk57kgfKn7LNxNdUioU
	Q0F8kBrLDoEKHKtVQpSRc0huTpxSWHE=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-250-pu-Za_vLO3apluNSLWQvkA-1; Tue,
 17 Nov 2026 12:20:36 -0500
X-MC-Unique: pu-Za_vLO3apluNSLWQvkA-1
X-Mimecast-MFC-AGG-ID: pu-Za_vLO3apluNSLWQvkA_1794936033
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id E5E5B1956053;
	Tue, 17 Nov 2026 17:20:31 +0000 (UTC)
Received: from dhowells-thinkpadp1gen8.rmtgb.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 9EE441801971;
	Tue, 17 Nov 2026 17:20:27 +0000 (UTC)
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
	linux-kernel@vger.kernel.org,
	Jens Axboe <axboe@kernel.dk>,
	Christoph Hellwig <hch@infradead.org>,
	linux-block@vger.kernel.org
Subject: [PATCH v18 02/17] Add a function to kmap one page of a multipage bio_vec
Date: Tue, 17 Nov 2026 17:19:00 +0000
Message-ID: <20261117171958.2982801-3-dhowells@redhat.com>
In-Reply-To: <20261117171958.2982801-1-dhowells@redhat.com>
References: <20261117171958.2982801-1-dhowells@redhat.com>
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
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

Add a function to kmap one page of a multipage bio_vec by offset (which is
added to the offset in the bio_vec internally).  The caller is responsible
for calculating how much of the page is then available.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Paulo Alcantara (Red Hat) <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Jens Axboe <axboe@kernel.dk>
cc: Christoph Hellwig <hch@infradead.org>
cc: linux-block@vger.kernel.org
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 include/linux/bvec.h | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index b63914ff56e3..7ea62643cfb7 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -344,4 +344,22 @@ static inline phys_addr_t bvec_phys(const struct bio_vec *bvec)
 	return page_to_phys(bvec->bv_page) + bvec->bv_offset;
 }
 
+/**
+ * bvec_kmap_partial - Map part of a bvec into the kernel virtual address space
+ * @bvec: bvec to map
+ * @offset: Offset into bvec
+ *
+ * Map the page containing the byte at @offset into the kernel virtual address
+ * space.  The caller is responsible for making sure this doesn't overrun.
+ *
+ * Call kunmap_local on the returned address to unmap.
+ */
+static inline void *bvec_kmap_partial(const struct bio_vec *bvec, size_t offset)
+{
+	offset += bvec->bv_offset;
+
+	return kmap_local_page(bvec->bv_page + (offset >> PAGE_SHIFT)) +
+		(offset & ~PAGE_MASK);
+}
+
 #endif /* __LINUX_BVEC_H */

