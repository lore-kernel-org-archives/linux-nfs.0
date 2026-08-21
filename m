Received: from mail-oi1-f178.google.com (mail-oi1-f178.google.com [209.85.167.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9CDD4493624
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.178
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329772; cv=none; b=i9I6gIeihhCac2QPBArduOfxTnmb75rfA0LdEz5T1cnDoxLXoIjvaKNdz8S+5iswDSPl/NubSdoDvCQq/Zpz3Ntv0R9LaUjFMids5mrW+JiKZxs7vKRoBH5kIhC+4r0tekQeZL3jKyQqBmw6z6OoUrStWyrRRVfuEC+DQQsA0z4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329772; c=relaxed/simple;
	bh=lW2ye5Wxyx6oWGvVv23WsRjP7SXvFpTSfbWSxs3TFys=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=l0ZovI4TYAhjTGkHV0jhAE9sUGh92ycOOMkCiY4P1zCWRxbUymKK41yP+uemyXfwx/m8Iz3fYVroTy9UghMY1ob6ZLbwOIlNlFDmRlerr2FGx+FTVt20zZqqPE2ZWuND6qriK57XSt3jOAiv1Ttal8x3AUUooL+KFZ0K/pZoixA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=B6smH9D6; arc=none smtp.client-ip=209.85.167.178
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="B6smH9D6"
Received: by mail-oi1-f178.google.com with SMTP id 5614622812f47-4a43c2a126fso538215b6e.3
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329770; x=1787934570; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Eozo7hnfADgTk/efjNbFXONG8FQS0UOXKXbvAiFpU/8=;
        b=B6smH9D6RvDWnrkSInf1Gd+tWep6gplu9a7ZEl9rS2SWg4YcjYBeOa3w53kzvev3u/
         3buXt1K/mgErgLYNk0wjQvoPG8IzfzQ9+7nrfTezN00No6mM54QY22QJgQIvO6BzvVCp
         N3tCu7iNzOaymc0EltzzwXgDlsNfee4ui7UfIZC7g5Kdr67muSSdbwlVsJrfWt5Z7hYI
         zcmqPuWarrmz5vg/myhzRGHGgdVOUtZJhT2zKJldX/K2zv8rqIN7MovJjwQ4gHyU0fpI
         KDOk3cVU5d6GDpifVhbmL2jYpZi/4yTOQkI/nTjt7xoKj6YYeRdyIGSZR5qFjUbZp8a8
         YdBw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329770; x=1787934570;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=Eozo7hnfADgTk/efjNbFXONG8FQS0UOXKXbvAiFpU/8=;
        b=BYNqiiOWtGSNg1QshmRd350f9yX8FkYs6Y+iACkE0+LJbSD+LrUpRhL2EchCNsGupQ
         t+3OD2ylHcqxefaZAbb/HBO6UhJI9Yhyuogv+eek2ZqNB3HJwpGoCOAvLQAh8S8Fi0wp
         IwO3KVtZhZYepbieaoV4V0tVq0JJUzO3c0vx4DxbH9osahPAYlD8lwpm36vZSObl1n+/
         H0B0f7c8uHKRKU/PuD4YaYPg1c4piwA5AsbWeBh4cP6y63W8OfX9iFU3qS2HocBEvhtL
         kkedCXG+ihQ+l6ZwwRlDDrjMwOYg8bj+ebfMjFZB3HrVhqeBdOc8RBVQvQhOqLaa7hhE
         sV/w==
X-Gm-Message-State: AOJu0YzKok9gg4Zi3o0xMrDkdKl7BOab/EmU29o/87be6C0Qw6/Yp/MH
	Q3elM61q5Ho2mA0Bqwh4Fl0jdRE/dUAxldL0M++pGxCXqzt+Z0Ucx6dGHlfjL5WA5QOkUUozah2
	B1q1H
X-Gm-Gg: AR+sD105GCC9DMII9jm3gvXlPk1iAOPc2x803a509tyIoA6mmS+RdY7j9nsgulOXUzz
	A4SfshHuwGum5TphUJc9ccpkldKpC44wJjcLte5sCxSU5m2gU1832VyKLoLW2nEJGKUWs5mmhse
	N1aUqB7M7WZXDIrgt74nsyvZF7624OTHL+tHipggqmpVuO6klaxGDbmw676oqfv9V4yiW4Tnvcj
	ct6pOpQEhaW7AkBYZc0wemq4TvBkDCvFKJ8WGm8ixjKCzh2WyOzkYwZIFL2B3l9NzsFz8HXenuC
	qB/w1qu/Brtyc7ihjSzcL56QJRYecstsqhWJ/PL8rv47ngZuYPkbisxRrdAIaQNlHxj6BaBUquC
	FRTQMEQlPAF1PRbSCxX3Ac0IgZeofUdLugVY4jQUrie9ZltKUkR40FK8tw5lIZDh9mo+pWqNcRx
	p1vUxi9c5IGGuTBnXwty0Ya3jY/3cDTcC1Y1PN1OSOE245QY/iHz1dhrB7PwM9i8oQ9oP3msPRh
	RfRUcCg/yWl6YNnDRyuGlgr
X-Received: by 2002:a05:6808:508d:b0:486:45c7:34c5 with SMTP id 5614622812f47-4b2ef40e01fmr8788610b6e.17.1787329770131;
        Fri, 21 Aug 2026 09:29:30 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:29 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 01/23] NFSv4/flexfiles: reject a stripe_unit that does not fit 32 bits
Date: Fri, 21 Aug 2026 12:29:05 -0400
Message-ID: <09f50acb9f481b3a9c3716e8f70b9b3dbe81888c.1787327939.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1787327939.git.bcodding@hammerspace.com>
References: <cover.1787327939.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

ff_layout_alloc_lseg() decodes stripe_unit as the 64-bit value the
protocol defines, but every consumer treats it as a u32:
nfs4_ff_layout_calc_dss_id() divides by it with do_div(), which casts
the divisor, and ff_layout_pg_test() copies it into a u32 first.  A
value that does not fit is silently truncated, so the client stripes on
a unit the server did not specify -- or divides by zero, if the low 32
bits happen to be clear.

Reject it where the existing zero check already is, using -EINVAL so
the layout is discarded and I/O falls back to the MDS, as the fh_count
check below does.  That also moves the existing stripe_unit == 0 case
off the -EIO exit it shared, which fails the I/O instead.

Fixes: 20b1d75fb840 ("NFSv4/flexfiles: Add support for striped layouts")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index c4aa995026f6..74b75d061c6f 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -515,8 +515,11 @@ ff_layout_alloc_lseg(struct pnfs_layout_hdr *lh,
 		    dss_count == 0)
 			goto out_err_free;
 
-		if (dss_count > 1 && stripe_unit == 0)
+		if (dss_count > 1 &&
+		    (stripe_unit == 0 || stripe_unit > U32_MAX)) {
+			rc = -EINVAL;
 			goto out_err_free;
+		}
 
 		fls->mirror_array[i] = ff_layout_alloc_mirror(dss_count, gfp_flags);
 		if (fls->mirror_array[i] == NULL) {
-- 
2.53.0

