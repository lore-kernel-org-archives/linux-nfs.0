Received: from cstnet.cn (smtp25.cstnet.cn [159.226.251.25])
	(using TLSv1.2 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CBD83304BCB;
	Thu, 11 Jun 2026 15:00:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=159.226.251.25
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781190005; cv=none; b=drm3jhfA3gBwoEli9Qyn0UwmrXC1qOwSgC3UPpFZBhjYdXfQjpa3b6mxcUhxyjhz6gnos4fW7wxnkj1ZKJBliQ/7PKyeGxpAyUv98ZkzN8RbqQiwbFTU1wGJa7mUe+ru3R/67f1sWJDXByswI5Pj5yAL2RzDwJlt8jYfwxxjZ3I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781190005; c=relaxed/simple;
	bh=du8BpUZ+F7Kv67ckLTr3vZYuPRS1w5nKj+rf6KIhMQM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=FZlXntVv6muhUfaJLCecqPKrl870pujeoKRAg8Rv2uxMQ0Vi7QUMqjlqS3aijkJfZ0O8tViRZzS0dSXYhS+aSVAFwLyOp4/9xW9wLHFDsea0mH2iW5PL9Rp4hmZfaToMk2l9QXzIEN6EOJYWDzjgZzW37YFOJelcGDtFY/lgiFQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=iscas.ac.cn; spf=pass smtp.mailfrom=iscas.ac.cn; arc=none smtp.client-ip=159.226.251.25
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=iscas.ac.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=iscas.ac.cn
Received: from localhost.localdomain (unknown [117.182.75.76])
	by APP-05 (Coremail) with SMTP id zQCowAD3Z+tuzSpqTQcYEw--.25433S2;
	Thu, 11 Jun 2026 23:00:00 +0800 (CST)
From: WenTao Liang <vulab@iscas.ac.cn>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	WenTao Liang <vulab@iscas.ac.cn>,
	stable@vger.kernel.org
Subject: [PATCH] nfs: fix refcount leak in nfs_direct_read_schedule_iovec()
Date: Thu, 11 Jun 2026 22:59:56 +0800
Message-ID: <20260611145956.90270-1-vulab@iscas.ac.cn>
X-Mailer: git-send-email 2.50.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:zQCowAD3Z+tuzSpqTQcYEw--.25433S2
X-Coremail-Antispam: 1UD129KBjvJXoW7Zr17tr4xGFW5CF47XF4fKrg_yoW8Gr1Upr
	Wrur9xKrn5ArWxtrZruF40vw17ZFZrAFW5Kr18Aw4xCwn5G3W3XFyUKFy5uFnIkr4rCF47
	Zrs0gw13G3Z0vaDanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUUkG14x267AKxVWUJVW8JwAFc2x0x2IEx4CE42xK8VAvwI8IcIk0
	rVWrJVCq3wAFIxvE14AKwVWUJVWUGwA2ocxC64kIII0Yj41l84x0c7CEw4AK67xGY2AK02
	1l84ACjcxK6xIIjxv20xvE14v26r4j6ryUM28EF7xvwVC0I7IYx2IY6xkF7I0E14v26r4j
	6F4UM28EF7xvwVC2z280aVAFwI0_GcCE3s1l84ACjcxK6I8E87Iv6xkF7I0E14v26rxl6s
	0DM2AIxVAIcxkEcVAq07x20xvEncxIr21l5I8CrVACY4xI64kE6c02F40Ex7xfMcIj6xII
	jxv20xvE14v26r1j6r18McIj6I8E87Iv67AKxVW8JVWxJwAm72CE4IkC6x0Yz7v_Jr0_Gr
	1lF7xvr2IYc2Ij64vIr41lF7I21c0EjII2zVCS5cI20VAGYxC7MxkF7I0En4kS14v26r12
	6r1DMxAIw28IcxkI7VAKI48JMxC20s026xCaFVCjc4AY6r1j6r4UMI8I3I0E5I8CrVAFwI
	0_Jr0_Jr4lx2IqxVCjr7xvwVAFwI0_JrI_JrWlx4CE17CEb7AF67AKxVWUAVWUtwCIc40Y
	0x0EwIxGrwCI42IY6xIIjxv20xvE14v26r1j6r1xMIIF0xvE2Ix0cI8IcVCY1x0267AKxV
	WUJVW8JwCI42IY6xAIw20EY4v20xvaj40_Jr0_JF4lIxAIcVC2z280aVAFwI0_Gr0_Cr1l
	IxAIcVC2z280aVCY1x0267AKxVW8Jr0_Cr1UYxBIdaVFxhVjvjDU0xZFpf9x0JUcBMtUUU
	UU=
X-CM-SenderInfo: pyxotu46lvutnvoduhdfq/1tbiDAYPA2oqh3jWrQAAsC

When nfs_direct_read_schedule_iovec() encounters an error after
get_dreq(dreq) increments the io_count but fails to start any I/O
(requested_bytes == 0), it falls through to the error path. That
path calls nfs_direct_req_release() to drop the I/O path’s kref,
but it never calls put_dreq() to balance the io_count. This leaves
the request’s io_count permanently elevated, a reference counting
violation that corrupts the teardown logic once the object is
freed via the remaining kref.

Fix the leak by calling put_dreq(dreq) before
nfs_direct_req_release() in the zero-bytes error path, so the
io_count is properly balanced.

Cc: stable@vger.kernel.org
Fixes: 65caafd0d214 ("SUNRPC reverting d03727b248d0 ("NFSv4 fix CLOSE not waiting for direct IO compeletion")")
Signed-off-by: WenTao Liang <vulab@iscas.ac.cn>
---
 fs/nfs/direct.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 48d89716193a..41a6cabb0592 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -400,6 +400,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	 */
 	if (requested_bytes == 0) {
 		inode_dio_end(inode);
+		put_dreq(dreq);
 		nfs_direct_req_release(dreq);
 		return result < 0 ? result : -EIO;
 	}
-- 
2.50.1 (Apple Git-155)

