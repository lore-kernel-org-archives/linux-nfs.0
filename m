Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552561;
	b=ytawGHnees0uNzwcCBIH7ZE3vxEixBJUNuklNg3LDrWEp4/tKh+vlqttyvblY/OPjNIE
	 ecw9AKpf8PsKjP1MN542MNjxX2xD5RIIAAmD4YV3/VkS/8l5MSC4KUrn5CbumulphpWV1
	 SU56eL8uauFDuJeeSnNdfx2DVOD1OfYALbzHfNc66noCZiPB41G3n/kI1wCM6C+FPc7ew
	 kiK6pX6eTr/8/loqNDJXOLggzOvyhm+HmCmqrl2ztO+I6ly9OUh5Y9YuRvNs5kkZCWxHS
	 Ump7f6ccOZW0y30x1SWfb3wIJhzH5S1vDmt710ee45yPh5gnJe2XpOic0TKUTdiZv+g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552561;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=8auVlpEIa832B22UfxOKY0hTOrXUXPF0AuIXJWKQe2Q=;
	b=3M4KA2xZes1Uv4YnyAf9WvaiU3In/B84Z8DiugOiKp+iGSlctH8b4I0vEDiOzvqE/LLw
	 CRaxvSM9J34LrM2pMM0IzbsSf0BwUlHmdmQ16EI1JNxUIuFukuOPpjQ3mwEY+Dh1rPEuv
	 jIPqVuCkaoQ5cZD9AmQJg3OKqrfVsrawGTfNOrwRGmdyCTWdbiD42hXDfMXtpzvul5HbO
	 v9muUNICyNCg6723bMZnV9r+uiushGKwX19yRromfx+ru7EindxTFnyfsm9oj8q9ws3N2
	 yC1VT3JDSYLXSVnP8sG1cWXYqN9QcH285ZK8dSnzNRd7UayCaARnczHh5zQDifQ65+Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=JlcOijbP;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 092CF60A6F4C;
	Wed, 21 Oct 2026 03:16:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 092CF60A6F4C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=JlcOijbP
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552559; bh=QpJWmptSSxJ9NCX4CSoJ9NPLuC+5iYwG87QA4+dF8FY=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=JlcOijbP5hWD/Ia/cdZ8ZUWKzG8cuzkEfgymfID2FBqo4nQ9oF1Uk88rtMV3VyXF5
	 JZEjouk1I/6H5NsztYId4MrHJXVunH6FX9d9EsQNgH8zyxXn91OU1XAqe691JvrNBN
	 M9XyBRgRTFXsR0qaxA3I5FrhIR7ZyzxvbxgcwaEQ8ITzUwSTFREgwH2Ykuwh+YKyHN
	 76BRGkUBfJqV9u9Cm+dW/qKzByMtfmFObP98Vt8JDnGYHCZLMUBSrffybFAl9QkCLB
	 atADl3zrfqvyscw5zhK0AUiVqevp3gI2yp5QQtZOZew2BIHHzP3XJ9hqASezLWnRc9
	 w/6fnkp3nhQTw==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id A38388A091B;
	Wed, 21 Oct 2026 05:15:58 +0200 (CEST)
Message-ID: <5b72905c9c3703b283cd9ecd0c39024c4fbb6eaf.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 11/41] fscrypt: show the whole uid in the description
 of user key claims
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
Date: Wed, 21 Oct 2026 05:15:31 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

The ".fscrypt" keys that account a master key to a user are described
as "<identifier>.uid.<uid>". For a UUID or GUID uid that printed -1;
use kuid_str() so /proc/keys shows who the claim belongs to. Lookups
compare the kuid itself and are not affected.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/crypto/keyring.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/crypto/keyring.c b/fs/crypto/keyring.c
index 76e28d1e00..080166267f 100644
--- a/fs/crypto/keyring.c
+++ b/fs/crypto/keyring.c
@@ -178,7 +178,7 @@ static struct key_type key_type_fscrypt_user = {
 };
 
 #define FSCRYPT_MK_USER_DESCRIPTION_SIZE	\
-	(2 * FSCRYPT_KEY_IDENTIFIER_SIZE + CONST_STRLEN(".uid.") + 10 + 1)
+	(2 * FSCRYPT_KEY_IDENTIFIER_SIZE + CONST_STRLEN(".uid.") + KID_STR_LEN)
 
 /* Create ->s_master_keys if needed.  Synchronized by fscrypt_add_key_mutex. */
 static int allocate_filesystem_keyring(struct super_block *sb)
@@ -338,13 +338,14 @@ static int add_master_key_user(struct fscrypt_master_key *mk)
 {
 	kuid_t uid = current_fsuid();
 	char description[FSCRYPT_MK_USER_DESCRIPTION_SIZE];
+	char uidbuf[KID_STR_LEN];
 	struct key *quota_key;
 	struct fscrypt_master_key_user *mk_user;
 	int err;
 
-	snprintf(description, sizeof(description), "%*phN.uid.%u",
+	snprintf(description, sizeof(description), "%*phN.uid.%s",
 		 FSCRYPT_KEY_IDENTIFIER_SIZE, mk->mk_spec.u.identifier,
-		 __kuid_val(uid));
+		 kuid_str(uid, uidbuf));
 	quota_key = key_alloc(&key_type_fscrypt_user, description, uid,
 			      current_gid(), current_cred(),
 			      KEY_POS_SEARCH | KEY_USR_VIEW, 0, NULL);
-- 
2.56.0

