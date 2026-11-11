Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794419040;
	b=dOnbwslRPYNVIVXbaBdQ+5Xg2R2rxJbYzy32AGX7K9Kqo4RaJ+zG+MnzaQfYBFS/Txnk
	 c1902gUm25P4ceOOgZpkw7YjevW62IJyQriwbmdGHGJNN5TN2gahHHBHH4/1xBVRQ974Q
	 UC00wwHqkLSYsOwwoNpqQAxWVPKoQtv/T5H29rmlv2SH8ufG1VzlJvH7+/MY8sRwY5LOq
	 97YgvXhsXMrJKIWtJiVXDUS05L2ThT1k7bfVQsp47Md3NRwy3QlLeaYDlqEPWrvtjCBKs
	 g35rVsfAYRMdNSaSD9D+QsAsrSvXBuxRWtM8bmxhOWPIo980wsLPcp/O0kxSln3I3fQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794419040;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=JG8HkUG0jpUKu4964H0wjKV7xaXGrg4yxztMKLpVEgo=;
	b=Q8XuApR2tfTe9lhFqu0apUtqEBuldvMl2pgC00/gmTNus8PpsIDViEW9tPtFVb81ebYu
	 OxRyDblypL0cRhRYNq3UI8mJPA7yb0y+ZdwJoZA3CKGsnp7lA3PDiJXxdTdM0T1+xlHcW
	 gEF5HKUlSApd0ybAKQgiAgg8kfFS/OG883MMMqeVYU7ZBi5VMx6c/WRiNKa/BObJbmHSE
	 cupHyDxev2HQizRBoIsnh09PHi/5rAf2kXQDmUdWDQ0L+xucbBLs5qls4bv2dnc9D7fs+
	 r+LMa6bVLSaq6DbvrwuEUdIqH9DPesMAFvvljyDTHyZCeEUK34gsBpE6Wk0oBvlnn7A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lqmb8U53;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E874606A334
	for <linux-nfs@vger.kernel.org>; Wed, 11 Nov 2026 17:44:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lqmb8U53
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2CCDF1F00A0E;
	Wed, 11 Nov 2026 17:43:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794419040;
	bh=JG8HkUG0jpUKu4964H0wjKV7xaXGrg4yxztMKLpVEgo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=lqmb8U53TdI67KVRt5LqLQlcHhyvM8neOeXa4VJ1t6inw3Ekn20dSoSiJ5QDztZLc
	 T+J55iW8ftHHtDfALDqqelR7NT/KWR49bgbvywnkmdeuGS6SXySPHjJktSHEAhtnw9
	 4A2GCsuWU5pzWjyVUu8M9OMPp97gCF4wT5DJQ8QPPueCpBoKLmaS7BTyzlZfHxoIVQ
	 jmG+9szm1dC7he0+I8S4ce3vzmYpqT+eRoqATr+YAvGEaWr9QcN8rXr/OKMPHyVhUR
	 9vwdyYwfHpeiisDWLD9FOrNzXEeAUJpj0nSLn5/A14+VtBTmsO+DIvCsv8UKU6QgX7
	 9lcFY8lL4tONw==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 11 Nov 2026 12:43:42 -0500
Subject: [PATCH v2 2/7] NFSD: Do not validate the transport before a
 deferred flavor check
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
Message-Id: <20261111-verofess-2-v2-2-01596ca4d8b1@kernel.org>
References: <20261111-verofess-2-v2-0-01596ca4d8b1@kernel.org>
In-Reply-To: <20261111-verofess-2-v2-0-01596ca4d8b1@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, sashiko-bot <sashiko-bot@kernel.org>, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1514; i=cel@kernel.org;
 h=from:subject:message-id; bh=BXOvFJxbz69peGtqH321s9C6ncbcpdilsVg4k+QZ5pc=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9Klbffr5o8vslbeo7ISnmSERiO0VONKdOlYej
 2ehCPH3bpqJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavSpWwAKCRAzarMzb2Z/
 l+vaD/9a3fdIscS1tRRV8GgThvBVBXLQDZ3Zs9hYbhz7RXTbWBx7dmaGjRVi1oUwGn08JXaGiGF
 r/vD8SPtJw4HAP9i3u4i+okZf0k/9EiDnqdMoZ66+AOvkEygULwXtuC2kcnR34yCsxxp88Hhq50
 ymc6A5JzyPU1kMlWukg7au3YSPJhexDr7xOxQxNHrbpKn6UUBh56quNfp38ZhNjlRK67QWFr7uV
 s8BhZH2Sm6EJ3ka+LOIhNJcac5pltzD7UpKZT4n//kWMTWYpa/NXkOVnPX+4kCzJJjMPt+mlNCT
 OGJ+W1Bn5BM0feP+wwamQwKiaE94qUx9F+LOCXtU6+UH+57J6x1Fy0198hO7jE/7zwn1SbfmEPS
 l4lWhGJ0HHa04TW5cf0P0r/xYPMuO52pUY5kYXfWWYOCXGwo0EeRHlOr6S+w/RmqlgTk5IToFXj
 Dihkq0ltcEk6LP6LfGfoGXoD4xY2H/RjlQtJB4hj71z2v3OhYlPU+TTjmrT05PVDTVjmMDxviWA
 HcjJ+Y3+w4/ftXu4qGq/u03mUmWN8OCJBykIhYDcNwQRI/IEMTmsV64lEloKnukecRlv8IdvfzS
 nRI3sl5sBWNqyiZMv7Sx/zhoK7+SIUUNbgoX1CI1sGIiAg0ThQ5G/Ext7xhe0QaUkDF0b3dgq4l
 5lBFcvgsXFRhDgQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

fh_verify() marks the transport valid once a filehandle passes the
export's checks, and svc_check_conn_limits() closes only connections
that are not marked valid. Since commit 6a7d0b390a0b ("NFSD: Defer the
PUTFH export security flavor check"), fh_verify() skips the flavor
check when the caller passes NFSD_MAY_BYPASS_FLAVOR but still marks
the transport valid. A peer whose security flavor the export does not
accept can send PUTFH on any number of connections, and
svc_check_conn_limits() never closes them.

Mark the transport valid only when fh_verify() has run the flavor
check. A client that uses an accepted flavor still validates its
connection with the first operation that calls fh_verify() without
NFSD_MAY_BYPASS_FLAVOR.

Reported-by: sashiko-bot <sashiko-bot@kernel.org>
Fixes: 6a7d0b390a0b ("NFSD: Defer the PUTFH export security flavor check")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsfh.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index f76ce9cc405c..6a18cf52ab8e 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -500,10 +500,9 @@ __fh_verify(struct svc_rqst *rqstp,
 		error = check_security_flavor(exp, rqstp, may_bypass_gss);
 		if (error)
 			goto out;
+		svc_xprt_set_valid(rqstp->rq_xprt);
 	}
 
-	svc_xprt_set_valid(rqstp->rq_xprt);
-
 check_permissions:
 	/* Finally, check access permissions. */
 	error = nfsd_permission(cred, exp, dentry, access);

-- 
2.56.0

