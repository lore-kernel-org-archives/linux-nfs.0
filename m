Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.44
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795630075;
	b=R/GNZAleAgdo6KZlADM1dF7cHqZocKLOUPonIvaLnnvrmkXcQCq8t56DuQr/oJiuXomR
	 i/oUc8U/58JLPpaD42Qj5wiPPX0soNeojrcJz3edyiFcpMZNQx0hpiQH/sFcTbkSzjIhI
	 SbSqoZ6YM6bRPX/xa3NR2MGIyLp2zA6z/PnYfNMa/hI+eA+d6R3Smmy+aASEdSHq3Cw/y
	 h8JdqadXkW0aiiDBruOU1CyKiqF1Au4XjJF50HDdYsykglXKfbDRPd+yM0/iKBZovN03Z
	 lMULhTFuqdVTIsPmEt+qlQKg6zAev2Dyj9e4dAYOGn0kEfwkI7sHA0uOEdzc6BTVl1A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795630075;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=OU50d1CaSKoDme25yexW26cDM9SaQpzkcmRtWd+JBsw=;
	b=mGcdW0RtiQeMKmpn7XqeoEvmd8orgaAjy9XbJ8yS6uVLi9YKpq1yO1uPSzD91KFMOEYz
	 cHAhlUVgmUFsWTChNvg0AIIhrRQXR/QYThEUjcqqUjH/qnveCk8Ht27eeV2fVOsjRVBUY
	 80NgyUi1Dyl0xBscvoUHgWCVKEDowqF0Rc6xH7TKg+ahitGgKipG9kBwKIHuXOTXp2Epc
	 L8nmEqMpx2HUQCWSHGENfgVpHGEybziKp/eGXsBIUe1FgVGn5bkfXq6dDVAxi18G112PF
	 mA/7oll1iUwdJMKMWCIVNyOLf8k2GfA9dBj4w9gTBjGKv64CXBpTbrdgWZsrnIxmctQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=vastdata.com;
	spf=pass smtp.mailfrom=vastdata.com;
	dkim=pass header.d=vastdata.com header.i=@vastdata.com header.a=rsa-sha256 header.s=google header.b=Ti7fN7p0;
	arc=none smtp.remote-ip=209.85.221.44
Received: from mail-wr1-f44.google.com (mail-wr1-f44.google.com [209.85.221.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5DDDC606A323
	for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 18:07:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5DDDC606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=vastdata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=vastdata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=vastdata.com header.i=@vastdata.com header.a=rsa-sha256 header.s=google header.b=Ti7fN7p0
Received: by mail-wr1-f44.google.com with SMTP id ffacd0b85a97d-4a7b8abe209so4726773f8f.0
        for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 10:07:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=vastdata.com; s=google; t=1795630074; x=1796234874; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=OU50d1CaSKoDme25yexW26cDM9SaQpzkcmRtWd+JBsw=;
        b=Ti7fN7p0M1tf31Cul41VYyFuL5tUg3yNutCxnFyNtsXPCy7LK+KjHjsnq1L6OVtLzX
         M15V+Dwa9jD3R+/fewwf3sZoXw5oGNciWzvkenl74gfORP0v98IrlGWhqdcS3LdjNo5e
         kstCihBIRiIKVnN1EOLnqFmM12kHDy9pV5b3qcuYqXYtZ5CUb6Jk5sJVuTXbxv5ueq9W
         y9A8ZUYYULIZgTPemVKzl4ITAb4W9TYYlqFr/CsJOcPXsgqh0ziRReCa8H30WReY2KHx
         fv1qAH+2ScmEuJb/wbS41B89exUfwmybCsQ779Nxw4E+G5z3J0TlpnlU0DLnx2z8H1hy
         v4jQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795630074; x=1796234874;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=OU50d1CaSKoDme25yexW26cDM9SaQpzkcmRtWd+JBsw=;
        b=EAVT1FSrFBLj8ml3MYtC/Rd/XhHOtHSlKPTMkO7yG+6evDSZdnUv04+D5vstI7smIj
         QtltqYf8SvB4oKhizqrwuVRYOr626GSFEF+SJ7pEd7vzogJ5U1Ibp2vmCCRvGIzeIUtE
         //gIYr6caNf0fImQOSGFnW2m26GCzfbvbh/jagf9m/gC7y16ZtvHoqG+MggAqBLchl+7
         KUu6wBcH0u5+qx7eX1vp0kecBqxd+V6U47pNKKYibg4ZZ24iJbCwKsccx5n8S6YlXdoR
         eNeKRaTeF9KK80/xsyolrMLpQNW+PskgdMI/K9wgPOti1bddhUgAPfbIYGxZMpHH151l
         Fj0Q==
X-Gm-Message-State: APuU4Z/7FEZ52mPVW7TzjQoAa5/XlGC0VSWfuRsuTLdPBJ5A08W4GjF7
	XSuLpV4Z+tduzSzGz9Jd/Oeg5YpCJxkcK6Kgx5HhE0DZ2RZy77KyJ47AB0yDt2kfqQ7t2JhZVzn
	DZwzhVE8=
X-Gm-Gg: AZFdTZfGogkQgX6WpjX82FbT+Bcp0IYekjN+M22A0CXTmUWB9zire9eMQEWBMQOMKcz
	188SSOjaUi3BMoyE7kbDXD2kELIETx3DttU1WzaalvS9InM+S0Q4PCiyx4UOahry3+VMNsJ4WKS
	aCbjVFM+phgQLZmIpyPFLZAjvv4xQExqYZ8dqC9+lZNY7Wo/VBz9oRqbzkw67dtJvTg8zlBYwgJ
	UrzHJKcgbi41qjhtQunu2654b2Dq00mJwfKUQTHX4yLa+19Zr6wIasEu60Vmh9xKpMrXxDK4gkM
	2C5gVM/FwWxDaAsyLlg12jvYUtktiFcd7aPyvzy3sF0oeuWPO/GyQKw9ynxH9/CFTRRfLdpO2tH
	tbbH+cRx2IXwC3e46aKYy8C8msLtuSfHYkWoC0TfoW1aKGHhV/gqdwK1mn1y650XZ6EvSAvLeod
	fdRfeECv/OEND13clFzV6ggCYbGxe8xqSUcaeMH61sQANPgy6hzsOFOwXXldDniuDEtDQG5I7Hr
	JYpndoFSRMVlXgE0Fj8C+dEmniezB8cWtcJ56/pQAHuKHQ7/Fb/Ln+4WNXT+sigNE5AbLO3j09F
	aFIlVI6bUUxqnCXD27w8ftCK00z20TyAdjQUwSlvGX8DZRYB4v9eZ0mXZIi7HjfvAMnozA==
X-Received: by 2002:a05:600d:82d0:b0:4bb:818d:8d8f with SMTP id 5b1f17b1804b1-4bb88818955mr456291405e9.23.1795630073774;
        Wed, 25 Nov 2026 10:07:53 -0800 (PST)
Received: from jupiter.vstd.int ([192.116.95.190])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4ab658e2d1bsm37267090f8f.8.2026.11.25.10.07.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 25 Nov 2026 10:07:53 -0800 (PST)
From: Dan Aloni <dan.aloni@vastdata.com>
To: trond.myklebust@hammerspace.com,
	anna.schumaker@hammerspace.com
Cc: linux-nfs@vger.kernel.org,
	Hubert Dziedziczak <hubert.dziedziczak@nmc2.ai>
Subject: [PATCH] sunrpc: don't dereference a destroyed credcache from the cred shrinker
Date: Wed, 25 Nov 2026 20:07:51 +0200
Message-ID: <20261125180751.3804694-1-dan.aloni@vastdata.com>
X-Mailer: git-send-email 2.52.0
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

rpcauth_destroy_credcache() clears auth->au_credcache before
rpcauth_clear_credcache() takes rpc_credcache_lock to unhash the auth's
credentials:

	auth->au_credcache = NULL;		/* no lock held */
	rpcauth_clear_credcache(cache);		/* takes rpc_credcache_lock */

It is relatively easier to reproduce this by doing two things:

1) lowering module paramater auth_max_cred_cachesize to a small number
   (it now has ULONG_MAX which is by practical means no bound).
2) adding msleep(200) between the store and rpcauth_clear_credcache()
   and causing a run of the shrinker (drop_caches) in that window.

In that window a cred of the auth being destroyed can still be on the
global cred_unused LRU with RPCAUTH_CRED_HASHED set. A concurrent
shrinker (rpcauth_cache_shrink_scan(), or rpcauth_cache_enforce_limit()
from the rpcauth_lookup_credcache() path) holds rpc_credcache_lock,
walks cred_unused in rpcauth_prune_expired(), passes the
RPCAUTH_CRED_HASHED test in rpcauth_unhash_cred() and dereferences the
cleared au_credcache:

  BUG: unable to handle page fault for address: 000000000000000c
  #PF: supervisor write access in kernel mode
  RIP: 0010:_raw_spin_lock+0x13/0x60
  Call Trace:
   ? rpcauth_unhash_cred+0x45/0x90 [sunrpc]
   rpcauth_cache_do_shrink+0xb0/0x1e0 [sunrpc]
   rpcauth_cache_shrink_scan+0x34/0x50 [sunrpc]
   do_shrink_slab
   shrink_slab
   shrink_node
   balance_pgdat
   kswapd
  Comm: kswapd0   6.8.0-111-generic

0xc here is offsetof(struct rpc_cred_cache, lock).

rpcauth_destroy_credcache() is only called from auth_gss, every gss cred
takes a reference on its gss_auth when it is created, and gss_destroy()
calls rpcauth_destroy_credcache() before gss_put_auth(). While a cred is
alive its cr_auth is alive, so reading NULL from au_credcache can only be
the store above. We looked at a vmcore of the reproduction below confirms
it: cr_auth is the auth being destroyed, au_credcache is 0, the cred has
RPCAUTH_CRED_HASHED set and cr_count 1, and the cache object is still
allocated.

This change makes rpcauth_unhash_cred() treat a cleared cache as "this auth
is being torn down" and leave the cred alone. rpcauth_clear_credcache()
will unhash it and drop the hash table's reference, so nothing leaks. Lock
ordering is unchanged (rpc_credcache_lock, then cache->lock).

Co-authored-by: Hubert Dziedziczak <hubert.dziedziczak@nmc2.ai>
Signed-off-by: Dan Aloni <dan.aloni@vastdata.com>
---
 net/sunrpc/auth.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 68c0595ea2fd5..4ff70ed66211d 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -269,15 +269,17 @@ rpcauth_unhash_cred_locked(struct rpc_cred *cred)
 static bool
 rpcauth_unhash_cred(struct rpc_cred *cred)
 {
-	spinlock_t *cache_lock;
+	struct rpc_cred_cache *cache;
 	bool ret;
 
 	if (!test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags))
 		return false;
-	cache_lock = &cred->cr_auth->au_credcache->lock;
-	spin_lock(cache_lock);
+	cache = READ_ONCE(cred->cr_auth->au_credcache);
+	if (!cache)
+		return false;
+	spin_lock(&cache->lock);
 	ret = rpcauth_unhash_cred_locked(cred);
-	spin_unlock(cache_lock);
+	spin_unlock(&cache->lock);
 	return ret;
 }
 
@@ -409,7 +411,7 @@ rpcauth_destroy_credcache(struct rpc_auth *auth)
 	struct rpc_cred_cache *cache = auth->au_credcache;
 
 	if (cache) {
-		auth->au_credcache = NULL;
+		WRITE_ONCE(auth->au_credcache, NULL);
 		rpcauth_clear_credcache(cache);
 		kfree(cache->hashtable);
 		kfree(cache);
-- 
2.52.0

