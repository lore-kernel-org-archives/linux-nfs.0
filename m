Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=159.226.251.21
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793758539;
	b=z32oxZujHe0cglUV8ebbfWT67cBFfStG6rqkEPj/NVynw7ChxMViY6h4HFUBwlYVWvgv
	 D/rHFMnf7Cl55HP/YahbwYZ2aGfT2B1zeCo1+mPY5EgWUE6NXJfQZNojYwjfPF43ij98n
	 mkhRJdO1CGRWAFlHo3hTepAD66Y5jj4oKNzOv8Pceu9lYWJQWlUHMOMMekm5VHshseQd7
	 io+56RtW6Crsa+CtskMtB43dGGVaukIZ0G+oX+e0R6/AAMUepYw1IGLs2DHiY1kQIJk5P
	 8t0OJvEPzSoiFnsdlj+aGVkBjZcQ2UaA37ijkjWcBJy02g9jpdVBj6/Cy3RcIX87YVw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793758539;
	h=DMARC-Filter:Received:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding:X-CM-TRANSID:
	 X-Coremail-Antispam:X-Originating-IP:X-CM-SenderInfo;
	bh=ev/MCQRcQulEBqWh7b56DIFoaYC3mCVJZNgRyTufn1U=;
	b=zDcop1nlCPABT8cEj1T1gyyUUwzbVUxIIjuHU9R87fXzIFmsaROrlBvt8IXOyLc1PQIu
	 UvaNepKeNfdO4tvGgTduJXqkocpO0X4GWsD+CjmQLZjPOiea78UlZcgmg8CqA8b1fDj7N
	 t5+85Wcb5sFpizqJGsn9yu5iHhWEkXRQ3+zZmrIjG/k0f7CTXO5apx3Pk+pa8f3IlJYMD
	 F5O2K1IuVmvG0NDC/AQXzqhHyI5rOBG/h/mrj1MtB9IdVl70GLh1SbsetZef90GQLe5lx
	 fLDQYezR0Hys63GALrAQ79QNlwNPdEBn79DVz4zPa+4oe1eetIUibeUEDlqXaF+q7Zg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=iscas.ac.cn;
	spf=pass smtp.mailfrom=iscas.ac.cn;
	arc=none smtp.remote-ip=159.226.251.21
Received: from cstnet.cn (smtp21.cstnet.cn [159.226.251.21])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B8E70606A31B
	for <linux-nfs@vger.kernel.org>; Wed,  4 Nov 2026 02:15:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B8E70606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=iscas.ac.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=iscas.ac.cn
Received: from dfae2b116770.home.arpa (unknown [36.110.52.2])
	by APP-01 (Coremail) with SMTP id qwCowADXAPtDlepqHHg+AA--.9511S2;
	Wed, 04 Nov 2026 10:15:31 +0800 (CST)
From: Wentao Liang <vulab@iscas.ac.cn>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] lockd: drop the host reference if the reclaimer cannot be started
Date: Wed,  4 Nov 2026 02:15:40 +0000
Message-Id: <20261104021540.1468799-1-vulab@iscas.ac.cn>
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
X-CM-TRANSID:qwCowADXAPtDlepqHHg+AA--.9511S2
X-Coremail-Antispam: 1UD129KBjvJXoW7ZF43KF1UKw43ArWUuw17Jrb_yoW8Gr13pF
	Z3Xrsak3s5JryavanrJa1UWr4rCws5K398Ca4kGw1Ivws5Xw43Ar9rCF1UZF4UAFyktFZ0
	qF1UKrWrZr1DXaUanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUUvmb7Iv0xC_Kw4lb4IE77IF4wAFc2x0x2IEx4CE42xK8VAvwI8I
	cIk0rVWrJVCq3wAFIxvE14AKwVWUJVWUGwA2ocxC64kIII0Yj41l84x0c7CEw4AK67xGY2
	AK021l84ACjcxK6xIIjxv20xvE14v26F1j6w1UM28EF7xvwVC0I7IYx2IY6xkF7I0E14v2
	6r4UJVWxJr1l84ACjcxK6I8E87Iv67AKxVWxJr0_GcWl84ACjcxK6I8E87Iv6xkF7I0E14
	v26rxl6s0DM2AIxVAIcxkEcVAq07x20xvEncxIr21l5I8CrVACY4xI64kE6c02F40Ex7xf
	McIj6xIIjxv20xvE14v26rWY6Fy7McIj6I8E87Iv67AKxVW8Jr0_Cr1UMcvjeVCFs4IE7x
	kEbVWUJVW8JwACjcxG0xvY0x0EwIxGrwCY1x0262kKe7AKxVWUtVW8ZwCF04k20xvY0x0E
	wIxGrwCF04k20xvE74AGY7Cv6cx26r48ZrWUJr1UMxC20s026xCaFVCjc4AY6r1j6r4UMI
	8I3I0E5I8CrVAFwI0_Jr0_Jr4lx2IqxVCjr7xvwVAFwI0_JrI_JrWlx4CE17CEb7AF67AK
	xVWUtVW8ZwCIc40Y0x0EwIxGrwCI42IY6xIIjxv20xvE14v26F1j6w1UMIIF0xvE2Ix0cI
	8IcVCY1x0267AKxVW8Jr0_Cr1UMIIF0xvE42xK8VAvwI8IcIk0rVWUJVWUCwCI42IY6I8E
	87Iv67AKxVW8JVWxJwCI42IY6I8E87Iv6xkF7I0E14v26r4UJVWxJrUvcSsGvfC2KfnxnU
	UI43ZEXa7IU5ENtDUUUUU==
X-CM-SenderInfo: pyxotu46lvutnvoduhdfq/1tbiBgIBA2rqY4K8dgABss

nlmclnt_recovery() takes a reference to the nlm_host before spawning the
reclaimer thread, and the new thread releases it when it is done.  If
kthread_run() fails there is no thread to do that, so the reference is
leaked and h_reclaiming stays set.

Clear h_reclaiming and release the reference on that path, like the
reclaimer does when it finishes, so that a later recovery attempt for
the host can still be made.

Fixes: df94f000c46c ("lockd: convert reclaimer thread to kthread interface")
Cc: stable@vger.kernel.org
Assisted-by: DeepSeek-V4.1-Flash and OpenAI Codex
Signed-off-by: Wentao Liang <vulab@iscas.ac.cn>
---
 fs/lockd/clntlock.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index f797cc99f94d..78cdf86c4403 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -216,10 +216,13 @@ nlmclnt_recovery(struct nlm_host *host)
 	if (!host->h_reclaiming++) {
 		nlm_get_host(host);
 		task = kthread_run(reclaimer, host, "%s-reclaim", host->h_name);
-		if (IS_ERR(task))
+		if (IS_ERR(task)) {
 			printk(KERN_ERR "lockd: unable to spawn reclaimer "
 				"thread. Locks for %s won't be reclaimed! "
 				"(%ld)\n", host->h_name, PTR_ERR(task));
+			host->h_reclaiming = 0;
+			nlmclnt_release_host(host);
+		}
 	}
 }
 
-- 
2.34.1

