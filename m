Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.226
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795136625;
	b=Rrv6bJRfIMlMxZHxx5Pa19GdybEBQwWkIFZG7aCt9/tr81aVJfjgc8lrX+EC2Q5TzTro
	 47mshS6gW8SzhMrz1GEMboEK3UXDGqsbuSZPeZ5ruhe/RdaU+e2L7zljHCt2XeDqp2xd/
	 TPdLRtSObCENJVL9Oo4acF40HbEJuJIPJxs1eG8NcEfhsSqJqgA2IdeJAjx0xgiPmZIKy
	 qmuEUY16JsZgWWJPN7VpQk504xc3GRCe/y/xVfdbb1FkKe38xbDmpD2rnD55GMP6Yph+l
	 /dd7dZQ/CRe1QL2mYdGNX2kyCP5lNfmM0OJGF5Gj2VHyXw5au/KbA0IT8XjSd6ybfaw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795136625;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:X-Relaying-Domain:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=f03S4oQ3kidU1WT5hTpJpYxy3HRw9wuocqAofdkvY1U=;
	b=rQ/mBwxW8SCvRAvWi702q3/pVXk1CLGiR72fxNN8FkU4shZt12cHOAQu/PikHszY/jp8
	 fL/FTyg9WOgUDj5cdW8GCFgg5MkhiD75kpaUlgzEZc/reZEU4G+GCKn3QNfGpvq2tqAcu
	 xS7xT8HB0NvwfAQryBNlCcdIXvm+XjEbFFjh7M9QjcOkHJgnd2HoakP2RxX9E8/iINANC
	 NBXaTJcrCP56SX7xpHvaZb/U8tFj2Ad8eDYwkHia0qrOeVD0+OHHYAnLjK5qkgmM/sEoV
	 6vpckQcE3NOfc89hc86KBka4WL9Cmen9Aoxr+YsEVOXzrKBZWXkNaQJC1motEq6TPdA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=everpuredata.com;
	spf=pass smtp.mailfrom=everpuredata.com;
	dkim=pass header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=TDFA9N4I;
	arc=none smtp.remote-ip=74.125.82.226
Received: from mail-dy1-f226.google.com (mail-dy1-f226.google.com [74.125.82.226])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CCF82606A325
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 01:03:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org CCF82606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=everpuredata.com header.i=@everpuredata.com header.a=rsa-sha256 header.s=google header.b=TDFA9N4I
Received: by mail-dy1-f226.google.com with SMTP id 5a478bee46e88-38587f3de36so353161eec.0
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 17:03:44 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1795136624; x=1795741424; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=f03S4oQ3kidU1WT5hTpJpYxy3HRw9wuocqAofdkvY1U=;
        b=TDFA9N4IRZW+Hkx/awuaatTxRTDIxw1qJrdSIJV5P/dKRKVfaD3TS3e0MdMk6gGe19
         pfWrzDS+12bFfJx54MRHHn8RjsM2jLw/PW4UZFA4NtsK7WiFDJcXxKLXx+14HzZRcvnn
         3TLGNtYdT9IlkaFaWygtQmYqcv5Cq+YEDj2TApN71JiIPCGvFuXouY9ZDEKvasRqdno9
         YHIwoIQwGkxzMqZOWIbjXnCIIAp5uaH4q2iTRYcOjekRcwhkmzSE/CHS/6gAzKWlA6v8
         iH/FjIOYoKZEOhZiv0GdKrOp3eizLbo/7mLQIZXdFqFNxCmrfH/9SN3ZjWcBZOrES2TR
         jK2g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795136624; x=1795741424;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=f03S4oQ3kidU1WT5hTpJpYxy3HRw9wuocqAofdkvY1U=;
        b=r83wRJS03qHTOy83t/KLgoa1hOfEgB6ByJokmLLiixujoe9XhYxNXKgAj+Oj3b1Uqw
         2k2zmX9WMW2mbUGpy1+EXAZPT3eH8vzJvJqum6tVgr4zcLYcO73UA4zX/rXpvaSx9oH2
         PxLlNWulu4Zu3Z46SuOudObgoc+Q7M53kQ/nA4kiH8rzLYIg2TAS0sUGAbJiRoDAlSCV
         7+MZMEUozTVxJRVIAN8fTaIlHlfefswbswoMWyuqvvzshqZtKexvuneRcAzuu4/HDyHr
         CNDxmaaeQvEvvKPEFnpDpbajJJdcaCYZEj2jB4VG394ZmEWf7IO/CE6Km/8jqXqi3LO8
         1MeA==
X-Gm-Message-State: APuU4Z99wdPDKdde9A5bgXd0jM7lj+7u0J9QXm2wr4b/aT6ZKfR5Ib6J
	qn7VPbZW/a5zI586J96fxEOzMKe0Gq6WCv8C81KzZJt/YlFRGzV6DLziKh4Cg3DeHQtZ6A1o4R8
	J58B7eumVY+DDvnufC5efddx/c6Yfzvc5ccr8
X-Gm-Gg: AZFdTZfXnCryICntAIqK3/vjBahbX5c2aoIau8h6dv5tO/wek6nG3QufkVhoaCJt+tu
	ohg2ABhcqdego6+OGIiqSIgaZMMIZFM+X6sE9italZUfaIHBeaaNKCgHgsNKFWtXFYFbDK566kk
	SRuc5vzupA4uUz416RC9ayObstBj17+QUO0fV7mrUVbNTk3b/m58Bvqvigu/tf4cDgJFR8wjuE7
	ck/niOCEsx51BxinaMmAHC8SH9aED0CJGo4uDJuSg4vNTR24beLPpTvyobHaycvOdJojHTiMUFa
	CCUNAjC+BIdSF7VAmx9YxBUJsGqnZv4oJWZWzupgUDRdfeQhJPwotvGxcC25ggNvZG21isE96qc
	f3DKIeWhQkwj26rv7aODdr3KTfz9j09MYh5ES/a0=
X-Received: by 2002:a05:693c:4001:b0:370:d6e4:e8aa with SMTP id 5a478bee46e88-38570b34fecmr1152737eec.41.1795136623678;
        Thu, 19 Nov 2026 17:03:43 -0800 (PST)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id 5a478bee46e88-385676c6aa7sm94876eec.18.2026.11.19.17.03.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 17:03:43 -0800 (PST)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 97A793400BB;
	Thu, 19 Nov 2026 17:03:42 -0800 (PST)
From: Tim Menninger <tmenninger@everpuredata.com>
To: Chuck Lever <cel@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jon Curley <jcurley@everpuredata.com>,
	Eric Badger <ebadger@everpuredata.com>,
	Shiva Lingappa <slingappa@everpuredata.com>,
	stable@vger.kernel.org
Subject: [PATCH] xprtrdma: Retire the connection generation when a connect attempt fails
Date: Fri, 20 Nov 2026 01:03:42 +0000
Message-ID: <20261120010342.2152535-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.53.0
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

When a connect attempt fails, xprt_rdma_connect_worker() wakes the tasks
waiting on the transport with the connect error. For errors such as
-ECONNREFUSED, call_connect_status() can then call
xprt_conditional_disconnect() with the task's rq_connect_cookie, which
was copied from xprt->connect_cookie when the task started waiting for
the connection.

The failure path tears down the endpoint through
rpcrdma_xprt_disconnect() without advancing connect_cookie, so that
cookie still matches and the conditional disconnect requests an
autoclose. If another task has already started the next connect attempt,
that attempt holds XPRT_LOCKED and the close request sets XPRT_CLOSE_WAIT.
When the attempt succeeds and releases the lock, the pending autoclose
tears down the newly established connection.

This was observed on 7.4-rc3 after restarting the NFS service on a pNFS
data server reached over RDMA. Connect attempts made while the server
was not yet listening were rejected, and the first connections that then
succeeded were closed within a millisecond of being established.

Advance connect_cookie after cleaning up a failed connect attempt and
before waking its waiters, so that their conditional disconnects no
longer match.

Also wake pending tasks before releasing the connect lock. Otherwise, a
task can capture the updated cookie and join the pending queue for the
next attempt before the previous attempt's error is delivered.

Fixes: f99fa50880f5 ("SUNRPC/xprtrdma: Fix reconnection locking")
Cc: stable@vger.kernel.org
Signed-off-by: Tim Menninger <tmenninger@everpuredata.com>
---
 net/sunrpc/xprtrdma/transport.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index e38637c2ec787..02946585e5f62 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -239,10 +239,12 @@ xprt_rdma_connect_worker(struct work_struct *work)
 					   xprt->stat.connect_start;
 		xprt_set_connected(xprt);
 		rc = -EAGAIN;
-	} else
+	} else {
 		rpcrdma_xprt_disconnect(r_xprt);
-	xprt_unlock_connect(xprt, r_xprt);
+		xprt->connect_cookie++;
+	}
 	xprt_wake_pending_tasks(xprt, rc);
+	xprt_unlock_connect(xprt, r_xprt);
 	current_restore_flags(pflags, PF_MEMALLOC);
 }
 

base-commit: aebb7274476403040d582c61478df8f4a7bf9cd3
-- 
2.53.0

