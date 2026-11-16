Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794872658;
	b=XPKlooq3XgPYmeNwpqaZT9++TPgQdUi9uhRjDEp3XerP4WTMJS8EEUE1/+EoTtUjO5oz
	 2Dj+9PRIg9po185KNR9kK8RwTrdmWXMh31VxK5og3dFQrAQbAKkDBNTf4kGblea1RGHwm
	 RYOxr6Vs89mSKu6eCCOSSF9LUZZXOqSDgKaUbeaxCatt3F3QXiQG1wzRKUdl1tKC4h2ly
	 3Q600KCawblaMXy4T/LYRXMOSds+zd6fjXzbmcliMaJM0418lp0nzMFeEIhqhVdggZ8rX
	 wBMmYMtrNLNYOgv5uIJ4TwWisNGe417zYcbkg8odoiAuA+fvAt9cQqhzNxuUblKVeDA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794872658;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=Ow1dpwivy/YA81V3HYwNxXFsM/RZVWdqbms2PnjlscM=;
	b=VlDwUhpDL96cIIVNUkJsvI7IC72/zTqtg0tMrHdo2uVQ2/yYS+sp/Bq6pj6bTbQdJpEV
	 RnftCFtfjDa6/92HyL7GwDxrW6CbfkOvRgb1oNFaKsrCLFF6SHjD901gPfWtJGVKyHBzu
	 W84HqXSZZirsJkMVkj/h2TMqLvtxK7IM4PLwbLo0N1rh67Wd2zzDQHsjxLEgpmic/M3qD
	 ghvIpXUtoB8kSwGSIL3cZO5JefyB5xTCBwebGY5Dj2EqEZ74neUuxjC7aN/mmZ7qXi8wC
	 vr6tBk5srTej2wMJosXOFAYkxEK67nLngsutXidSnUwXdZJX6su3PrvM0jcpTr/BO/g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="PdTz/6mr";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9A3DD606A332
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 23:44:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PdTz/6mr
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3F28D1F000C5;
	Mon, 16 Nov 2026 23:44:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794872658;
	bh=Ow1dpwivy/YA81V3HYwNxXFsM/RZVWdqbms2PnjlscM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=PdTz/6mr9g4c5NJjNc4p3O/Qoae1bj8/pQnnR6nurvmlYBTs64DDAjXzocczZYX95
	 KNo9G2NsQLbHqU15rCyT6tfT/MPjkOMlnDNfg7rVXvO7AR2a6HoTg9VJHAV15M6KZH
	 EMRSBbqZ1IOYM4EedMP5BdDv3syKL0SuGjMFTzaow/na25/KzP6Hs6T/j9dQQxlis5
	 oI3luUU7Qm0mlxwUFFx83etGdkNafdCq00wO0oe9FBB1Sond8Rrm7CzfSExMjjJThZ
	 ck/AmTUCQx7zRfj8P+4pogu0aORmUlhpnloFt4a+oisqKe69L1xknupcUA0CpfyKf3
	 +h7yth1/d2NZw==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 16 Nov 2026 18:44:10 -0500
Subject: [PATCH 2/7] NFS: Return NFS4ERR_DELAY when CB_SEQUENCE decoding
 runs out of memory
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
Message-Id: <20261116-quinn-v1-2-f05258cab8e4@kernel.org>
References: <20261116-quinn-v1-0-f05258cab8e4@kernel.org>
In-Reply-To: <20261116-quinn-v1-0-f05258cab8e4@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1850; i=cel@kernel.org;
 h=from:subject:message-id; bh=9hgro4FOlUbO1uIS91qKQWm6ns+P++vK8w33m/DjhEo=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq+5VRw51bPNp5wt2LsKN9HQZXxv0nZL/DbKPud
 W7oND9QMMKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavuVUQAKCRAzarMzb2Z/
 l9GfEACT3ZHCq5b4+hImwDtXdO47usVnY3UZN8Lj1w/rscYN2GFwXP9qPAY16nepb3V61Qb/+Xz
 A6Dgof0j377jn46sVYkAzL1QxvjoWPsFiHDYEk8yCApx7G4v2O+lELM6xuIOTQwRybvSHHOvDoW
 H7tvb5AmP+Q+0vjKIN3WoR/UHJYShmt/HPElFrdn8XnnlCjf6GZmINi6g5VSOQiNbBhcWVStE4A
 ffqaKHIluTACdv5/e6mpFIoyLGT3N80UjK+ucacxJv3sn9rDnKVCiaql5v/RuoUjrJXDOm63Jh8
 AAtFXQuF0gTUG1CfAPhrV+1dRsLa5UfsR6Yr1myrcC9+4p9A5RmdV/KKw1w9JXFZlmIvtA5Z6Ow
 uvIRRCaJUziYDK635GYuwPb9ZDCJAVP3y64egXb8m4ArEwsZHDk8gqdt9lrRv7msfRBbCSkyitP
 cJitozYFPzVEnOQ+UZsWVdXInWZjMK/mEZ6OR+bj/4SXtxdXebbPxqfH543BWXQDkihGsHsp8xD
 HxR7KJB2UahSQ7awj57duQIP/33hkzerBHl9r/LIX32EmJ9naO+UZn0wc4m4kLzoX345bVsb43P
 91VDx9zxcfHb9LxK2ZwC4C2cnTB5Dll3Tj3fD276rpCBpqHfYRNH+0l/Hnse+n1+XO1QL80aAPu
 l9DLTFz5gDn+omg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

decode_cb_sequence_args() and decode_rc_list() allocate the referring
call lists carried in a CB_SEQUENCE request. When either allocation
fails, the decoder returns NFS4ERR_RESOURCE. CB_SEQUENCE exists only in
NFSv4.1 and later, and RFC 8881 does not define NFS4ERR_RESOURCE. The
NFSv4.1 XDR in RFC 5662 marks NFS4ERR_RESOURCE as "not a valid error in
NFSv4.1". NFS4ERR_DELAY asks the server to retry the callback later, and
decode_devicenotify_args() already returns it when its own allocation
fails.

Return NFS4ERR_DELAY from both allocation failures.

Fixes: 4aece6a19cf7 ("nfs41: cb_sequence xdr implementation")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/callback_xdr.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 3136476c3a2b..64ce903918ec 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -387,8 +387,10 @@ static __be32 decode_rc_list(struct xdr_stream *xdr,
 			goto out;
 		rc_list->rcl_refcalls = kmalloc_objs(*rc_list->rcl_refcalls,
 						     rc_list->rcl_nrefcalls);
-		if (unlikely(rc_list->rcl_refcalls == NULL))
+		if (unlikely(rc_list->rcl_refcalls == NULL)) {
+			status = htonl(NFS4ERR_DELAY);
 			goto out;
+		}
 		for (i = 0; i < rc_list->rcl_nrefcalls; i++) {
 			rc_list->rcl_refcalls[i].rc_sequenceid = ntohl(*p++);
 			rc_list->rcl_refcalls[i].rc_slotid = ntohl(*p++);
@@ -428,7 +430,7 @@ static __be32 decode_cb_sequence_args(struct svc_rqst *rqstp,
 		args->csa_rclists = kzalloc_objs(*args->csa_rclists,
 						 args->csa_nrclists);
 		if (unlikely(args->csa_rclists == NULL))
-			return htonl(NFS4ERR_RESOURCE);
+			return htonl(NFS4ERR_DELAY);
 
 		for (i = 0; i < args->csa_nrclists; i++) {
 			status = decode_rc_list(xdr, &args->csa_rclists[i]);

-- 
2.56.0

