Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552533;
	b=laXYx8y82W4xTO0JdodbmeXF95x4duy+BOK2WJY3zFLoH8/Eybo02W9MM4USwx8u3IJM
	 J0bczwF3rqU58CoOq6IPKnOBnVZhM0eX3ZpAY96R34jG3WsqOEdV2VkCnilrBKRpPfCdJ
	 3byb3mzvQZ8b8TIDHc6HnsESX4wg6UwmauEwpd23wxYvn5AAj9dWnfVKqkFQLic09oio+
	 NPGvP7p1+EWcgsdr8k6LzBTBZE8Pka96QSF7g10i5t8F8XfSLob+Aqu/QOSpKFBSgHfjw
	 lLWWtg/+cwgToKoUYvd3XqXYGhxekkalQn0gNBtt1vIYPe4slQolE7h6YM9s3MmAfhA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552533;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=EfTRtZy0G2OuIXu4PScrnzWcsEd6oPudCAluCFucq4Q=;
	b=HHPDGmseBhMaBymXXmQ0yhPxtk+XikZXYX6wwK2XmXZiRWsJktdjFcPH4g2CMCd9wJGE
	 JohwYG3PyjViIBL2t3c1qWC1MP5Nv4EK+GZcTisnvTLiqxBiJ/wisOAsvczjz173o5ifj
	 UzQCceirVJ7hKABsKuBN7bflXN6bcLdaQAs1sQtv1UAiLSYotSL9cEZnJlaMrdFOM9wEh
	 nXeXlB2ZzLX0+miES9TcQbkLpwWGu0v7xQJVQx6IguJAGf5QT45CRq/rBVj8E6iUfwbHz
	 U1sPrh6ERUGTNFxFZDY0oRDH3zzoG4rnb0GQI4/xzNX4FHlaeUfLvyXs55G21v59C+Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=Pf58hAVc;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3EF38606A31D;
	Wed, 21 Oct 2026 03:15:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3EF38606A31D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=Pf58hAVc
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552531; bh=0PLU2tqzeCB9lkMpzBKLluy29433zzBAWGe4OWhQlrE=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=Pf58hAVcCvsS5lNh9fqRRUi3TwaXPunlCLXPI/td2NJ/6FEy3z79xJAxuUS2SoCjZ
	 WEb3TENz5f62EOOs4A5a02u3F0nE/V1AE1YLBORyQihdlvpbLFcOu79QVbIyOFmarp
	 m+I6tSLTEOmbWUgUHw+UsoAy9nbOt+pAvye4VcmB8PYLd2vKMb0L91M271usDv+W52
	 xnaJJfpfRfpFCDZUZEOWCRwuEpyOX1QSysYCzb990kiVk50lcWn2BMFptVZOSKYXYv
	 1ux91G3892m5rfY56V236tyQi82U36XcjKQEkpg2vzycz0kIXkh1QSOrnXqrodkLKW
	 aHW6YUJ4vw0RA==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id 8B28B8A08F4;
	Wed, 21 Oct 2026 05:15:30 +0200 (CEST)
Message-ID: <acd7e5be521cc2ba0526c45212e0c7b0010a6d16.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 03/41] uidgid: add uid_is_legacy() and gid_is_legacy()
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
Date: Wed, 21 Oct 2026 05:15:23 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

User and group ids are about to become able to hold a UUID or a GUID
besides a classic 32 bit id. Add the predicates code that can only keep
a classic id (in 32 bits of a buffer, for instance) tests with, so it
can be converted before the types change. For now every id is a classic
one.

No functional change.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 include/linux/uidgid.h | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/include/linux/uidgid.h b/include/linux/uidgid.h
index 2dc767e08f..182c682458 100644
--- a/include/linux/uidgid.h
+++ b/include/linux/uidgid.h
@@ -22,6 +22,20 @@ struct uid_gid_map;
 #define KUIDT_INIT(value) (kuid_t){ value }
 #define KGIDT_INIT(value) (kgid_t){ value }
 
+/*
+ * Whether an id is a classic 32 bit id. All of them are for now; code that
+ * needs one (to store it in 32 bits, for example) checks with these.
+ */
+static inline bool uid_is_legacy(kuid_t uid)
+{
+	return true;
+}
+
+static inline bool gid_is_legacy(kgid_t gid)
+{
+	return true;
+}
+
 #ifdef CONFIG_MULTIUSER
 static inline uid_t __kuid_val(kuid_t uid)
 {
-- 
2.56.0

