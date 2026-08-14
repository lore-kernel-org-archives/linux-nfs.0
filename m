Received: from mail-yw1-f181.google.com (mail-yw1-f181.google.com [209.85.128.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0BA184908DA
	for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 17:26:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.181
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786728395; cv=none; b=Doe4KyWmoYClonk/WAFtlOz1K5NtMh7NSUn03BDmwKJJtMQoQ7a4oJdbrkxGAZ2LAc67rLkZ560+S2bgO2KIECl6gzvmLsLwSiX8uVVpprDdrDdZwpZwWcoYm/gjShuDkhqPtqaKAhCInOT1CB9IacX3uNM5A7nQMp0BObBAr0o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786728395; c=relaxed/simple;
	bh=Qu1HyqOGUSjznwJJfhi+VZle8XJpGlHvF5BD86xXBF8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=deeuXGRpBQoeSlTtPyZ0D2jka9xLQuNbA1HHM4MOVm5pDw5atRm+IwR4b2KURPUXQ7DalUjVyC5HXGcV/mOx/6egMvjw+TzQ/i0v+q7PVzzECSKlvXAVC9Xep+bGpIZa2fBY0b/LdXDuWm8j44sfprYP8u/CSOxYTSdTEVa2Kt0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com; spf=pass smtp.mailfrom=truenas.com; dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b=WDRDhO5f; arc=none smtp.client-ip=209.85.128.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=truenas.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b="WDRDhO5f"
Received: by mail-yw1-f181.google.com with SMTP id 00721157ae682-81ecf499af9so19340137b3.1
        for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 10:26:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=truenas.com; s=google; t=1786728392; x=1787333192; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=QhVVR7CPJPyXFN0ZneAP94GAaINXOiRBL560ZjbrBXs=;
        b=WDRDhO5fn2Ed1Sk4TadRlocRADRMu7P4kTVSS4BKhe+1fB8OY2HYoLrUoiEafaYgn5
         CsQMb9TpYvVDD8lS1D3vOBnuMONtZIkTvuINj6KL84+MP8mZho45+G46KXtOS5btNH8l
         BFTdGyA+PuWOjMkXTXlW2tvn6XmiZ1RUCLw6V8lraEN4vEq2N/d47zck6MDD3BWGjyEp
         FTG0px4uItzGLJ6mdOkwq5WVkN5ng4hZLb5TjDhFJqi5xxdh65K1uuTEVCNNIQSV3wDE
         mzivt1GcbumZX6vK5YIX6uCv2m1qk2CXBp/z8LfK3abX8PfAWk8xQbyeZFSNlxqv3tkC
         oaRQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786728392; x=1787333192;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=QhVVR7CPJPyXFN0ZneAP94GAaINXOiRBL560ZjbrBXs=;
        b=W4+0d4JIUGzqIJeFahWQ/RoPmciKq2IGhiSNzA9CzUx8kkzXsDGXwWsa64Y8VNaSF3
         e3SMrPmytNt+SVUD14GiCB/vHf+eBuOvou5aF67nE8DqmfApWqGB+gbCFoQHQoQIMkwL
         lT84eJVQNzDRbsJdOJ3bLfnENoW0RHRAalrbzvJn437RotXrGM+yjifUNJ2aErdJOrpu
         z8hHsK5YAHPLwVtoog6BvnsPuf8BFaPEpi67t63E2EAEnQB7C9E3eSSYTUOJ8s1bglGA
         TvAvUgueqUP/ehyQiQANA6pzPwutEjqPOlEdtlp6n+jx5rIIyztTDtco02jeGEdOMAXc
         AC5Q==
X-Gm-Message-State: AOJu0Yzdhelg4//VYTk8mdTftWPbPfU/H5NkkiXnM5KuvaAeKIEzHYp0
	vTfjnYfA3yzfPR8WC574uXzdCH5tfFNHlxf9BVljJQHVfPXJcU11pYvbdDuDVzjzAg==
X-Gm-Gg: AR+sD10XfQJeWTqc8THgJNx8nODWCZC7ZnOV76WmqihbuwJDO4c5i2GopKzlh3zF9F8
	51Fw1u0ioSsSx3EUTB36JhN2sppZ9HqjPo7W2JxZGxjjeAMdjdN9kCaAyLglZ7l+cTMXnplYYnL
	TkPkq82fi3lkX/Yt0llfoM+pluPTUh/+bef5CAQSf82uLlDJJMs67pIr4cjnIjh+J1l7vFLKrt0
	QYyV4fqCHj/zBeJpHmwn8oCRsH55FSVyeLlHsOPsKrsWkHvkk0ppZVqeUUbwggGR0KbFS18emaq
	wTPl837kNaaWE78oO8AA0Pz8ubuC5MhNZf+NNLqtKUKNzfiIpobkBuuxM4QrhfE76EReyHVHuQZ
	vY1FEYyXlm8b+x1ke6jHGgM4cGmH6BmIRwUU32FnhfcK472g/mLN5Fimqv1QbutYq2WcmMfu97m
	1Idv8WlgBHhR0mUtUlrCqwF/A7R7LTivm/cYKf6h5pte9FE5u/j3LxJBnEnCKG4fuQfyw/S8s=
X-Received: by 2002:a05:690e:1c0a:b0:66c:82ea:573d with SMTP id 956f58d0204a3-66c82ea5886mr1343630d50.47.1786728391485;
        Fri, 14 Aug 2026 10:26:31 -0700 (PDT)
Received: from hamza-PC ([124.29.197.38])
        by smtp.gmail.com with ESMTPSA id 956f58d0204a3-66c7934cf98sm1178663d50.16.2026.08.14.10.26.27
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 14 Aug 2026 10:26:30 -0700 (PDT)
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
Subject: [PATCH] sunrpc: treat empty auth.unix.gid replies as negative entries
Date: Fri, 14 Aug 2026 22:25:07 +0500
Message-ID: <20260814172507.1474519-1-ameer.hamza@truenas.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When rpc.mountd cannot resolve a uid (getpwuid() or getgrouplist()
failure, e.g. while winbind or sssd is briefly unreachable), it
answers the auth.unix.gid upcall with zero groups. unix_gid_parse()
installs that as a valid positive entry, and svcauth_unix_set_client()
then replaces the credential's group list with the empty one on
every request, RPCSEC_GSS included via svcauth_gss_set_client().
One failed lookup strips that uid of all supplementary groups on
every export for up to mountd's configured TTL (30 minutes by
default), long after the NSS backend has recovered.

mountd cannot send an empty list for a successful lookup, since
getgrouplist(3) always includes at least the user's primary group,
so a zero-group reply can only mean the lookup failed. Record it as
a negative entry: unix_gid_find() then returns -ENOENT and
svcauth_unix_set_client() keeps the groups the RPC credential
already carries. This is the fallback that
commit 3fc605a2aa38 ("[PATCH] knfsd: allow the server to provide a
gid list when using AUTH_UNIX authentication") promised when no
answer is available, and the same state try_to_negate_entry()
already creates when no listener holds the channel open.

Fixes: 3fc605a2aa38 ("[PATCH] knfsd: allow the server to provide a gid list when using AUTH_UNIX authentication")
Assisted-by: Claude:claude-fable-5
Signed-off-by: Ameer Hamza <ameer.hamza@truenas.com>
---
Reproducer (any server with rpc.mountd --manage-gids; 'alice' is a
member of group 'proj' *supplementary*, /srv/proj is root:proj 0750):

    runuser -u alice -- cat /mnt/proj/data          # ok
    # the reply mountd sends when getpwuid()/getgrouplist() fail:
    echo "$(id -u alice) $(( $(date +%s) + 600 )) 0" \
        > /proc/net/rpc/auth.unix.gid/channel
    runuser -u alice -- cat /mnt/proj/data          # EACCES until
                                                    # refresh/flush/expiry

Applies unmodified (fuzz 0) to every maintained stable tree, 5.10.y
through 7.1.y. Tested on a live 6.12-based server over NFSv3 and
v4.0-v4.2, with sec=sys and sec=krb5.

 net/sunrpc/svcauth_unix.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index aebd97e7f66c7..2f592ba54a366 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -540,6 +540,13 @@ static int unix_gid_parse(struct cache_detail *cd,
 	if (ugp) {
 		struct cache_head *ch;
 		ug.h.flags = 0;
+		/*
+		 * mountd sends at least the user's primary group on
+		 * success, so an empty list can only mean the lookup
+		 * failed. Keep the credential's own groups instead.
+		 */
+		if (gids == 0)
+			set_bit(CACHE_NEGATIVE, &ug.h.flags);
 		ug.h.expiry_time = expiry;
 		ch = sunrpc_cache_update(cd,
 					 &ug.h, &ugp->h,

base-commit: 46db3c8a1be96a354758b44b1d4fbb4b70d09a20
-- 
2.53.0

