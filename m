Received: from mail-pl1-f202.google.com (mail-pl1-f202.google.com [209.85.214.202])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 39FE727456
	for <linux-nfs@vger.kernel.org>; Sat, 24 Jan 2026 04:19:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.202
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769228347; cv=none; b=fJGOtvRhGWIES8SSSeXgEYvNVIJeZHAeTiT1q8ube6HfZN+ZJLD9EWrqAEEuD8vvbdVnO/kmqpunPT31Fpi6uXVWc2QlyYfv67BWmCo4M3Nr5ZRZOOc/P0JSjmyQEP7bjmdrmLtg+LxBCEpVuZqToN3s2sYdBFcgxewcZl2nJq4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769228347; c=relaxed/simple;
	bh=yxfjcoc4JA9lgY5730BQHFwnttUMAlcl/UidIDeiHmI=;
	h=Date:Mime-Version:Message-ID:Subject:From:To:Cc:Content-Type; b=WC+srhR4gyLkcJsp9CyX8poSggl+QI0UUryuAVI13ymO4yb6CCuF23ziSk03XCE1J1e0UbE5ptoisKmpBOvy+fvf9qvAIBLt/5qMhJgVuEK8yvDuljzjYKybf7UzI0F5Wa688Bpowjgv/mJ0aXEnp4Il2xwjwO1n850+m3HpB2w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--kuniyu.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=BcaH+gQA; arc=none smtp.client-ip=209.85.214.202
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--kuniyu.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BcaH+gQA"
Received: by mail-pl1-f202.google.com with SMTP id d9443c01a7336-29f1f69eec6so25871915ad.1
        for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2026 20:19:06 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20230601; t=1769228345; x=1769833145; darn=vger.kernel.org;
        h=cc:to:from:subject:message-id:mime-version:date:from:to:cc:subject
         :date:message-id:reply-to;
        bh=5GpcW+PRQI54iUePg3EXjx9l64VA0lqKoBFnRDChYIM=;
        b=BcaH+gQA2+y6rxgurXlJi4Y2WoH4aq4r6Ko1hBTd4GbB4g86dkn7AAmJDqYEJuVKQG
         aA8GU5xz9luJO4DPIdK4miGjpNLsOogTOqfekr3i0P/10iP+v2fcs/zBsv19je5LSaNu
         JlPBGSH3rLKvXoiK2aCxl14XUe9DUYV8x8+yWTPTjPGczGDwXW+lyB1xyCXW+JJdeYz9
         yWp7x4IA5fk0BFfV5BJ0DHeEa2m7FYKDOxpW1+YQ+6HWyMgvnWLkGFx8Ef0sCaM+rTMh
         BaQ9Pgc9fDWCgNufvdwhj2CLcH34HWzszKShOOxmv9sFe6dM0H+E2Pq9tx0Sn2sxuNKk
         shJA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1769228345; x=1769833145;
        h=cc:to:from:subject:message-id:mime-version:date:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=5GpcW+PRQI54iUePg3EXjx9l64VA0lqKoBFnRDChYIM=;
        b=CkLWKBqShb8zcDvrMjMy394LjYne1nzMQT/4fe9+cnGuMb8chuc2xNEbrppGmk82Wb
         CmxgljykcTNPhmA2yvy6aFPXweiE7xFzGv22gN7uWlzRDRbXqUYcO1+4HU/bIqcNOwHP
         24ZWnaNlhzFmc/cvch4+xtZlCFiiOGKCiPLaCGj9jmdVsUkG5Yu9TzlQRLFQlx5AhH64
         VnWleDrVelavAAI6eEb4pRsEn6x0yYFkEWVZWp/AqjA6XBwkyghHdeba+peUic/J4CZp
         qmi1kap7R8iMd/Vl2s8fJwmvmhuXxckuomR8/meGnaRybhY313MQwQDEowNBk0krdXHZ
         IY1Q==
X-Forwarded-Encrypted: i=1; AJvYcCU6BS9TwM+ZJRyK9pCElY0AyHlE8GA6xl9MWbV34VC7ew8FsnWDF5AoUm0j1KIk4s1XXaaw9PnOQOQ=@vger.kernel.org
X-Gm-Message-State: AOJu0YxGv7DvshqDD8lhYRCdm5ekmTutUlalushTk0dBKsGX+F75K5xB
	BioyHeWD6FXcuBrJ4magURMEsvDAJbrfGzRFJ6rPoCY1TN2eXra/da+zVxoNlHqkbqM0Q/YODRm
	VmRJUHQ==
X-Received: from plmm3.prod.google.com ([2002:a17:902:c443:b0:269:7c36:eeb9])
 (user=kuniyu job=prod-delivery.src-stubby-dispatcher) by 2002:a17:903:3583:b0:2a0:8f6f:1a12
 with SMTP id d9443c01a7336-2a7fe56e92dmr46231795ad.17.1769228345568; Fri, 23
 Jan 2026 20:19:05 -0800 (PST)
Date: Sat, 24 Jan 2026 04:18:39 +0000
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
X-Mailer: git-send-email 2.52.0.457.g6b5491de43-goog
Message-ID: <20260124041902.548904-1-kuniyu@google.com>
Subject: [PATCH v1 0/2] nfsd: Fix cred refcount leak.
From: Kuniyuki Iwashima <kuniyu@google.com>
To: Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
	Tom Talpey <tom@talpey.com>, Lorenzo Bianconi <lorenzo@kernel.org>, 
	Kuniyuki Iwashima <kuniyu@google.com>, Kuniyuki Iwashima <kuni1840@gmail.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

get_current_cred() is misused in nfsd_nl_listener_set_doit()
and nfsd_nl_threads_set_doit(), leaking the cred refcount.

Patch 1 & 2 fixes the leak in each function.


Kuniyuki Iwashima (2):
  nfsd: Fix cred ref leak in nfsd_nl_threads_set_doit().
  nfsd: Fix cred ref leak in nfsd_nl_listener_set_doit().

 fs/nfsd/nfsctl.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

-- 
2.52.0.457.g6b5491de43-goog

