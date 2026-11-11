Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.219.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794438097;
	b=aRCOGGqBUrdWF4EDqXvdw95DIW2Zq7pAXklpVxZ2ocpp9rd8LxAABd+e8eOiZgH31Om8
	 JIdwUzU8TBDzqWrDej9yrlWekRkIfRBExxtScetjcyZkXpRYiteapI0oCTuln3VFAl0aA
	 tPOWchY8p76fPwiOZRnrG3yMCNcC470++wFo6aEbboC50jeRb+eWIs7/z95V4IS4uGJ+5
	 Budm+2DNlx8KkeBQegpoLiTtONiAgGKbnxvl460DgatrvmdsdPI4WpSF4zLXFHj2G5WVX
	 tFDiyNTLMTYVu7jcVWMRYDNKrW5UanH5twTnLYcf9F8JxKM8ps2JuAvvSMFE8Tg8jaw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794438097;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Sender:From:X-Google-Original-From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=vrjxIwYzgzIno/ZvKWb4GfBW1iRpVpfDFeiRjMrdKCo=;
	b=BVGP6mbhHo4Y5g0cfMSg57Q7Q7Az2jYbuCaAHghD5iKVRl5VZcYh08rZWCzJ2Ys+cpms
	 MGrHUeSAysNCywup9ij7hRUw1pZfxKkFuhLjVrv82R8RCyMxovQpP+ksS9ga8mn4WmOyd
	 9LenXP1XgVxxxLxMST9O3N41Vb3ABnZnPjLu6OkS7JipfIi6NW0AyJ2uadmBM6jyqR4dI
	 tV+n5BXHZSEnHpur5vHQ4+iYGv/9an7AkyUTOP9ePHnnzs+aADLuBAel/5S8dM5fXvGfk
	 9aAz1WRCsM2sU0PHSRNivfAxtEtG19qzEY08D0I0Kj5BGVGYU6b+fBxsGhUaxFs+T0A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=IAgA8Ftr;
	arc=none smtp.remote-ip=209.85.219.47
Received: from mail-qv1-f47.google.com (mail-qv1-f47.google.com [209.85.219.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E1518606A336
	for <linux-nfs@vger.kernel.org>; Wed, 11 Nov 2026 23:01:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E1518606A336
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=IAgA8Ftr
Received: by mail-qv1-f47.google.com with SMTP id 6a1803df08f44-91f0b9f0b1cso7938926d6.1
        for <linux-nfs@vger.kernel.org>; Wed, 11 Nov 2026 15:01:36 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1794438096; x=1795042896; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:sender:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=vrjxIwYzgzIno/ZvKWb4GfBW1iRpVpfDFeiRjMrdKCo=;
        b=IAgA8FtrnA7XZuPG3Hwe6HbxqkONUzUvxcz8f9YPOLPxN/wTIUtknO/bs7UNGoqr//
         ro0l87l7i+UX4E26pFHzHFIjWZFZNipuAKBWz0+u+q2MPtTbN0aCZ/2qxX4dADUdmNi7
         +sQQ/+aH4SQwDbM0wangc7+82OHyG1VLZpQFvuv6yTUmnRHnmiZgURM96n6DGUatbz+2
         EJaX+sNIDP29JRh5JdMAMX90IVheeRl/I1/YaTEcRzM5AYecFxrJ1KKD4oPTnc3oT+Hz
         fSbyF8/cVkZl/V0/BnTqcMpUmw8DdduoYu3lc2Y9od55CJ0Uy7elEH45PnhDquwCcM+R
         11qg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794438096; x=1795042896;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:sender:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=vrjxIwYzgzIno/ZvKWb4GfBW1iRpVpfDFeiRjMrdKCo=;
        b=jCQtJpgQke0/JoXGULlSBFC8mwzr8YhGw1Osr4LYuv0OicSgGZ62adO4ydMc9mkhZm
         D7jyYpIYNzDFtgdnbMVQ4uj1XoFWYH42WHhky5X//qXVbjuuE0BPVEJwYMiBz9QdFaYL
         KYAfIckDAaA/eiTREndu6i2MJGn6EhdgJil2za0Q0p4gEeD0SL5AvQxwc8XjqegzN2/l
         FWQoyV91yhUMDxDmDYRWSrgNTSXi40K2XRgm8scz+k8KYuCzTHEZ0NHea9rCy44iiJxx
         TUx+8RTijYyJHvbmRxa477vHQsbd6pOkC0+1vHFGUA2vtbTl5AtU15vzUKwgUINDJA6K
         zyHQ==
X-Forwarded-Encrypted: i=1; AL+hErFHUVCWqiwWb9kVfTb2po/LWArmoo93N4VovjdQfiHYGNcnDPKQqsXgX5iFz/HpBcFNQ2Ps5UVwHFM=@vger.kernel.org
X-Gm-Message-State: APuU4Z8StFub+7AZc9nuxYqRSfUiu06PGSwAh7ud3gGElgDojAHnxlMt
	1sLGwbsjTZeMdpVmryWdYnCda+y7O05qN8HGfziCfb1tFLGmdD0bhwJ+svQostHtFgM=
X-Gm-Gg: AYBFou25XXzhlO+tlBRLCSJLhgClOKZncFrv8e/3u/ktDJRkcDPonksvSlJSZvxPN1p
	0os256GOOl0Cp7OEE2yUBY1nksxNSwetSNYHh1POeoG98XhjD6WtqGMhcLja68ay4jEtC7Y4k4o
	GlypOAfUgQtMx0y8tLRO20jycLAg6IxKZCUg7BttdLtOJ+so6aoJEUvWr0ConDrfcN4yu09l0R0
	kNndPVjr6sf+Cky+1ymIfglmP/0p4X2L0I6CxVtJebDnOosFCk8wlH0cdVS7fkeXi9WsS3o3xgv
	VIYyJ3VwTfEfbRA+TR9zGlGHsnKwFlqJwEUS5528/yzdfva5uuT1oK80PjqpoAzvOcrdG+YuLUW
	iEWIimo+yjpS9QXZkOYCs9zZ2e2Az3Ys2FY2l912cbumnPUP6ShdC03Qrel4Bq1fgM1lMkATEPK
	okIijyaN7g5PFg4Qk/mJ1UcZH+Kp83VAlerZbpSQKW9lGmpydnUwvmvjJlZxP4Z3D5esX+irKg7
	hlfNVhJ/IDfSTyZKRUrj9yoCbBV20kSxeDyuPfkHi9rwbM89gYu3SQopCSmAtGJQELXwEeh57hf
	9HYf/55YuIBDeQJ/U7P3D5iPLu4Qsq3Zff9mfO2YgklA9Ur4/NxMqfiMd0De9/rp6XoQO5fDcJA
	BdPS01EaV5QkWMZg6jY8VwVJ/49wa56o5wZcOKHM=
X-Received: by 2002:a05:6214:2301:b0:91c:9002:6286 with SMTP id 6a1803df08f44-91f040e1132mr68269396d6.24.1794438095239;
        Wed, 11 Nov 2026 15:01:35 -0800 (PST)
Received: from localhost (pool-68-160-167-46.bstnma.fios.verizon.net. [68.160.167.46])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-91ef051dc53sm57384976d6.32.2026.11.11.15.01.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 11 Nov 2026 15:01:34 -0800 (PST)
Sender: Mike Snitzer <mike.snitzer@hammerspace.com>
From: Mike Snitzer <snitzer@hammerspace.com>
X-Google-Original-From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: [PATCH] nfs/localio: remove the localio_O_DIRECT_semantics documentation
Date: Wed, 11 Nov 2026 18:01:33 -0500
Message-ID: <20261111230133.65304-1-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
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

Commit 25ba2b84c38f ("nfs/localio: avoid issuing misaligned IO using
O_DIRECT") removed the localio_O_DIRECT_semantics module parameter.
LOCALIO now issues an application's O_DIRECT to the underlying local
filesystem.  It issues IO that is not DIO-aligned as buffered IO, so
that misaligned IO does not fail.  But localio.rst still documents the
parameter, in its description of how the client issues IO and in its
list of module parameters.

Remove the parameter from both places, and say what LOCALIO does with
O_DIRECT now.

Fixes: 25ba2b84c38f ("nfs/localio: avoid issuing misaligned IO using O_DIRECT")
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 Documentation/filesystems/nfs/localio.rst | 24 ++++-------------------
 1 file changed, 4 insertions(+), 20 deletions(-)

diff --git a/Documentation/filesystems/nfs/localio.rst b/Documentation/filesystems/nfs/localio.rst
index 45c6981da0d89..9f1eb2a3c2db6 100644
--- a/Documentation/filesystems/nfs/localio.rst
+++ b/Documentation/filesystems/nfs/localio.rst
@@ -272,21 +272,10 @@ is issuing IO to the underlying local filesystem that it is sharing with
 the NFS server. See: fs/nfs/localio.c:nfs_local_doio() and
 fs/nfs/localio.c:nfs_local_commit().
 
-With normal NFS that makes use of RPC to issue IO to the server, if an
-application uses O_DIRECT the NFS client will bypass the pagecache but
-the NFS server will not. The NFS server's use of buffered IO affords
-applications to be less precise with their alignment when issuing IO to
-the NFS client. But if all applications properly align their IO, LOCALIO
-can be configured to use end-to-end O_DIRECT semantics from the NFS
-client to the underlying local filesystem, that it is sharing with
-the NFS server, by setting the 'localio_O_DIRECT_semantics' nfs module
-parameter to Y, e.g.:
-
-    echo Y > /sys/module/nfs/parameters/localio_O_DIRECT_semantics
-
-Once enabled, it will cause LOCALIO to use end-to-end O_DIRECT semantics
-(but again, this may cause IO to fail if applications do not properly
-align their IO).
+With LOCALIO, an application's O_DIRECT extends down to the underlying
+local filesystem. LOCALIO issues DIO-aligned IO as O_DIRECT. It issues
+IO that is not DIO-aligned as buffered IO, so misaligned application IO
+does not fail.
 
 Security
 ========
@@ -325,11 +314,6 @@ LOCALIO.  The mount's timeouts do not apply to the probe.  Set to 0, the
 probe uses the mount's timeouts instead, as an NFS RPC would.  A change
 applies to the next probe.
 
-/sys/module/nfs/parameters/localio_O_DIRECT_semantics (bool)
-controls if O_DIRECT extends down to the underlying filesystem, defaults
-to N. Application IO must be logical blocksize aligned, otherwise
-O_DIRECT will fail.
-
 /sys/module/nfsv3/parameters/nfs3_localio_probe_throttle (uint)
 controls if NFSv3 read and write IOs will trigger (re)enabling of
 LOCALIO every N (nfs3_localio_probe_throttle) IOs, defaults to 0

base-commit: 5e810a57a1cf2fc785d89e711ff40f1112f6404c
-- 
2.52.0

