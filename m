Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794429056;
	b=WIynf1UyVHeq0LPwur/8CLrpe9vOU74bUiM61XPFTPW0vUHltuLZ3LLqjuOmhVQIkw7Q
	 NKrfLllBYh4+i3eMZtaDmin8I9bOMs2QxtlGppxUo2ZyqR35JHetkJK/n44+7rc3MEoPB
	 At5/P00cii0jBDj1bc7AAZUSOLyY73D8tCy1vAGPKxneweuzx0IixobFpb5vDfGrn3Tes
	 gGEMGRpjvTh+/kRNZ8VeFCBRzh6PRPVOfkJoDKiwUxRVDOsv+Ye9Ax3G0v7xhnkXEVfLD
	 whH8FLDHj8ynvNNLk1EHgB84Asx8gGQg377QRzK6nlclCgJVxLmXX8TmURKItcXoHvw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794429056;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=y3TtDW1WKRbGF0ZusHGDdMsHnXiCQqqrodTZSz3UVtw=;
	b=lcWYj32FPiBTwCFo3YDPYLGUT4/XPlj0ULlhviaj/5mI7+6Q3caS6ytVDVLidynsK/64
	 2J5GEF/DeXkjnBnOFXoZ8CoLlrtByCJWMlM3L8f8vO6Tlw/vOxRKNyWtnsQ6hHkb3Er0F
	 T/Vz7zCl45KuQ3u7Xkl0AztpYY93MB1xLrTkseteE4KOOsifE7LMEVN0w0xzevLmfWgrF
	 3ZAlWjXcBEaaktwPzUUgPybF05IdFbApqaQvidObR2exg+/0WdDO97f83ZnR8h8EWJ8gP
	 Yy5NGU8KRaxamBj/NzoD8cYenCphq4y//qvpCNVyLpy0FJFH/xq22U7iBBU+S8f9jog==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=RYVLWTn5;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1CDB4606A337
	for <linux-nfs@vger.kernel.org>; Wed, 11 Nov 2026 20:30:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1CDB4606A337
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=RYVLWTn5
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794429055;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=y3TtDW1WKRbGF0ZusHGDdMsHnXiCQqqrodTZSz3UVtw=;
	b=RYVLWTn5DM09cGqfLt0g0oTkbw6UUe3VCwHQgqnCFGfA9nnfy+OO2yDcmJ765mG6l6AfaS
	cqVqqfW5Y+xnTeqfthcfhsAFtH0FX32by+HNg/3wDUHbjYklyv/A78FXQON6PEfegKXaZa
	m8igOEtAodLV9Ed9YnX0M5AsARVRZ10=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-104-qZYmIXuZNtWtwqwgSmiJLg-1; Wed,
 11 Nov 2026 15:30:53 -0500
X-MC-Unique: qZYmIXuZNtWtwqwgSmiJLg-1
X-Mimecast-MFC-AGG-ID: qZYmIXuZNtWtwqwgSmiJLg_1794429051
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 870C519560B9;
	Wed, 11 Nov 2026 20:30:49 +0000 (UTC)
Received: from dhowells-thinkpadp1gen8.rmtgb.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 7E83E195608B;
	Wed, 11 Nov 2026 20:30:44 +0000 (UTC)
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
Subject: [PATCH v17 01/17] iov_iter: Fix kunit test to remove __init and __refdata marks
Date: Wed, 11 Nov 2026 20:30:14 +0000
Message-ID: <20261111203034.2126314-2-dhowells@redhat.com>
In-Reply-To: <20261111203034.2126314-1-dhowells@redhat.com>
References: <20261111203034.2126314-1-dhowells@redhat.com>
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
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

Remove the __init marks from the functions in the iov_iter kunit test so
that they don't get removed after the module is loaded or if the test is
built in as the tests can be triggered through debugfs too.

Also remove the __refdata mark which is unnecessary if the table so marked
doesn't point at any __init funcs.

This was found by claude-opus-5-5 run locally.

Fixes: 2d71340ff1d4 ("iov_iter: Kunit tests for copying to/from an iterator")
Signed-off-by: David Howells <dhowells@redhat.com>
cc: Paulo Alcantara (Red Hat) <pc@manguebit.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Jens Axboe <axboe@kernel.dk>
cc: Christoph Hellwig <hch@infradead.org>
cc: linux-block@vger.kernel.org
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 lib/tests/kunit_iov_iter.c | 96 +++++++++++++++++++-------------------
 1 file changed, 47 insertions(+), 49 deletions(-)

diff --git a/lib/tests/kunit_iov_iter.c b/lib/tests/kunit_iov_iter.c
index 32e42d8c7ca1..b4ad38d1a4bd 100644
--- a/lib/tests/kunit_iov_iter.c
+++ b/lib/tests/kunit_iov_iter.c
@@ -48,9 +48,9 @@ static void iov_kunit_unmap(void *data)
 	vfree(data);
 }
 
-static void *__init iov_kunit_create_buffer(struct kunit *test,
-					    struct page ***ppages,
-					    size_t npages)
+static void *iov_kunit_create_buffer(struct kunit *test,
+				     struct page ***ppages,
+				     size_t npages)
 {
 	struct page **pages;
 	unsigned long got, last;
@@ -90,11 +90,11 @@ static void *__init iov_kunit_create_buffer(struct kunit *test,
 	return buffer;
 }
 
-static void __init iov_kunit_load_kvec(struct kunit *test,
-				       struct iov_iter *iter, int dir,
-				       struct kvec *kvec, unsigned int kvmax,
-				       void *buffer, size_t bufsize,
-				       const struct kvec_test_range *pr)
+static void iov_kunit_load_kvec(struct kunit *test,
+				struct iov_iter *iter, int dir,
+				struct kvec *kvec, unsigned int kvmax,
+				void *buffer, size_t bufsize,
+				const struct kvec_test_range *pr)
 {
 	size_t size = 0;
 	int i;
@@ -116,7 +116,7 @@ static void __init iov_kunit_load_kvec(struct kunit *test,
 /*
  * Test copying to a ITER_KVEC-type iterator.
  */
-static void __init iov_kunit_copy_to_kvec(struct kunit *test)
+static void iov_kunit_copy_to_kvec(struct kunit *test)
 {
 	const struct kvec_test_range *pr;
 	struct iov_iter iter;
@@ -166,7 +166,7 @@ static void __init iov_kunit_copy_to_kvec(struct kunit *test)
 /*
  * Test copying from a ITER_KVEC-type iterator.
  */
-static void __init iov_kunit_copy_from_kvec(struct kunit *test)
+static void iov_kunit_copy_from_kvec(struct kunit *test)
 {
 	const struct kvec_test_range *pr;
 	struct iov_iter iter;
@@ -234,12 +234,12 @@ static const struct bvec_test_range bvec_test_ranges[] = {
 	{ -1, -1, -1 }
 };
 
-static void __init iov_kunit_load_bvec(struct kunit *test,
-				       struct iov_iter *iter, int dir,
-				       struct bio_vec *bvec, unsigned int bvmax,
-				       struct page **pages, size_t npages,
-				       size_t bufsize,
-				       const struct bvec_test_range *pr)
+static void iov_kunit_load_bvec(struct kunit *test,
+				struct iov_iter *iter, int dir,
+				struct bio_vec *bvec, unsigned int bvmax,
+				struct page **pages, size_t npages,
+				size_t bufsize,
+				const struct bvec_test_range *pr)
 {
 	struct page *can_merge = NULL, *page;
 	size_t size = 0;
@@ -275,7 +275,7 @@ static void __init iov_kunit_load_bvec(struct kunit *test,
 /*
  * Test copying to a ITER_BVEC-type iterator.
  */
-static void __init iov_kunit_copy_to_bvec(struct kunit *test)
+static void iov_kunit_copy_to_bvec(struct kunit *test)
 {
 	const struct bvec_test_range *pr;
 	struct iov_iter iter;
@@ -328,7 +328,7 @@ static void __init iov_kunit_copy_to_bvec(struct kunit *test)
 /*
  * Test copying from a ITER_BVEC-type iterator.
  */
-static void __init iov_kunit_copy_from_bvec(struct kunit *test)
+static void iov_kunit_copy_from_bvec(struct kunit *test)
 {
 	const struct bvec_test_range *pr;
 	struct iov_iter iter;
@@ -392,10 +392,10 @@ static void iov_kunit_destroy_folioq(void *data)
 	}
 }
 
-static void __init iov_kunit_load_folioq(struct kunit *test,
-					struct iov_iter *iter, int dir,
-					struct folio_queue *folioq,
-					struct page **pages, size_t npages)
+static void iov_kunit_load_folioq(struct kunit *test,
+				  struct iov_iter *iter, int dir,
+				  struct folio_queue *folioq,
+				  struct page **pages, size_t npages)
 {
 	struct folio_queue *p = folioq;
 	size_t size = 0;
@@ -429,7 +429,7 @@ static struct folio_queue *iov_kunit_create_folioq(struct kunit *test)
 /*
  * Test copying to a ITER_FOLIOQ-type iterator.
  */
-static void __init iov_kunit_copy_to_folioq(struct kunit *test)
+static void iov_kunit_copy_to_folioq(struct kunit *test)
 {
 	const struct kvec_test_range *pr;
 	struct iov_iter iter;
@@ -491,7 +491,7 @@ static void __init iov_kunit_copy_to_folioq(struct kunit *test)
 /*
  * Test copying from a ITER_FOLIOQ-type iterator.
  */
-static void __init iov_kunit_copy_from_folioq(struct kunit *test)
+static void iov_kunit_copy_from_folioq(struct kunit *test)
 {
 	const struct kvec_test_range *pr;
 	struct iov_iter iter;
@@ -560,10 +560,10 @@ static void iov_kunit_destroy_xarray(void *data)
 	kfree(xarray);
 }
 
-static void __init iov_kunit_load_xarray(struct kunit *test,
-					 struct iov_iter *iter, int dir,
-					 struct xarray *xarray,
-					 struct page **pages, size_t npages)
+static void iov_kunit_load_xarray(struct kunit *test,
+				  struct iov_iter *iter, int dir,
+				  struct xarray *xarray,
+				  struct page **pages, size_t npages)
 {
 	size_t size = 0;
 	int i;
@@ -591,7 +591,7 @@ static struct xarray *iov_kunit_create_xarray(struct kunit *test)
 /*
  * Test copying to a ITER_XARRAY-type iterator.
  */
-static void __init iov_kunit_copy_to_xarray(struct kunit *test)
+static void iov_kunit_copy_to_xarray(struct kunit *test)
 {
 	const struct kvec_test_range *pr;
 	struct iov_iter iter;
@@ -649,7 +649,7 @@ static void __init iov_kunit_copy_to_xarray(struct kunit *test)
 /*
  * Test copying from a ITER_XARRAY-type iterator.
  */
-static void __init iov_kunit_copy_from_xarray(struct kunit *test)
+static void iov_kunit_copy_from_xarray(struct kunit *test)
 {
 	const struct kvec_test_range *pr;
 	struct iov_iter iter;
@@ -712,7 +712,7 @@ static void __init iov_kunit_copy_from_xarray(struct kunit *test)
 /*
  * Test the extraction of ITER_KVEC-type iterators.
  */
-static void __init iov_kunit_extract_pages_kvec(struct kunit *test)
+static void iov_kunit_extract_pages_kvec(struct kunit *test)
 {
 	const struct kvec_test_range *pr;
 	struct iov_iter iter;
@@ -792,7 +792,7 @@ static void __init iov_kunit_extract_pages_kvec(struct kunit *test)
 /*
  * Test the extraction of ITER_BVEC-type iterators.
  */
-static void __init iov_kunit_extract_pages_bvec(struct kunit *test)
+static void iov_kunit_extract_pages_bvec(struct kunit *test)
 {
 	const struct bvec_test_range *pr;
 	struct iov_iter iter;
@@ -870,7 +870,7 @@ static void __init iov_kunit_extract_pages_bvec(struct kunit *test)
 /*
  * Test the extraction of ITER_FOLIOQ-type iterators.
  */
-static void __init iov_kunit_extract_pages_folioq(struct kunit *test)
+static void iov_kunit_extract_pages_folioq(struct kunit *test)
 {
 	const struct kvec_test_range *pr;
 	struct folio_queue *folioq;
@@ -949,7 +949,7 @@ static void __init iov_kunit_extract_pages_folioq(struct kunit *test)
 /*
  * Test the extraction of ITER_XARRAY-type iterators.
  */
-static void __init iov_kunit_extract_pages_xarray(struct kunit *test)
+static void iov_kunit_extract_pages_xarray(struct kunit *test)
 {
 	const struct kvec_test_range *pr;
 	struct iov_iter iter;
@@ -1033,8 +1033,7 @@ struct iov_kunit_iter_to_sg_data {
 	size_t npages;
 };
 
-static void __init
-iov_kunit_iter_unpin_sgt(void *data)
+static void iov_kunit_iter_unpin_sgt(void *data)
 {
 	struct sg_table *sgt = data;
 
@@ -1042,9 +1041,9 @@ iov_kunit_iter_unpin_sgt(void *data)
 		unpin_user_page(sg_page(&sgt->sgl[i]));
 }
 
-static void __init
-iov_kunit_iter_to_sg_init(struct kunit *test, size_t bufsize, bool user,
-			  struct iov_kunit_iter_to_sg_data *data)
+static void iov_kunit_iter_to_sg_init(struct kunit *test, size_t bufsize,
+				      bool user,
+				      struct iov_kunit_iter_to_sg_data *data)
 {
 	struct page **spages;
 	struct scatterlist *sg;
@@ -1080,10 +1079,9 @@ iov_kunit_iter_to_sg_init(struct kunit *test, size_t bufsize, bool user,
 	memset(data->scratch, 0, bufsize);
 }
 
-static void __init
-iov_kunit_iter_to_sg_check(struct kunit *test, struct iov_iter *iter,
-			   size_t bufsize,
-			   struct iov_kunit_iter_to_sg_data *data)
+static void iov_kunit_iter_to_sg_check(struct kunit *test, struct iov_iter *iter,
+				       size_t bufsize,
+				       struct iov_kunit_iter_to_sg_data *data)
 {
 	static const size_t tail = 16 * PAGE_SIZE;
 	size_t i;
@@ -1128,7 +1126,7 @@ iov_kunit_iter_to_sg_check(struct kunit *test, struct iov_iter *iter,
 	KUNIT_EXPECT_EQ(test, i, bufsize);
 }
 
-static void __init iov_kunit_iter_to_sg_kvec(struct kunit *test)
+static void iov_kunit_iter_to_sg_kvec(struct kunit *test)
 {
 	struct iov_kunit_iter_to_sg_data data;
 	struct iov_iter iter;
@@ -1145,7 +1143,7 @@ static void __init iov_kunit_iter_to_sg_kvec(struct kunit *test)
 	iov_kunit_iter_to_sg_check(test, &iter, bufsize, &data);
 }
 
-static void __init iov_kunit_iter_to_sg_bvec(struct kunit *test)
+static void iov_kunit_iter_to_sg_bvec(struct kunit *test)
 {
 	struct iov_kunit_iter_to_sg_data data;
 	struct page *p, *can_merge = NULL;
@@ -1173,7 +1171,7 @@ static void __init iov_kunit_iter_to_sg_bvec(struct kunit *test)
 	iov_kunit_iter_to_sg_check(test, &iter, bufsize, &data);
 }
 
-static void __init iov_kunit_iter_to_sg_folioq(struct kunit *test)
+static void iov_kunit_iter_to_sg_folioq(struct kunit *test)
 {
 	struct iov_kunit_iter_to_sg_data data;
 	struct folio_queue *folioq;
@@ -1190,7 +1188,7 @@ static void __init iov_kunit_iter_to_sg_folioq(struct kunit *test)
 	iov_kunit_iter_to_sg_check(test, &iter, bufsize, &data);
 }
 
-static void __init iov_kunit_iter_to_sg_xarray(struct kunit *test)
+static void iov_kunit_iter_to_sg_xarray(struct kunit *test)
 {
 	struct iov_kunit_iter_to_sg_data data;
 	struct xarray *xarray;
@@ -1207,7 +1205,7 @@ static void __init iov_kunit_iter_to_sg_xarray(struct kunit *test)
 	iov_kunit_iter_to_sg_check(test, &iter, bufsize, &data);
 }
 
-static void __init iov_kunit_iter_to_sg_ubuf(struct kunit *test)
+static void iov_kunit_iter_to_sg_ubuf(struct kunit *test)
 {
 	struct iov_kunit_iter_to_sg_data data;
 	struct iov_iter iter;
@@ -1221,7 +1219,7 @@ static void __init iov_kunit_iter_to_sg_ubuf(struct kunit *test)
 	iov_kunit_iter_to_sg_check(test, &iter, bufsize, &data);
 }
 
-static struct kunit_case __refdata iov_kunit_cases[] = {
+static struct kunit_case iov_kunit_cases[] = {
 	KUNIT_CASE(iov_kunit_copy_to_kvec),
 	KUNIT_CASE(iov_kunit_copy_from_kvec),
 	KUNIT_CASE(iov_kunit_copy_to_bvec),

