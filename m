Received: from cstnet.cn (smtp25.cstnet.cn [159.226.251.25])
	(using TLSv1.2 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 51AA74F4CFF;
	Thu, 17 Sep 2026 16:32:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=159.226.251.25
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789662728; cv=none; b=r9cL/k3Drm50eu5uKWDJ9RGvvdktzaEfv4OPExJIJdkh3/eyuxUf9BW2yOgEW7WyLob2mpoA6cha6+eF7nXrCarwCd1dQv3HJ7zcodqA1mlYQSSnrYmwNeKGKS6NL04GVuUMQm1a/U9manARrr7CrApGNUwx9m4rNZ2LMBQfs1c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789662728; c=relaxed/simple;
	bh=7Ibz1xz5DfhjrbbCPfxSiz/JHlKh+7wI06ETEzN1qfo=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=HOAZfvqPUJm2F2SXTF6mKhKLaXugVoSk8NSanZY1Z1l/iPFQSNjVCEaJbGqfFnm9Ewwj3MyHnYXk5R3AWEL38vaTxRJv8q5MZZVErpBJp8wN3dgNCayFGai3YBvCcldil2PClqDwubA5yjSF+nZHqymy/NcmiMbnrGbcvXtgavI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=iscas.ac.cn; spf=pass smtp.mailfrom=iscas.ac.cn; arc=none smtp.client-ip=159.226.251.25
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=iscas.ac.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=iscas.ac.cn
Received: from dfae2b116770.home.arpa (unknown [36.110.52.2])
	by APP-05 (Coremail) with SMTP id zQCowAC36EL6FaxqnIaECA--.6863S2;
	Fri, 18 Sep 2026 00:31:54 +0800 (CST)
From: Wentao Liang <vulab@iscas.ac.cn>
To: Dai.Ngo@oracle.com
Cc: akpm@osdl.org,
	chuck.lever@oracle.com,
	jlayton@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	tom@talpey.com,
	Wentao Liang <vulab@iscas.ac.cn>,
	stable@vger.kernel.org
Subject: [PATCH] nfsd: Fix id-to-name cache entry leak in idtoname_parse()
Date: Thu, 17 Sep 2026 16:31:54 +0000
Message-Id: <20260917163154.2162438-1-vulab@iscas.ac.cn>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:zQCowAC36EL6FaxqnIaECA--.6863S2
X-Coremail-Antispam: 1UD129KBjvdXoWruFykKF4DAw1kWF4rArWrZrb_yoWktrg_ua
	9ayFWku398JFs3KrWfX3W7CrsIqF4DCry8GayIqF9xGFZ5tr4Fvr4xXrs5Jr97W3y5Xr1r
	Cr1Dt34Y9w1a9jkaLaAFLSUrUUUUjb8apTn2vfkv8UJUUUU8Yxn0WfASr-VFAUDa7-sFnT
	9fnUUIcSsGvfJTRUUUbTkFc2x0x2IEx4CE42xK8VAvwI8IcIk0rVWrJVCq3wAFIxvE14AK
	wVWUJVWUGwA2ocxC64kIII0Yj41l84x0c7CEw4AK67xGY2AK021l84ACjcxK6xIIjxv20x
	vE14v26r4j6ryUM28EF7xvwVC0I7IYx2IY6xkF7I0E14v26r4j6F4UM28EF7xvwVC2z280
	aVAFwI0_Gr0_Cr1l84ACjcxK6I8E87Iv6xkF7I0E14v26r4UJVWxJr1le2I262IYc4CY6c
	8Ij28IcVAaY2xG8wAqx4xG64xvF2IEw4CE5I8CrVC2j2WlYx0E2Ix0cI8IcVAFwI0_JF0_
	Jw1lYx0Ex4A2jsIE14v26r4j6F4UMcvjeVCFs4IE7xkEbVWUJVW8JwACjcxG0xvY0x0EwI
	xGrwACjI8F5VA0II8E6IAqYI8I648v4I1lFIxGxcIEc7CjxVA2Y2ka0xkIwI1lc7CjxVAa
	w2AFwI0_Jw0_GFyl42xK82IYc2Ij64vIr41l42xK82IY6x8ErcxFaVAv8VW8GFyrJr1UJw
	CFx2IqxVCFs4IE7xkEbVWUJVW8JwC20s026c02F40E14v26r1j6r18MI8I3I0E7480Y4vE
	14v26r106r1rMI8E67AF67kF1VAFwI0_Jw0_GFylIxkGc2Ij64vIr41lIxAIcVC0I7IYx2
	IY67AKxVWUJVWUCwCI42IY6xIIjxv20xvEc7CjxVAFwI0_Gr0_Cr1lIxAIcVCF04k26cxK
	x2IYs7xG6r1j6r1xMIIF0xvEx4A2jsIE14v26r4j6F4UMIIF0xvEx4A2jsIEc7CjxVAFwI
	0_Gr0_Gr1UYxBIdaVFxhVjvjDU0xZFpf9x0JUgXocUUUUU=
X-CM-SenderInfo: pyxotu46lvutnvoduhdfq/1tbiDAANA2qr9nBL5gAAso

idtoname_lookup() returns the id-to-name cache entry with a new
reference. The name is parsed between the lookup and the update call,
and when the parsed name is malformed (negative length or longer than
IDMAP_NAMESZ), idtoname_parse() jumps to the error label without
dropping the reference returned by idtoname_lookup(), leaking the cache
entry.

Release the reference with cache_put() before taking the error exit.

Fixes: f9ecc921b5b5 ("[PATCH] knfsd: Use new cache code for name/id lookup caches")
Cc: stable@vger.kernel.org
Signed-off-by: Wentao Liang <vulab@iscas.ac.cn>
---
 fs/nfsd/nfs4idmap.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index ba06d3d3e6dd..e0f1bebdf660 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -252,8 +252,10 @@ idtoname_parse(struct cache_detail *cd, char *buf, int buflen)
 	/* Name */
 	error = -EINVAL;
 	len = qword_get(&buf, buf1, PAGE_SIZE);
-	if (len < 0 || len >= IDMAP_NAMESZ)
+	if (len < 0 || len >= IDMAP_NAMESZ) {
+		cache_put(&res->h, cd);
 		goto out;
+	}
 	if (len == 0)
 		set_bit(CACHE_NEGATIVE, &ent.h.flags);
 	else
-- 
2.34.1

