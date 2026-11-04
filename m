Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=159.226.251.21
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793758544;
	b=ziDN2gRcyzbj00LnMykMRPQgdBR89brFHmwvGBiH4bqMDwKSmvKeoXLhiJD2jp8/FD/g
	 +5Z6H4UuZHVSlJtWNQ1UWhWXgXnwQ1ffgP0b1QHbhqO3sBxulS18cOxVeXAXkLICCk9Ct
	 PIWjtusRruJpskE+IIPna0hisQ9/h8LtfXc7ZChyGQIPO6Gg0o36IzRvoLUhgJhp5lHos
	 DIcrIEUmqS27rrsRwEV1BBaZmaO1RO+fw2asgNvEJuzxo1J0gVLWWGOxxoCs6uNP6vv1m
	 gZ+3vTP1+b5FDAwPmRUB7HWQDL31A6+PWoAiBEbf4sbDipBSON+hXA9VNPuH0oXq/7g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793758544;
	h=DMARC-Filter:Received:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding:X-CM-TRANSID:
	 X-Coremail-Antispam:X-Originating-IP:X-CM-SenderInfo;
	bh=YuKJEvRxMK+2Owr/3WeBrndWrtcha+uGJnk0/CAmTa8=;
	b=GCRol0TuOMSrWaL/vlkaYE3nIBq0pfStKNdIUFwlIxDYilCy5T+Mm70+8jAkcnimjs0L
	 hUvnUqjjOMSaFl6hhEVyYAT5wzBnfGpcbFEwpseoFWYGoKteuh1c4ibzUvSQZjTFrjf2I
	 c//0avXvivsdTdyAgHa3fJT3SDpiy/byhCXQc2CMHDKhEeyRIle1s4Syzsszr0NQPZwZT
	 qHZLMPBFU+UD5xC8Qdp8GUGwWPfcqq8f8EbdvNE9SGaUlSLkEK7EccaAwKp7V4znhY4hD
	 lym1kfCZEc1lySd8Zeetly5zU5kE+eTfh4cc8OSy8dmhVi6ych6TUn4aonyjgMynwCg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=iscas.ac.cn;
	spf=pass smtp.mailfrom=iscas.ac.cn;
	arc=none smtp.remote-ip=159.226.251.21
Received: from cstnet.cn (smtp21.cstnet.cn [159.226.251.21])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86F56606A31B
	for <linux-nfs@vger.kernel.org>; Wed,  4 Nov 2026 02:15:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 86F56606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=iscas.ac.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=iscas.ac.cn
Received: from dfae2b116770.home.arpa (unknown [36.110.52.2])
	by APP-01 (Coremail) with SMTP id qwCowACnzvhNlepqong+AA--.9341S2;
	Wed, 04 Nov 2026 10:15:41 +0800 (CST)
From: Wentao Liang <vulab@iscas.ac.cn>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: release the state owner reference in __nfs42_ssc_open()
Date: Wed,  4 Nov 2026 02:15:50 +0000
Message-Id: <20261104021550.1468884-1-vulab@iscas.ac.cn>
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
X-CM-TRANSID:qwCowACnzvhNlepqong+AA--.9341S2
X-Coremail-Antispam: 1UD129KBjvJXoWrZr4kWF4xurykCF4fKFW5Awb_yoW8JF45pr
	ZYkr1rKr98JF18tFZrAa1jva4j9ryftryUWrykZayxAF93Xr1agF1q9rWFqa1UZrWku3WY
	qr1UtaykX34vvFJanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUUkqb7Iv0xC_Kw4lb4IE77IF4wAFc2x0x2IEx4CE42xK8VAvwI8I
	cIk0rVWrJVCq3wAFIxvE14AKwVWUJVWUGwA2ocxC64kIII0Yj41l84x0c7CEw4AK67xGY2
	AK021l84ACjcxK6xIIjxv20xvE14v26F1j6w1UM28EF7xvwVC0I7IYx2IY6xkF7I0E14v2
	6r4UJVWxJr1l84ACjcxK6I8E87Iv67AKxVWxJr0_GcWl84ACjcxK6I8E87Iv6xkF7I0E14
	v26rxl6s0DM2AIxVAIcxkEcVAq07x20xvEncxIr21l5I8CrVACY4xI64kE6c02F40Ex7xf
	McIj6xIIjxv20xvE14v26rWY6Fy7McIj6I8E87Iv67AKxVW8Jr0_Cr1UMcvjeVCFs4IE7x
	kEbVWUJVW8JwACjcxG0xvY0x0EwIxGrwCF04k20xvY0x0EwIxGrwCF04k20xvE74AGY7Cv
	6cx26r48ZrWUJr1UMxC20s026xCaFVCjc4AY6r1j6r4UMI8I3I0E5I8CrVAFwI0_Jr0_Jr
	4lx2IqxVCjr7xvwVAFwI0_JrI_JrWlx4CE17CEb7AF67AKxVWUXVWUAwCIc40Y0x0EwIxG
	rwCI42IY6xIIjxv20xvE14v26F1j6w1UMIIF0xvE2Ix0cI8IcVCY1x0267AKxVW8Jr0_Cr
	1UMIIF0xvE42xK8VAvwI8IcIk0rVWUJVWUCwCI42IY6I8E87Iv67AKxVW8JVWxJwCI42IY
	6I8E87Iv6xkF7I0E14v26r4UJVWxJrUvcSsGvfC2KfnxnUUI43ZEXa7IU5EQ6tUUUUU==
X-CM-SenderInfo: pyxotu46lvutnvoduhdfq/1tbiCRMBA2rqY-m5dQABsP

__nfs42_ssc_open() takes a reference on the nfs4_state_owner with
nfs4_get_state_owner(), but the success path never releases it.
nfs4_get_open_state() takes its own reference when it creates a new
state, and the existing-state path does not consume the caller's
reference either, so the owner reference obtained at open time stays
around for the lifetime of the server.  Every inter-server copy source
open therefore leaks one state owner.

Release the reference once the open context has been installed on the
file, as the success path in nfs4_do_open() does.

Fixes: ec4b092508982 ("NFS: inter ssc open")
Cc: stable@vger.kernel.org
Assisted-by: DeepSeek-V4.1-Flash and OpenAI Codex
Signed-off-by: Wentao Liang <vulab@iscas.ac.cn>
---
 fs/nfs/nfs4file.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 9a434f5dda8d..24f6be064c34 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -377,6 +377,7 @@ static struct file *__nfs42_ssc_open(struct vfsmount *ss_mnt,
 
 	nfs_file_set_open_context(filep, ctx);
 	put_nfs_open_context(ctx);
+	nfs4_put_state_owner(sp);
 
 	file_ra_state_init(&filep->f_ra, filep->f_mapping->host->i_mapping);
 	res = filep;
-- 
2.34.1

