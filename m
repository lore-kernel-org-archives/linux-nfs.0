Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793801478;
	b=D+/krLBo9gwivzJx3rqwCHeIOtPYOscJ25JFEgyKEroi++Ne7odzTOmiEFn2V3QHcxXC
	 gPEgDyZ2R8Xq69U14aPoXnXznLCavJIdAiyjX+TIkK3Ds0fHN6+uD93Z9xB3cNWqyUPc3
	 Pgn4sb/Ij3QyZFgyvEIBwGCnDPmhl6WF5z8RwJoLDGyAMOQqVkXtQkqA+4LM6wLurOKxI
	 A3R12Rs+OJKsz42YFJH22ZJX96c2j6gG0ioS54rTAPs6tt9oKr3SJnVXXEoZuKfUlXpv9
	 jUS6bsMG+Dl4BlADKcq3W943G+iWPYBUvAyQSgB6hX7iko932e0G8uO/UL4BOrTci0g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793801478;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=LIM1PWO7q5cuwC7cO7Y6aYPZzRA6rK/8Dp3kAsbCSzc=;
	b=wEnXybXmodh1W+kul/VNl2E3GbDVxK1SHuxMIwtG0ibO6QSjNrNklWCvxDtizjhgK6PD
	 0ReVFlSxaI+fgMJ7BgcLucIWDlyVL4Yq8ktYqqyMMr2VDNE4Xbi3BmxwE1/+/0Excb4TO
	 kyzqPwGoKP+m0R0TPKyAKARoPhR6Q4RFH+crL4sBSfCAZZSwDtHzWE5Tl5wmQnROUmBqA
	 yhOl2ZHEBd4mm+wKKXG0HK5qewh9s/JzwoaqCtV1ddLOjdlJ0LzqOppXvo1xnw+fNnl9C
	 T5M6GMpAXnCj484UJsicoMNKROSySaBhXv3LhpCZG1vSKEJdusgzmAE/7RhXNndTTIQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=e1xbKznV;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CF436606A31B;
	Wed,  4 Nov 2026 14:11:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=e1xbKznV
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7F4CA1F00A15;
	Wed,  4 Nov 2026 14:11:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793801477;
	bh=LIM1PWO7q5cuwC7cO7Y6aYPZzRA6rK/8Dp3kAsbCSzc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=e1xbKznV1EvFwxVRvJsRCbpPoL/lV94qu6HAbK98uNUSBdpNr1QCWu1CEKjhSkrNj
	 Hu2hJGOdDdppHA0U/kYnTlyvqWylbST+8rskZCf2AY4UPMkL/2NNqQ0BJkq9rdrMIH
	 XRHJyZkH/eghlVrrxxmXsx1ULaZpNbxUC3NR4O3oTl9qdJy4oAIu9acEonh+wbbAsF
	 IUu4saWmpuV1k+gyD0qYiEsRTKJJ/oXa0pjM+IsdUVZwXwvmvwhj59ErdQirN3WBI2
	 KkzxcJOM4zAj5+Tdq9+LQVs9VAVg7Y208FKgkFAfi+iLHVuzEwlVcARhVQLA674oXD
	 tS4mvbyRc2TcA==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 04 Nov 2026 09:11:02 -0500
Subject: [PATCH v8 02/14] NFSD: Make the DRC size limit independent of page
 size
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261104-duplicate-reply-cache-v8-2-eea5b90e4318@kernel.org>
References: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
In-Reply-To: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1491; i=cel@kernel.org;
 h=from:subject:message-id; bh=COgGg9i1XBm5Uu8T4x3im/AHRL0LXao1dtUbQzdmV0s=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6z0A6JcubTaZcllN3ClZXgp/C8jIzoe5SYOhw
 13ZHBkrhi+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaus9AAAKCRAzarMzb2Z/
 l4HrEACWyklH0YtO4MgotcLGUwu7gKf8FBXVF44mA5NHGOFBltnu8UG7XC6bL0kAWbyof3YXH27
 EVOTT+VdYm/1XZucdLShSoQoda5W8CkcGwQECzGDOm7fQH0+W8HzWx0dE0tl9KBU3jILZ62wJ/e
 4Sai8EHsJS0I8T2FxrHLJE5f6k1wEmSVd/0p6X3iUo72Z6jIezs8ZrS3Lp3D+4Kmx9p1kVY7BaY
 DGfXue96yy1JDtpgINSDCw1VHsfWihgsUAaLVcpjDoLi7RonHquzQ1csVjsUvO11oUU/3eMJYLe
 LKh5lLpOggwP5psUv8XhpM6QtH8ybdZLYMyjKq4hofvEeF8xYpeRaStv2uwPYWCUlyhti+58I3a
 ppzKNz799BeHej0YgITHVG0o8oxBuuWX07aZvgG5utPk2zwyzVYybMFGPRVxq4/VuZsN1CNKND4
 xQ8GlwTqzhWx4nMa84ZZAisvD6znJvvqC2GRpzfVQt1id0rkB0hYLOrzE/dmnjyVKxKZSUpKidV
 eAd92dlJHwOHzofOmodm2RsSraiXBXLrId0NMT9oVUPAFVM/iqWXcNkYox65Am2EB5hXnxsLka3
 9Z5HEuSucJqUWFPH5wNJfUB9whs5AYjYGyUfBN+f87zIeSVG4K3lHr3j2CDjiLN/Fk2ipUWJtoC
 ZKiIw5Zdb7CQ7Zw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_cache_size_limit() takes the square root of the low-memory page
count and then shifts the result by the page size in KB. The shift
belongs under the root. A host with 64 KB pages has a page count 16
times smaller than a 4 KB host with the same memory, so its root is
4 times smaller and its shift 16 times larger, and the limit comes
out 4 times larger. With 8 GB of low memory the limit is 92672
entries on 4 KB pages and 370688 on 64 KB pages.

Take the root of the byte count instead. The result matches the
table above the function on every page size. Low memory on a 32-bit
host is under 1 GB, so the byte count fits in an unsigned long.

Fixes: 0338dd157282 ("nfsd: dynamically allocate DRC entries")
Suggested-by: NeilBrown <neil@brown.name>
Reviewed-by: NeilBrown <neil@brown.name>
Link: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-1-db5e13fd9944@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 80364b91331a..b43b276a92b3 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -73,7 +73,7 @@ nfsd_cache_size_limit(void)
 	unsigned int limit;
 	unsigned long low_pages = totalram_pages() - totalhigh_pages();
 
-	limit = (16 * int_sqrt(low_pages)) << (PAGE_SHIFT-10);
+	limit = int_sqrt(low_pages << PAGE_SHIFT);
 	return min_t(unsigned int, limit, 256*1024);
 }
 

-- 
2.56.0

