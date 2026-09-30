Received: from mail-wm2-f13.google.com (mail-wm2-f13.google.com [74.125.225.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 03EA84F96C5
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 20:22:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.225.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790799748; cv=none; b=ize8tpDJGyZLbuqyRlaLrGhVwf9mhlttJ/qIOWJgzP17yem+lqTW/JNTN8MC9V32zpdL6e3r63ac4IRwEb8CjOll01p9iBuJ8QYMc4/CJGKWR8WG2IvF6BuuAJwCFtbbu2eMNar5ovLuoIYxGeNZDqizPGIHOxM6GxLlrGs19tI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790799748; c=relaxed/simple;
	bh=pN/G0+fViAWcFotxNNYaHvIrBf4dqFEFrepGUufaYk0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=N57MsT2axXk4c4Vmt29a5XAHhjEdzJY77O04QrzwA8raxqAOgUPqATQ0V1bkQYxZKA88vUX82VHPObyCBTp3ZPTF1estlxWamF1Re5ReuNc6itxk+UiXnAGY3QwfKOJEeAiantpw+2eJ61xsNcXH+th4kuGPUC2g8Ya725kJuQ0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=imNWqkwH; arc=none smtp.client-ip=74.125.225.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="imNWqkwH"
Received: by mail-wm2-f13.google.com with SMTP id 5b1f17b1804b1-49e69b9e16aso59778965e9.1
        for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 13:22:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790799744; x=1791404544; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=QsbcUIyvcZ+zskSrFDYxowHlHtYifbo/michUtyrAnY=;
        b=imNWqkwHvnjmoe4H8U8qhTs76+3le0J4bGoYKZAqS+xBMIc2VehVdeDHZ4JeYTyIUJ
         GGZLhYh2mUQ8dRO/ZUjHxwt3XwTcZ5tZqadqJEesaxjbuOErUAAqkCU7Dmn1nbLbMiTV
         Sr+hvZ65Y81w6Km4o15/GLe0+Qtkt9PHVUxu3TvrZAJUTK4UwjSa994lP/NYQoweGIdi
         u5BVcufZYnZV7yKFdcSKUTbumgRdzapzukS6pZp3hQV2Lr77ja5iTiuHwCXkOjyr5VW7
         1GBQ1I8u5M8YO5ORRVi8fFDaQpNpJsBleqwy8mkZ4IRmno/GrBoltVQWpLZQ0yv3GrHb
         ihnQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790799744; x=1791404544;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=QsbcUIyvcZ+zskSrFDYxowHlHtYifbo/michUtyrAnY=;
        b=sIllWfzqhFMVNxWkF6Y+J+kUSpjgARzx0Ac458h5GQuaIPhiQdmrRh0R15UmKwmePF
         Es3F6e9dCFnEy51MhBuHuQmLAwuInfjet7B+CUi96GNgQc+6w0mtA0QyPtQt+ucK7d01
         Nejhx1E/5zVBrwZZzL4KDT5fUcmX24hXGY4VQy8fwShugQEBC6QrSRQVX1NXKw7UL87n
         /9QeLV52UWjSpolxAjUhUuas1zhLrx2IBxtV2wYcITTmnMnEe+zZk1cAfmSItsm3V42D
         Mrv6w/mKaUmm+NC0xsGcD32/LtxWXTRlxJD0eVZWIcWBerhCNWyGljMlL4n5RPECztNg
         u/2w==
X-Gm-Message-State: AFq9FYLKbBn/ouqXqZLK0c+9u7E+4B+ZvHNJPM4T6L282Y7KcCVYgOJJ
	ndFy7/kuGhCEx5ecb0jZcxCggF4eqniRo6LCbCG3GZ3wSlCoGmd5ACseiQLnvQ==
X-Gm-Gg: AYBFou22aX3EZfDskCnuqAhNOJMgiLShhxGZwW54zeJ1y6nxkeAPQcSm3up5/sYBGkg
	w1G+Wq7nBbqWchpLqXfQUVniwamGg6IbgSwv1ZHIBRos1tNiekckz439a+0emeHEq/X8p+/qX5G
	KNs5XpUaDPAt7d/jcnIqkSnLGyxrH8AFGXSv9luLuYbtoFbSaD20rJSy+TT4PjP9So8u1aHdBUG
	TgzgD0nTrJRzhjzvb2a9QjTjy2Rpq/fFMq5sYQaWXvNSocXjh0vPmAAWytldb9aXefO82GY+lX4
	8eGEv6A1OXFmoggQdNjJQ9JpwHOzlel5vm8nFZW5iVz0q1iSdFAfEbfndRI2Vqlaj+Yp0ds78f+
	V2nVHm/hlmxmmkdCe+NuZpax2LDjvj7KClXP4Ofyj8RTguzHNiY2YcM5cHonk8WDoW1udMby16d
	z3ATkrp7+wtIUTacVKK0M0znvPxLU0R/hHNCHPrZqT0KHUiL+HOIAlmwY05k2khk0WwHj+DOM/B
	ne+ZYWiLXXhO++3
X-Received: by 2002:a05:6000:4904:b0:488:6072:c0bc with SMTP id ffacd0b85a97d-48b02430da7mr4724064f8f.4.1790799743668;
        Wed, 30 Sep 2026 13:22:23 -0700 (PDT)
Received: from SurHub.localdomain ([102.213.68.159])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48b068ff6eesm1457831f8f.11.2026.09.30.13.22.20
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 30 Sep 2026 13:22:23 -0700 (PDT)
From: Abdifatah Suruur <suruurism@gmail.com>
To: cel@kernel.org,
	jlayton@kernel.org
Cc: linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	Abdifatah Suruur <suruurism@gmail.com>
Subject: [PATCH] lockd: fix use-after-free in nlmsvc_retry_blocked()
Date: Wed, 30 Sep 2026 23:22:12 +0300
Message-ID: <20260930202212.1482-1-suruurism@gmail.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A block queued on the nlm_blocked list holds exactly one kref, the
list's: nlmsvc_create_block() hands out an initial reference,
nlmsvc_insert_block_locked() takes the list reference, and
nlmsvc_lock() releases the initial one at out:.

nlmsvc_retry_blocked() then drops nlm_blocked_lock and dereferences
`block` (b_when, b_flags, b_deferred_req) and passes it to
retry_deferred_block() or nlmsvc_grant_blocked() without holding any
reference of its own.  Concurrently, an svc thread processing the
client's GRANT_RES (nlmsvc_grant_reply()), a CANCEL or UNLOCK
(nlmsvc_cancel_blocked()), or a host failover sweep
(nlmsvc_traverse_blocks()) can find the same block, unlink it and drop
the last kref, freeing it while the lockd kthread is still using the
pointer.  The freed slab is then written through: kref_get() on the
freed block, the B_TIMED_OUT flag, the list operations in
nlmsvc_insert_block(), and the b_deferred_req revisit - a
use-after-free on a remotely reachable path.

nlmsvc_notify_blocked() has the same problem: it moves the block to
the head of the list and then calls svc_wake_up(block->b_daemon)
after dropping nlm_blocked_lock.  Keep that wake-up under the
spinlock, as nlmsvc_grant_deferred() already does.

Pin the block before dropping the spinlock in nlmsvc_retry_blocked()
and release the pin after processing, so the block cannot be freed
while it is in use.

Cc: stable@vger.kernel.org
Signed-off-by: Abdifatah Suruur <suruurism@gmail.com>
---
 fs/lockd/svclock.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index e628b5d355071..38d02b10591ae 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -775,8 +775,8 @@ nlmsvc_notify_blocked(struct file_lock *fl)
 	list_for_each_entry(block, &nlm_blocked, b_list) {
 		if (nlm_compare_locks(&block->b_call->a_args.lock.fl, fl)) {
 			nlmsvc_insert_block_locked(block, 0);
-			spin_unlock(&nlm_blocked_lock);
 			svc_wake_up(block->b_daemon);
+			spin_unlock(&nlm_blocked_lock);
 			return;
 		}
 	}
@@ -1023,6 +1023,13 @@ nlmsvc_retry_blocked(struct svc_rqst *rqstp)
 			timeout = block->b_when - jiffies;
 			break;
 		}
+		/*
+		 * Pin the block before dropping nlm_blocked_lock: a
+		 * concurrent GRANT_RES, CANCEL or UNLOCK can unlink the
+		 * block and drop the last kref, freeing it while we are
+		 * still using it.
+		 */
+		kref_get(&block->b_count);
 		spin_unlock(&nlm_blocked_lock);
 
 		dprintk("nlmsvc_retry_blocked(%p, when=%ld)\n",
@@ -1033,6 +1040,7 @@ nlmsvc_retry_blocked(struct svc_rqst *rqstp)
 			retry_deferred_block(block);
 		} else
 			nlmsvc_grant_blocked(block);
+		nlmsvc_release_block(block);
 		spin_lock(&nlm_blocked_lock);
 	}
 	spin_unlock(&nlm_blocked_lock);
-- 
2.53.0

