Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=173.212.254.19
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792552663;
	b=zUl95No3DHynTKURJsUWv6k0yIEW2Iyw6r98x3LQEXUCnK15OJO8jOLOvh2MslY0dqGw
	 GRkP/Ls8fteAb4siaIVXhvQZtQlGuYCkvdJKU02InHUAO+yXQbSyTqYK8OElApxODf58C
	 RJD7Iik6uWpXaIkBYjAO1uZC2vSKtGAKTrmlRgsYXIlNT6I9JP2/0RnDw2AgyiDhqxhyP
	 z9wb8f2o46pvXl9n0YbbnBu2b0nyqSFOngGSsXrge0D7/lmz+icnLQ08XJutvorTqjjy3
	 nyvDSt5LjuWBFnRPgC2Azm0mnp5v92iZRdCDmD4/tqTjk+biKNi46JrO4bd7vtsTgCg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792552663;
	h=DMARC-Filter:DKIM-Signature:Received:Message-ID:In-Reply-To:
	 References:From:Subject:To:Cc:Date;
	bh=y32/ROgNC7BgAXo+nbH2255cc57LBlEzLSh+9uilSGk=;
	b=qTQrc29KB5QFubcBhsJB9TSj8FHx8kEnWu/IWJIjmbSDlPOC70Zzj+BCbOK3tzI5gzQK
	 4Do+4BhApRSseRjqaCDp3AtAKAQmHAwzxyuqrvuI+wJnlpwlzhLE2EJaETHHJjW2DLQJj
	 2EedrJYR3WLXaALC0ivGSuXfU0Ai8APbTluPDCqQQ+cYvvAqgJiGYpgynpQQISeT8c+51
	 hAj1cYb9Ax/G4cvQVVzroWl8w4v8SvKJ6D36zR7Nk+eaWqsx/HBDiVtrbfLS7/tvinKB4
	 EilNmBY02R69nBs6dQtStXRKVCbQRZzYPx5QLhlec4NXtCemGaJbHexZG92ETtu+ClQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=tuxist.de;
	spf=fail smtp.mailfrom=tuxist.de;
	dkim=pass header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=mpgsQu8z;
	arc=none smtp.remote-ip=173.212.254.19
Received: from groupware.tuxist.de (groupware.tuxist.de [173.212.254.19])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1D2FC606A324;
	Wed, 21 Oct 2026 03:17:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1D2FC606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=tuxist.de
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=tuxist.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=tuxist.de header.i=@tuxist.de header.a=rsa-sha256 header.s=201705 header.b=mpgsQu8z
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=tuxist.de; s=201705;
	t=1792552661; bh=mzSPlQGBuMO7y2s2jl+wM34YIMvxDwXoEWlZHf1iIwY=;
	h=In-Reply-To:References:From:Subject:To:Cc:Date:From;
	b=mpgsQu8zZ8116Z0hmW2qTEd1s/Mc78aoSlh8KJAfXQj18ol4SKv81K7GVHvppXSzJ
	 9FtfQMYu8BWozwLggMww43+IvU3oExktKDVmu5vhQoTKbH44zmgEATAkvkedhDKSx4
	 ECrWx62uwOhPCRgybGgJJ1YQKbA9I5iDQLfb3sTS1W2XWhE848crYOFdDKdl09cjke
	 B5U50HIobLhumcuc0etOKdkObl9atBr7BFo+7JR8ITut6JQNkPvdMPg5r5TKJ+Yjr2
	 9PZoGTqcBggIOohJEa6HCIoQ5lLMHyBs2jcHRnX8RfWoMYuQmcklFVq4YBmIDzkJTg
	 famVp94H35eTA==
Received: from [10.1.1.106] (unknown [10.1.2.1])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by groupware.tuxist.de (Postfix) with ESMTPSA id C04EC8A0938;
	Wed, 21 Oct 2026 05:17:40 +0200 (CEST)
Message-ID: <59c60ce7d56e4198e148dde225c10313df019359.1792552161.git.jan.koester@tuxist.de>
In-Reply-To: <cover.1792552161.git.jan.koester@tuxist.de>
References: <cover.1792552161.git.jan.koester@tuxist.de>
From: Jan Koester <jan.koester@tuxist.de>
Subject: [RFC PATCH v2 41/41] Documentation: uid_r: describe SMB and NFSv4
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
Date: Wed, 21 Oct 2026 05:16:01 +0200
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list

ksmbd's login extension and SIDs for UUID and GUID users, NFSv4 owner
strings, and what AUTH_SYS and the SMB3 POSIX extensions can't carry.

Assisted-by: Claude:claude-opus-5-5

Signed-off-by: Jan Koester <jan.koester@tuxist.de>
---
 Documentation/userspace-api/uid_r.rst | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/Documentation/userspace-api/uid_r.rst b/Documentation/userspace-api/uid_r.rst
index c080485455..d16d4317f5 100644
--- a/Documentation/userspace-api/uid_r.rst
+++ b/Documentation/userspace-api/uid_r.rst
@@ -159,11 +159,28 @@ RPCSEC_GSS upcalls
 	user as ``__kernel_uid_r_t``, then the usual fields. The binary (v0)
 	upcall can't carry such users and fails with ``EACCES``.
 
+SMB (ksmbd)
+	The login response extension (``struct ksmbd_login_response_ext``)
+	carries the user's ids as ``__kernel_uid_r_t`` with
+	``KSMBD_LOGIN_EXT_ID_R`` and the supplementary groups as
+	``__kernel_gid_r_t`` with ``KSMBD_LOGIN_EXT_GROUPS_R``. Such users and
+	groups appear in security descriptors as
+	``S-1-22-<kind>-w0-w1-w2-w3``: kind 3 and 4 for a UUID user and group,
+	5 and 6 for a GUID user and group, w0 to w3 the 16 bytes of the id as
+	big endian words.
+
+NFSv4
+	Owners and ACL principals that are UUIDs or GUIDs travel as their text
+	form, on the server and the client, with or without idmapd.
+
 Limitations
 ===========
 
 - Quotas don't account UUID and GUID owners; quota files hold 32 bit ids.
 - RPCSEC_GSS needs a gssd that knows ``uid_r=`` for UUID and GUID users.
+- NFS with AUTH_SYS sends a 32 bit uid: a UUID or GUID user on a client
+  reaches the server as the overflow id.
+- The SMB3 POSIX extensions' fixed size SID fields show the overflow id.
 - UUID and GUID users can't create unprivileged ublk devices.
 - Audit filter rules, SafeSetID policies and IMA policy rules name
   classic ids only.
-- 
2.56.0

