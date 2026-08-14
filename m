Received: from mail-yw1-f175.google.com (mail-yw1-f175.google.com [209.85.128.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8A08E3A450F
	for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 22:25:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.175
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786746344; cv=none; b=pV/ToL9PBUeBetVzYQG8qM55vtJnziAKq5f3629zs6fdpEpKUKvIz1hwGk1NY31mmr7L+OLQJfaDdh5U63UhjQ3sBjVdMUemmwW7aeqZH1kCYuO17U5tvVaSIQWct4Vm2X76ZlOzE55iBDwruyCm3i073YWAhg1ZIfUMngKt9qg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786746344; c=relaxed/simple;
	bh=QpCg1coYctY6lqy/4VlceyICqqeUnz5voKnkE4JQaHU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=G1EBmBgMzE7GIGDteTKirr16bXGoSvEiwGfApB53gvGzWVvo2Ouz7kXn2jjr7fy30oTZ+bDDZMlM7YYmoGmY08uBMmDoG+C0OvaabUv/j5DbaQfrcP+0q37Ud83tkSRI6fLAOXnJB0Wu/k7B/zn2vQcZ5E7CkTOSeCMSjvwX2u8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com; spf=pass smtp.mailfrom=truenas.com; dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b=iu/+AY8N; arc=none smtp.client-ip=209.85.128.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=truenas.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b="iu/+AY8N"
Received: by mail-yw1-f175.google.com with SMTP id 00721157ae682-836f34a0ceaso27312717b3.1
        for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 15:25:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=truenas.com; s=google; t=1786746338; x=1787351138; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=jwB1C+RNhjAgt1UbZNR2QMeClPWif5hxjvqzBTXQXKY=;
        b=iu/+AY8NohAVQEnJn1FPgK6BoJ2H+FyBX+mlRJMoF1imnM53O+w13qdU+3oDRcA21J
         mxpKzVSkCSuU9xGUBsjza7QCsOCX+Nzkk7VOdMHbvPqbv4ai+w4Vl+nzQoG1s467kMo1
         WBpIF/2hJfMNDYurfNFnjwAAw3865QfJqs5Z4gvtKSdFS4oFFNmu8arLYgwVNzMiQggK
         zgLhzqGf7VJDsmqvClQf5zLg6z8nLNLYz+RFJ1WJd5h5T3Wudq+XbdTh5C38ajy0nX5N
         MI7SPtB82UIp+gJp3UgWCstxMQw+1EUmj+OPRizmo7AlNcvsLdzvQc3SESk8p4MTrDrY
         fLeg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786746338; x=1787351138;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=jwB1C+RNhjAgt1UbZNR2QMeClPWif5hxjvqzBTXQXKY=;
        b=JgKsxSooyXXJ7c7LFkxZQaKOR/GYF2kVVGwsaEweavbN8u3xO1BbFTCBNUeGVh7gIs
         YDDhyb/K6Lh0zA/oWPUlW5X9il14hjiys7uUzUxkLEooG49UxNZmvNI+PDHwJsJEbQFh
         OB9/7l9l+8M/cTQNONscsWlzT+S3qAxq6kGUK9sD4EH9DvKlBZLgzmKyJzHW6T9cFDu8
         oJrKpKCfkimE3RFPSHZYjcPWEXBbWq6GMQ2VP1rA8JIoq88C3DgodaRBvkwFgTjy457+
         5NvfeG6rADvuAuVFc/HrCnKi5ZPeDUMkqxQVujqGm+aa0DyD3KsAQAwmgyKBZnc4go+V
         KRfw==
X-Gm-Message-State: AOJu0YzmFtdS04U8176Jozj7jCLFSuG2OPEvBUCcjfKH4VzQaAOBIezo
	Nfqek1eQ8EwA5pVSaTtqXji58HKEvI2V2X/bfbPA0WYqPwtm+hoRPM2/2xNjMdUsHIAv81uReCI
	k5Tuo9r1D
X-Gm-Gg: AR+sD11hvFJ9XVGqjChzvbmKuTzan7UxuyJzg008/ogsPk4mnVBdHu7ovhoQjDMqtAX
	FPqMVCGgigvKVw5TgnQv9UZcMkVV9Ff9cysX/5lqKbUqpCPe2YxdCjUnv1HFU5hg3NFff/U8bZh
	0WGUp10GqsTBpipaI+sqLXNX7gRXB/2R9oyGPqFc00PNmq/oTd584NWgq1Z0p8GFhnx0bv8rJcJ
	0V0JBetBwHtsPEht/dcCKdXoI8f7SIexpZ9ezK+BRBy+VQeMiH0FeiFnVNoyvlWPtPOnWkaLEkW
	tTTwAjGrHrYorD0s9MSbMhxHFWHt+DQzG8/NJwGm6RxEK+pFcKx4kC9X3MkRtdUIXfCaeg/oUl3
	qfUgWVn9PnWC9G+IUu5mEltf8Ah/oa7+6IGpw+6MpHLU6/fQhsUTZKllMd9d+m9U0uUv2yjLvMo
	TeRJwHjKQWsoGBppS5G7Mm6+qCX4YmX7MAI0cPdd9qnew+u6pLbFgGa2ekW1GT
X-Received: by 2002:a05:690c:60c7:b0:7f0:38f7:6ca6 with SMTP id 00721157ae682-834840e734bmr74383837b3.5.1786746338166;
        Fri, 14 Aug 2026 15:25:38 -0700 (PDT)
Received: from hamza-PC ([124.29.197.38])
        by smtp.gmail.com with ESMTPSA id 00721157ae682-836c1777c5esm19859857b3.26.2026.08.14.15.25.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 14 Aug 2026 15:25:37 -0700 (PDT)
From: Ameer Hamza <ameer.hamza@truenas.com>
To: cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alexander.motin@truenas.com,
	caleb.stjohn@truenas.com,
	ameer.hamza@truenas.com
Subject: [PATCH v2 0/2] sunrpc: don't strip a uid's groups when the mountd group lookup fails
Date: Sat, 15 Aug 2026 03:19:51 +0500
Message-ID: <20260814221953.108837-1-ameer.hamza@truenas.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On a server running rpc.mountd with --manage-gids, a transient
name-service failure makes mountd answer the auth.unix.gid upcall
with a zero-group reply, which the kernel installs as a valid
positive entry.  Patch 1 records such replies as negative entries
on the classic /proc channel, so the credential keeps the groups
it already carries.  Patch 2 does the same for the netlink upcall,
which has an explicit NEGATIVE flag the parser does not propagate.

One observation from reviewing the netlink path: in steady-state
netlink-only operation, mountd currently receives no unix_gid
upcalls, because unix_gid_upcall() still gates request generation
on cache_listeners_exist(), which counts only classic-channel
writers, and netlink-mode mountd opens no /proc channels.  A
flagged reply reaches the parser today only via the 30-second
post-close grace window, a concurrent classic-channel writer, or
a direct SUNRPC_CMD_UNIX_GID_SET_REQS.  Patch 2 fixes the parser
semantics ahead of that; making upcall generation netlink-aware
needs a per-cache listener signal (mountd subscribes to the
notification group even without --manage-gids) and is left for a
separate, runtime-tested series.

Patch 1 was tested on a live 6.12 server over NFSv3 and v4.0-v4.2
with sec=sys and sec=krb5, and applies unmodified to every
maintained stable tree, 5.10.y through 7.1.y.  Patch 2 is build-
and static-checked (sparse, W=1) but not runtime-tested.

Changes since v1:
- split the netlink fix into its own patch with its own Fixes:
  tag, as requested by Chuck
- patch 1 is unchanged

v1: https://lore.kernel.org/linux-nfs/20260814172507.1474519-1-ameer.hamza@truenas.com/

Ameer Hamza (2):
  sunrpc: treat empty auth.unix.gid replies as negative entries
  sunrpc: honor the netlink unix_gid NEGATIVE flag

 net/sunrpc/svcauth_unix.c | 9 +++++++++
 1 file changed, 9 insertions(+)


base-commit: 46db3c8a1be96a354758b44b1d4fbb4b70d09a20
-- 
2.53.0

