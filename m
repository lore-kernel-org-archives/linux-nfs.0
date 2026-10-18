Received: from mout.gmx.net (mout.gmx.net [212.227.15.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7A61F3A6EEE;
	Sun, 18 Oct 2026 18:01:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.15.19
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792346499; cv=none; b=TBBwskWNCbQQDoXIdL2IX6i3g/S9uhbQs4GhQb7aGBorl7C+SSDbj/T768MjeL6UGDrD4hagkovyeyrArErrmrRAgN8Czgf6fMotRzL2Q/20MG56vdCu5xQbHBARAiW8MCMNJ7eqosrzBJ4reMWhgp0RkKYdD7O47K/ecdOC1BU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792346499; c=relaxed/simple;
	bh=igDPB54ohkA/iCGPz5QHHAI/cGPj6A5SAFTyNAnDRpE=;
	h=Message-ID:In-Reply-To:References:From:Subject:To:Cc:Date; b=mHwCG1dD5cGOUiy0sY9pfLnYxFviv2ec3nbdMrCCFEIVh8zDlf9+gW2FFFh+XHdokoenZS+nt/bpxk5DHKbo568r4EvMVxHqmA+hmM6YbpGMIfZSxw7MVoLuSl6p7EjDr3Z+Cl44aVHOB9jRNAA3gvz/Fq7rdKnkvPC3XnUBFrc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net; spf=pass smtp.mailfrom=gmx.net; dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b=Z8A8KpGl; arc=none smtp.client-ip=212.227.15.19
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmx.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmx.net header.i=jan.koester@gmx.net header.b="Z8A8KpGl"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmx.net;
	s=s31663417; t=1792346495; x=1792951295; i=jan.koester@gmx.net;
	bh=evA8GgCA3NQFkHXDQ7MeNdC+6mXl1ook8LjtjQ/lxm8=;
	h=X-UI-Sender-Class:Message-ID:In-Reply-To:References:From:Subject:
	 To:Cc:Date:Content-Transfer-Encoding:cc:content-transfer-encoding:
	 content-type:date:from:message-id:mime-version:reply-to:subject:
	 to;
	b=Z8A8KpGletgjVwrJfsHKy3hKq5Pk3JQ2QLcluY94O8JY5jQZ5WV2Lhv6m7ySbkSR
	 eBX59NeFBNFvQgQix2wVZpB5g6F3YnSAnUgCRSh/2ap81ePHZrL8i1eNlYQ0g2oS1
	 Hf7ongbcSmsJRyNAGeGsXhxeMz+W5w5ofLeVh1EwisV3+5GT+sbsMpOUEOeTGaCav
	 BtgPyhBghvotDykPazB9/wZSSK4mjGoX261l8iAtn6JpKFdp2T6z+d3HyDkz1csUk
	 ZeVu8ql3s4LvOpSNDx2X4TnCAsj+Vyipn96nm+XEDfkRzcFMLpOoKPYSsXyn+DffF
	 e4UUaFFGLCxDUTIpUQ==
X-UI-Sender-Class: 724b4f7f-cbec-4199-ad4e-598c01a50d3a
Received: from client.hidden.invalid by mail.gmx.net (mrgmx004
 [212.227.17.190]) with ESMTPSA (Nemesis) id 1N1wq3-1wcf2c0gkT-00tMmo; Sun, 18
 Oct 2026 20:01:35 +0200
Message-ID: <900dcae782cd38981235a9b80fdf72a03e7966c8.1792346472.git.jan.koester@gmx.net>
In-Reply-To: <cover.1792346472.git.jan.koester@gmx.net>
References: <cover.1792346472.git.jan.koester@gmx.net>
From: Jan Koester <jan.koester@gmx.net>
Subject: [RFC PATCH 03/41] uidgid: add uid_is_legacy() and gid_is_legacy()
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
Date: Sun, 18 Oct 2026 20:01:24 +0200
X-Provags-ID: V03:K1:ut5J5TE6c0eCoSrs8Otn0Uu9bFSWqFfe3IkqFS+2hCyzDsSR3Fm
 Xl5cGvB15sCJDcprXV+lLSJoD/MdhVmMJDdRTCEUsC/BYVBpT9Ldw8sl0WKD42gqBYIQiYz
 Mc4JYnRfyiyGpEaf1sZD/mdn3D70ZjfizABXGYIKF2ilOvtDvLSJvczeZhYeyOAkff56fe+
 s84aCdGdp6D7q7vZ7ZMRQ==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:NDmdPdIb2eg=;qqhwh5vSeNBOxkoylCQcsR0GxJY
 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
 SYAwByncX8H2Vl+m1DU9Wsu5qyaO8=
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>

User and group ids are about to become able to hold a UUID or a GUID
besides a classic 32 bit id. Add the predicates code that can only keep
a classic id (in 32 bits of a buffer, for instance) tests with, so it
can be converted before the types change. For now every id is a classic
one.

No functional change.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@gmx.net>
=2D--
 include/linux/uidgid.h | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/include/linux/uidgid.h b/include/linux/uidgid.h
index 2dc767e08f..182c682458 100644
=2D-- a/include/linux/uidgid.h
+++ b/include/linux/uidgid.h
@@ -22,6 +22,20 @@ struct uid_gid_map;
 #define KUIDT_INIT(value) (kuid_t){ value }
 #define KGIDT_INIT(value) (kgid_t){ value }
=20
+/*
+ * Whether an id is a classic 32 bit id. All of them are for now; code th=
at
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
=2D-=20
2.56.0

