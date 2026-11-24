Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.208.71
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795543571;
	b=T6+H4pjb9YcKnd9Fs/Whr0TsnEaBehflGoP7zdoO3MRamb+3bT9ZP7xAhX451y/mXNNz
	 gntfxHSOHYvDgFQFCw9YI/yAubsgJPJvQErklKX9EqQ7yTc18FD0ndroQqBV0oQL6cENd
	 Ll/NoHrmQlgPjOAGrfseP7/TmtimSzmVVzk0Oj7rbem6IOkiOHr77vDBfA0QbYRIPRoxH
	 dEXzDM5oIvE4lCSSOHAKuofaiyvLQ3Jqx6wgyqKOV+B858rKgPhSbQbG6V2kbiB838SsN
	 UjZu038T98x5IcpPvsxiOH3uNgaXku7c1SnQ9+1XWnmlz7ynGVtUiQQ/by2JzMK+2EQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795543571;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:Mime-Version:
	 X-Mailer:Message-ID:Subject:From:To:Cc:Content-Type;
	bh=JtWovyNmMEcEzaHmdcNjvNynpMl7fq3rNMmfiHfsy5w=;
	b=PZKS7KmvKueLKqODN9iQCMDxJ3k+bM0tRR8fNJX0UJLOaaWBPZiLKKQjBXRqIvJtgTni
	 W0lkskNGzwx/EDeTKjjd/QHZsLdggzYuiZCKFrSe/o5upOLbj4ROM5cYGyGR9k8W+R4Y/
	 gpuTo3tZQ3j8UAhkKvqfnZPhiebAPw7x9JWi2uNGPHnnaxi2KzHpkG2AvbSqOTu0zH5wE
	 EBFyo19DlUTfVY0ltMcCxl+Kcu+bFixtyaijFGUGGF16Y0+EiqGbuGtnbf1omUQVBKKPm
	 mDkYhT0wjZOBbQQs7FUtRct2ezcsAPbTt0R/2lpWazkwvFkbzVcNuz6+gaySQoLnyWw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=nXaqfG1+;
	arc=none smtp.remote-ip=209.85.208.71
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 68859606A33C
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 18:06:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 68859606A33C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=nXaqfG1+
Received: by mail-ed1-f71.google.com with SMTP id 4fb4d7f45d1cf-6babdfe3810so2397742a12.2
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 10:06:09 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1795543568; x=1796148368; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:mime-version:date:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=JtWovyNmMEcEzaHmdcNjvNynpMl7fq3rNMmfiHfsy5w=;
        b=nXaqfG1+dt65qE1Tlzfy81EohiNzboaEQZO0RCga5LfQlCZXYRZRYdhzIHlIuneozN
         7EMz6NGadJxRq/+vZXuiMocuq9Zz1TvGbwL79MVYXbMR4rEPbmsA/jJdWl7Id6h7RaEk
         KxT1fE5BjVE10i0aAsJiwr4wt1rfNr2KVqgabPkUINFh8PTypTDGyjYjL292d65u7QGO
         LcD4B4JqFVDEL31yZ8zMUYpHIkoHgVrdMpzRL7KmRtNUrdRZfdvaRfPhFEzGcNr50s73
         p7gQzMQhAX7IqpctVfwn7zCQi1s/YMrPtQNsFaQW7CmtUgMS9IFSajn0G0gc0adIt/Nr
         9PEg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795543568; x=1796148368;
        h=content-type:cc:to:from:subject:message-id:mime-version:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=JtWovyNmMEcEzaHmdcNjvNynpMl7fq3rNMmfiHfsy5w=;
        b=eKm36jJ3003ks97NdKSalMii1YjD2me+BiVe//dUuX5lOSTTThwSWkRzn+urNOAdCm
         CCkpkknugnguXuPWlWmG/hi8FRXHdpsSAivqZDdizl3kd7DDh65pbB1M45KNOXrUpRwE
         adjTWGx35PtK+m8RTyfpfA08c5PioDrYEKsaOyHM98s4eaWApuqvQWZ/bCtR03nCPmKM
         bcmZvrmJlrG9pvowmoSVLiHOADyeIcUodgkMwzoZG1PjjwjWaI9jG62NktaGgZaFcyPM
         d5d7hTWA6jJtV7RN0uZWXOCCX8cMt8jYSL7mmIAf/eETvwSxc8M0YaIRBXmmGoVEYk7W
         F36A==
X-Forwarded-Encrypted: i=1; AL+hErGr3L1NxYNwWO0aNFFl0u1geJRlWP8ugzdaaLSV82qbGZxfXyj0i0t6ZWtJ+TpNyDCW9rCOEciHzao=@vger.kernel.org
X-Gm-Message-State: APuU4Z9TM3MH6xYbWHAQ/3N+JDaeKibEuNywI0Q6DdeX0nAaWg7nbhw5
	CTaQJ0vbYAJMzsk6gCe8Wn2HkyQw+tV0w4PanlO4dKzjRQ4RCvRvhSXpQmoTOOUi+9HCV+8W5w=
	=
X-Received: from edgc18.prod.google.com ([2002:a05:6402:a612:b0:6b7:7f4d:1b93])
 (user=dmnk job=prod-delivery.src-stubby-dispatcher) by 2002:a05:6402:90b:b0:6bb:6a9:b1b7
 with SMTP id 4fb4d7f45d1cf-6bb06a9ba28mr1745996a12.6.1795543567469; Tue, 24
 Nov 2026 10:06:07 -0800 (PST)
Date: Tue, 24 Nov 2026 18:06:04 +0000
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
X-Mailer: git-send-email 2.56.1.663.g77904e546d
Message-ID: <20261124180606.73719-1-dmnk@google.com>
Subject: [PATCH v2 0/2] nfsd: enforce search permission on directory
 delegations without breaking stat()
From: Dominik Maier <dmnk@google.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
	Tom Talpey <tom@talpey.com>, linux-nfs@vger.kernel.org, dmnk+artist@google.com
Content-Type: text/plain; charset="UTF-8"

Enforce NFSD_MAY_EXEC (and limit NFSD_MAY_OWNER_OVERRIDE to S_IFREG) when
acquiring directory delegations, preceded by returning GDD4_UNAVAIL on
nfsd_file_acquire_dir() failure so Linux NFS clients issuing
PUTFH + GET_DIR_DELEGATION + GETATTR do not fail stat() with EACCES on
directories lacking read or search permission.

Changes in v2:
- Add patch 1/2 returning NFS4_OK with GDD4_UNAVAIL when
  nfsd_file_acquire_dir() fails (Chuck Lever).
- Add Jeff Layton's Reviewed-by on patch 2/2, keep the single root
  Fixes: 544a0ee152f0 tag, and drop the commit-body tool boilerplate.
- v1: https://lore.kernel.org/linux-nfs/20261119192318.2689409-1-dmnk@google.com/

Patch 2/2 was found with AI-assisted code review and reproduced against
an unmodified kernel in QEMU; the v2 series is based on nfsd-testing.

Dominik Maier (2):
  nfsd: return GDD4_UNAVAIL when nfsd_file_acquire_dir() fails
  nfsd: require NFSD_MAY_EXEC when acquiring directory delegations

 fs/nfsd/filecache.c | 10 ++++++----
 fs/nfsd/nfs4proc.c  |  6 ++++--
 2 files changed, 10 insertions(+), 6 deletions(-)

-- 
2.56.1.831.g720f3f5937-goog

