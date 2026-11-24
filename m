Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.49
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795526681;
	b=avrLq2I+MoaKxgW026lWVwREzAWufKJKVyI9Eo/T3QOREn5Wpz2QkRnRrVpnIkId6mR1
	 k7d4CniQym4kYU9hjlk/lV4utNv3EUNkuaPQrPEr2jxCq/cabBq9DHxPEG0/KitdPMGeV
	 +r13ek/5YmXL8hQXkasoFLIDirvqsPSdxk5ATCQPQiv00mp32OEyIjAb8AAsRjjb9LaAB
	 OKRjiJMm4TRaw3XqrGZArmAn/iwuKmiF18MVPqJLqRbgFvXJh+4srUMRkvXl7ajfSdAOa
	 fLdMdvVY5hwrGfSGWNUZYtuXIjZUrErQ9VkLfMjyxsFY2zT8lmDiGLSoG5ZE6zjdrSQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795526681;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=Jg/IvZ+CqBAgcG+VV3IUxltdhuj6dsssOpvBwe9TDXk=;
	b=g0mFJhZW6a2R1EpBxLMV6KhavXbALWmQwv/znewH4Toox/2g+CmFu0dAXrBTtbaYcakm
	 K+qPvktyFwhOrs3EFSwwAEA96HRPVlLGWZPXhW+rjI8Xy+weVmlS3xSV1m2ZsjWUdKjHY
	 Riaua2H7DF8wsb6ldLuHh762fqJdij/LZk0GlbZHmRY89Vi+bEH4I/aI7z6wfFZHCQOu4
	 syQi+/gMfPZw2sXZlq8Ht/vvjafWnW12I29DbOJy3yeGWc76Amkma70mKqWgcJubZ6Ms7
	 xRZuiSul+Nd9/PUcpA0MpPNzJphLiYqE+FVUbucLt/sPalIsGBxmBjmOLHFVpEKSM0Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=EbzNxOOT;
	arc=none smtp.remote-ip=209.85.218.49
Received: from mail-ej1-f49.google.com (mail-ej1-f49.google.com [209.85.218.49])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 96E9D606A31E
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 13:24:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 96E9D606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=EbzNxOOT
Received: by mail-ej1-f49.google.com with SMTP id a640c23a62f3a-c4d21051042so726833166b.0
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 05:24:40 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795526679; x=1796131479; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=Jg/IvZ+CqBAgcG+VV3IUxltdhuj6dsssOpvBwe9TDXk=;
        b=EbzNxOOTcB1clHjTg6KwEBbsSUYEC5KYdwdNXHOro6UDKY2cBwUEmf7YomcYa9eIK/
         ue6qrNs25TiB3MmuqOtmv3BtguO/lMtbdAvvMgkNk8ldGkVMrMmGGSjxEhKehmf0b3DM
         BpVqlNtl+PO4CX5+7C1/ex0/TqmK0BuOxrVKB8ylR8wTQ3/ESWg1owOgTlpAddhHK5Uk
         aaksIPL4brdPgDeue4wXWkpT+KO+hh3Kx6b1IsO0lSy4szZcW5JDr3l6Z9im3YCcS/ZQ
         F+wf9XrjgquDTqsnFq7ni/fB3wlV2T/KStstbvzSVQNhzu2JRHTe/CCLYG3zBjVkNDTH
         kGTA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795526679; x=1796131479;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Jg/IvZ+CqBAgcG+VV3IUxltdhuj6dsssOpvBwe9TDXk=;
        b=2X8GA7DIddqvIPAk2kQbKWsLf7DKXj/7kTjYchB85d7p3szRpQMVJtZCpMgAiNIU6Y
         BoJSaOHE4MEcDlbGUbNK3oLgnJ8USJWEQN3O/KZpyV+jqdfvCageelrNvPf7YnvxK7d2
         7tA4ZJZ3vaCpH3FVS48pqjlkvDR93oiIw1FPs+eNOmLi/YFtqpXIm7TA83p7n9KTmC2V
         PIS/6fN9mZ9rqbsqrYf+CMHqd+unAJIKrH2hHH9HcJFuRdKUvRSgqKIs3bNJfdwmvC1R
         KrdCnnNg6OpKXwyUel/qShhZGTrpM7WBc59/YMEvLIblslDUSqDRh1TvNu0Nqn1p2yMc
         58Sw==
X-Gm-Message-State: APuU4Z/CEoaFFGLKPGV59Cqt5cpg28ksFzqAiuTQrTZBQhde12Kbq/dJ
	jlSe+e6H0ZmXy/554PA66vKR7L27QHm1zO3Txt+jFIoTfjMLwmGd2i49
X-Gm-Gg: AZFdTZc+AwLX5Nl02hUwV6N6lSe4JCdkMQkvAF+z1J5fzVt9jvbo1YHYPNz2C37OO6f
	Am1ei0CenXjeHZGB5N0IfHeog4AMcAgyfTeIseXSibaPuxtyWs80Xprxo4gcbfmdpAR+fj2abQw
	qL1F+LG3fkndM9QkIBWxsMxVwfWAIHrP5OZgohvxSU3G0lflxi2zPo88P+FEXSzzTTOFeumYTMi
	XAU6i1P5irzkU3Z8K6QvDyBoTaclNUAd4cuEHS+QVRlLQxGPmWgGGeoDsi9KZQxFaLPRPc6oKoA
	oMt8RoWIp5xCy/4akF/K9/nATwHtRYjwYR8KjmGF2egMbx94L4+OsLNjTW6UvB4vl9kUg8cW+Af
	zkohse3OHPcc6mF/d5tGjAMOTKVkLl4rak0SPJstsVy/ouZYSBbydTQFgUydrp1oUSyUG+Lb2C8
	qb7a9FfyfsY6YUKbQfUDJZarMga5Ml2/rYKf6a4FmXsas4hRfkszZS2vSE1luXSQALs03/0Ib1H
	QRXSiYkK6DT00VGDtgdrviDI9SZH7taxjPFYB2Fuaugab+7DmR3bx7aHPiXKRiavthZEwg5PpVX
	Q6y1FlVVp0k4jwKav8Q5yORsXmM9wBhRGlq3Cl7v7RqXedxmh1I6oO23pa/Z/36sa/GEHx/VHnv
	X4IOXAKA=
X-Received: by 2002:a17:907:1041:b0:c3e:d0ca:d2fd with SMTP id a640c23a62f3a-c513a5ecdafmr809420966b.12.1795526678660;
        Tue, 24 Nov 2026 05:24:38 -0800 (PST)
Received: from docker-desktop (host-145-14-240-255.wtvk.pl. [145.14.240.255])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c513aeabdcbsm508640066b.46.2026.11.24.05.24.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 24 Nov 2026 05:24:38 -0800 (PST)
From: Marcin Krystianc <marcin.krystianc@gmail.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org,
	Marcin Krystianc <marcin.krystianc@gmail.com>
Subject: [PATCH] NFSD: Accept an empty access ACL in NFS_ACL SETACL
Date: Tue, 24 Nov 2026 13:24:21 +0000
Message-ID: <20261124132421.3698977-1-marcin.krystianc@gmail.com>
X-Mailer: git-send-email 2.51.0
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

The xdrgen SETACL decoders reject a request that sets NA_ACL with an
access ACL of zero entries, and the SETACL procedures return
ACL3ERR_INVAL or ACL2ERR_INVAL.

The Linux NFSv3 client sends such a request when it creates a directory
under a default ACL and the inherited access ACL is equivalent to the
mode. posix_acl_create() then returns a NULL access ACL and a non-NULL
default ACL, and __nfs3_proc_setacls() sends both, the access ACL with
zero entries. mkdir(2) fails with EINVAL, although the server has
created the directory. xfstests generic/319 and generic/697 fail over
NFSv3.

The old decoders used nfs_stream_decode_acl(), which decodes zero
entries as a NULL ACL. The SETACL procedures passed it to
set_posix_acl(), which removes the access ACL. Restore that behaviour:
drop the zero-count check.

Fixes: ae1f4d75a973 ("NFSD: Implement NFS-ACL v3 ACL encoding and decoding with xdrgen")
Fixes: 2125d74330f5 ("NFSD: Implement NFS-ACL v2 ACL encoding and decoding with xdrgen")
Signed-off-by: Marcin Krystianc <marcin.krystianc@gmail.com>
---
The checks become reachable in 96ce1cc333bc ("NFSD: Use xdrgen XDR
functions for the NFS-ACL v3 SETACL procedure") and 2a9b0e5195be
("NFSD: Use xdrgen XDR functions for the NFS-ACL v2 SETACL procedure").

Tested with xfstests -g acl over NFSv3 in UML on nfsd-testing
8489270d1cb9: generic/319 and generic/697 fail without the patch and
pass with it. The NFS_ACLv2 change is untested.

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 8b6e3d717217..ed41fc6dbcff 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -612,11 +612,11 @@ bool nfs_acl2_secattr_decode_begin(struct xdrgen_aggregate_cursor *c)
 			argp->invalid = true;
 			return true;
 		}
-		if (!dfacl && !c->count) {
-			argp->invalid = true;
-			return true;
-		}
-		/* An empty default list publishes NULL: default ACL removal. */
+		/*
+		 * An empty list publishes NULL, which set_posix_acl() takes
+		 * as removal: of the default ACL, or of the access ACL,
+		 * leaving only the mode bits.
+		 */
 		if (c->count) {
 			*pacl = posix_acl_alloc(c->count, GFP_KERNEL);
 			if (!*pacl)
diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index b426b3e64df8..50e5aee8b49b 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -480,11 +480,11 @@ bool nfs_acl3_secattr_decode_begin(struct xdrgen_aggregate_cursor *c)
 			argp->invalid = true;
 			return true;
 		}
-		if (!dfacl && !c->count) {
-			argp->invalid = true;
-			return true;
-		}
-		/* An empty default list publishes NULL: default ACL removal. */
+		/*
+		 * An empty list publishes NULL, which set_posix_acl() takes
+		 * as removal: of the default ACL, or of the access ACL,
+		 * leaving only the mode bits.
+		 */
 		if (c->count) {
 			*pacl = posix_acl_alloc(c->count, GFP_KERNEL);
 			if (!*pacl)
