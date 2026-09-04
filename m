Received: from mail-ot1-f43.google.com (mail-ot1-f43.google.com [209.85.210.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0CDDA49CF26
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 11:05:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788519933; cv=none; b=N+5oCkJZ2/C50Zjmv4qv4/J8fPjnPNlfUwPCJNzX/pv6jASutRa8LsuaPZ+u1d8ONaQ+Zi/WuJddAqN7qw7gZGGThRcgqWNBoeEDGznFzlxbZGb6UKT0U2vfbr/13drj6gdpHFZ1G0HYFmeCKWpXDKe03Oxgl6sfBEpGlQ2mvGI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788519933; c=relaxed/simple;
	bh=N0NRuMnQNT4U5LjQKRjWQiu7rFtDq9i7K1NImELSQZc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=AvUDDbjwLoOB50HWGUnAIu+Y9q45CbqfrHGHrhBsaQI42GwQgaUAjj8zn7OXfJKh3BGoTaCE93XcsXzai2X2pGxWA2aLWPk9NMbCOa9wblm1CGFgQ737qXU8wPuw+1vVbC+2x4ZnCUUdA+SKGffIK1RGUTk9hYfkjczLvY1Cu6o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=WedIWgxN; arc=none smtp.client-ip=209.85.210.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WedIWgxN"
Received: by mail-ot1-f43.google.com with SMTP id 46e09a7af769-7f3f52143cdso729226a34.2
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 04:05:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1788519931; x=1789124731; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=pUAku8kEB1Qfbu/4zomfSevYTVMYvS8FyB0ooNWeIWg=;
        b=WedIWgxNuAwQbSfvNIB/vFwyt2YQvhyhuRpa6+96rvVlaSgnjGfmyvfRNXwrV+hy2j
         ZsAB9+9N8iFi292JM/eMd2M8UpZ5Vi02Zzi0IcZFHUzmSPj/iL1XIt06QHgRwgmAJ33M
         UN7e08JSqXbU7CKWwmlgtv1hRZjfOQmd9/6thHsIJzuJ0H90WIBIFrgbL2nrS7E7lIz2
         DvoBXWsmtOdVUGXr+xr1scFuiXiI9Y0S6E+1DxlqInQGZhU6f8EliEu2I87l5D8hE09S
         BSDRYkF2+uclEIzoq7xhEk5CRfXL/MEJ95Ry4tnoopmSAB+Pg4/FKVi4oviAUZRdt1EE
         nObA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788519931; x=1789124731;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=pUAku8kEB1Qfbu/4zomfSevYTVMYvS8FyB0ooNWeIWg=;
        b=L1xjzHY/UmgagxJvswkqVOLO7ek4QuuNCXDASe9huMrUl+DqeZNvFJRJXnzzBVxB8H
         d245JHeqXm9YbEkZtnon0CDUBnEbpS1snmIW705VwXcaRgcKUhmHGyETLudoAjr0862N
         J4pYTizO8kZyKVwjPLLeN57RT6f2WP4FK0WzpcAyX5PfpnkQxWCqcA/ahLPK/FAbSUKG
         g1lI2cskj/z0tZdwU2uilJbwihPRzjLfJybSuoRAn0Y1VsBa40s9RlWSgEkanZQ11Pyy
         CgN/HJADvdBs7LT/q3PpT84LSl5btBWuuGaFlKFhsw+HqqZ4NWM4aU08MuC0LPmopxCj
         HH2g==
X-Forwarded-Encrypted: i=1; AKwUvBwvksZPl5bRs4wNr2c1qUStGIk6UpfF7mK5geifNyLg4eKm5Dxh/7sZEUc94lc/rcXxz7nkPtRMXS8=@vger.kernel.org
X-Gm-Message-State: AFuF++kbyAqzu8EgcJvIBYyQXYsXnlM5YBmmiABwiMiFabywJQPZ5H25
	9N02rO1UT4ndAOFyAYhnLovydNEhpJT63uJ+8qNqXWKcXzj2R59PIqIL
X-Gm-Gg: AYBFou0zKWCYjpSJJ+xndExKKi3qWxy7CmNFP+oBDlhxuEDTBbDfjYdmxAXG3eyhw7a
	csHsYxLRYAJD9UdKe1TyI7CZ7SQSPpKAoJlu5lx6Q7aFtQAU6z+d8lfTTfYwajxt9jW9N8tjpFx
	iQ4cI3BnwQ+H0B/szGIlzsrm9KzzCBtx7ERheaouPMHYYl6ivI+9k6h+QK/uMdmhSUfD5Kv11NZ
	Z24XYDXjs/oqmuDcKQL3nAAg6oOFDoXU1qDEhMGy01aoMRw2gLCpW9iU+GQWmISn685/KKxZpQ5
	j699ZSWs4XzW7hdJXEOkLHqhSDICdss6FMYjP7ewBGvXG+vzPZY8W4R42FZW9Kn7fWBYj6vXF6Q
	Ewyqzqu6rp3kbVcgCYoQQUpoImDg8GZXJ9mzXAAS3pYiU/NJzo+ZgCKAiGfoDwW8JB+0K4gOw5K
	SfoM19H47LQRG7OfHdcAtKH1+3ourhjNeQavhRpNCWg6D7fBlrhJAYt7eXEZUsyUHvkymx0RBQu
	1qsa/LvAvLODpI=
X-Received: by 2002:a05:6820:4b88:b0:6b7:8415:d787 with SMTP id 006d021491bc7-6b78415d81emr1080277eaf.50.1788519930706;
        Fri, 04 Sep 2026 04:05:30 -0700 (PDT)
Received: from volcano9f6e-hostos.amd.com ([165.204.217.251])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-333c9db92b1sm5220280eec.9.2026.09.04.04.05.24
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 04:05:29 -0700 (PDT)
From: Hemanth Selam <hemanth.selam@gmail.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>
Cc: linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
Subject: [PATCH 1/2] net: sunrpc: fix typo "miliseconds" in comment
Date: Fri,  4 Sep 2026 16:35:16 +0530
Message-ID: <20260904110519.15207-2-hemanth.selam@gmail.com>
X-Mailer: git-send-email 2.48.1
In-Reply-To: <20260904110519.15207-1-hemanth.selam@gmail.com>
References: <20260904110519.15207-1-hemanth.selam@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Correct "miliseconds" to "milliseconds", reported by scripts/checkpatch.pl
using the misspelling list in scripts/spelling.txt.  Only touches comments,
no code changes.

Assisted-by: Cursor:claude-opus-5
Signed-off-by: Hemanth Selam <hemanth.selam@gmail.com>
---
 net/sunrpc/auth_gss/auth_gss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 8ddc65e894da..8de85da8ee42 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1468,7 +1468,7 @@ gss_stringify_acceptor(struct rpc_cred *cred)
 
 /*
  * Returns -EACCES if GSS context is NULL or will expire within the
- * timeout (miliseconds)
+ * timeout (milliseconds)
  */
 static int
 gss_key_timeout(struct rpc_cred *rc)
-- 
2.48.1

