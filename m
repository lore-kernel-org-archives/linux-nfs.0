Received: from mail-pj1-f45.google.com (mail-pj1-f45.google.com [209.85.216.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 875213E63B3
	for <linux-nfs@vger.kernel.org>; Fri, 20 Mar 2026 18:10:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774030260; cv=none; b=MTujojSUauhaLQ8nphPNkB4Nv09pby3nV+KHX+HzlhNhlvneWG+idGwq2S4LZC/rG5vRtwQf51XKBlPIVBtNXsUNIBRcxOxID9fbJ77KYQglzHXthjyMOam9wldkI6aOAhKzJQStav+3ojNIItrBreE7ZGwx2dVyXdZBS0n+wnk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774030260; c=relaxed/simple;
	bh=26UQrZbU/JLBJCqLwaX88rDbciQrWYFpkBrK87bA5aM=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=qg280j8V3TOJytqvWXS5GACNWhqaV5Pb02ANVJbKw7M+VlY9T0XVxu5kwnRKCy/ZyDtvbV2MGalZnFdDHxytSeF/q3V3PMVCSxcc0f1pEBXvEp3ZRtQ/Ceb1KVFuwyF0fq5yoLMUZSwYp6QB02joPvzKpnHP0mLeTR/qVszbMGY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Ukjksohu; arc=none smtp.client-ip=209.85.216.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ukjksohu"
Received: by mail-pj1-f45.google.com with SMTP id 98e67ed59e1d1-35b90d6fe14so1479729a91.2
        for <linux-nfs@vger.kernel.org>; Fri, 20 Mar 2026 11:10:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1774030255; x=1774635055; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Rs59ZYsmevHDwekpgOW1Jo5Q8vTfXRm0+cDIBjhCcOE=;
        b=UkjksohuJRYV5krQr4lw6YbTM+VwHFPMavoxqbeht8miFHq0+Lv9iyzkDcQUh8s0+r
         Mw+Rws3X3e66QkhywIn62m3bxVEcWB41nbn92CwOMy5NLFL2p7aRUrbX8Rqi+NZRMq1r
         RVPpmii67atOMA0F1ctiuFl0vH0ImsdOwevJPvm8K0TqYWounQjCR2GEYl2B/8sMxylX
         Tnww8bxFJ7EnWzwMnjcfyVledFObeHpY7WOD2eu6bNV03sw+nAulD9KxJzzUiso4OikN
         Btj7rq1b3KhetrGEx/F8cva4uAUg5cLPYkUM5KlNohMhR5r/TAnsZE6PVHNscX6lkMFm
         ERBg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1774030255; x=1774635055;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=Rs59ZYsmevHDwekpgOW1Jo5Q8vTfXRm0+cDIBjhCcOE=;
        b=IEYEyWQF6vo+ATzgFKXF4MjiWkV+y6ZqNQ53Pz4u1Fk+K25B0UkhDU8TjzNUIF5Wlp
         yjVoiypm41wCBxBRrXxYjibhvm8Ofw6VdXUVeh/+wIaKFQ6UufbkX5bSJQJE3KjyOY6q
         lAL+dY2hsdj4+ZQJuuhgjj6WeBAiVfVtAxoVsHmOO/65vpUFOLMBxtEsg7PnVY1mnkmu
         Si7R7cpG5EKx+H+MdLVDt2jSJC3p08zy9F5eBJ1GOM6muLNbAlTUYXvd3HjhC0dKMYhA
         bZeqCFy8k0xO6DS2nnqFOdSI6FGz8gAD5j+qT+3NjdS5NSV8GR0bu2ZVmVD1gP1odHub
         Q7lQ==
X-Forwarded-Encrypted: i=1; AJvYcCXpQx14sqL/amIkiiejH7BXu0wKRyPvFUP92PJ8jz524S94AiFI0N/EuLzUsqr6qNi8XtuWTtuYCMA=@vger.kernel.org
X-Gm-Message-State: AOJu0YwY/4VTiG8wSde0Fzxdeaq3p0TuEzc02RCkD0nWEEFcm7GjPj/I
	7mCEL6GYznhDGWZlH8zWkd6Ke2XfdLFz3eGmbvGhrfrF2JMlIMLlOvw9
X-Gm-Gg: ATEYQzyAnbigZP7W5Gld56vQoYCD0Y7w+Z5pnFgNaUnkeG0WbcKLofz9XYE19bxNZKE
	4M3VZ9TetB4KM22mzCwV5JDoxH1nB7+cag4x8Wt+gkklHDvhkvV74aGa1mxo4JwiYHrQJksvOkS
	UusdHiF4eXxDX9k0qW2rwSZJqRByrGcXoLJyDf31J5oWtLi76jwahrhuSXLv84V56vvmeoUmA8A
	+5pmkwFcDKf82jjTRzTqmqzRHQjUFKdqggyGGjoOzUOV1ccClhXnIj/NtHp62Uzedls15rOK2qE
	4v+9W1RMMbrzvyXD1XrgLVW8Uz9Gg+cvDzon94kqlaJIYMxBXSn0xRh7T2fi5VEwcs4os8OMR2i
	ps5z05uHP/IVy+GpoARIjB/psbKziSy2JfW/Nu1qIwhZGd2XreJOHYy4SGzgz1GdB275q/bQ8Kd
	9tRDwW3O60OYzzzKXHVgnR7D6pkfa1BI5j0M71PoivBHjC//78HQOJ1Ej+icfgEmUP6YA7cU8=
X-Received: by 2002:a17:90a:d605:b0:359:406c:49f3 with SMTP id 98e67ed59e1d1-35bd2d1f873mr3078727a91.27.1774030255511;
        Fri, 20 Mar 2026 11:10:55 -0700 (PDT)
Received: from sean-All-Series.. (1-160-226-215.dynamic-ip.hinet.net. [1.160.226.215])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-35bd368837bsm959352a91.11.2026.03.20.11.10.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 20 Mar 2026 11:10:55 -0700 (PDT)
From: Sean Chang <seanwascoding@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>,
	Chuck Lever <chuck.lever@oracle.com>,
	David Laight <david.laight.linux@gmail.com>,
	Anna Schumaker <anna@kernel.org>,
	Andy Shevchenko <andriy.shevchenko@intel.com>
Cc: netdev@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Sean Chang <seanwascoding@gmail.com>
Subject: [PATCH v4 5/5] nfsd: remove obsolete __maybe_unused from variables
Date: Sat, 21 Mar 2026 02:09:55 +0800
Message-Id: <20260320180955.150696-6-seanwascoding@gmail.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20260320180955.150696-1-seanwascoding@gmail.com>
References: <20260320180955.150696-1-seanwascoding@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Now that dprintk() has been refactored to use no_printk(), variables
used only for debugging are properly referenced by the compiler even
when CONFIG_SUNRPC_DEBUG is disabled.

Therefore, the __maybe_unused attributes added in commit ebae102897e7
("nfsd: Mark variable __maybe_unused to avoid W=1 build break") are
no longer necessary. This patch removes them to clean up the code.

Suggested-by: Andy Shevchenko <andriy.shevchenko@intel.com>
Signed-off-by: Sean Chang <seanwascoding@gmail.com>
---
 fs/nfsd/export.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 8fdbba7cad96..8116e5bcbe00 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1025,7 +1025,7 @@ exp_rootfh(struct net *net, struct auth_domain *clp, char *name,
 {
 	struct svc_export	*exp;
 	struct path		path;
-	struct inode		*inode __maybe_unused;
+	struct inode		*inode;
 	struct svc_fh		fh;
 	int			err;
 	struct nfsd_net		*nn = net_generic(net, nfsd_net_id);
-- 
2.34.1

