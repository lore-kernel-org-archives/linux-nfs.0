Received: from mout.gmx.net (mout.gmx.net [212.227.15.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 10F4A4DE722;
	Sun, 18 Oct 2026 18:02:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.15.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792346533; cv=none; b=g6aV/te6jQoG15/ux4p+WWfjZ/xOTELCEnrtRyQ/BA8mlCVIV+vpbEcqt9RVaxGEGsffpP77PXuC/iaFFPLQV2L9xZ6oP1RxR6Rg/MnwAJ3qNfee64sm+8LRvE7xKB/Fg1IGJehr0XId26FYpUHaC1RXiLmEups7491XG+LfIIk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792346533; c=relaxed/simple;
	bh=pSVtPL0sYGxtTV59w9Pqm7Nn1IzJHxqwOeJcCxlkycA=;
	h=Message-ID:In-Reply-To:References:From:Subject:To:Cc:Date; b=H9o8hnWNatMMJfamk0uqWhV52Y1x/6TNUHggrlc80V+lWpowaFAt9pn2tIo5PHsi//O0vZsE/bwCRiJAnKLMM2Q/5yDi0r1fssPEfRo7RtLl0y5coEyraxPpaXlE5f0HnGgIsXgkcXPrvvHDEQkOY/K5cU9SIbrvB3kFT+oC5TY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net; spf=pass smtp.mailfrom=gmx.net; dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b=jom01Y2m; arc=none smtp.client-ip=212.227.15.18
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmx.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b="jom01Y2m"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmx.net;
	s=s31663417; t=1792346521; x=1792951321; i=jan.koester@gmx.net;
	bh=UbyCGDawRYHsXc162u6tpnYmZ2iUMBn9TTkNoh1575U=;
	h=X-UI-Sender-Class:Message-ID:In-Reply-To:References:From:Subject:
	 To:Cc:Date:Content-Transfer-Encoding:cc:content-transfer-encoding:
	 content-type:date:from:message-id:mime-version:reply-to:subject:
	 to;
	b=jom01Y2mrzXwquBQZ7hRn+4WqSOEXoO7m/chSUrOKo5FWO3vBQLKFx0biACqj2XL
	 jHeZYMTbO8XMSUQaE52rBlnv2laA7H7IfOti2jlZAnecSwhFDjLuMW2KT6vPPqXRp
	 it5qJqs61mJ0qt7yyJCEad5oWCGz0hPUbpoyU3F3ScwVKbCLHGQEi/IkJmoEis3/r
	 yK6ALuGz0uK1k0LImNN38Ff9j0zUrv86nITidvV0L4snQKicWpQE8L02mqXELblZ8
	 NiRrha7bYI9VyfseYFQBR+yLOjVzqvbUqDPP94K+34sqRHG3WdmJQmrkbVZV04H9m
	 nnQB0LIQaJMUGXOT3A==
X-UI-Sender-Class: 724b4f7f-cbec-4199-ad4e-598c01a50d3a
Received: from client.hidden.invalid by mail.gmx.net (mrgmx004
 [212.227.17.190]) with ESMTPSA (Nemesis) id 1M72sP-1xFUWs2tx9-00HVXt; Sun, 18
 Oct 2026 20:02:01 +0200
Message-ID: <b80d3e04312e7286cccb37e66643bd1537b5d52d.1792346472.git.jan.koester@gmx.net>
In-Reply-To: <cover.1792346472.git.jan.koester@gmx.net>
References: <cover.1792346472.git.jan.koester@gmx.net>
From: Jan Koester <jan.koester@gmx.net>
Subject: [RFC PATCH 11/41] fscrypt: show the whole uid in the description of
 user key claims
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
Date: Sun, 18 Oct 2026 20:01:32 +0200
X-Provags-ID: V03:K1:l5JKVr3aKpWnK1BsZef/u10yK4ulYjF/sziwuNwartYVOWZimrG
 5ZZNaKnmUMR7HlvsAJlwZVtvunHF9Nc0z/FPPWShB+9H3VVNzGNOtHPHYhh28W4JV4WLthp
 ywP8HKqKZQfkTCCJh3QofPtAyyn41g4EUResTVJ9T9fBJ8ywYvN2bh81Oyzv8f2LbosqaTe
 HnJramMe+Z0DnUiDogtog==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:mmETAOHPftg=;0elC46bHCClTLZDZL90CPkQoH4p
 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
 p8Zb31KrnZNpaIoOHChTHs/Pz6M89aD2
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

The ".fscrypt" keys that account a master key to a user are described
as "<identifier>.uid.<uid>". For a UUID or GUID uid that printed -1;
use kuid_str() so /proc/keys shows who the claim belongs to. Lookups
compare the kuid itself and are not affected.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@gmx.net>
=2D--
 fs/crypto/keyring.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/crypto/keyring.c b/fs/crypto/keyring.c
index 76e28d1e00..080166267f 100644
=2D-- a/fs/crypto/keyring.c
+++ b/fs/crypto/keyring.c
@@ -178,7 +178,7 @@ static struct key_type key_type_fscrypt_user =3D {
 };
=20
 #define FSCRYPT_MK_USER_DESCRIPTION_SIZE	\
-	(2 * FSCRYPT_KEY_IDENTIFIER_SIZE + CONST_STRLEN(".uid.") + 10 + 1)
+	(2 * FSCRYPT_KEY_IDENTIFIER_SIZE + CONST_STRLEN(".uid.") + KID_STR_LEN)
=20
 /* Create ->s_master_keys if needed.  Synchronized by fscrypt_add_key_mut=
ex. */
 static int allocate_filesystem_keyring(struct super_block *sb)
@@ -338,13 +338,14 @@ static int add_master_key_user(struct fscrypt_master=
_key *mk)
 {
 	kuid_t uid =3D current_fsuid();
 	char description[FSCRYPT_MK_USER_DESCRIPTION_SIZE];
+	char uidbuf[KID_STR_LEN];
 	struct key *quota_key;
 	struct fscrypt_master_key_user *mk_user;
 	int err;
=20
-	snprintf(description, sizeof(description), "%*phN.uid.%u",
+	snprintf(description, sizeof(description), "%*phN.uid.%s",
 		 FSCRYPT_KEY_IDENTIFIER_SIZE, mk->mk_spec.u.identifier,
-		 __kuid_val(uid));
+		 kuid_str(uid, uidbuf));
 	quota_key =3D key_alloc(&key_type_fscrypt_user, description, uid,
 			      current_gid(), current_cred(),
 			      KEY_POS_SEARCH | KEY_USR_VIEW, 0, NULL);
=2D-=20
2.56.0

