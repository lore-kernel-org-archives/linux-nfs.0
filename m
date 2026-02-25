Received: from mail-pj1-f68.google.com (mail-pj1-f68.google.com [209.85.216.68])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B18362BE7D1
	for <linux-nfs@vger.kernel.org>; Wed, 25 Feb 2026 03:38:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.68
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771990741; cv=none; b=Z9AX4HK+ksapGfb2evz4XR0kzj1KM+Pg8qvvNb3YK9a1EHCdTq0y9f8pM8B+GTpD+TTGZgyt/2vhQv05kxrpKveh5upPlFV4yvDC/MnUCORODlkhgJkmfpsuldLdTkPEMJvQpZt1wmKsldxe+KTHm4v0oVS5JO1URCf9xWdIFxU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771990741; c=relaxed/simple;
	bh=Xmf0Usl2CbiEJ++dZC/dkjhOytdRgouJKZh4aFkNkks=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=poL6m96aoD2PhdkXl3MLpaJAxDCPDkFwdkfG/XOnCoDQiCIaKg5D+9nNEww1Kp6pRQ33R1khYMbMoFCYi7s+yHG4dbxbbAN+9Uk3mxxGjGtMy79wKz3Fgf2BtkwdYZfrZJI3tFHDc26p7cDJONYBtiHt7+H7Nb5VhHY6jSokB/I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Phz/w6/f; arc=none smtp.client-ip=209.85.216.68
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Phz/w6/f"
Received: by mail-pj1-f68.google.com with SMTP id 98e67ed59e1d1-358e3cc5e7eso752589a91.0
        for <linux-nfs@vger.kernel.org>; Tue, 24 Feb 2026 19:38:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1771990739; x=1772595539; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=1x6mfY87rLHQQy6u5hEHImplDq7CY6og6rQC/w4gcIk=;
        b=Phz/w6/fN+I9dmIs3HRecR/af3PTONFhFAAvysU7IkpEEBQ9pIZbrdlVZhpL58INf2
         tA6oj+W7Ybn3bhnOsdzzRUahaMYumOHIq+zTyl/Gx3nLI+iJLPme054nZBLUDpnpj2or
         MTryVNfs9fG4pH8mtRHd7SsS49/uV6Akp+gSzSKRJDV353Fw3rJiCT+jpG66Anf/rwD8
         iCjI56waJvF1zDHy1zrl4RFFkp0j2hk7iylERdR0JJCB6pXHnILTI3oOD8uxuyTRNWeq
         NnNU40VaFgXqi+66s7IB8PvzR96fLY0dJ0URziSBYadnLQTJsZXbEJsck9+V8KiH+hUV
         y2BA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1771990739; x=1772595539;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=1x6mfY87rLHQQy6u5hEHImplDq7CY6og6rQC/w4gcIk=;
        b=eVrDRA6cPTsTchz32qrlBb2HOUpTnZsH11Ht/DFaIaRvpUD4RWBbdLmBaUycMLu7z4
         s+RhpVJbwkeXIuStyFj1h1wuFViUd/90KcqeS5OBm629QVuBC2IjCJOL96giAUPbr2m+
         773gICxLhyUxFcSYh7+Rj8DdNVCBVd54Ekmcpo+xddmEVBE7GrED3j73w5mY46MI7RyM
         h7Z3l1TD5gIWa1g8e80TPMGpnWmXGpZMcsmdMfayabhc3rwrdyVZZNXivP+kk2Op0/TH
         v7rFomlwwfd5PjC0wu8WlsehqGD0v44hWl4Mhdun6j/3iYhnHIN9ucNGd8kbb4ooQQ06
         J9Ow==
X-Forwarded-Encrypted: i=1; AJvYcCWa/GilfYqNhSgdIxzI78Nmy+8iciEOzqTm341TJ5FyhfxtbKdqTl2i0W6bLknlmIRdT4oF1LBONSc=@vger.kernel.org
X-Gm-Message-State: AOJu0Yxcxq/AzrNvsXhkgWWZ+8TwvTVd5H9mh6iLKsD2QPt7x9DI2MHn
	oPyAmziiwBAwjXRhbgBy8CO8FRp9JVVjTJ7yNxmzQ1PSXfwaKM/vs3YE
X-Gm-Gg: ATEYQzy45g5kywrRx+ROd+vjfIevyIx73S9IEpjDWhTGt53gIin4w4/WZ37wyBzss24
	1iu/XM7xryuIFG/8NZMt0jmNBPCAZyc3huVcAQxBuN2EB3jtL9kE2i+TuX3H0i6XmZzTgcviyrj
	pLWIvKhrxtQW0bEBFsW/RGd6+BjdrmRBS2JXWoBhMOjqS+N5BN6SWCmqjOh+jOtWLtT9fQQ8Mdj
	h1HabTomXjVoL5RsRLU1e10RRlAYAkp9lj9zdPFU0WDYCrGM9fFlQs80F3s6iu3TMyARn5pYjKx
	UpX5P3go5A07FDYbLpn9ZiO2TFcB8/y+sU6a+AwendYiAsJD9d0MHoMuH6uwMyeOCfz/Qlx7Zna
	fpcm9GpSzOirEHrXLxuKANBr6QgB3HHD1cFJv0RP9/QHlxWa9MB4YecpFpI52c32u5RFNI+qLa6
	6ZTUidjKxwUu2cH9Ik2L8S4Wa5MkZyWUkDDoI1GJVfyx8dFxZ7kQYQFV21S+KvuRDt68kbXQ==
X-Received: by 2002:a17:90b:56cb:b0:353:4f7:cc3a with SMTP id 98e67ed59e1d1-358ae6a20c3mr10834421a91.0.1771990739052;
        Tue, 24 Feb 2026 19:38:59 -0800 (PST)
Received: from localhost.localdomain ([138.199.21.245])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-359018838b2sm1161746a91.5.2026.02.24.19.38.55
        (version=TLS1_3 cipher=TLS_CHACHA20_POLY1305_SHA256 bits=256/256);
        Tue, 24 Feb 2026 19:38:58 -0800 (PST)
From: Eric-Terminal <ericterminal@gmail.com>
To: Dominique Martinet <asmadeus@codewreck.org>,
	Eric Van Hensbergen <ericvh@kernel.org>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"David S . Miller" <davem@davemloft.net>,
	Jakub Kicinski <kuba@kernel.org>
Cc: v9fs@lists.linux.dev,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Nikolay Aleksandrov <razor@blackwall.org>,
	bridge@lists.linux.dev,
	Anna Schumaker <anna@kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org,
	Yufan Chen <ericterminal@gmail.com>
Subject: [PATCH v2 3/4] net: bridge: replace deprecated simple_strtoul with kstrtoul
Date: Wed, 25 Feb 2026 11:38:39 +0800
Message-ID: <20260225033840.33000-4-ericterminal@gmail.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260225033840.33000-1-ericterminal@gmail.com>
References: <20260225010853.15916-1-ericterminal@gmail.com>
 <20260225033840.33000-1-ericterminal@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Developer-Signature: v=1; a=openpgp-sha256; l=1158; i=ericterminal@gmail.com; h=from:subject; bh=c73ZZJhJVbdBF0f9KkqjyvY2nE5EvyIEm2O6pWmXnD4=; b=owGbwMvMwCXWM/dCzeS3H+sZT6slMWTOy5PnqLqsF81puzI5ayHffb3zHYcZDL1UHARPrTOS+ L/mqIZHRykLgxgXg6yYIsvd//vm5nrdmnOd+3AuzBxWJpAhDFycAjAR55eMDHuY6jkmG7ptFBOa 4PKkJd6hVPdHv8EUc5nrVxctfxvR8I/hv1doohTPKjst3sM5214eqV8idXiXa8/OijYjjbnujbs /8wIA
X-Developer-Key: i=ericterminal@gmail.com; a=openpgp; fpr=DDFFBE9D6D4ADA9CD70BC36D8C9DD07C93EDF17F
Content-Transfer-Encoding: 8bit

From: Yufan Chen <ericterminal@gmail.com>

Replace simple_strtoul() in brport_store() with kstrtoul() so
conversion failures and range errors are returned as standard errno.

This keeps parsing strict and removes deprecated helper usage.

Signed-off-by: Yufan Chen <ericterminal@gmail.com>
---
 net/bridge/br_sysfs_if.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 1f57c36a7..cdecc7d12 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -318,7 +318,6 @@ static ssize_t brport_store(struct kobject *kobj,
 	struct net_bridge_port *p = kobj_to_brport(kobj);
 	ssize_t ret = -EINVAL;
 	unsigned long val;
-	char *endp;
 
 	if (!ns_capable(dev_net(p->dev)->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
@@ -339,8 +338,8 @@ static ssize_t brport_store(struct kobject *kobj,
 		spin_unlock_bh(&p->br->lock);
 		kfree(buf_copy);
 	} else if (brport_attr->store) {
-		val = simple_strtoul(buf, &endp, 0);
-		if (endp == buf)
+		ret = kstrtoul(buf, 0, &val);
+		if (ret)
 			goto out_unlock;
 		spin_lock_bh(&p->br->lock);
 		ret = brport_attr->store(p, val);
-- 
2.47.3

