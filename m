Received: from m16.mail.163.com (m16.mail.163.com [220.197.31.2])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9EB8A36B07E;
	Wed, 18 Mar 2026 07:56:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=220.197.31.2
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773820618; cv=none; b=AvqRRWZ7hULXQuz1TH2Mrgo+gwTJWcqOIskQyKgUqWMC7kfyzZjpbfos0LNK7g6vsjHkdmU9DnqCm0KUOjgc7w4NmjSo4ANU9N/PBQdIp2mkKLlL0CdLVK33p31yt/RRn2qllHf47JukHOxuFNlnC8pcMH0TL/6OtoljD7ucHho=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773820618; c=relaxed/simple;
	bh=3XTTl3LEOOJSxh3bPyjhegVTZLN5AHADJeciGinB5gM=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=Zp/EggJV1vCs9Onvxjqrarvr8MkW5GjSNoXZIHOEmMNHH2J0Lt7LPCOPAMRSpzm3vIj6YP2eDKytRELGYmElybahxrP0eMGtpkxl2H9NGZ+NCDD6o+NjapA0Txe/BHx3zKFj1suKTLiy/1d6ONF043Da9W0xMQ5xGecSQzl/8OQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=163.com; spf=pass smtp.mailfrom=163.com; dkim=pass (1024-bit key) header.d=163.com header.i=@163.com header.b=UDeGb7mH; arc=none smtp.client-ip=220.197.31.2
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=163.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=163.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=163.com header.i=@163.com header.b="UDeGb7mH"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=163.com;
	s=s110527; h=From:To:Subject:Date:Message-Id:MIME-Version; bh=Tp
	9i1hh0AXWBiYH65D0/JDIPSB18WNuvMfE8rai68LI=; b=UDeGb7mHZTRlvxYZ5e
	Pd5OPC6QmUlhubaXJEuwrfDq0VoFGhOXMADKqsyj96h9jTV6BDPEbDStaCQ5t3sq
	OpctqWBYvN2CSpM3ATM/lf+MIBB413HJ0dwBqyFRjp88NRiurc6wF4QDSX9mGIjo
	XrW0yXnWCQBkWnFFF+9w1byrg=
Received: from pek-lpg-core5.wrs.com (unknown [])
	by gzga-smtp-mtada-g0-2 (Coremail) with SMTP id _____wDnt6yHWrppnayqBg--.44690S2;
	Wed, 18 Mar 2026 15:55:52 +0800 (CST)
From: Robert Garcia <rob_garcia@163.com>
To: stable@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>
Cc: Miri Korenblit <miriam.rachel.korenblit@intel.com>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	Robert Garcia <rob_garcia@163.com>,
	"J . Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	"David S . Miller" <davem@davemloft.net>,
	Jakub Kicinski <kuba@kernel.org>,
	Olga Kornievskaia <kolga@netapp.com>,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 5.15.y] SUNRPC: lock against ->sock changing during sysfs read
Date: Wed, 18 Mar 2026 15:55:51 +0800
Message-Id: <20260318075551.1668418-1-rob_garcia@163.com>
X-Mailer: git-send-email 2.34.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:_____wDnt6yHWrppnayqBg--.44690S2
X-Coremail-Antispam: 1Uf129KBjvJXoW7Kry8tryxKFW5Zr4fZr1fZwb_yoW8uw4kpF
	yak34fG3yDKrZ7urn5Ar4v9rZxu3WfGF4UGr48C3WFyrZrKF15Jryjkay3ur18urZ5uF43
	tF4UWF45JF1DAaUanT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDUYxBIdaVFxhVjvjDU0xZFpf9x0p_ku4UUUUUU=
X-CM-SenderInfo: 5uresw5dufxti6rwjhhfrp/xtbC5QjBLWm6WogINgAA3+

From: NeilBrown <neilb@suse.de>

[ Upstream commit b49ea673e119f59c71645e2f65b3ccad857c90ee ]

->sock can be set to NULL asynchronously unless ->recv_mutex is held.
So it is important to hold that mutex.  Otherwise a sysfs read can
trigger an oops.
Commit 17f09d3f619a ("SUNRPC: Check if the xprt is connected before
handling sysfs reads") appears to attempt to fix this problem, but it
only narrows the race window.

Fixes: 17f09d3f619a ("SUNRPC: Check if the xprt is connected before handling sysfs reads")
Fixes: a8482488a7d6 ("SUNRPC query transport's source port")
Signed-off-by: NeilBrown <neilb@suse.de>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Robert Garcia <rob_garcia@163.com>
---
 net/sunrpc/sysfs.c    | 5 ++++-
 net/sunrpc/xprtsock.c | 7 ++++++-
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/sysfs.c b/net/sunrpc/sysfs.c
index 55da1b627a7d..83ba1f2adf62 100644
--- a/net/sunrpc/sysfs.c
+++ b/net/sunrpc/sysfs.c
@@ -113,11 +113,14 @@ static ssize_t rpc_sysfs_xprt_srcaddr_show(struct kobject *kobj,
 		return 0;
 
 	sock = container_of(xprt, struct sock_xprt, xprt);
-	if (kernel_getsockname(sock->sock, (struct sockaddr *)&saddr) < 0)
+	mutex_lock(&sock->recv_mutex);
+	if (sock->sock == NULL ||
+	    kernel_getsockname(sock->sock, (struct sockaddr *)&saddr) < 0)
 		goto out;
 
 	ret = sprintf(buf, "%pISc\n", &saddr);
 out:
+	mutex_unlock(&sock->recv_mutex);
 	xprt_put(xprt);
 	return ret + 1;
 }
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 9e122c20fcc6..07acc6845ce2 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1680,7 +1680,12 @@ static int xs_get_srcport(struct sock_xprt *transport)
 unsigned short get_srcport(struct rpc_xprt *xprt)
 {
 	struct sock_xprt *sock = container_of(xprt, struct sock_xprt, xprt);
-	return xs_sock_getport(sock->sock);
+	unsigned short ret = 0;
+	mutex_lock(&sock->recv_mutex);
+	if (sock->sock)
+		ret = xs_sock_getport(sock->sock);
+	mutex_unlock(&sock->recv_mutex);
+	return ret;
 }
 EXPORT_SYMBOL(get_srcport);
 
-- 
2.34.1

