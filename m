Received: from mail-vs2-f12.google.com (mail-vs2-f12.google.com [74.125.227.12])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 928213E0C4F
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 16:01:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.12
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789488096; cv=none; b=AwpWO86v90n1sQLKzczFWcNYn3H6Sr7KX61DYeukokFPUo7ht2q+kbc/GTOoLYz65Jt95pNaG24PJivXTNcTdsIXPlW9ZRo7sn8xLOmJxdYGlN1NSXWTRB0p5lAbQEja/cdM97PLo2vjLwoEDrr+gqcrC6aH15Y3gokOWBpaCow=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789488096; c=relaxed/simple;
	bh=l1wdurB+pidV4AILXrT+tLTz7zo3y2Q6OKy1w1aG1kQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=S0v5JTAsEmmD0PQI9/8+V+bDOe5oUXc5WIsxc9ZJ0ohA+DboBlRYI3arRHX1iA2YWyK5ylfX42SC6gBdzrBmsQ5BcnO3YXqIUZQs3fiFaOVPCe+9EZfSgjSQqeYSYDZjTrTJna1DC1PELCCI4ff1DW2KTVmQV8pBgwKB5Cuxxy8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=hdu+kAFk; arc=none smtp.client-ip=74.125.227.12
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hdu+kAFk"
Received: by mail-vs2-f12.google.com with SMTP id ada2fe7eead31-79022baa364so791576137.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 09:01:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1789488093; x=1790092893; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=s20q7T542NAQUDk9biMPbZxXmVhh38LLJCMfX8DFltU=;
        b=hdu+kAFk17kuJfjDPLx2/MBTd28lL+xe7nxB82TLgOJIzSQQ9PflXqtUhltCEi7rv9
         IpNh+SuqiOwipQMoH8pHplDpAa5y59vFqX/bc3pic9FA1EQXrjM6KgPsgz6U981Gh/7M
         VC8dqehDfynG9TzXpozl5euKgsgNnN4mqQ/8cgn8NVgLw8iehJVq2o+z2rV1yfDkSCfO
         aUK3lpL8PVnF6CxZ7XJLnR7f9nmtR+kUn9BeGosQa+HzpGAbXDIsIraJWIn0VKACfMAQ
         8/JvVgBZc7wm6eEUmeM6GluMW4NJfuu7yVfsWBzdo8LUtegPtlLFlxeOesPdlRc4thGb
         E0nw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789488093; x=1790092893;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=s20q7T542NAQUDk9biMPbZxXmVhh38LLJCMfX8DFltU=;
        b=w5XjVYBb4xYfhFy80+7T2ybVgJHd5r09xT59qKZasP0/SpGlBYi+6R6vhNptrPr7iV
         o5BL/kwxzGNBWdd9nY7KZj0Rlh9IVx0QJIptB30uxSx5G3H76P3s5JnGm0K39D5nMVsB
         FfeIhdlQlLY4bvm4oadIgKBpukRsFRsLZa+RyoOAqtIFBdbqZ/0rCbdhRavh9JHU7CCb
         9XALKiUthS4sPBvDQ5zQyVXl89iSxoH7/k0BdbZ6mnvnEvSjBOqwXEm4VEBUGa9BWBdx
         757tzDBQoba4KEp4svpf8ltRIU1v64BnNN68wizJElEUkBvnAZYy4sT8BcgFK/y7tQ2l
         BzQg==
X-Gm-Message-State: AFuF++l6DQvKBLQ1BnuW7lOS7VH8INtQvxF1GZFGtFEFPb58VNsH2bYo
	7Yr7WKt5OhRguewztRnXoxr1BA7Q0ZrIv79INNxickfxInzSyb05xZCA
X-Gm-Gg: AYBFou0Id01wBsmUmQ3ac5/yn6HNTMfxnt9KI1/0GWX+nsHeajc7M7TWiCbKnSfttLS
	hQKjBNy8jZd4tqHQpqiGnUVeFfPGUu36lT/bMRADOJlvVvwtAb/X4vE1FqHuW1D0gt9O7i3He/a
	jsH698G3YkVw/5VFTdhqCig3KbpHdBE1p9llxTgduBVL2vLhm1Abnx5q1LEnhrQFPcS7N/mcyOv
	z+oDRDGp0JTkLZflWZgNwXnGP67aYtH4gaMdS0NLAuiLNtIDClC8toCJcMGZWWMnJo4SHgGzClh
	ECj7MWUyucmtRfILre45rO6FeLMqLA04H1JjMHwgCaBtefu9QOe3i7LD0GSpVKVXFkgYfiSBmtN
	5NcZ2Ua/OwICEuzD6RinLVcYV1IP0Zx9qiQiKREmmdxBesf6em6t4Usf6TbzWysYu8BrJxa74oI
	aQtGl/rmToHWmdERQ6T/MppKJBxuFj6Gb3FLj1RqVmCD0OTi4Sgqyr65HAJK0w8Dr7
X-Received: by 2002:a05:6102:5f0c:b0:779:328:8a2e with SMTP id ada2fe7eead31-79d24d179bfmr613801137.5.1789488091386;
        Tue, 15 Sep 2026 09:01:31 -0700 (PDT)
Received: from beelink.. ([187.13.206.89])
        by smtp.gmail.com with ESMTPSA id ada2fe7eead31-79facab39basm114393137.2.2026.09.15.09.01.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 09:01:31 -0700 (PDT)
From: Aldo Ariel Panzardo <qwe.aldo@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	Aldo Ariel Panzardo <qwe.aldo@gmail.com>
Subject: [PATCH] nfsd: clear XDR padding in GETXATTR replies
Date: Tue, 15 Sep 2026 13:01:19 -0300
Message-ID: <20260915160119.3105745-1-qwe.aldo@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd4_vbuf_to_stream() uses a raw memcpy() for the first fragment of an
attribute value. xdr_reserve_space() aligns the reservation but does not
initialize the extra bytes. If the complete value fits in that fragment,
the loop that clears padding for the final fragment is never entered.

A remote client reading an attribute whose length is not a multiple of
four can therefore receive one to three stale bytes from the response
page.

Encode the first fragment with xdr_encode_opaque_fixed(), matching the
final-fragment path and ensuring that any XDR padding is zeroed.

Fixes: 23e50fe3a5e6 ("nfsd: implement the xattr functions and en/decode logic")
Cc: stable@vger.kernel.org
Signed-off-by: Aldo Ariel Panzardo <qwe.aldo@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index e17488a911..51ab68ffdf 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -5953,7 +5953,7 @@ nfsd4_vbuf_to_stream(struct xdr_stream *xdr, char *buf, u32 buflen)
 	if (!p)
 		return nfserr_resource;
 
-	memcpy(p, buf, cplen);
+	xdr_encode_opaque_fixed(p, buf, cplen);
 	buf += cplen;
 	buflen -= cplen;
 
-- 
2.43.0

