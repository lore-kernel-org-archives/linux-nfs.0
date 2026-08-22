Received: from mail-ed1-f51.google.com (mail-ed1-f51.google.com [209.85.208.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DAA6C3AE18C
	for <linux-nfs@vger.kernel.org>; Sat, 22 Aug 2026 08:10:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787386241; cv=none; b=I8daxQ85kfl65fhfVnRrVa750cWwZKXztraSqr6+U3xr2pIeloCcWh5VHPYvusCfWGCk8PpRRLuyQFzRi1SGWBbaYGTLaFIZibuB1mxsPyhRjHp9BRrdt0Tn8acBDq0WQWDdeOn5nzPkTcOIyuTnPksi1oDADp/gf0rc8/IKOi8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787386241; c=relaxed/simple;
	bh=8dpBHV5ZpKgmc3MhvnVoObSzPNUFx4cCMcQA9FwXJRU=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=bV0azRpQd3QP5NTdZb5hwwQZ70X8NgjtvOHEqKTH1z6ByU9rsQflgf0gnSuQ5T9CmxJwL1+Rvt+IaSyJkl+kxBssExqkjvFsHjA/F/nJXnJXdyo9UWNx7Ry0j7F/q4f+mT4jf/h5nhFa21urlw3B8VdKcVcu97Psc6ccvuwesbw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=PckETiqB; arc=none smtp.client-ip=209.85.208.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PckETiqB"
Received: by mail-ed1-f51.google.com with SMTP id 4fb4d7f45d1cf-6a378f90555so3098006a12.3
        for <linux-nfs@vger.kernel.org>; Sat, 22 Aug 2026 01:10:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1787386237; x=1787991037; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=zBRw/luZ5nn4J7WrRRWBVfkjR8lUWIDEN9VTq8ggW/A=;
        b=PckETiqB+aFHOyxJ6UUf3Isiss3S5ufiCYWmsSNdi5kv8NETowGECfVZZwfNF20+6I
         9584dByRiRvYgK1nuBTStkVtcsGTQLXNsg0LuYb+wg4DGCzpUnP2/mPGk5XoALqsiAO/
         YUh0VgbRipSMM9lFi5+rMb61NrFScR703O6l1RWOw0WKhAaaQuVGcU0lfLC3jYRaZaR/
         RbsHGowDZPzu3Oz7qTIqhfMBaIV6N0vchf/YIodz2S15qE0sQYR6nVweWmwOuFoG5+kg
         pxN6DDz2jG982JiqRLhiik90QfY1jFOKf+bhy1r21fW0eqM/A9s2oxJLK2sNcwypy0LB
         fhqw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787386237; x=1787991037;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=zBRw/luZ5nn4J7WrRRWBVfkjR8lUWIDEN9VTq8ggW/A=;
        b=V7KTC/HNub239NAige2jg9ayr9YjyWT0g8duDFdCypRDJwiLOts5RG/pTtTbtsERft
         o6aa7DEEzktO76RGfPPfyGi9DwnQ9IhGtokcof/pFJVquCSGGr92erqvlhdzkAAaqllo
         5X3G2yB2r0T6LEcoU7rEqONU1LxjWvJUkYs2d+Xe1bpE2XJFx93Jr1kpsamTsLRqGdon
         s2PGVUN6hzcvi2b+gIVZax2V0H3klKa5lXjLoHSeVpqzW1+7z/M9uRP2bHfQ82+ZTzQE
         JCsog2YRO3fml/7QZMoxnQ4FbFoSEjFcXUsnDISKMuY2ycsTVqrFXupojRCDLdmcIOGi
         3TGQ==
X-Forwarded-Encrypted: i=1; AHgh+RoBf0tS/mVYfDlqx1U5iX11JvJM+DCbwQKepWE8HXM4x6TzMH+loq+9VQOH0yHzSpqQqu7AZSRsMQg=@vger.kernel.org
X-Gm-Message-State: AFuF++ndTT97nzPbVV1MTTySh6E7qNQkAXirrFooOVmbQOKgstuz4rjb
	THjKX9NXe4CmQkU49DK+8ovLgueNMIhZ9euCF5G1sLlSUCRw2fsMz1RP
X-Gm-Gg: AR+sD11m2cOyOuG+xXhV1JKPyQRZyOerUR4m7Q4xcBZHrDEa1847Se0mkTmkxg+O/Ir
	0+bJyQ6H2kkkTK5o5fj/kPhtgDQ6+PfG8SBGwwMqspFBSsJMgOC5qgHqOEUNfHD6wConPMyxWl4
	9Kq1C69FKfbkJQb15AGnIK466pukjxXXX+KYe71dgjcuwcYX2XBI8GwnJ4lLIjdEEPEe6MBI3BO
	/lcL1+egDgyq2idX7dPdoTKMAr7kHeIKULFIDOEs5jEHUJvBJp8UTkl7xKc6INnIu3zPeJJ0dyA
	xQntLnjndlgITTMU4rDA1+Cbhid6EDz2NAP6tS87TUcnrK8o7viLgbb5Qj5YaRhY84zJlxZJtLq
	I1SaweutZi4Lvq24cQXrnx7UPGLR7gnZid8GtDAFsNyCKJTTNEmdHZp5pTsa+A3YO/kzXAA9Cut
	QAc9XioS7O/zwuZVhjKLsOzkVxa8m9K5JQ1yHUWoqFkISHBcR4YvqBUjFZz9/KHAo4orQsJlZTf
	zNChL5Q0sgvPjlfs7vJ5juD9XDzXHs+pNHE/ezrgrlPCJtoiQdcQP5LsnJt5uu8e1LyMfMYOwxn
	HRABy8ogWBy/hWGxeyiqMcw6HApGWyN92lBx898JuZI7t4OHi5i8qCaDTphUvlz2WmTT/u+mgQ=
	=
X-Received: by 2002:a05:6402:321a:b0:69a:a4cb:2882 with SMTP id 4fb4d7f45d1cf-6a42f216beamr14699761a12.9.1787386236851;
        Sat, 22 Aug 2026 01:10:36 -0700 (PDT)
Received: from localhost.localdomain (dynamic-2a02-3100-a0f5-8c01-3de3-cd62-aa6f-2fb0.310.pool.telefonica.de. [2a02:3100:a0f5:8c01:3de3:cd62:aa6f:2fb0])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-6a3ff177859sm10413456a12.27.2026.08.22.01.10.35
        (version=TLS1_3 cipher=TLS_CHACHA20_POLY1305_SHA256 bits=256/256);
        Sat, 22 Aug 2026 01:10:36 -0700 (PDT)
From: Karl Mehltretter <kmehltretter@gmail.com>
To: Chuck Lever <cel@kernel.org>
Cc: Karl Mehltretter <kmehltretter@gmail.com>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>,
	linux-nfs@vger.kernel.org,
	Jonathan Corbet <corbet@lwn.net>,
	linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] NFSD: docs: Fix pNFS SCSI Kconfig symbol
Date: Sat, 22 Aug 2026 10:10:33 +0200
Message-Id: <20260822081033.82098-1-kmehltretter@gmail.com>
X-Mailer: git-send-email 2.39.5 (Apple Git-154)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The pNFS SCSI layout server is controlled by NFSD_SCSILAYOUT.
NFSD_SCSI has never existed.

Fixes: f99d4fbdae67 ("nfsd: add SCSI layout support")
Assisted-by: Codex:gpt-5.6-sol
Signed-off-by: Karl Mehltretter <kmehltretter@gmail.com>
---
 Documentation/admin-guide/nfs/pnfs-scsi-server.rst | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/admin-guide/nfs/pnfs-scsi-server.rst b/Documentation/admin-guide/nfs/pnfs-scsi-server.rst
index b202508d281d5..a3074450ac158 100644
--- a/Documentation/admin-guide/nfs/pnfs-scsi-server.rst
+++ b/Documentation/admin-guide/nfs/pnfs-scsi-server.rst
@@ -16,7 +16,7 @@ addition to the MDS.  As of now the file system needs to sit directly on the
 exported LUN, striping or concatenation of LUNs on the MDS and clients
 is not supported yet.
 
-On a server built with CONFIG_NFSD_SCSI, the pNFS SCSI volume support is
+On a server built with CONFIG_NFSD_SCSILAYOUT, the pNFS SCSI volume support is
 automatically enabled if the file system is exported using the "pnfs"
 option and the underlying SCSI device support persistent reservations.
 On the client make sure the kernel has the CONFIG_PNFS_BLOCK option
-- 
2.53.0

