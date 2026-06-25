Received: from out-180.mta1.migadu.com (out-180.mta1.migadu.com [95.215.58.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4CD09176238
	for <linux-nfs@vger.kernel.org>; Thu, 25 Jun 2026 03:21:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=95.215.58.180
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782357706; cv=none; b=Kkbr3F3tCJuee+Ox3QWEJu6rPpcSeWVt9Yir9fbNuCCcvLwmabqZCTQwrbRFdJqBql4oZHb59oTKkreZlIew4d8IHfdDXQxc8U3smPOYGhDo20lZ/PJpdWhxtqFUtUe16yQH72xJDYzhKCGQqfYXDkdrtA76SlWFYnKxjjKBmcI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782357706; c=relaxed/simple;
	bh=t+JsEsUGnKbjCQWT9fJq8yDaxdrqg5IKE0VOKaizCYA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=mCEikU32SDgPfIlqO93aSoF3QWQQUG7hzF4uL1XgmHrK3eGCaDlWyxqvQ8UZj2N2eLQycwfwOULspuuWdUfiF0y7OtPyuQLgQN0wZd/Fmkfy+Z9o/NyQ8AMx7F8dgChp2ufGKazrucR6feeuYW0AROxBDN4RVTLIJUKthZTB3wU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev; spf=pass smtp.mailfrom=linux.dev; dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b=SaumYqGm; arc=none smtp.client-ip=95.215.58.180
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.dev
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.dev
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux.dev header.i=@linux.dev header.b="SaumYqGm"
X-Report-Abuse: Please report any abuse attempt to abuse@migadu.com and include these headers.
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=linux.dev; s=key1;
	t=1782357702;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=MgsAtPy6/Lf4+/ZZRQP+VQ73jDWiHvp0GATuDR08K/E=;
	b=SaumYqGm8cCJz7fLZZKvBcxF5TqAniiEK03NosqD2bm2CysSg6VVrizn/O9mSkqcfQCBmL
	a5/oDUgPkn/SFEK6QFS+foOPromjbzKR14CvwBLc9PqtyzZtGNIE69YRMqEsCJLLkkC6/3
	0+ECMiBBuC90pj+LI9M6WCIRQJ281JI=
From: zhang.guodong@linux.dev
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	ZhangGuoDong <zhangguodong@kylinos.cn>
Subject: [PATCH 1/2] NFSv4.1: Fix nfs_client refcount leak in nfs41_free_stateid
Date: Thu, 25 Jun 2026 11:20:37 +0800
Message-ID: <20260625032038.11535-1-zhang.guodong@linux.dev>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Migadu-Flow: FLOW_OUT

From: ZhangGuoDong <zhangguodong@kylinos.cn>

nfs41_free_stateid() takes a reference on the nfs_client before
allocating the FREE_STATEID calldata. If the calldata allocation fails,
the function returns -ENOMEM without dropping that reference.

The normal async RPC release path drops the reference from
nfs41_free_stateid_release(), but that path is not reached when calldata
allocation fails. Drop the nfs_client reference before returning the
allocation error.

Signed-off-by: ZhangGuoDong <zhangguodong@kylinos.cn>
---
 fs/nfs/nfs4proc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c48281db3..b86818607 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -10380,8 +10380,10 @@ static int nfs41_free_stateid(struct nfs_server *server,
 
 	dprintk("NFS call  free_stateid %p\n", stateid);
 	data = kmalloc_obj(*data);
-	if (!data)
+	if (!data) {
+		nfs_put_client(clp);
 		return -ENOMEM;
+	}
 	data->server = server;
 	nfs4_stateid_copy(&data->args.stateid, stateid);
 
-- 
2.43.0

