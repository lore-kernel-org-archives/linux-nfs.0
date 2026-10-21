Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552551;
	b=Wt7e9/VOVnwY35nTTw8QzvzWBp8uYl3/QDwAbgvCsyZMEk2i1Mzrcs3UYOxTJ7PA3fPy
	 VO/ce5ZvQVbsm8VSUtG5c5slua+Lyrv8qA2ZWdLMDaunGO4/S7NwxWFypmt1zjiPg7mx0
	 /GKHsqdig27O7L8nLHw9ISs+25kEo+3+KrxoRXUCNyP4jakHph2Txzq2+6VqdVXxXvXGT
	 zZWt9flGjLT4oIZO38TQ0zy3cAmDX7bwHKp/r+j4osLjy9sU9IWHW186rwMd7rn3BvxJb
	 fV/hML7+ZKCI9p5F61EJBsIsq9cGOVXK4YiusAuL+os/lAydL9+NF3FyxRLDCmY2Jhw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552551;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=PVhQJ7324CMbIfhXtNzYL5dBLF6NS0/WJG6p16uxHQw=;
	b=eIc9dD3BbN+Um6fs5Z1arj6U+Du2g2X3LenQnf2PjDtnh8KFu+E/D1adqGk0u/ePj9uE
	 R0UPsssXQcL2hkhKKnd7/mhz5OcOv2Mjly87jWWYFoJwt6lNlhFnsy82AaEyl41MM9iDd
	 ipwWJz4QA+iLIfhDDbGxzWHCVlVWQCE+SwvCjz8/I+ZeZ9az3A7xAzP8IhP8y2mRo1s0O
	 boB8dxbDTR0yba7hIOJ6LVjS3WqmAVG4OwR9oUKElZAV81j6EA2Ex7F2v0s1VQ91Jgse9
	 Gj2FbnfBpG+LhLDcsdhmLUyuA8pUb14T+yeYYYp/kxHcBBlIWbcjgcfHEsTV2Usp3HA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=FGXjLsBU;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E3936606A329;
	Wed, 21 Oct 2026 03:15:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E3936606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=FGXjLsBU
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552548; bh=q7T/4Y2o1qGWLISuafRJIl+4GZmfBU1aB4YS1XRxh40=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=FGXjLsBUf17Ic0V9FROUlyTLuWgh0GJgISMTwITx2rAEXesSTMeL6oRrj+5kLlP90
	 /jVvFb521dvqX+iuFI4qg80jV7ObE4G1tKPWzoI6lPOZOGSqDX9B3wKydRtRk9mi7v
	 hFacffaEVj7o9qnOeyH19yj3dZ8EZy8L+UgaK1wUZuaR5ip/aIKAo2XF/LHOU/WDLu
	 KWREwqRXaEaZt60RnkCXnvByCFv7WDq277xKWlYIwZfkRTvj6Xxc8PeC1kBBdO5st4
	 Nzoz5DajwBwmR5LMXQY/9MNZGnUVD9Gz5ZU/P+kFhxB8/ML2nLR3nosptLwRQg2CrG
	 yeQoD6hhJF/Zg==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id EFAE88A090C;
	Wed, 21 Oct 2026 05:15:47 +0200 (CEST)
Message-ID: <89a8d25ee5266ebab437aed8d86cc5e41bad3965.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 08/41] smb: client: use __kuid_val() for the unix SIDs
 of the caller
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
Date: Wed, 21 Oct 2026 05:15:28 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

The S-1-5-88-1-<uid> and S-1-5-88-2-<gid> SIDs sent with a create
request take the raw kernel ids from kuid_t.val, which is gone now that
the ids can be UUIDs and GUIDs. Use __kuid_val()/__kgid_val(), the same
value for classic ids and -1 for the others, which have no unix SID.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/smb/client/cifsacl.c | 2 +-
 fs/smb/client/smb2pdu.c | 7 ++++---
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/smb/client/cifsacl.c b/fs/smb/client/cifsacl.c
index c5e47a835f..78ed25b1f7 100644
--- a/fs/smb/client/cifsacl.c
+++ b/fs/smb/client/cifsacl.c
@@ -1086,7 +1086,7 @@ unsigned int setup_special_user_owner_ACE(struct smb_ace *pntace)
 
 	pntace->sid.sub_auth[0] = sid_unix_NFS_users.sub_auth[0];
 	pntace->sid.sub_auth[1] = sid_unix_NFS_users.sub_auth[1];
-	pntace->sid.sub_auth[2] = cpu_to_le32(current_fsgid().val);
+	pntace->sid.sub_auth[2] = cpu_to_le32(__kgid_val(current_fsgid()));
 
 	/* size = 1 + 1 + 2 + 4 + 1 + 1 + 6 + (psid->num_subauth*4) */
 	pntace->size = cpu_to_le16(ace_size);
diff --git a/fs/smb/client/smb2pdu.c b/fs/smb/client/smb2pdu.c
index cfe3c4b4ab..941ca8a3d6 100644
--- a/fs/smb/client/smb2pdu.c
+++ b/fs/smb/client/smb2pdu.c
@@ -2731,7 +2731,7 @@ static void setup_owner_group_sids(char *buf)
 	sids->owner.Authority[5] = 5;
 	sids->owner.SubAuthorities[0] = cpu_to_le32(88);
 	sids->owner.SubAuthorities[1] = cpu_to_le32(1);
-	sids->owner.SubAuthorities[2] = cpu_to_le32(current_fsuid().val);
+	sids->owner.SubAuthorities[2] = cpu_to_le32(__kuid_val(current_fsuid()));
 
 	/* Populate the group ownership fields S-1-5-88-2 */
 	sids->group.Revision = 1;
@@ -2739,9 +2739,10 @@ static void setup_owner_group_sids(char *buf)
 	sids->group.Authority[5] = 5;
 	sids->group.SubAuthorities[0] = cpu_to_le32(88);
 	sids->group.SubAuthorities[1] = cpu_to_le32(2);
-	sids->group.SubAuthorities[2] = cpu_to_le32(current_fsgid().val);
+	sids->group.SubAuthorities[2] = cpu_to_le32(__kgid_val(current_fsgid()));
 
-	cifs_dbg(FYI, "owner S-1-5-88-1-%d, group S-1-5-88-2-%d\n", current_fsuid().val, current_fsgid().val);
+	cifs_dbg(FYI, "owner S-1-5-88-1-%d, group S-1-5-88-2-%d\n",
+		 __kuid_val(current_fsuid()), __kgid_val(current_fsgid()));
 }
 
 /* See MS-SMB2 2.2.13.2.2 and MS-DTYP 2.4.6 */
-- 
2.56.0

