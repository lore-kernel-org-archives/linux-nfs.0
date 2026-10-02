Received: from mail-qv2-f12.google.com (mail-qv2-f12.google.com [74.125.230.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8EF294B7A22
	for <linux-nfs@vger.kernel.org>; Fri,  2 Oct 2026 14:13:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.230.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790950439; cv=none; b=gXiCtlojNe0p8nT70NbZWNXLLzdhONLS2QshFLkoqk4S+QWTWOcNuGLq66pctV22QKBff+Spy7A6aEMeBHfQcmdwvi4YQym+GijVZx5QOcmtlk0yTEQCX0IUS9WS28vGLL2m99ub9uYsuAKQCDI3pkdzltIxNrrE9cOnmscorOs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790950439; c=relaxed/simple;
	bh=ecLdzVlyyEVSoagyjfJaI/MVE1ss1FL179UKwSi1Umk=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ViyJzlRU5GlBd/QrhbDahtBebAPvEZqU4zN6CjeflCDcbAHbe2OabCN0T3xoqLCnAGgfYoQYlyCW0kCQJqMgJm0WdqpEgINNbiBXQEbH8abWf+f+9rm1/zHw4aQnWSRFoW3QQ1kX/Vx9KCI4EltgQ2Y4mX+08kn3HFykBlKiFYE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=imBnhktN; arc=none smtp.client-ip=74.125.230.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="imBnhktN"
Received: by mail-qv2-f12.google.com with SMTP id 6a1803df08f44-91071ba92a8so38914216d6.0
        for <linux-nfs@vger.kernel.org>; Fri, 02 Oct 2026 07:13:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790950435; x=1791555235; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=kz5BNGvtQN27tO5bNJ/lnOnVvOARDzBgNARZZNdZZ28=;
        b=imBnhktNQDt8+ph23vKGnWbz4I0bSeR5yvffPbUeC1I7Q2eGacu8DbeXuKNvv9Z2h8
         BByDXYiu6TzHKFZe6TsKSJlgq16pxTce+mcUpsQLuGKSjgoHYE58wN7kx4E+mkuC0EgI
         HXW0Vz51+5Dn44+gKh3yoicScTdqXKhHUJaUYEmFp+WVekDZ+8j6XjcZ6YM7tUbeQ0i6
         eV1eMCefYBmSfJReMWK0qvmsp/bZXCmv1w7Gy8sa8733Pj3b/7IVF6zMAi16wTKuI0Si
         KPDQlM6ZDyKbA4vXdBMUzU62ti8MxUMtCEP0sZPzOPyqkrRFExVNYXJXxoy1MKqIUU+Q
         H9oA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790950435; x=1791555235;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=kz5BNGvtQN27tO5bNJ/lnOnVvOARDzBgNARZZNdZZ28=;
        b=ncCNdNQRNb7MRZ0G1c/dcdkubqbTJFDVOAHqW6NceexNJIK1OuuZUNVlZMUbSFK+To
         zcjQD/ITwA9kxq+7ulkvt7YVY5+ThV2DorzBqVO+ElHVa7aOgl65Rs7LCG0/pJaoTo9s
         C9jLGbFd3au85UIDf6QFmn8U3fA21xVKvSvPLd32U8P2WDmNdAPTnzW5l1UXHH2TBZBs
         OE0n6Hu5TwYTiVhB1watUExhNyBeO8naV6GmW+FEQOh31a2CS54TSFPkqNJk5jhn5Jiu
         LZ8bx93I18JSOfWUt98Df293atCVosDaMWsOlPQsEEf8LVJ7ncWV1sZXaORZKlLKh3pl
         TcrA==
X-Gm-Message-State: AFuF++nmh0P3sXZiWrl9NwjJhsecWWff/FD7JE4m3w5VxaOfXCmxPi4b
	TMoXww1bJJUk4i6C589WUAZ8Ue1QCbOY6RDvadni4wGwFe0BUcH5AoosLG1WrNESUVrI1Ao5LzW
	RHwtW
X-Gm-Gg: AYBFou1R04EXCn1n9G1i3ybeO6jy10TUSsBDVyjVRNLe9p4z61mCDJ7boiQsmxZzDVs
	/Ahy8lw3Gpf6jkUjt+fPwJRsrkfORJroh1v03QzB5Qj6iCqjUuLu0FZWphPdrqBTnw1DZwdDpJM
	NbfijeRH7lPPv/tG/i3ybpPqEVKOvdPqcNubIE+4ZhwwUdoZG7OIttN9mt+dUAs8hbt/AQIXbmS
	QoK7ET12Y7L/JuIsOG0xxkdGBXwxuG2rvycUje8ugl5DkLKRdR/1D24NrPv/I7hv3zEzY0NWotd
	zndU/8DpKsFh1eokY40QnQ3r8ShLyPv4SLxh7Z2ZzmTNGNqiBX8ho501zc+qDLHLY6voqwNVEEa
	f89MZNHAYigW0+yfQdaEb4lQcm/cK/qNH1SZfS8NmaTYPfeph5cY+mHLsyj3/pdwpAc1JDzFXBC
	Or0BToX842mILU4sBy8BHArTSPeH8ePVR4GXTWDyyRldGMB0pJ3vw33moWUJj6JbWwmd3U+VybU
	ZvMVnQtcN2Fc2xDVoKgMvgAdiuMGzkFTQ==
X-Received: by 2002:a05:6214:55ca:b0:917:a8ae:26d6 with SMTP id 6a1803df08f44-917c015fbd4mr48663016d6.34.1790950435036;
        Fri, 02 Oct 2026 07:13:55 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-917e0c0bef6sm20632276d6.39.2026.10.02.07.13.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 02 Oct 2026 07:13:54 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: wake a thread after re-queueing transports in svc_clean_up_xprts()
Date: Fri,  2 Oct 2026 10:13:53 -0400
Message-ID: <5b162e1a03d59bd0d3cc479891965834d0d4f0c8.1790948398.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

svc_clean_up_xprts() takes every ready transport off the pool's queue,
deletes those belonging to the network namespace being shut down, and
puts the rest back with lwq_enqueue_batch(), ignoring its return value.
No thread is woken.  A thread that tested the queue while it was
drained has gone to sleep, and the re-queued transports still carry
XPT_BUSY, so the data they receive next cannot enqueue them either.
They wait until an unrelated transport wakes a thread.  nfsd bounds
that with the 5 second timeout it passes to svc_recv(); lockd and the
NFSv4 callback service, which share one service across network
namespaces and wait without a timeout, do not.

Reproduced with lockd: with NLM traffic running in the initial
network namespace, mounting and unmounting NFSv3 in a second
namespace takes lockd down there, and lock requests in the first
namespace stop being answered until something else wakes the
lockd thread.

Wake a thread when the re-enqueue reports the queue was empty.

Fixes: 9a0e6accc0a8 ("SUNRPC: use lwq for sp_sockets - renamed to sp_xprts")
Reported-by: sashiko-bot <sashiko-bot@kernel.org>
Closes: https://sashiko.dev/#/patchset/cover.1782314746.git.bcodding@hammerspace.com?part=2
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 net/sunrpc/svc_xprt.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 0de613b36fff..c891532fb1f6 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1246,8 +1246,8 @@ static void svc_clean_up_xprts(struct svc_serv *serv, struct net *net)
 			}
 		}
 
-		if (q)
-			lwq_enqueue_batch(q, &pool->sp_xprts);
+		if (q && lwq_enqueue_batch(q, &pool->sp_xprts))
+			svc_pool_wake_idle_thread(pool);
 	}
 }
 
-- 
2.53.0

