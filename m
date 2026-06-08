Received: from mailtransmit04.runbox.com (mailtransmit04.runbox.com [185.226.149.37])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 81ABA3BB101;
	Mon,  8 Jun 2026 09:55:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.226.149.37
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780912553; cv=none; b=u/VHmyVg4RD6+sN3GnmdYexxHJfZL9kxaKgsWxSGLTVyZXoplpdNxTlFcZknexckCr4uT6jmKKaB1PgHz0PusNlqbqU9XLZo+2i7gL7jAbqpfNKOg74yP822w2ZKxl9HdaTOy6DxS6vi0m+eByYVw10ltI01RfL6j4932uzz1AM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780912553; c=relaxed/simple;
	bh=+F41YjfVMXGTwqZ/2mL2Yt5rfLcKeD+08oAWPpiLw7Q=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=JxpcdlPdJR7rDJiZDMIkXvzrVNZLEar8fYvWR3/QKaM1F6mBzs2FR2uxWRm7dom5z02McnULEy34Lkl7m/WIN2R7IULiPwRXguPWIepNIx8EYiso3CR6QBh2Lv2YByqXHn7kDZ8q2zbVislHFfz9RyO7T4UOt4J9ibWzYdRCVy4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=runbox.com; dkim=pass (2048-bit key) header.d=runbox.com header.i=@runbox.com header.b=kysfFZiR; arc=none smtp.client-ip=185.226.149.37
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=runbox.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=runbox.com header.i=@runbox.com header.b="kysfFZiR"
Received: from mailtransmit02.runbox ([10.9.9.162] helo=aibo.runbox.com)
	by mailtransmit04.runbox.com with esmtps  (TLS1.2) tls TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
	(Exim 4.93)
	(envelope-from <david.laight.linux_spam@runbox.com>)
	id 1wWWhs-00BS2A-SU; Mon, 08 Jun 2026 11:55:44 +0200
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=runbox.com;
	 s=selector1; h=Content-Transfer-Encoding:MIME-Version:Message-Id:Date:
	Subject:Cc:To:From; bh=5FlDnBocISId6m5hu7/zPIiEP0EAR8el1j+PrS9Ng7c=; b=kysfFZ
	iRS1hD2DDoIO+FZHxjIcBaKNZs8XDi1wQo2DaPfS3xjdZxDDNBYCMkUK5YV8C3wEa0Iw7D3Ax2+Oc
	5rlT+4ukZ1DXdYWO7nWz0ts+RhVxA4IWvz8CB6xB0QNe6khfQDh0IMZCIe7UnqIiEsm3UGaDEjs3y
	Cq00cGBxYocxR4R+MnLuz16rXBFP0YZt0UG2bRZhlQHYnDxJPZbcVxSjAS5J3m82tqL6qXtd31uw0
	YSKlBP1kqVvz6FNhvK3zCGtrOlSTkpWPsEAP1wf6J1T53Sg4CWPU1dH31KlPziZ78Q9BFYv5itTdI
	OQ1dGkyT3Oc7+ZumJN3LVgpFXjhQ==;
Received: from [10.9.9.73] (helo=submission02.runbox)
	by mailtransmit02.runbox with esmtp (Exim 4.86_2)
	(envelope-from <david.laight.linux_spam@runbox.com>)
	id 1wWWhs-0000Il-6r; Mon, 08 Jun 2026 11:55:44 +0200
Received: by submission02.runbox with esmtpsa  [Authenticated ID (1493616)]  (TLS1.2:ECDHE_SECP256R1__RSA_PSS_RSAE_SHA256__AES_256_GCM:256)
	(Exim 4.95)
	id 1wWWhg-00Ag6G-4D;
	Mon, 08 Jun 2026 11:55:32 +0200
From: david.laight.linux@gmail.com
To: Kees Cook <kees@kernel.org>,
	linux-hardening@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
Cc: Arnd Bergmann <arnd@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Trond Myklebust <trondmy@kernel.org>,
	David Laight <david.laight.linux@gmail.com>
Subject: [PATCH net-next] net/sunrpc/svcauth_unix: Use strscpy() to copy strings into arrays
Date: Mon,  8 Jun 2026 10:55:00 +0100
Message-Id: <20260608095523.2606-16-david.laight.linux@gmail.com>
X-Mailer: git-send-email 2.39.5
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: David Laight <david.laight.linux@gmail.com>

Replacing strcpy() with strscpy() ensures that overflow of the target
buffer cannot happen.

Signed-off-by: David Laight <david.laight.linux@gmail.com>
---
This is one of a group of patches that remove potentially unbounded
strcpy() calls.

They are mostly replaced by strscpy() or, when strlen() has just been
called, with memcpy() (usually including the '\0').

Calls with copy string literals into arrays are left unchanged.
They are safe and easily detected as such.

The changes were made by getting the compiler to detect the calls and
then fixing the code by hand.

Note that all the changes are only compile tested.

Some Makefiles were changed to allow files to contain strcpy().
As well as 'difficult to fix' files, this included 'show' functions
as they really need to use sysfs_emit() or seq_printf().

All the patches are being sent individually to avoid very long cc lists.
Apologies for the terse commit messages and likely unexpected tags.
(There are about 100 patches in total.)

 net/sunrpc/svcauth_unix.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 3be69c145d2a..71efec9618f5 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -130,7 +130,7 @@ static void ip_map_init(struct cache_head *cnew, struct cache_head *citem)
 	struct ip_map *new = container_of(cnew, struct ip_map, h);
 	struct ip_map *item = container_of(citem, struct ip_map, h);
 
-	strcpy(new->m_class, item->m_class);
+	strscpy(new->m_class, item->m_class);
 	new->m_addr = item->m_addr;
 }
 static void update(struct cache_head *cnew, struct cache_head *citem)
@@ -293,7 +293,7 @@ static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class,
 	struct ip_map ip;
 	struct cache_head *ch;
 
-	strcpy(ip.m_class, class);
+	strscpy(ip.m_class, class);
 	ip.m_addr = *addr;
 	ch = sunrpc_cache_lookup_rcu(cd, &ip.h,
 				     hash_str(class, IP_HASHBITS) ^
-- 
2.39.5

