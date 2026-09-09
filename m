Received: from mail-wr1-f48.google.com (mail-wr1-f48.google.com [209.85.221.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ACE0F3B0AE6
	for <linux-nfs@vger.kernel.org>; Wed,  9 Sep 2026 06:45:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788936306; cv=none; b=SDe3lhMrWf/vuhfKftP1Wyxbf4SbBQ+FuvbXlC4HjNOoe/8iCc3n7q+7SVciFzTi/hXQGnHrVVMs7liJCR8Rl9lO4yl8N93vHMeQpWx8zL+5v5QdFRdAZBrTvw9pdmomvMWMiZA1UKFxeSc3WH3ECsnhMaqrluB0EncK1VyT4nI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788936306; c=relaxed/simple;
	bh=DanluAYLKGnSSr8y1+7HZ6AUnVzsPNVwXGZvF4Qstfk=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=RLWIjY6BWsp4Ctok0U3N5QoGgDnGfRtwCxRYtnFODztvgo0CpWOH/1/wD1xXwOJOdBeZaZMGDjGpSM5Kjv6/LLPL6jgn7STEvjgLo0ha1iYI3oObfFyK1XKi+6+aYef11H5wOwmc6W5/SvWPLcWcdvWVB67A9XyJZA3fOT008T4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=rZzwWbx2; arc=none smtp.client-ip=209.85.221.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rZzwWbx2"
Received: by mail-wr1-f48.google.com with SMTP id ffacd0b85a97d-4843f205a5bso3456655f8f.1
        for <linux-nfs@vger.kernel.org>; Tue, 08 Sep 2026 23:45:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1788936303; x=1789541103; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=e0E6YoepVX602+BZgbZmpihibucX2fS9462FnPD7Cgw=;
        b=rZzwWbx2sH4d/qXVZKNVxq08MnLLftOjjcT2cbATDTP2kvqWwSayrt/deiN6L/lyZP
         BOafq7gp2gma07KgA2FtbZocta3Obs0REa+qcCDl7OIabpc09XqM1TTaQcE04rd56B1d
         RVBOojzXobjRbMnPS9hS9WQAyLJ3OsBzZpBm4JmpHbveOvnPVNIMJFJORdD+1yE269Y1
         B0L9agqSKqLdslZ883bQQ/gqz6DwCs0kiVEftNW/o6BQh3yr8qQXu+OkPK555nNbhT6q
         UuqNpONmMK72JfZ3WjzEOAbe2AJawNw81YyBvpWSsSvSgOZ556IaMN8mH0BDsyJnvJYN
         fRSg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788936303; x=1789541103;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=e0E6YoepVX602+BZgbZmpihibucX2fS9462FnPD7Cgw=;
        b=CS+XXrqEpCsHOdpgWRoNZzmBHU8o4vbY/S/WPGMmy+fPKjaue8/Qk/PQ0IZ845EbrV
         6WTCX1Kls8de7KwsibUzo7zMjJUk9/ZxQMNLADV7942UA52MA9QKLOTTxxh0bGTWSuOc
         BB5VD4jbi+3Z2U20A5LhIQThiaJ+siwi41OIaVplAW1Y/MUueXgBVS33eW4M8gs6Zwer
         76qHrDS2G4fANYJtscZsbkBKFM/mc7FI+4f7LUDvZhxfW87fu7QLDJoQCQY+l/3FxDl8
         9Xs7BjaqvuLrSaI/BVGa9YG5HHLPGZCcUIziJUJU9HNTp4f/p4/gmhe8YHt15tFY08rw
         aKRg==
X-Forwarded-Encrypted: i=1; AKwUvBzaTWMkY19vKBrw4cppYq01wklUsoIm024nrHUu2UcZxZyN4+t0evQgtrs6dRS0q2SfJg0RCHCKxHQ=@vger.kernel.org
X-Gm-Message-State: AFuF++lKbPRj9A8jLlxiYAtR10BVZ0xw88iJLB2GCyYMCN/vxE30sOdD
	62Q+Vkkb7V8yUNRzbVbEekmptbxevKnIh1y7soqFUPtOH1MO68dwEx0B
X-Gm-Gg: AYBFou2FhYsrv5ruKGqxsO62cEFyvLGoG0Jq0Lw21wM0ETVH6qs2B4sFERuNLYLNT28
	b0Ea020OXEe9m1xBHmcuoQCFZZaxhpotrs/Tz7GvPGXJ51ubs5nFX/d7b1SNt+2kc0BclwGIwKp
	TK+Z4REdYJYiTh2qXYPlY+gtkZdTHo2+BqfZsV7KZNvMBskB6JLyPKIfpOOAjmqycoASxZaoxsw
	QgmLuCtpnZ2l7CJ+DVR6/VZ8BSCLTZE5ueDQ2RuR+68ZwImjcMH7hzsh4yF0Y8x5yZsXCAtKEXj
	bAY4QVX+WAjQk0F/RJikCY5xt1HFId42NH5rZyGMswaZmLcAr7kiWf5Zz1voRrNmrX0G2LAsfhh
	wfFlVChWQah54eRG+7vGrNR27C64VNbmDhOBn9lWrSle76XTdO1oTTgdSGXRkHdlKJ1Ab1TEn6h
	S21ojnbrsiT/1qNFIkcfgxox7acEH2K5cDgTOOho7CQF92zOHKJ4tj5ZHOMRRAQ7oGxoSQDgQMs
	snRxj7hlKn7l/EEjagR9nx1ZLMzUMLzN7uBnqmUY2Pbll/ZgZ10Ua9cz5cgHCBrEcsNWLsKnrk6
	GP8fgPfKt+D4n/yLqhrhnhc8RW0xRGRw82RuskPzwc0Zq4LBxDqZAFkK8Z2vm6w=
X-Received: by 2002:a05:6000:608:b0:485:8e4b:3d34 with SMTP id ffacd0b85a97d-4858e4b3ed7mr31596984f8f.5.1788936302679;
        Tue, 08 Sep 2026 23:45:02 -0700 (PDT)
Received: from MacBook-Pro-von-Karl.localdomain (dynamic-095-114-212-219.95.114.pool.telefonica.de. [95.114.212.219])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4859207c28fsm36579522f8f.5.2026.09.08.23.45.01
        (version=TLS1_3 cipher=TLS_CHACHA20_POLY1305_SHA256 bits=256/256);
        Tue, 08 Sep 2026 23:45:02 -0700 (PDT)
From: Karl Mehltretter <kmehltretter@gmail.com>
To: Chuck Lever <cel@kernel.org>
Cc: Karl Mehltretter <kmehltretter@gmail.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] svcrdma: Fix svc_rdma_recv_cid_init() kernel-doc
Date: Wed,  9 Sep 2026 08:43:43 +0200
Message-Id: <20260909064343.90437-1-kmehltretter@gmail.com>
X-Mailer: git-send-email 2.39.5 (Apple Git-154)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

svc_rdma_recv_cid_init() initializes a Receive Queue completion ID,
but its kernel-doc heading names svc_rdma_send_cid_init(). The latter is
a separate helper immediately below it, so kernel-doc cannot match this
comment to the receive helper.

Fix the copied function name.

Fixes: 28ee0ec8948a ("svcrdma: De-duplicate completion ID initialization helpers")
Assisted-by: LLM
Signed-off-by: Karl Mehltretter <kmehltretter@gmail.com>
---
 include/linux/sunrpc/svc_rdma.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/svc_rdma.h b/include/linux/sunrpc/svc_rdma.h
index 76aa5ec4ab40..5ccb13bf906f 100644
--- a/include/linux/sunrpc/svc_rdma.h
+++ b/include/linux/sunrpc/svc_rdma.h
@@ -142,7 +142,7 @@ enum {
 #define RPCSVC_MAXPAYLOAD_RDMA	RPCSVC_MAXPAYLOAD
 
 /**
- * svc_rdma_send_cid_init - Initialize a Receive Queue completion ID
+ * svc_rdma_recv_cid_init - Initialize a Receive Queue completion ID
  * @rdma: controlling transport
  * @cid: completion ID to initialize
  */

base-commit: 893e11787f78e43b534e252249ac3fff4d1333f8
-- 
2.53.0
