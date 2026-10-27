Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793119842;
	b=PjFFib2ChqH2JFqeFfdwRvd+epGR8aSv9nH629AgAHqVwESHGHC6WEFU0GWgh+b+Euh5
	 QhC6yBmmMOzxgfXzEoONM/eDzp1nHpHEilkvDFrE1c4hVXplUw4RStHreWEJA+cIEi7JX
	 jYHqJNDtMtuj+zBdizoUM0J/OTPhQ2jhUDa166Nr2GMhtbPU1n/34UJhZA7lHouanxqPn
	 dHuUqkfHny4M76hmS9DwIGoJOVUF2JCC5yzg600sGpSVwQatm8vGZMmx2UUdXzWopx54Q
	 iOtuqD/8gjiPZeUZgFVeCevDf9jVtzzGaKGNowdTqqcYa3Mhs2Befi6RhClre7GBA4g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793119842;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=X4f3A1ORy0x7vrd+xR8bc7ok8qguF+03XH0uco0/AKw=;
	b=O1Td85EYMUAvigX11sYDuEA1uu2QwV3laPMbv5DZI8B8jIFyzKF6rvk3BqlhjvWgbPnq
	 mUhc5pIoGiBVioH5gJtnZJ+gTJv7m2q/VcwFU9YMHJUyf4NUMQ3wWi2mGveCVXFqeyPDg
	 l0B2h7zDJ8g7m7Zro8VBEkbVZRiix0znl6zS+VD0J6wz5a04BVFmcSljFAkU6o8mKho9b
	 b41I6q1J432OsYGqQCvptaYGmD+JGcC0Flkp5FnDdOQSUOEdx7x0zzqjyHxN75P7VBHvT
	 929+6/I3e1pBHHRbn0Wd4ygPZClMcms92BARq056OMVaONrQrEVo49B/O4MGeqVJJVg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="cFzt/eCr";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5ABD606A31F
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 16:50:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cFzt/eCr
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C11071F01828;
	Tue, 27 Oct 2026 16:50:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793119841;
	bh=X4f3A1ORy0x7vrd+xR8bc7ok8qguF+03XH0uco0/AKw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=cFzt/eCrkfwX7XPHhu64gyJGzYfDCRyHXyUCOlfScocrYV/DR+FR5Zfa2Humm/kNn
	 fyFpHZRdRETEdb9U1gz4gaexDWumBYyQ9heR4gZv7m0azaNMByLBak4SfLyeB3gInt
	 961xIvtSBZuQZ63RGphGxwLMWVxNx4e11sDObQUSEKoH46gtVN/9qNGr1JjqQZ7piN
	 jKtRi+E+WCg0QcwmpicMADmBT+M2hs/ZKDyrnCoB1gIOQy8PcNCua1dw+GeuRBpBZ9
	 gjg4nU5MZ0IiikkAT+pyalruzbd3L+gUi6puzh9QLvfoqAu0mpwK4v1SetjeFrQI4o
	 BSn8rhN+G5FWA==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 27 Oct 2026 12:50:23 -0400
Subject: [PATCH nfs-utils 1/4] exportfs/mountd/exportd: track the
 svc_export policy highest attribute
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
Message-Id: <20261027-master-v1-1-6f1f7a35a83b@kernel.org>
References: <20261027-master-v1-0-6f1f7a35a83b@kernel.org>
In-Reply-To: <20261027-master-v1-0-6f1f7a35a83b@kernel.org>
To: Steve Dickson <steved@redhat.com>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2251; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=K1+quiOCFzxm6ulbw4AtHIuR/uILoCs7iUd/bbYBetU=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq4NZepWD0F0DwvICAyzqD4KLZsZ8oe+2spljK2
 W+i55dSmD2JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauDWXgAKCRAADmhBGVaC
 FexmEADJrI6EUAfcSlukFvdfihIf7AZZYWgRo6jS/78FcPPQsY422Hr23tmgzFdXAYR2d+6vPG+
 14icmYsf5t1i6uobO5B/dF+2rAvBLcJ8j9B87sj4utpx7tAIvr2+P0Yi9xWZjKhH2nmia9YiCwi
 hOV8cfyHMVwLfcYToBIS/hjJe/wRAU6vhk7bD6WdOuvE6wN0msbHXTDrVk0qmnVL58+X/odRR8O
 7qcpna4GrMqYn9iYy+C8JMUCiDaodFTvnMqnGiI4VPTMIIfelu5Wr13KAvygX/cmpDVFfbx0n2Y
 iO02ncKo3pk7/yn8MU5W97xsfpZxtXWbOGVe0zgE2vnH0GJAuXxpfi/mRCYZ+u++OlCMXbEvy2s
 I4pc5GHVADW13eRwrMgvxnplf07g6GazxgP/WgxoTAzE+i+RpjlCPH5VZlrLaiyRSwWj4gGQRo3
 iZDDoi7J4G9NdtSZUYO07UA7tXdJypaOgro8aIbWSGib0lqItQTXDvf7PAELRTQLBkPktyMRnX6
 Ii3byFloygrM7++OWAUAttExdH9fNsjDWRZIVVrwNyfVlbQbSFIAkPKsbI4wrnisH0kZda5uuY7
 2cVCWZ9SWR/F6Wsqi4aR+jsjPAQAzOnWEnG7dh6GQaRqCz1Z8j/k0aPY9Y2rktmnxvZiM5ZLFK9
 aDm38XibJqrX9OQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Record max_attr, the highest attribute in the kernel svc_export netlink
policy, in struct nfsd_export_policy. Follow-on work needs it to avoid
sending attributes that an older kernel would reject the whole entry
over.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 support/export/export_policy.c | 7 ++++++-
 support/include/exportfs.h     | 2 ++
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/support/export/export_policy.c b/support/export/export_policy.c
index 9c0a099fb0c2..a0170cb87f91 100644
--- a/support/export/export_policy.c
+++ b/support/export/export_policy.c
@@ -40,6 +40,7 @@ struct export_policy_dump {
 	int		done;
 	int		do_idx;		/* the op's own policy */
 	/* per policy: */
+	int		max_attr[NL_POLICY_SLOTS];
 	int		reqs_idx[NL_POLICY_SLOTS];	/* REQUESTS nests this */
 	uint64_t	flags_mask[NL_POLICY_SLOTS];	/* mask of FLAGS */
 };
@@ -106,6 +107,8 @@ static void nl_policy_attrs(struct export_policy_dump *d, struct nlattr *attr)
 		nla_for_each_nested(a, pol, arem) {
 			int type = nla_type(a);
 
+			if (d->max_attr[idx] < type)
+				d->max_attr[idx] = type;
 			nla_for_each_nested(p, a, rem)
 				nl_policy_type_attr(d, idx, type, p);
 		}
@@ -219,8 +222,10 @@ int nfsd_export_policy_query(struct nfsd_export_policy *pol)
 	 * every kernel with the netlink export interface.
 	 */
 	cached.secinfo_flags = NFSEXP_SECINFO_FLAGS;
+	cached.max_attr = d.max_attr[svc];
 	have_cached = true;
-	xlog(D_NETLINK, "svc_export policy: flags 0x%x", cached.flags);
+	xlog(D_NETLINK, "svc_export policy: max attribute %d, flags 0x%x",
+	     cached.max_attr, cached.flags);
 	*pol = cached;
 	ret = 0;
 out:
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index d762e4533560..a7c145543075 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -170,6 +170,8 @@ struct nfskey *			key_lookup(char *hname);
 struct nfsd_export_policy {
 	unsigned int	flags;		/* export flags it knows */
 	unsigned int	secinfo_flags;	/* flags that may vary per flavor */
+	int		max_attr;	/* highest svc_export netlink attribute,
+					 * 0 if it did not say */
 };
 
 struct nfsd_export_policy *get_export_features(void);

-- 
2.56.0

