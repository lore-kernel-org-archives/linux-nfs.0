Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792762111;
	b=bfC1jo7voXHTeKJwsVCLbGPwbw206dUgIzoid8QOEfQlx6BGPyYjWoJVgIvBq5PR+uOW
	 7gIBQQSE78xZo4M8pJJEgpcL17/W4LrxiTqvmc+Z2nT1SypDG+8KUnXf/6s4y2dV1YaTz
	 5MtHjt71t0ienhhBbxueIlrp2ygK6TWgE/tc23IecPYrXWb5ecmTuoMFdzquXGgm9hzqy
	 PEi5KRThUwmg0fiEICvCnpOv/fvpYypWYMQL6Obo9M6gYFdCeRBQURLr59A5qeyKJYcF+
	 4eaYdx2YwAz4SErByvwHfs0xDK1N8Oip8cAkQnJ4tKXyGR3+Z+OEh2d0ea7TUKyrCBw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792762111;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:MIME-Version:Content-Transfer-Encoding:X-Scanned-By;
	bh=MfjR5b8wRFYnzIMozzE7fJ4URDBgOy11gpEgGlCUVco=;
	b=sSHEec2bslMRkMezA7dSoXqW4zniTahbN+Rhapsm/v0GRXuxr4Mhnyboiq02SeczFsI4
	 6apBfsDlY7mEyk4OwtPfTD5ROR3YkSOtrGm6v0vhknJIfeGVfgwr3moUg73rIVYrgefZb
	 uO6YeME4crlrfbU/I2oo3YM+sU3cfy+MOtIc0SkQVE34ctau5rth+m9pTshNWuJbhtJVa
	 ZwLwgOl3nQ+yOH7Ms2EBz7RSB+8RUw6jJhSJ6JgRQg8PzZleBe2AXe5Y+uREz5IoohLEU
	 Ce2//APnXq2Gum3hECd+t9qaLsI1Aj62/FQpmCN/5EmxIz911fw228DYjlqtAeuwYQQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=bkCpgze0;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB49860A2602
	for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2026 13:28:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AB49860A2602
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=bkCpgze0
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792762109;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=MfjR5b8wRFYnzIMozzE7fJ4URDBgOy11gpEgGlCUVco=;
	b=bkCpgze0HaB/pntiE8S/kiTQnh3FFEjVzJnOUYJ8y0G747WTFo5gatQorcrwV6CiIJ/e5V
	EGh+/oORJq6/mZCHcVBawz11Yvu4rlOMMEuI24PQjWoQOaFi/vrJoOZiiUdh7YZpk4ZvKt
	8T2uQwFvHmS1xIr7b1L5vpH/sVzELIw=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-588-lqCuB4NgOUmz-3Ho4n4EnA-1; Fri,
 23 Oct 2026 09:28:26 -0400
X-MC-Unique: lqCuB4NgOUmz-3Ho4n4EnA-1
X-Mimecast-MFC-AGG-ID: lqCuB4NgOUmz-3Ho4n4EnA_1792762105
Received: from mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.95])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 0EDBD18052FA;
	Fri, 23 Oct 2026 13:28:25 +0000 (UTC)
Received: from jklus-thinkpadp16vgen1.tpbc.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 251527DE;
	Fri, 23 Oct 2026 13:28:22 +0000 (UTC)
From: Jakub Klus <jklus@redhat.com>
To: cel@kernel.org,
	jlayton@kernel.org
Cc: neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: fix delayed cache cleanup in write_flush
Date: Fri, 23 Oct 2026 15:28:21 +0200
Message-ID: <20261023132821.3273867-1-jklus@redhat.com>
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
X-Scanned-By: MIMEDefang 3.6 on 10.30.177.95

When writing to the cache flush control file, write_flush() advances
cd->flush_time so newly added entries aren't prematurely invalidated.

However, write_flush() was also assigning this future timestamp to
cd->nextcheck. When cache_clean() runs, it sees that cd->nextcheck is
in the future and skips cleaning the cache buckets. Rapid flushes (such
as running `exportfs -ua` followed by `exportfs -r`, which can happen
during systemctl restart nfs-server on RHEL) push cd->nextcheck
further out, leaving old tombstone entries stuck in RAM.

Fix this by anchoring cd->nextcheck to current boot time (`now`),
allowing cache_clean() to sweep deleted entries immediately.

This delay causes a subtle SELinux label loss failure in nfs-utils:
1. `exportfs -ua && exportfs -r` invalidates cache records but leaves the
   '-test-client-' tombstone in RAM due to the nextcheck delay.
2. During mount setup, rpc.mountd calls export_test(), which uses
   auth_domain_find() to verify if path probing succeeds.
3. Because auth_domain_find() does an RCU lookup without checking cache
   entry expiry, it hits the lingering tombstone (whose kref > 0) and
   erroneously returns success instead of -ENOENT.
4. This causes rpc.mountd to assign a physical UUID to a pseudo-root,
   collapsing the fsid boundary and causing the client to drop SELinux
   labels.

Note: The export_test() in rpc.mountd is scheduled to be removed from
nfs-utils.

Tested on RHEL 10.3.

Link: https://lore.kernel.org/linux-nfs/20261019-netlink-noproc-v2-6-7d09a49b574b@kernel.org/
Fixes: 3b68e6ee3cbd ("SUNRPC: cache: ignore timestamp written to 'flush' file.")
Signed-off-by: Jakub Klus <jklus@redhat.com>
---
 net/sunrpc/cache.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 1bc04109d213d..871ba95626849 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1532,9 +1532,9 @@ static ssize_t write_flush(struct file *file, const char __user *buf,
 	 */
 
 	if (cd->flush_time >= now)
-		now = cd->flush_time + 1;
-
-	cd->flush_time = now;
+		cd->flush_time++;
+	else
+		cd->flush_time = now;
 	cd->nextcheck = now;
 	cache_flush();
 
-- 
2.56.0

