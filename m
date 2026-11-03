Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.180
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793729660;
	b=x9xmfFj+nHXR9fLtRrFRAe3AHodySLCDvqo0/KCKFhZNSDDx3vtR1o0rHtJ0T+zIViC+
	 I1YFboFm6MzExYg/dFu+uFXimXyx5P4acSCZsPQg0WvMb+efJzDOprtO2BaWUGW8s58Zz
	 OqrXepef+Dysu/ZOTsB2Ug6IZSINwqbKNmv8tPUzk4kMj9hWB8an0H9EtfIRjf/G7iAU/
	 rMoPRTDvx39yLg4hmuCRD2Vq2vFW5OXg7282BDVWGqOM7uLIBc8m5BIZgEl8sYjij0gwN
	 NKWn+t4Jc7uT8gbS37XGB0yaqXSU8uvrmC1ZgOps8OK7v+kblFw0GjcsmwWfWrmIryA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793729660;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-Id:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=OqWiK66+ITYgEweXXpu9oPRXdnmQupnf0R3lUGvBlJc=;
	b=zVbyQNjTtwSYGxeN4cCDpcET8ck5LnF4/AT/HaL27HUtDKK8Qf6CSFSAaoxJKU0rdj8c
	 /bND4G/f23aLIO63Pwfo0ClCRR+ZbWKRLls4/8QLh6jVnKzS5cQbCtz/3t2+CPzmsjiwV
	 mbuRYykJQnvNjrDgViYUnhOVtljpdDqfr9pf1p/Yo06IherXu3/rMCvfbCB7lgl1EMfVD
	 xZjHMNZLARhFJAGD3DONmEVgj1Ct7ulkRQeToRswOdKpL4kP7mmRvJcdCMZ+ftqnG/C7I
	 pQhXjfheJwErNj+5hma0Tbrt+JgXj+Dv+f46BWRbW4rupMCCMRNMDh3YRaWtTEfqjpA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b="bNRyP3U/";
	arc=none smtp.remote-ip=74.125.82.180
Received: from mail-dy1-f180.google.com (mail-dy1-f180.google.com [74.125.82.180])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5AE1D606A326
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 18:14:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5AE1D606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=bNRyP3U/
Received: by mail-dy1-f180.google.com with SMTP id 5a478bee46e88-36bd3dd31a6so108636eec.2
        for <linux-nfs@vger.kernel.org>; Tue, 03 Nov 2026 10:14:20 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793729659; x=1794334459; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=OqWiK66+ITYgEweXXpu9oPRXdnmQupnf0R3lUGvBlJc=;
        b=bNRyP3U/CnE4DU3IS4KQPH9SCFHqw3ogyoj/xzEhUsdCCMtQdFDUiHslJnzgezPCnA
         Jbk0hcOozBvYsPlgQaPaBHQZ0Av4UIZt0mJTnvS++/ZUxjCSrxLCU2ZG+XS0FxnCRbiE
         vDw/anv23miCdy+FHc8LMez/AC0wKMWMxPEgabI7BfaDFNqiS7DKwacy/eJXwEn7+jeR
         rtf9bxr6Y+DBFVfhhM0XTtcV42080oi/35G9AiLnopCLVkcYxVgqq6U3cbJ3xOYX0tQ8
         svjgr7Bhr88FLMfTNxq/naf2qgerU73ObSVko39M6LoSzEljKWjdicPHhslBERS1i6V5
         njQw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793729659; x=1794334459;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=OqWiK66+ITYgEweXXpu9oPRXdnmQupnf0R3lUGvBlJc=;
        b=c3oWQDgUrPh/QPcfg5nISjDW8J+X2zAA7WOTNg3XFRSI1DvBHhhtHyFGPtaI2mz5x/
         LJCl0cz1dhXjSCD7nwKqdCXxq9dPqQVFJWMaPu2k4k5Iom8sRqNu1OAIq86gUOYXM5Jc
         7ssLr0ob+NX6EltDUYt2V9SCI63Do+QnCoPjJZF2rMQMF5a5qa7H8W3jJcyw2FM5cFSc
         E8OuFiWoewMaWfYavthkvRIfOW4stEanl5muhFkT18Vj9OmbJAUd5DQC0/+ECMynyImL
         x2EAlOGIW0XTdgVxZ/7G1opJ63w8WWJMNDqjd64ImuXRUgECWk03KJD/cMRbA5GokjkF
         VhJA==
X-Forwarded-Encrypted: i=1; AKwUvByxeeFvwpbC1UnCC1hVGWdTCzqPpJsbgh2x7u81q1azCMeghQasoR31hhU5HZ7KF+CIUhBhDWsWKmM=@vger.kernel.org
X-Gm-Message-State: APuU4Z+RH4yG9QlqK1JsBShvxIocF7NWSKf8BNZDV35Ut4HkTH1X+bFd
	wT1OJh6u64C7YYbEwtBZV+BGa6PcmckR/gm0cE/BfpaegIKJrvXBtHsn
X-Gm-Gg: AYBFou2wpEQzEcp4i8yeeEoxeoE0Km6yLMZRqupK1Ubgdh7ua/42YX7fpbCK1uvGYf3
	2dC09wUGDkfQoignvPQeOq4W0cMPUZGgmwdks4VO45LCcQVgdKbgi82Uj+luW4QzAM1KFjpfrkx
	2bc2AAFr6jkju29yIa45ylLnkiCYX+fHlTgcHKK1A4PxRBBCqR7ElQuptyXinBA9c9tY157EnBk
	Gy+5OYRwxEzLXRzR5+hmE0+tUvzG9eYLsfZIu//J6rCx7IrsXoPTUgOne+MH5/yQV6DiHG++8jH
	DLLcmrDUgDZAPeE4VKsSkdrJyJrYnJEuoASKeo9E/bD/s3u4Yz56KLn0h9XnSrxlQaK9w0Maqep
	YuroHq+l6Grx/uZu7loVDrXwD6xAHw335udPHN8NlSB6mknUEIoOrwxc1jDFafgjrMX2kzIURkl
	VuitDbUH09D6yNIeIgZ2QZcW4LHpRvIoIz3Kr+k9C2/OX6j3LwicCBDhhm3sroaZAxlNskjGh4O
	R+90xw7YFMHXMyDMC3QkYEKGfgi7dXi+CBwjHQB/YBFsKRe8zQjL6qM2sgct3wtRjdrO/rZbV3O
	1FdJrNqTT44UBx8XntEqIOtS8vY9x8lWTxaTizVhwA==
X-Received: by 2002:a05:7022:eb46:10b0:14b:edb2:c3bc with SMTP id a92af1059eb24-1ac4fd01362mr32675227c88.0.1793729659320;
        Tue, 03 Nov 2026 10:14:19 -0800 (PST)
Received: from CRASHEDROM.localdomain ([142.249.36.161])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-36a428af1dfsm51929768eec.7.2026.11.03.10.14.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Nov 2026 10:14:18 -0800 (PST)
From: Chengyu Liu <lui2012qwq@gmail.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: cel@kernel.org,
	jlayton@kernel.org,
	linux-nfs@vger.kernel.org,
	Chengyu Liu <lui2012qwq@gmail.com>,
	stable@vger.kernel.org
Subject: [PATCH] nfs_common: release decoded ACL on nfsacl_decode() error
Date: Wed,  4 Nov 2026 02:14:10 +0800
Message-Id: <20261103181410.1601083-1-lui2012qwq@gmail.com>
X-Mailer: git-send-email 2.25.1
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsacl_decode() is used by the NFSv3 client to decode GETACL replies.
xdr_nfsace_decode() allocates desc->acl with posix_acl_alloc() before
validating the entry contents, and the out: path of xdr_xcode_array2()
only frees its temporary element buffer.  If decoding fails partway
(e.g. an entry with an invalid id), nfsacl_decode() returns the error
without releasing nfsacl_desc.acl, leaking an up-to-
NFS_ACL_MAX_ENTRIES acl (about 8KB, a kmalloc-16K slot) per failed
reply.

A malicious or compromised NFSv3 server can repeat this for every
client GETACL (getfacl, getxattr system.posix_acl_access - also issued
periodically by backup/scanner agents), slowly leaking client kernel
memory.

Release the acl on the error path; posix_acl_release() is NULL-safe.

Found by static analysis.

Cc: stable@vger.kernel.org
Signed-off-by: Chengyu Liu <lui2012qwq@gmail.com>
---
 fs/nfs_common/nfsacl.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
index e2eaac14fd..e7ad47e2ca 100644
--- a/fs/nfs_common/nfsacl.c
+++ b/fs/nfs_common/nfsacl.c
@@ -353,8 +353,10 @@ int nfsacl_decode(struct xdr_buf *buf, unsigned int base, unsigned int *aclcnt,
 		return -EINVAL;
 	nfsacl_desc.desc.array_maxlen = entries;
 	err = xdr_decode_array2(buf, base + 4, &nfsacl_desc.desc);
-	if (err)
+	if (err) {
+		posix_acl_release(nfsacl_desc.acl);
 		return err;
+	}
 	if (pacl) {
 		if (entries != nfsacl_desc.desc.array_len ||
 		    posix_acl_from_nfsacl(nfsacl_desc.acl) != 0) {
-- 
2.25.1

