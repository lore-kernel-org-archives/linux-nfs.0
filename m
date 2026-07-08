Received: from mail-pl1-f180.google.com (mail-pl1-f180.google.com [209.85.214.180])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 10F973F0AA9
	for <linux-nfs@vger.kernel.org>; Wed,  8 Jul 2026 07:44:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.180
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783496698; cv=none; b=LX+heqLKR5OX2PoHd5paSWQsxNdW7Z0WuIxTgrjcgiZvjXnYUVK2z8ZdlKw/nKnc6H1ocYbzooyuP1v1Cf6TP4eOHIbBy2aU3sUojC1LYKN3yVir4lJu8DIYStYfzh/7NUp7b1XJ369tlKu4+m3wFRW2fqEJqyy3uNXs2D7H6GE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783496698; c=relaxed/simple;
	bh=5wgIhcz5dUbyLc6gsqkJDqa86lbI69k4eZmdDL38RUk=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=iBckfFl84M5hGbcQi6fFtzVMI6g4Mjntn8Oo5ZGluk792p3D9+Gv439rMRX5WDBJ8MDL33Wi6w9xct6O+WPreHBQIpv6wTqVlbu5Yg1aLD3rpj4Ct9zFoqPx5m24mxHfuix1EIXphyo6PghJyochlITtIQxtXiiwC+Njuj29+oc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=FIPr7LUV; arc=none smtp.client-ip=209.85.214.180
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FIPr7LUV"
Received: by mail-pl1-f180.google.com with SMTP id d9443c01a7336-2ccdb73f0e1so3870235ad.3
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jul 2026 00:44:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1783496691; x=1784101491; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=2+AAszIXf7+JKb0b1PUUMxwKBwibCloV+wRATKmETRY=;
        b=FIPr7LUVeqE7CN3jGi0tes4o3OEcoeLKZKASLSgLciDPEG2PzWKu7YqJoWC0CoFew/
         B9HTcB6KpSdD3hTPQStT5smu5ZI2PxwLGEg0XIDPVoNlQ1eLerZwPEBtwBJ/tL2qQ4x6
         BFfgI8Hn/E5v/tXajy53vTla29A3Wg9wpPxTuOBJ65qbk6lYNMkIz90Xh0ZUz6Ce4/ly
         YHX/42yT8SbFjPJ/82DEQkFvRv395w8uNx0BOrYsbW9Z5V9aaGBvb4CtedSxIA9tROs6
         +Qpn6XdDtoaSCTzNKVlGf3p6cHj+V+Us7zbsvKiGlpLRAlQ6WjYQ5nzvpZOvk/WyMSr4
         Y/5A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1783496691; x=1784101491;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=2+AAszIXf7+JKb0b1PUUMxwKBwibCloV+wRATKmETRY=;
        b=fywOsXPyiiiAtkgmjZUFxKDpqbUHH4/6QiluFopUm9aZGNiH7K0gO5DZ188Zuji4Zq
         Etu+ZTh8Y5t1qtkSSUoyEZc8zXuChEAotpwf+dTsThggG20RDW9ozTIWoUKTTZCeLQxi
         /94llhBo1hrce9yTQTK/4jLLYrqz1N8G2D6OMlrSSheazueGUh/nU3BlECG71rCa21Dz
         eZAe9hK+lU/qhAoFvUEmcHH2j6Nooea6I7fPhbw1CLBNzQb97CMQP4p1a0J6lqxHLpch
         IqIL3JwpMn7WlRwryOSkTA13bx67w42Mc2oXpuSuUi6IuvVTbbcfqDPwTiEPqrbujRrL
         352g==
X-Gm-Message-State: AOJu0Yx4U8ewoQF/Y0OO3xxTj7Un78eODoDbizTafVnOmPNPmmzUMSlh
	h33AMeJsofIMu2eRdGz/OKy04EdP4R4oZKjFPYAxeEq3jWvr8nnGtQKB
X-Gm-Gg: AfdE7clDtGLpRyroLfS6WW+WN6hw9GE9/yVQAZl4jrPki6EK7Lt4IrhIbtT42uxS8WV
	nM+Q/otVVWL8Sts9YTf+KxK/c03nIwPBLeblHw66plKg1u96Rd8+njvby84sNdaVRehnaGPOiLs
	NrF3mQouad1wfRB2uKpM1DObCdwy8Vupnt3OOlHGD5Dhv+j65xMQ1r9sNHz9GrT3hnFkTIgR+bm
	+EoDpF4xiaNe/v5pWiirF4uud78s7JWm0R9BJzUBOi27pfWxcRAaNeBoY7WIhF8RXgAxhFGRGYO
	cuF5pnzgyWThPydjr8cwz5T5n+QPa6sNbj/NBVR16LfZ41HWSrHeADrNCH+dcGgTmkWT/dyl9OW
	wPtFVbIvfUDo+mwLGIxTJwZn3XKFjy/0HD4Ly7KWE54bnqu7cD7E8tS6Mn9LYHJTJVmKnVG0GdJ
	nsYhQovhsxjx62pFK8cPVu
X-Received: by 2002:a17:902:f550:b0:2ca:ed57:8586 with SMTP id d9443c01a7336-2ccea45aa02mr16102925ad.23.1783496691089;
        Wed, 08 Jul 2026 00:44:51 -0700 (PDT)
Received: from jeuk-MS-7D42.. ([211.226.54.223])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2ccc9bfe040sm23932035ad.31.2026.07.08.00.44.48
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 08 Jul 2026 00:44:50 -0700 (PDT)
From: Jeuk Kim <jeuk20.kim@gmail.com>
X-Google-Original-From: Jeuk Kim <jeuk20.kim@samsung.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
	hui81.qi@samsung.com,
	j-young.choi@samsung.com,
	peng.yun@samsung.com,
	qian01.li@samsung.com,
	xing1.he@samsung.com,
	jeuk20.kim@samsung.com
Subject: [PATCH 0/2] NFSv4/flexfiles: support loosely coupled data servers
Date: Wed,  8 Jul 2026 16:44:31 +0900
Message-ID: <20260708074433.390161-1-jeuk20.kim@samsung.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

RFC 8435 allows a flexfiles data server to be loosely coupled, i.e. an
NFS server that does not advertise EXCHGID4_FLAG_USE_PNFS_DS via
EXCHANGE_ID. The client currently ignores the ffdv_tightly_coupled flag
and treats every DS as tightly coupled, so NFSv4.1+ I/O to a loosely
coupled DS fails during DS setup.

Patch 2 threads the decoded tightly_coupled flag down to the DS connect
path and, when it is false, skips the NFS_CS_PNFS flag and the
is_ds_client() check.

Patch 1 fixes pre-existing NFSv4.0 DS crashes on the same path (the DS
client has no session).

Jeuk Kim (2):
  NFSv4/flexfiles: fix NULL dereference for NFSv4.0 data servers
  NFSv4/flexfiles: support loosely coupled data servers

 fs/nfs/filelayout/filelayoutdev.c         |  2 +-
 fs/nfs/flexfilelayout/flexfilelayout.c    |  3 ++-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c |  3 ++-
 fs/nfs/internal.h                         |  3 ++-
 fs/nfs/nfs4client.c                       |  5 +++--
 fs/nfs/nfs4session.c                      | 21 ++++++++++++++-------
 fs/nfs/nfs4session.h                      |  3 ++-
 fs/nfs/pnfs.h                             |  3 ++-
 fs/nfs/pnfs_nfs.c                         | 14 +++++++++-----
 9 files changed, 37 insertions(+), 20 deletions(-)

-- 
2.43.0

