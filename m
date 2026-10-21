Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552568;
	b=0yxpM2eCZnzi1xKyNrFueADAldz8mzUfqjBOVOG7TwW558EnUrh81fPVgOM2v4sbJe7E
	 nL+HJSDOsK946XS4bsB+58pZlH7AlVrRSj3Z4JuubQbERIoNUBhpGbIsqS/2HNycbAK5U
	 Wzx/s0V3ZF3GEYh8Jth/ocEySL1UK+Onc2qOqUHBfCSbFzlJpVULN0VhRP09wJQMeeXqs
	 I8R/v+GE/gp0dCh6nVxhkcwPHTcwbup6lKt55zNa7r1K/Z30/H+dFfoc94+bmw77WBNAl
	 V3bLwV1KPSjne1T0FS3aENqzUIvycx79bVqtCAJt0Uiz9SUT7GV2whrMVcDIEZ+CCnA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552568;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=ib0nlJadXDep+U14bwYxShdaxBEBbQPpAy7Z/Ymc78U=;
	b=TvBzOF6RMiYOzZNQS/KJ6MlDurEB7vKTgcQD4PvUrQah4YtHRv3xdvPDhsj0CNc4v6k7
	 SvlHRbI7+Cp+04AaXq4+MwRJsQUGMsuWm/TpX5KeR8f+nJXeQ7PQUstS73yOthQgdZcyp
	 wQ/72NXtflqVWmmHTFvRGGvhFks9GVwLXPDq1TVixPJvQndnRC+qFbSjXvriDvsHx2f/9
	 A+jypv6JN9F29lHiCJ5bCzwRLlLl8eGqczhf4mmxcdxP53eR+p+1YI64WIkkpJKhUEQjq
	 gHe0Vm9ugj4Fan6B4r+E+du5fKHtJ2HsR5QWBfQ8lKIa5AyTkTNEZ1xFOHlV3vkw1kg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=kBnyzixn;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B2F4460A3803;
	Wed, 21 Oct 2026 03:16:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B2F4460A3803
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=kBnyzixn
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552565; bh=/svxbILxTL0TSYd/4NFPp7T2dgkN7SzVLTbqNFSVtUs=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=kBnyzixnDL7eQ84r0eIxGen66YxJNnYDaNye9yyMZ2/NHe99jzC5joblq2ox6cUYY
	 Si5eD99tl/eewnwZPi/VH7418FgjuuaYPiEN8fv5qj38ptaJfnbrom9DgibLExDqna
	 gTrhYCn2TG82pwJ5BKVUBDBxZeBwiR5wb5eJBcyagVkQof2amMQphExTn4jBVwdky/
	 DF5c1ND/8XfmPMjUAcWLjMS3IOdG2eYlg2ew1jG11VC02BKAIO42IsFZ93s4SPuzmA
	 0B/rrdhed14oWzsEPOtyBpG9Ko+WugpTBq/hXY7Z1+j6K7vn6fSDjbSpKvb8DGcJ1C
	 r2BmpYdWGk7qw==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 2F5978A08DF;
	Wed, 21 Oct 2026 05:16:05 +0200 (CEST)
Message-ID: <f9cecad11d5acce30303f25861d7e9f25daecc88.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 13/41] ublk: refuse unprivileged devices to UUID and
 GUID users
To: Christian Brauner <brauner@kernel.org>,
    Alexander Viro <viro@zeniv.linux.org.uk>,
    "Serge E. Hallyn" <serge@hallyn.com>
Cc: Jan Kara <jack@suse.cz>,
    "Theodore Y. Ts'o" <tytso@mit.edu>,
    Paul Moore <paul@paul-moore.com>,
    Arnd Bergmann <arnd@arndb.de>,
    linux-fsdevel@vger.kernel.org,
    linux-api@vger.kernel.org,
    linux-security-module@vger.kernel.org,
    linux-arch@vger.kernel.org,
    linux-ext4@vger.kernel.org,
    linux-nfs@vger.kernel.org,
    linux-cifs@vger.kernel.org,
    netdev@vger.kernel.org,
    audit@vger.kernel.org,
    keyrings@vger.kernel.org,
    linux-kernel@vger.kernel.org
Date: Wed, 21 Oct 2026 05:15:33 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

The owner of an unprivileged ublk device is recorded in 32 bit fields of
struct ublksrv_ctrl_dev_info, and only the owner may open the disk. A
UUID or GUID user comes out as -1 there, like every other one, so they
could open each other's devices.

Fail the creation of unprivileged devices by such users with
-EOVERFLOW, and never let such a user pass the owner check.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 drivers/block/ublk_drv.c | 17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/block/ublk_drv.c b/drivers/block/ublk_drv.c
index 66eb55e716..8125b79c87 100644
--- a/drivers/block/ublk_drv.c
+++ b/drivers/block/ublk_drv.c
@@ -1324,7 +1324,12 @@ static void ublk_free_disk(struct gendisk *disk)
 	ublk_put_device(ub);
 }
 
-static void ublk_store_owner_uid_gid(unsigned int *owner_uid,
+/*
+ * The owner of an unprivileged device is kept in 32 bits: -EOVERFLOW for
+ * a UUID or GUID user or group, which all would come out as -1 and so
+ * pass for each other.
+ */
+static int ublk_store_owner_uid_gid(unsigned int *owner_uid,
 		unsigned int *owner_gid)
 {
 	kuid_t uid;
@@ -1334,6 +1339,7 @@ static void ublk_store_owner_uid_gid(unsigned int *owner_uid,
 
 	*owner_uid = from_kuid(&init_user_ns, uid);
 	*owner_gid = from_kgid(&init_user_ns, gid);
+	return uid_is_legacy(uid) && gid_is_legacy(gid) ? 0 : -EOVERFLOW;
 }
 
 static int ublk_open(struct gendisk *disk, blk_mode_t mode)
@@ -1355,9 +1361,8 @@ static int ublk_open(struct gendisk *disk, blk_mode_t mode)
 	if (ub->dev_info.flags & UBLK_F_UNPRIVILEGED_DEV) {
 		unsigned int curr_uid, curr_gid;
 
-		ublk_store_owner_uid_gid(&curr_uid, &curr_gid);
-
-		if (curr_uid != ub->dev_info.owner_uid || curr_gid !=
+		if (ublk_store_owner_uid_gid(&curr_uid, &curr_gid) ||
+		    curr_uid != ub->dev_info.owner_uid || curr_gid !=
 				ub->dev_info.owner_gid)
 			return -EPERM;
 	}
@@ -4744,7 +4749,9 @@ static int ublk_ctrl_add_dev(const struct ublksrv_ctrl_cmd *header)
 	}
 
 	/* the created device is always owned by current user */
-	ublk_store_owner_uid_gid(&info.owner_uid, &info.owner_gid);
+	if (ublk_store_owner_uid_gid(&info.owner_uid, &info.owner_gid) &&
+	    (info.flags & UBLK_F_UNPRIVILEGED_DEV))
+		return -EOVERFLOW;
 
 	if (header->dev_id != info.dev_id) {
 		pr_warn("%s: dev id not match %u %u\n",
-- 
2.56.0

