Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.70
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795543573;
	b=494G0jyuk5ZCtIrtLsRuedJnZnKV6l1cC8IfOJtiGHq+qW7rV9r8dwcyrpmR41b6KysY
	 rD10yt78ifskohBQ/Ivrk0jGjMfjsnHhFVwR2QkmP8gV8vFI4jhTPcwJJvX5EZY7RZSLQ
	 ipZAeIq52gz+dlrsoDZzT6yWy68gPGXsQKG9AmHkTLniz1lJR1WDVowEHLGnQmdnZ8Adt
	 LJcJIGLlyhU2aqdJCrQ3nzua9lLbMR1s8tI5kBgwX9zbVBD/anhkQil1FlR0PQX6eEjs5
	 IgJ3jcbyas3+e67U1wJH8OMcNBYgD5gKGDzBcqZx9306ywcV7IMPyIH7ebDrWSKqsOg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795543573;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:In-Reply-To:
	 Mime-Version:References:X-Mailer:Message-ID:Subject:From:To:Cc:
	 Content-Type;
	bh=H19idL2DCe8Pkair6dWjNm7yrERdkXdr6YWJZRKroKs=;
	b=fENdrMh1sTNtVE3FBBLDLvQPLRog3TopKjyJP5nA+FH1pKayjbRh+b6zctytxq8Aszbv
	 7M6+ld+bkIBkzQY31pbicbxVpiM7FhVVHhOHTYly11wK+gUbbyv01C0mRl9PHtb9GqozN
	 SzoHdTkYMhU79JZw/vSMbGWCaHsOwiBFXZhWWERinrsORg9U5ABSLoptbn9O1PwgvQ+3H
	 a0cOGx3G/k+Qx+d5xslP86DixHk5Rpkdzuk/zGDP5jUjp7TYJAjJXKCemln4PBJQhYZ2K
	 E9J7pHjVf5T6dbT/pPgLlbtUr0Y+0yoT9IbBFT06J9oMQryL1SkEsF8qVJ6pM4MOkFg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b="Q//ztl1C";
	arc=none smtp.remote-ip=209.85.128.70
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EE58C606A684
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 18:06:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EE58C606A684
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=Q//ztl1C
Received: by mail-wm1-f70.google.com with SMTP id 5b1f17b1804b1-4a70b42bab0so46941525e9.1
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 10:06:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1795543570; x=1796148370; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=H19idL2DCe8Pkair6dWjNm7yrERdkXdr6YWJZRKroKs=;
        b=Q//ztl1C7ovibynw4PG4KNE41q3wR0hlFkshlzvA+OMbDljLF6hICE4Dacde9yXgS9
         Hw6vgqq2kOXlEaaN3+Iyb+obgDPiExBvZfvYOmOw+wxhjgB4PD3tmmarKN4/JE07eiqZ
         QzFW/muZCmQsCZtWEDEz7Ik5H4EJpWDlx0OkKt7pCRYLjkWLlWzBqk9YVP0CxzNEC6/u
         qH/hti89akpYepktWyqz4wSUsNv3DmuUSZ3Vov4XNieK9hbFHVlCoUzZ0dbuuHIkMNCW
         FMPJZv8eIbYqBSKhIy7Y+UjuJnzGdye4yo9bijGL7vZCY4zW8nF4JwW/BjpXf3WX/1mo
         es2w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795543570; x=1796148370;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=H19idL2DCe8Pkair6dWjNm7yrERdkXdr6YWJZRKroKs=;
        b=M/Nf4Vr5aHHqVBtb7UZdOd3hyI+dVRHy3xtWBr0EwTwRnK3DuAo9usuFEMnU1w+JwG
         VaJUF6bPgKrjb8HHTM7pQD4C2IZB7yja8wkICZ5BIYCumcHjAYVGbc188Hk7nay5uySY
         pdSR/4F9jLFbBOtEm8IdDYmlBcFIAy36JTJ5404+TuK0w8vH+2PFDAeXUZ7j8NS/Tw1m
         Y8c/iybGW4PSRxQkDwDfmLJry1Rbpis18zjXiXe/F5U1SQ0dtH0wkMfizYRkwYclg8kI
         2wC/nJ910UMf51ilgbMegtldsoXUCqBPtgXAqvwby/h/ysR5XnWTWL3hcDSAH1FfPepp
         5lnw==
X-Forwarded-Encrypted: i=1; AL+hErES8bCavQ7ZNtpX002mw4htLx2ofcIuE9PZGLYXmD9YImoC7/40gHdJ6KYOvMEQbBJ+mqpa9bofwOk=@vger.kernel.org
X-Gm-Message-State: APuU4Z85skc/pY0/pVpDzyGshBW2VjktVdXNPEy6IXj+p9wWASHK8Kny
	d9n2nvFTgvz3s//T51zi4OhpIE6GliOpClr2Em3Yt/eyJnGDRltVBtSNP7NJhp+xuts5KNf0WA=
	=
X-Received: from wmpo40.prod.google.com ([2002:a05:600c:33a8:b0:4bb:76bb:3497])
 (user=dmnk job=prod-delivery.src-stubby-dispatcher) by 2002:a05:600c:37c6:b0:4a1:88df:8a2a
 with SMTP id 5b1f17b1804b1-4bb88812a84mr316108945e9.13.1795543569858; Tue, 24
 Nov 2026 10:06:09 -0800 (PST)
Date: Tue, 24 Nov 2026 18:06:06 +0000
In-Reply-To: <20261124180606.73719-1-dmnk@google.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
References: <20261124180606.73719-1-dmnk@google.com>
X-Mailer: git-send-email 2.56.1.663.g77904e546d
Message-ID: <20261124180606.73719-3-dmnk@google.com>
Subject: [PATCH v2 2/2] nfsd: require NFSD_MAY_EXEC when acquiring directory delegations
From: Dominik Maier <dmnk@google.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
	Tom Talpey <tom@talpey.com>, linux-nfs@vger.kernel.org, dmnk+artist@google.com
Content-Type: text/plain; charset="UTF-8"

nfsd_file_acquire_dir() opens a directory for nfsd4_get_dir_delegation()
with NFSD_MAY_READ | NFSD_MAY_64BIT_COOKIE, omitting NFSD_MAY_EXEC, and
nfsd_file_do_acquire() unconditionally sets NFSD_MAY_OWNER_OVERRIDE even
for S_IFDIR (unlike nfsd_open(), which limits it to S_IFREG).

On a directory with read permission but no search permission (such as
mode 0744 for a non-owner, or mode 0400 / ACL-denied search for the
owner), an NFSv4.1 client can still acquire a directory delegation with
NOTIFY4_ADD_ENTRY and FATTR4_WORD0_FILEHANDLE and receive valid child
filehandles in CB_NOTIFY callbacks when entries are created, despite
LOOKUP returning NFS4ERR_ACCESS.

Require NFSD_MAY_EXEC in nfsd_file_acquire_dir() and restrict
NFSD_MAY_OWNER_OVERRIDE in nfsd_file_do_acquire() to S_IFREG, matching
nfsd_open().

Fixes: 544a0ee152f0 ("nfsd: allow filecache to hold S_IFDIR files")
Cc: stable@vger.kernel.org
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Dominik Maier <dmnk@google.com>
---
 fs/nfsd/filecache.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 162d07eb5be4..a703d376a52f 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -1197,13 +1197,14 @@ nfsd_file_do_acquire(struct svc_rqst *rqstp, struct net *net,
 	__be32 status;
 	int ret;
 
+	if (type == S_IFREG)
+		may_flags |= NFSD_MAY_OWNER_OVERRIDE;
 retry:
 	if (rqstp)
-		status = fh_verify(rqstp, fhp, type,
-				   may_flags|NFSD_MAY_OWNER_OVERRIDE);
+		status = fh_verify(rqstp, fhp, type, may_flags);
 	else
 		status = fh_verify_local(net, cred, client, fhp, type,
-					 may_flags|NFSD_MAY_OWNER_OVERRIDE);
+					 may_flags);
 
 	if (status != nfs_ok)
 		return status;
@@ -1475,7 +1476,8 @@ nfsd_file_acquire_dir(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		      struct nfsd_file **pnf)
 {
 	return nfsd_file_do_acquire(rqstp, SVC_NET(rqstp), NULL, NULL, fhp,
-				    NFSD_MAY_READ|NFSD_MAY_64BIT_COOKIE,
+				    NFSD_MAY_READ | NFSD_MAY_EXEC |
+				    NFSD_MAY_64BIT_COOKIE,
 				    NULL, S_IFDIR, false, pnf);
 }
 
-- 
2.56.1.831.g720f3f5937-goog

