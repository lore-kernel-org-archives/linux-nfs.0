Received: from cstnet.cn (smtp81.cstnet.cn [159.226.251.81])
	(using TLSv1.2 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6222D463B73;
	Wed, 16 Sep 2026 07:41:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=159.226.251.81
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789544492; cv=none; b=d6oOMtgO29ENQQrI2eUgAqOpMKNvnUgQBYjExFzvW9xB2z2fQ9dbRJeZaxeqD59t9P0JFZgL5HiwUdhGpf2SLQ9lZt5hWUIxSIfahbj42XyEcwf4oufB7xhHLHyX9hQFGMOgQTbYEk2JmahXfcrRqZ2JTwtTt8VdGlQNUIw8bdo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789544492; c=relaxed/simple;
	bh=rgTTy4XlZHUTrAmKsM9993K+HnUGwqPcN3m/v80Vk3c=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=IlZk9K8oQQwR/V4FxS5Lbd3PNIhzG4vHClcbNQ1GPxuhFwSHMxh8UBgsVZJIInKUZPIaAoQTRT0tPyEBcRZ8NdsOlo0XQLc9OmtBO7MiSdl039HBwPPvSybY9Hl+bzTTKvT7Jih9SxbVDBLrJFXzzuS1+kAjHQ5ve9iMNwzl0Ks=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=iscas.ac.cn; spf=pass smtp.mailfrom=iscas.ac.cn; arc=none smtp.client-ip=159.226.251.81
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=iscas.ac.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=iscas.ac.cn
Received: from dfae2b116770.home.arpa (unknown [36.110.52.2])
	by APP-03 (Coremail) with SMTP id rQCowAAnKjgOSKpq4D7fBw--.40107S2;
	Wed, 16 Sep 2026 15:41:02 +0800 (CST)
From: Wentao Liang <vulab@iscas.ac.cn>
To: Dai.Ngo@oracle.com
Cc: anna@kernel.org,
	chuck.lever@oracle.com,
	jlayton@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	tom@talpey.com,
	trondmy@kernel.org,
	Wentao Liang <vulab@iscas.ac.cn>,
	stable@vger.kernel.org
Subject: [PATCH] lockd: Fix host reference leak in nlmclnt_recovery()
Date: Wed, 16 Sep 2026 07:40:34 +0000
Message-Id: <20260916074034.1972173-1-vulab@iscas.ac.cn>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:rQCowAAnKjgOSKpq4D7fBw--.40107S2
X-Coremail-Antispam: 1UD129KBjvJXoW7KF43JF17tF1fAw1xtrW8Zwb_yoW8Jw18pF
	Z3twsFkr95t34avanrJa1DWr4rCrZYg398Ca4kGw12ywnxXw4Yy39ruF1jvF48ArWvyrZ0
	gF17Kr4rZr1DJaDanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUU9a14x267AKxVW8JVW5JwAFc2x0x2IEx4CE42xK8VAvwI8IcIk0
	rVWrJVCq3wAFIxvE14AKwVWUJVWUGwA2ocxC64kIII0Yj41l84x0c7CEw4AK67xGY2AK02
	1l84ACjcxK6xIIjxv20xvE14v26ryj6F1UM28EF7xvwVC0I7IYx2IY6xkF7I0E14v26r4U
	JVWxJr1l84ACjcxK6I8E87Iv67AKxVW0oVCq3wA2z4x0Y4vEx4A2jsIEc7CjxVAFwI0_Gc
	CE3s1le2I262IYc4CY6c8Ij28IcVAaY2xG8wAqx4xG64xvF2IEw4CE5I8CrVC2j2WlYx0E
	2Ix0cI8IcVAFwI0_Jw0_WrylYx0Ex4A2jsIE14v26r4UJVWxJr1lOx8S6xCaFVCjc4AY6r
	1j6r4UM4x0Y48IcxkI7VAKI48JM4x0x7Aq67IIx4CEVc8vx2IErcIFxwACI402YVCY1x02
	628vn2kIc2xKxwCY1x0262kKe7AKxVWUtVW8ZwCF04k20xvY0x0EwIxGrwCFx2IqxVCFs4
	IE7xkEbVWUJVW8JwC20s026c02F40E14v26r1j6r18MI8I3I0E7480Y4vE14v26r106r1r
	MI8E67AF67kF1VAFwI0_Jw0_GFylIxkGc2Ij64vIr41lIxAIcVC0I7IYx2IY67AKxVWUCV
	W8JwCI42IY6xIIjxv20xvEc7CjxVAFwI0_Cr0_Gr1UMIIF0xvE42xK8VAvwI8IcIk0rVWU
	JVWUCwCI42IY6I8E87Iv67AKxVW8JVWxJwCI42IY6I8E87Iv6xkF7I0E14v26r4UJVWxJr
	UvcSsGvfC2KfnxnUUI43ZEXa7VUbtl1PUUUUU==
X-CM-SenderInfo: pyxotu46lvutnvoduhdfq/1tbiBgQMA2qqPpQsJAAAsv

In nlmclnt_recovery(), nlm_get_host(host) is called to take a reference
on the host before spawning the reclaimer thread via kthread_run(). If
kthread_run() fails, the reference is never released, and
host->h_reclaiming remains incremented, preventing subsequent reclaim
attempts.

Fix this by releasing the host reference with nlmclnt_release_host(host)
and resetting host->h_reclaiming to 0 on kthread_run() error.

Fixes: df94f000c46c ("lockd: convert reclaimer thread to kthread interface")
Cc: stable@vger.kernel.org
Signed-off-by: Wentao Liang <vulab@iscas.ac.cn>
---
 fs/lockd/clntlock.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 8fa30c42c92a..aba37847356c 100644
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

