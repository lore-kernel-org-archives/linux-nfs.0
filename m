Received: from mout.gmx.net (mout.gmx.net [212.227.15.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 394524AA024;
	Sun, 18 Oct 2026 18:01:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.15.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792346524; cv=none; b=N3XC6qjKanIm5d32IKg1LRnTtWF2Tz2u0zdia1MD/DpJdjGDcaSu0ZOyw+l4YCZ3Gfkyi+UxWLtYXqyWXv3kjFPd2Df/qoQqAuYAOIGHkAsPrbvSZJBUhtIZkqMYfzinr3kjOVPMNHqXhDzBH+6CKIEJjlvO/cgbZf+HF3pN7F8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792346524; c=relaxed/simple;
	bh=OepXgNZXyxk6HXxSljZZ6Znh3tbQS19aZAVKPqM4VY4=;
	h=Message-ID:In-Reply-To:References:From:Subject:To:Cc:Date; b=izq9JcVM2toldLxfAdMFSJrTQsvTQsAKOo79m4r/IYjoIIPrWLW2USf6EBcacLteJeNBtoLpNFzlz0FpcGDjCoFZjJm99AjcLwxlQIxFW3o5bdalPtAh+GrQyaTwCTxbGp7T9VOe9eLxCV7FROBIyOZ9i656bhE2e5WlFjEMDYE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net; spf=pass smtp.mailfrom=gmx.net; dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b=iVJBJti6; arc=none smtp.client-ip=212.227.15.18
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmx.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b="iVJBJti6"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmx.net;
	s=s31663417; t=1792346512; x=1792951312; i=jan.koester@gmx.net;
	bh=+LVxrwS65M5K6b4cJwN1JyXAH+h1cW2cTUGBvIccYp8=;
	h=X-UI-Sender-Class:Message-ID:In-Reply-To:References:From:Subject:
	 To:Cc:Date:Content-Transfer-Encoding:cc:content-transfer-encoding:
	 content-type:date:from:message-id:mime-version:reply-to:subject:
	 to;
	b=iVJBJti6dJXqWvKsNXH4Vpoulbpac2LaYjqe69NDWKVBgprYpYzkqGezOtHlSbAC
	 ybuG3Iu85xn7JIUMgWm8bVLRrwTCadGusfjFQcWc4m5M9GOJw3+N/NGQs6WQ5EDeA
	 goeMOVPUSq8Tuj02aT5+/emnZBGhrsqR6r4aaTyR5nUDIuGnRfdFbbAq/pSDJrLkd
	 rYmUKGl70HBMgnk6s8axhBx0yyqMgFqdiXqvhN3DjoUi8jzCGgt/nwGfXUmikX3T8
	 ZNvZ5JQ57w/GIRUYA/pCn7WptascE5N998rB3qSuFVKr8eDnryCy16mCoyHYkEOls
	 SPuIG3AiNOR6X4wxsA==
X-UI-Sender-Class: 724b4f7f-cbec-4199-ad4e-598c01a50d3a
Received: from client.hidden.invalid by mail.gmx.net (mrgmx004
 [212.227.17.190]) with ESMTPSA (Nemesis) id 1MiacH-1weEtz0iKF-00oMO9; Sun, 18
 Oct 2026 20:01:52 +0200
Message-ID: <616048deb3cdc9a66a68d134d1391f477a43f0b7.1792346472.git.jan.koester@gmx.net>
In-Reply-To: <cover.1792346472.git.jan.koester@gmx.net>
References: <cover.1792346472.git.jan.koester@gmx.net>
From: Jan Koester <jan.koester@gmx.net>
Subject: [RFC PATCH 08/41] smb: client: use __kuid_val() for the unix SIDs of
 the caller
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
Date: Sun, 18 Oct 2026 20:01:29 +0200
X-Provags-ID: V03:K1:Iao8b2p97EB9NBKSr91a6IVQX8kjVGkT7cNLK6Td6uu3ctaOORu
 gVK7h5iu5ZamRRTJdxvfOh/XIP6vgfoF/qsA9p/eUyhlVVI8Mjwhlq7rpxqdHdK/mVEDIFO
 FgTIrnivheb+s65SqWUofyU79kThYonuaEh1M5oWVh1Vfct1cOTbuZ3hSFdjIuQB0uJQVt3
 +5MybHnLXMGFmfYZd4k+g==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:GTmLhBFJ7L8=;sExaXSchzIQzXQF3W9M0Edgw5yc
 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
 s57xaOPLbPY=
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

The S-1-5-88-1-<uid> and S-1-5-88-2-<gid> SIDs sent with a create
request take the raw kernel ids from kuid_t.val, which is gone now that
the ids can be UUIDs and GUIDs. Use __kuid_val()/__kgid_val(), the same
value for classic ids and -1 for the others, which have no unix SID.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@gmx.net>
=2D--
 fs/smb/client/cifsacl.c | 2 +-
 fs/smb/client/smb2pdu.c | 7 ++++---
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/smb/client/cifsacl.c b/fs/smb/client/cifsacl.c
index c5e47a835f..78ed25b1f7 100644
=2D-- a/fs/smb/client/cifsacl.c
+++ b/fs/smb/client/cifsacl.c
@@ -1086,7 +1086,7 @@ unsigned int setup_special_user_owner_ACE(struct smb=
_ace *pntace)
=20
 	pntace->sid.sub_auth[0] =3D sid_unix_NFS_users.sub_auth[0];
 	pntace->sid.sub_auth[1] =3D sid_unix_NFS_users.sub_auth[1];
-	pntace->sid.sub_auth[2] =3D cpu_to_le32(current_fsgid().val);
+	pntace->sid.sub_auth[2] =3D cpu_to_le32(__kgid_val(current_fsgid()));
=20
 	/* size =3D 1 + 1 + 2 + 4 + 1 + 1 + 6 + (psid->num_subauth*4) */
 	pntace->size =3D cpu_to_le16(ace_size);
diff --git a/fs/smb/client/smb2pdu.c b/fs/smb/client/smb2pdu.c
index cfe3c4b4ab..941ca8a3d6 100644
=2D-- a/fs/smb/client/smb2pdu.c
+++ b/fs/smb/client/smb2pdu.c
@@ -2731,7 +2731,7 @@ static void setup_owner_group_sids(char *buf)
 	sids->owner.Authority[5] =3D 5;
 	sids->owner.SubAuthorities[0] =3D cpu_to_le32(88);
 	sids->owner.SubAuthorities[1] =3D cpu_to_le32(1);
-	sids->owner.SubAuthorities[2] =3D cpu_to_le32(current_fsuid().val);
+	sids->owner.SubAuthorities[2] =3D cpu_to_le32(__kuid_val(current_fsuid()=
));
=20
 	/* Populate the group ownership fields S-1-5-88-2 */
 	sids->group.Revision =3D 1;
@@ -2739,9 +2739,10 @@ static void setup_owner_group_sids(char *buf)
 	sids->group.Authority[5] =3D 5;
 	sids->group.SubAuthorities[0] =3D cpu_to_le32(88);
 	sids->group.SubAuthorities[1] =3D cpu_to_le32(2);
-	sids->group.SubAuthorities[2] =3D cpu_to_le32(current_fsgid().val);
+	sids->group.SubAuthorities[2] =3D cpu_to_le32(__kgid_val(current_fsgid()=
));
=20
-	cifs_dbg(FYI, "owner S-1-5-88-1-%d, group S-1-5-88-2-%d\n", current_fsui=
d().val, current_fsgid().val);
+	cifs_dbg(FYI, "owner S-1-5-88-1-%d, group S-1-5-88-2-%d\n",
+		 __kuid_val(current_fsuid()), __kgid_val(current_fsgid()));
 }
=20
 /* See MS-SMB2 2.2.13.2.2 and MS-DTYP 2.4.6 */
=2D-=20
2.56.0

