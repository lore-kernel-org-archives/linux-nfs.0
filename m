Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=159.226.251.21
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793759283;
	b=J96Yh0PuMqzm1l8rLfrj1kJN+V+a7gOHAgCtEYP3deDotdskFf9GWsdKpsnVRsYe6vk2
	 KEJ1RC6jYpR2NOjUZb+W0ha4FQ/7bE6aX1YQdoEbYk6JxhGI+Q9Wtlzcf78WtFB80CmRt
	 9Nv0lrTzqHqYXT98l9YzP3od1idVOu08lYmU94hw8Jfz0C18R7Gt5TcHYcLa55FP/f9/N
	 UAMdMDflwsS33gazZzG04QwaAFqXPA1+dnB8ylU6O4B0l1UeTPCN3SOxM6n1QVHrthlcI
	 niUb/Gvn8I/Na4cxVYjs72ZsB3isMNt+cyT0jCEi2ZH4yQsJcQ3XBJycCYvXZF5fZ6Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793759283;
	h=DMARC-Filter:Received:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding:X-CM-TRANSID:
	 X-Coremail-Antispam:X-Originating-IP:X-CM-SenderInfo;
	bh=Lqjf61ZtZmNDLjcYstxY4yfi59CFvtK1AV70cUWOet4=;
	b=BUQhU948lpsAhnK1qBRtY0ARf87fEM5ZpVO3TGQyYozShZxfxxp8J4r1qTSF6cXGSRch
	 rKvLNT3bfS6AGDcf1VQhsPLm5k2SuvwfVSqAAFf048J85631HTdNncOazRGGwVK0ljiNz
	 BGZSq6qEDXAoIfMzPI1mTUXh8cOBvIe5qgCqI8gjjnCCjS0LqM72VafD7XtqiCcCKqGvf
	 YO8BTbDvBlqFC/+6BSi/Q5YA5z9cwwKzf698nXNictlIP6QP8ajtCw2ay6dCG5yjsqbRc
	 DRgwW616TbYCqOXZvHXsPpX8jVi9Do905/RsLb0MEuHJ5S9M0B4VS/qnHAxAiAFR/Hw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=iscas.ac.cn;
	spf=pass smtp.mailfrom=iscas.ac.cn;
	arc=none smtp.remote-ip=159.226.251.21
Received: from cstnet.cn (smtp21.cstnet.cn [159.226.251.21])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 30AAC606A329
	for <linux-nfs@vger.kernel.org>; Wed,  4 Nov 2026 02:28:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 30AAC606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=iscas.ac.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=iscas.ac.cn
Received: from dfae2b116770.home.arpa (unknown [36.110.52.2])
	by APP-01 (Coremail) with SMTP id qwCowADXAPsrmOpqcJs+AA--.9642S2;
	Wed, 04 Nov 2026 10:27:55 +0800 (CST)
From: Wentao Liang <vulab@iscas.ac.cn>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs_common: release the decoded ACL when an entry is invalid
Date: Wed,  4 Nov 2026 02:28:04 +0000
Message-Id: <20261104022804.1484027-1-vulab@iscas.ac.cn>
X-Mailer: git-send-email 2.34.1
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
X-CM-TRANSID:qwCowADXAPsrmOpqcJs+AA--.9642S2
X-Coremail-Antispam: 1UD129KBjvJXoW7tFyDGry7WFyrWF1kGr1fXrb_yoW8CrWxpF
	n3u3yDCry5AF1IyryfZayrGFW0y397tFW8Xr429r1xA393Jrn5AF4Utw4FgFZYyayvvF1j
	kF4Yyw47Zan8CFJanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUUvlb7Iv0xC_Kw4lb4IE77IF4wAFc2x0x2IEx4CE42xK8VAvwI8I
	cIk0rVWrJVCq3wAFIxvE14AKwVWUJVWUGwA2ocxC64kIII0Yj41l84x0c7CEw4AK67xGY2
	AK021l84ACjcxK6xIIjxv20xvE14v26w1j6s0DM28EF7xvwVC0I7IYx2IY6xkF7I0E14v2
	6r4UJVWxJr1l84ACjcxK6I8E87Iv67AKxVWxJr0_GcWl84ACjcxK6I8E87Iv6xkF7I0E14
	v26rxl6s0DM2AIxVAIcxkEcVAq07x20xvEncxIr21l5I8CrVACY4xI64kE6c02F40Ex7xf
	McIj6xIIjxv20xvE14v26rWY6Fy7McIj6I8E87Iv67AKxVW8Jr0_Cr1UMcvjeVCFs4IE7x
	kEbVWUJVW8JwACjcxG0xvY0x0EwIxGrwCY1x0262kKe7AKxVWUtVW8ZwCF04k20xvY0x0E
	wIxGrwCF04k20xvE74AGY7Cv6cx26r48ZrWUJr1UMxC20s026xCaFVCjc4AY6r1j6r4UMI
	8I3I0E5I8CrVAFwI0_Jr0_Jr4lx2IqxVCjr7xvwVAFwI0_JrI_JrWlx4CE17CEb7AF67AK
	xVWUtVW8ZwCIc40Y0x0EwIxGrwCI42IY6xIIjxv20xvE14v26F1j6w1UMIIF0xvE2Ix0cI
	8IcVCY1x0267AKxVW8Jr0_Cr1UMIIF0xvE42xK8VAvwI8IcIk0rVWUJVWUCwCI42IY6I8E
	87Iv67AKxVWxJVW8Jr1lIxAIcVC2z280aVCY1x0267AKxVW8Jr0_Cr1UYxBIdaVFxhVjvj
	DU0xZFpf9x07bzhL5UUUUU=
X-CM-SenderInfo: pyxotu46lvutnvoduhdfq/1tbiBwEBA2rqZFjHlgAAsp

xdr_nfsace_decode() allocates the posix_acl lazily from the first ACE
and stores it in the decode descriptor.  A later entry can still be
rejected, for example on an unknown tag, extra permission bits, or an
invalid uid/gid.  xdr_decode_array2() then returns the error to
nfsacl_decode() and nfs_stream_decode_acl(), and both return without
releasing the partially decoded ACL.

Release the descriptor's ACL on the decode error path in both callers.

Fixes: a257cdd0e217 ("[PATCH] NFSD: Add server support for NFSv3 ACLs.")
Cc: stable@vger.kernel.org
Assisted-by: DeepSeek-V4.1-Flash and OpenAI Codex
Signed-off-by: Wentao Liang <vulab@iscas.ac.cn>
---
 fs/nfs_common/nfsacl.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
index e2eaac14fd8e..c02f0237940f 100644
--- a/fs/nfs_common/nfsacl.c
+++ b/fs/nfs_common/nfsacl.c
@@ -353,8 +353,10 @@ int nfsacl_decode(struct xdr_buf *buf, unsigned int base, unsigned int *aclcnt,
 		return -EINVAL;
 	nfsacl_desc.desc.array_maxlen = entries;
 	err = xdr_decode_array2(buf, base + 4, &nfsacl_desc.desc);
-	if (err)
+	if (err) {
+		posix_acl_release(nfsacl_desc.acl);
 		return err;
+	}
 	if (pacl) {
 		if (entries != nfsacl_desc.desc.array_len ||
 		    posix_acl_from_nfsacl(nfsacl_desc.acl) != 0) {
@@ -405,8 +407,10 @@ bool nfs_stream_decode_acl(struct xdr_stream *xdr, unsigned int *aclcnt,
 	if (!xdr_inline_decode(xdr, XDR_UNIT + elem_size * entries))
 		return false;
 	nfsacl_desc.desc.array_maxlen = entries;
-	if (xdr_decode_array2(xdr->buf, base, &nfsacl_desc.desc))
+	if (xdr_decode_array2(xdr->buf, base, &nfsacl_desc.desc)) {
+		posix_acl_release(nfsacl_desc.acl);
 		return false;
+	}
 
 	if (pacl) {
 		if (entries != nfsacl_desc.desc.array_len ||
-- 
2.34.1

