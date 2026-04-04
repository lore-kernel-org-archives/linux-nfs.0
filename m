Received: from mail-qt1-f169.google.com (mail-qt1-f169.google.com [209.85.160.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6B8B51F3BAC
	for <linux-nfs@vger.kernel.org>; Sat,  4 Apr 2026 02:00:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775268035; cv=none; b=ge6qdeH4zyufuFKcSa6IP574hc+4ylJzwlqM6csNrn+F7GbJV0CnLwKsa+o7+yzMLI6FDDfgeM+R+ZYhA3a+ZM6wKADcmTwU4UwXuVyuL6t3gTFQeiQetKtYazTOeBXZ9IqoRF2Lf+U2RbZ0p8PEepNQpcor77AOJ5MU0RZrUi4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775268035; c=relaxed/simple;
	bh=2Up/ooB1F1IW8Et3iiWgK6r3LpYS5a02mdN+3AgSDSo=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=dSE/ECUxB/RLhrVhiNKLDfO6MKIq1is9JitS7wuXh04btSMtX56VTweSc9x5/U1P9OY/9qm3ieZQhKcgxQzFfKvhoPqjo/ePjvyZQ/5I1TmZ5MCIMZa+22kHJNPr6WMWhlx/dO9jvCTQOlQHyHEGwwDQYOXb1oqEK5ZTWEumWGE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=r96PNvYc; arc=none smtp.client-ip=209.85.160.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="r96PNvYc"
Received: by mail-qt1-f169.google.com with SMTP id d75a77b69052e-506aa685d62so13589151cf.0
        for <linux-nfs@vger.kernel.org>; Fri, 03 Apr 2026 19:00:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1775268033; x=1775872833; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=/QW+xJnpJU8nKA23Wo9lc4Fv12FM04P5h1eCRyd3g/I=;
        b=r96PNvYc7R+Vg291BJtXjNRDArGvhYN9Ccj8rs8iYp/znmc79IBg0IitT/ipZTYs56
         1vES8mAcDzcCw24/lD79EByxBQ59QTdEh9+n0CZy7NZ6DhQq7niMzpB6SoHOuGz6KMkL
         XFWI14a+F9ALu2SW8RWd2TvJ0vtkOygsqG25tjAqcecnSZiwTA+xqrCDVigtB7g+RhYw
         CTvQRwCw80IAJ43BeHX7BUiSCtWQaDhiGCT9aHlcP/Z5h+wWCl+Bz5G5Em79C6+s8R5e
         FHJuAPEo4HpJ+hBN+l/RaBjWuGy4A4nmgzGW8IMduEfdxNqyZ5la8oP5zl5hHPk3a7bj
         uIJg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1775268033; x=1775872833;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=/QW+xJnpJU8nKA23Wo9lc4Fv12FM04P5h1eCRyd3g/I=;
        b=gj/rZqbXm2nnZ2H4q2RzXvrkWdAsO2xzAXC/7lI97bHs0LSzko8cOFZ6lWgZTwsZYG
         Icx2j2aZzBVTqKQGMkkhc4/2jsTg0Kq82tu7aap/juEEVPUnJUlcTExqUSL95OYlHAVc
         vhiWMDqBwlybI3NJGGitiZeOy8xczQnfVD7mckGwx/J1r34vVbtEHRPyVCRNai+XsvuU
         9c1vMyaJWoHvb6oq7wgmcWAeKdYN65aWlmbaEnJsq/fZqVGPTa2cRxOg/VizFaQUUsEq
         Hm4XvpEecD+orMiZqSv9J1sH6L1py+L4MazyStjzjW1pvHCOrydwAD+aHahmlI731mwQ
         vejw==
X-Gm-Message-State: AOJu0Yz0kgHegma/z7YV9hJD7BQFnYposiCTm98TXpEN4rQhw5I4QS5S
	dmCApsVWGKugzm25l3ISwBjCSxm5D3F0r4aX9842qfR8tZv8IXmr7ZwJ/FpTI0p6
X-Gm-Gg: AeBDievgxI2ZSoxLVIMtq9RoaowfLByFKE70StBHVc+++nZD6zLHoiw0XsH2Eu7jHe4
	h2G+HcxVHQ+pUVUfCeAn/12jtXA7OnuTfPaSDiKkFkN053trYXHBDl20PDiQYHCsfRYQ8F1KX0r
	kbfc9SJQAtz58i2Lfqh7f2JFsUKlCGYuAV75MjU2k/3OQ5w9BQgJJmlQBhCv1NzY0Z7MERqESeG
	qXfhL3IVVweayNluWVpvbPdxuy4GcHUD94aVYYX4S0qNXLNtb+ItOQ4T6qJQxMzlLhIBmyM6YEF
	7qOqrbb0YJdtKiRDJ42C28k+3AzDQwM8HGUHwsjgiv7JL6SGpSdbCzGgkKdXXF5g1A0HG7YU9OI
	fF4InN8CPsy8lKjjFzL3/ne3UVqGGHIQwAEfyOJKa2E/9auqCtS1YF1yl/KIYHS1GC/QZx0u2G0
	CxfQ6IbdVX5INT3j6OWPjqShHYBSd/QgLUGEw89o5RCjI=
X-Received: by 2002:a05:622a:41c4:b0:50b:52ee:62b6 with SMTP id d75a77b69052e-50d62ad9332mr53933351cf.38.1775268033237;
        Fri, 03 Apr 2026 19:00:33 -0700 (PDT)
Received: from desktop.. ([2607:fea8:d681:2400:aac2:af07:379d:ffaa])
        by smtp.gmail.com with ESMTPSA id d75a77b69052e-50d4b8a8f38sm57316941cf.24.2026.04.03.19.00.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 03 Apr 2026 19:00:32 -0700 (PDT)
From: Tushar Sariya <tushar.sariya77@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Tushar Sariya <tushar.97@hotmail.com>
Subject: [PATCH 0/1] NFSv4.1: Apply session size limits on clone path
Date: Fri,  3 Apr 2026 23:30:24 -0230
Message-ID: <20260404020027.3327248-1-tushar.sariya77@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

From: Tushar Sariya <tushar.97@hotmail.com>

The NFS automount clone path (nfs4_clone_server) is missing the
session-size clamping that top-level mounts get in
nfs4_server_common_setup(). This was exposed by 2b092175f5e3 which
changed submounts to no longer unconditionally inherit the parent's
already-clamped rsize/wsize. On servers that enforce tight
max_request_size budgets (reported on Dell EMC Isilon/OneFS), the
child mount ends up with raw unclamped values that exceed the session
channel limits, resulting in NFS4ERR_REQ_TOO_BIG and user-visible EIO.

Note: I was unable to reproduce the exact failure locally as it appears
to require a server that enforces tight max_request_size budgets. The
fix is based on code analysis — the clone path is missing the same
session-limit clamping that top-level mounts apply in
nfs4_server_common_setup(). Tested that the kernel builds and boots
successfully.

Tushar Sariya (1):
  NFSv4.1: Apply session size limits on clone path

 fs/nfs/internal.h   | 2 ++
 fs/nfs/nfs4client.c | 4 ++--
 fs/nfs/nfs4proc.c   | 3 +++
 3 files changed, 7 insertions(+), 2 deletions(-)

--
2.43.0

