Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552581;
	b=GeIROkDcIgHyBemf4Doo4dSr+Uz+jEVy6Qqf+y1r6ve6tAM73K54FFK57qO/owwBlGPK
	 vEO1xGP8QiTXpZv/VhUUKOgtD0iR3vYC2qiWnVb1pqYzaQMiL3CGGaUgoCerRw57Sme0J
	 RfPIDnjFczW8toK4plawpEFJtM6sB0C4q/0l8rbLt1Qp9pr9kZesbjMptox9leEVmITBR
	 OSux6cKFL+Mtr7WGaAnFy4tA2kYZTP97FpKAAosn1UNRNj6G+Jdj0uAOJ+lDjlq4TIeib
	 mDn1aH7+x/fduV1iov2mrF0UAH02Aj/Ito5BVkX08plmYDlfk2gfGU22C0XVB8PHqCw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552581;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=LSH0H2p+4hPwyxhykRR+OoOPuBJNPy27VM/n5UgWimw=;
	b=jblpVsFt+nyx437ORBUptQjSTqWKHsrNK9vgiwmskBx1iAa1IYmXKuG0dFgMpCFNd5iq
	 pRPWlsWgZUSI7toEfL6nBaciLEYhu2BeIlcs7A7wBtgVruV9l4WhUkeZWyZlq0z7iIllP
	 EGz4qjij/TVyJb8FvgvNEVOeCiemeLJf8D4fgrgaGgASqkiI4DYeLFO+Jz7p8/Z//3Cjb
	 kDP1u/zhDClZ7X9r2VlsIXlMPNjMozYlzgDYDhpXudV9dEUsFzIF4KMzFPnmUFo2/j7nE
	 QgOue2b+tGNm9z+h16c/e+1F6mAmlCWfOVtk1Ja/DoYB1CG6Oy6h3WX4AXISG0RLNQg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=aCM+Okv6;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3175F606BED5;
	Wed, 21 Oct 2026 03:16:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3175F606BED5
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=aCM+Okv6
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552579; bh=cPizOxWZGJDi5/QHy2w18Y9MZUJPB6xdHmqFawOY40c=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=aCM+Okv6LaS3A+GYWsvFYkea4+QW5+9Lm7IoFhmLKwgqXgBcpJT2i5MhMbA01UGlz
	 e3E3B3DjhhzaGtThZwtdw+UI6PKl/AeZbqZJQqcSRFwBGUkmg3Vr/p4FpSShhiH2PE
	 dWekEqjds1nA7tW/E1RopBjeAfnYzy/NVm5Kpcc53Pv97mkANHRkS8HNHa+KecbPLk
	 qqf7qWJ077gy+CQO1tKgE8xFzxJ3QLRCD6Ay23lfjO8ZtIlfpQUgxL321oH4xo3T4r
	 cbmwYaCPP0+MUUoFMeYpfUOa3kXrTbJDaKaXA3Ud2vcdmLJ7BhEKmfh2O44xmKgZjH
	 mxytheHKsaJfg==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id D745F8A0651;
	Wed, 21 Oct 2026 05:16:18 +0200 (CEST)
Message-ID: <3c65c1107a1f9e634b35f59566f6ed70f217c85e.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 17/41] quota: don't account UUID and GUID owners
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
Date: Wed, 21 Oct 2026 05:15:37 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

Quota files and the quotactl interface use 32 bit ids. dqget() would
hash and store a UUID or GUID owner as -1, so all of them would share
one dquot, written out as id 4294967295.

Treat such ids like quota being off for them: dqget() returns -ESRCH,
which its callers already handle by not charging the inode. An inode
given to such an owner stays charged to the previous one.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 fs/quota/dquot.c      |  3 +++
 include/linux/quota.h | 18 ++++++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/fs/quota/dquot.c b/fs/quota/dquot.c
index 1c78c695d0..62f333f824 100644
--- a/fs/quota/dquot.c
+++ b/fs/quota/dquot.c
@@ -954,6 +954,9 @@ struct dquot *dqget(struct super_block *sb, struct kqid qid)
 
 	if (!qid_has_mapping(sb->s_user_ns, qid))
 		return ERR_PTR(-EINVAL);
+	/* Quota files hold 32 bit ids: like quota off for UUIDs and GUIDs */
+	if (!qid_is_legacy(qid))
+		return ERR_PTR(-ESRCH);
 
         if (!sb_has_quota_active(sb, qid.type))
 		return ERR_PTR(-ESRCH);
diff --git a/include/linux/quota.h b/include/linux/quota.h
index 89a0d83dda..00685209fd 100644
--- a/include/linux/quota.h
+++ b/include/linux/quota.h
@@ -80,6 +80,24 @@ extern qid_t from_kqid(struct user_namespace *to, struct kqid qid);
 extern qid_t from_kqid_munged(struct user_namespace *to, struct kqid qid);
 extern bool qid_valid(struct kqid qid);
 
+/**
+ *	qid_is_legacy - Report if a kqid fits the 32 bit ids of quota files
+ *	@qid: The kernel internal quota identifier to test.
+ *
+ *	UUID and GUID owners don't, and are not subject to quotas.
+ */
+static inline bool qid_is_legacy(struct kqid qid)
+{
+	switch (qid.type) {
+	case USRQUOTA:
+		return uid_is_legacy(qid.uid);
+	case GRPQUOTA:
+		return gid_is_legacy(qid.gid);
+	default:
+		return true;
+	}
+}
+
 /**
  *	make_kqid - Map a user-namespace, type, qid tuple into a kqid.
  *	@from: User namespace that the qid is in
-- 
2.56.0

