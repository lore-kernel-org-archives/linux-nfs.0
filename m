Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.182
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795777009;
	b=lVhlXr3zyBuPlowsGeCR9HoaYidXLNA+XvMzUSpyxqWnnKantLFbr5gmiGZIqQTi06ic
	 BADiuV4KYPXLmiAxDQAqJ4OrniC9YFB1k4QPOTBiwZjzF/wkFTVc2Pgm0m0U9G35Xi6jO
	 XZwhKZI6xi8R3Oihgqz5EGy3/KldlPRBhDye3Z9MAu5/mf5eKeg4PhVinpCd8l3IKyK74
	 hEGEilzCUmL1xbfXs2AugYN39YtyWiebbzoXyBLrVGSOHBhY5/WQzqB9RmdQg4owkoqNX
	 0aWGq2EFCPuJkIITl8OCrvScCX3/JQO8QYP/nkr58nvONmtfR4Dbt0/OcjhJ3RmGD3Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795777009;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-Id:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=uGRu1YiKX/bMIxmsS1uKkMBOHlcKQ3bTOVU2lGWV4Hg=;
	b=0q4owGDBE+XtWIeR5S1mCJApY2Q/i5GLBPo1ziBXnP5Ft0Jg96UX8j0+JIQut0B5Kn8s
	 TkvZpibpDw0XDBYdU6TB7Ttty/QiO/BRM1TiM7CIylgjyrieWkgQPii4HIBsYcf/9+fhI
	 VdnVHbPXvZWnsF9RPMr/hFIEWj+e4a3WiTgP+cEJWBWyJZDey//ltYzqgcGr3pIpgClUn
	 Vq/Nmii3ogo8AFHNXLFqUAuX4BXgh09YLUpaorLO8pP9oz8Xnhb8zhGGsgmQRfkmEglt+
	 Quzx/JMT8FoQRx8hwFecb+eVLPG8SJ7uubdRNTuE80t+//GAWe550sy4GjDrHCe8nuQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=iiitd.ac.in;
	spf=pass smtp.mailfrom=iiitd.ac.in;
	dkim=pass header.d=iiitd.ac.in header.i=@iiitd.ac.in header.a=rsa-sha256 header.s=google header.b=Y+1PcCbF;
	arc=none smtp.remote-ip=209.85.210.182
Received: from mail-pf1-f182.google.com (mail-pf1-f182.google.com [209.85.210.182])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE04A60A260C
	for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 10:56:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BE04A60A260C
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=iiitd.ac.in
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=iiitd.ac.in
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=iiitd.ac.in header.i=@iiitd.ac.in header.a=rsa-sha256 header.s=google header.b=Y+1PcCbF
Received: by mail-pf1-f182.google.com with SMTP id d2e1a72fcca58-8b68e59ab33so5854844b3a.2
        for <linux-nfs@vger.kernel.org>; Fri, 27 Nov 2026 02:56:48 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=iiitd.ac.in; s=google; t=1795777008; x=1796381808; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=uGRu1YiKX/bMIxmsS1uKkMBOHlcKQ3bTOVU2lGWV4Hg=;
        b=Y+1PcCbFNDEPQQhERe56HBn2ULcX9K7X1rig7/w1KebamCCkqB8QHsWcCVWJlsQMPv
         W/N9w3QnnKj3DxsGlmDV+3rp6MZO2GHV2xyzB9x0T1TejFIQDF+A1wskMWUMomPR0jac
         95cJ8kQBq63BBZU7hsb1oBsf0ePHjvO26ky7Q=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795777008; x=1796381808;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=uGRu1YiKX/bMIxmsS1uKkMBOHlcKQ3bTOVU2lGWV4Hg=;
        b=Rz8/CbKDBR7xAEAJ9USR6iNS1azw67P72CtEmslNKaWbEPpFqPhnoPFzi1ifWouPvb
         kGKyIw8QrfhOGxhuADpf3uSy9mhcogEsHXn7JtBF6PfQcbyak55sATh/IsEqUngJxV2V
         NYbOH8fRr40l6MDJPZCfJBchO0JKaEzf1ySBoabdB2GEoYuDhZpYOhUD8gStlUn6b4NS
         z1U39lPlGdu/zUnXuiSS5t22Ir7FtxDWrKT1SNjg8Kls31wGHa/Em2+tHISFdQIUMbzL
         naSDGUnW/cnqPGlZRnucWN9dxH1xX7Bjpq+yhxuoonrxHYRqBF+aLIugv3QwSZBCCVRK
         8e7g==
X-Forwarded-Encrypted: i=1; AL+hErGVhNPFCS73o6sHXKQiskzVktpRq5kxRXD9Kb0e75NW0vj5u4sFTBRrPQJNXh9WRnQEfguGH1c2Prg=@vger.kernel.org
X-Gm-Message-State: APuU4Z9iv9LZ0ESOIICwbbxfoPcETfKlF6c2FGM3c6wvyUPJ7bl9Q0Vp
	EC5NWZ/9CrAE77SM+aipxmiTJ6iOt5xzG0GnFxrJPluwuIHuAt4GwNaU0EETTte8Pn4=
X-Gm-Gg: AZFdTZeVQx0RjoWDqhc+oeWBsG7TI32XAAt5QLEe8NJfGbnR58EkPfXF958ptgR1fD5
	Vloxc0aj+j5yIqyMxj+t3Y3x2iqQYhZhakbHB61VWoDijAM3hcwUcYk7Vh2FUQU5q2XgOiSrBA7
	smcBLIHhqcGrTVOiw10t1hWPylk9LMxSSAkx9HxK+krIEt8chTMMarbiT9G+PvqYuA1JwlQiQWp
	8Q/BgcSil2L7MjaCeqQNLICIez2OHGCIk4ER8g4SVH4tFb2pJHJSoMQWDUELOflAVGm1URHHIjZ
	B/nMM2F9dFbWchJidZyI2Rjx+TP/q9Et1+KHg+tSjuAOoYzmssY9K5AExFrI7ohYKpsbErde5UR
	ZmCs7jwIov8X2tTjLtQSAY8EGjwp1ndWS0KUGmEdKvslkWdVi96+kz9OXT3Co05+QctHO4W2AEW
	8na6T45tApKbdKFM5jRf1Oh+dcHpUGf4RBFaIggdDPAjygDpkPisMYABTxEu9GSpqxJllEAAfap
	EqP59wIuHKHHhriChJCDwKPy2i4Kkvipt+J8w+FtT5XNJmbNocULB0TCXBCXV57Ihtcypb92DGa
	UBTdBoa+lFZr99xVnF2yLklPGzQV50zm0Go7dHM34CUdOxR0FsYx0cvan3SakmK8BTfC8bzXETC
	IH/Cu6egZ4kqjEnYJxsGzpVUkM35E0N3E/urM+nhdVDLRHvnREIOTzhyRHaIQ1Tr7
X-Received: by 2002:a05:6a00:4408:b0:878:34d7:697b with SMTP id d2e1a72fcca58-8c87c8602c3mr21453562b3a.41.1795777008027;
        Fri, 27 Nov 2026 02:56:48 -0800 (PST)
Received: from iiitd-S2600STB.iiitd.edu.in ([103.25.231.160])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-8c872e485f5sm12505768b3a.22.2026.11.27.02.56.45
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 27 Nov 2026 02:56:47 -0800 (PST)
From: Piyus Kedia <piyus@iiitd.ac.in>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	Kapil Vaswani <kapil@presceralabs.ai>
Subject: [PATCH] nfs: do not trace an xdr_stream that has no RPC request
Date: Fri, 27 Nov 2026 16:26:43 +0530
Message-Id: <20261127105643.3281166-1-piyus@iiitd.ac.in>
X-Mailer: git-send-email 2.34.1
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

The nfs_xdr_event class reads
xdr->rqst->rq_task->tk_client->cl_program->name, so it needs a stream that
belongs to an RPC request.  The readdir decoder has no such stream:
nfs_readdir_folio_filler() builds one over the page cache with
xdr_init_decode_pages(), which leaves xdr->rqst NULL.

decode_nfs_fh3() traces nfs_xdr_bad_filehandle when a server sends a
filehandle longer than NFS3_FHSIZE or of length zero.  Reached from
nfs3_decode_dirent() that stream has no request, and the trace handler
dereferences the NULL pointer:

  BUG: KASAN: null-ptr-deref in trace_event_get_offsets_nfs_xdr_event+0x32/0x1c0
  Read of size 8 at addr 0000000000000098 by task syz-executor
   trace_nfs_xdr_bad_filehandle+0x16c/0x1b0 fs/nfs/nfstrace.h:1979
   decode_nfs_fh3+0xb5/0xd0 fs/nfs/nfs3xdr.c:442
   nfs3_decode_dirent+0x3be/0x4a0 fs/nfs/nfs3xdr.c:2017
   nfs_readdir_entry_decode+0x14a/0xab0 fs/nfs/dir.c:814
   nfs_readdir_xdr_to_array+0x8af/0x1040 fs/nfs/dir.c:966
   nfs_readdir+0x1003/0x23f0 fs/nfs/dir.c:1277
   iterate_dir+0x29d/0x520

The tracepoint has to be enabled for this to happen.

Give the class a condition so it only fires for a stream that has a
request.  The event reports the task and client ids, so it has nothing to
say without one.

We found this with a syzkaller-based fuzzing harness driven by an AI tool.

Fixes: eb3d58c68e39 ("NFSv4: Catch and trace server filehandle encoding errors")
Cc: stable@vger.kernel.org
Signed-off-by: Kapil Vaswani <kapil@presceralabs.ai>
Signed-off-by: Piyus Kedia <piyus@iiitd.ac.in>
---
Reproduced on 7.4.0-rc1 (63fe746a609a) with KASAN, same config and image
before and after, only fs/nfs rebuilt between the two.  The reproducer runs
rpcbind, MOUNT and NFS servers inside the machine, enables the nfs
tracepoints and reads a directory whose READDIRPLUS entry carries a
zero-length filehandle:

  before   KASAN null-ptr-deref at 0x98, then "Kernel panic - Fatal exception"
  after    the same program reads the directory, no report, twice

 fs/nfs/nfstrace.h | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfstrace.h b/fs/nfs/nfstrace.h
index a32c76df72db..a3056264344f 100644
--- a/fs/nfs/nfstrace.h
+++ b/fs/nfs/nfstrace.h
@@ -1971,13 +1971,19 @@ DECLARE_EVENT_CLASS(nfs_xdr_event,
 			show_nfs_status(__entry->error)
 		)
 );
+/*
+ * Only trace a stream that belongs to an RPC request.  The readdir decoder
+ * builds a stream over the page cache with xdr_init_decode_pages(), which
+ * leaves xdr->rqst NULL, and this class dereferences it.
+ */
 #define DEFINE_NFS_XDR_EVENT(name) \
-	DEFINE_EVENT(nfs_xdr_event, name, \
+	DEFINE_EVENT_CONDITION(nfs_xdr_event, name, \
 			TP_PROTO( \
 				const struct xdr_stream *xdr, \
 				int error \
 			), \
-			TP_ARGS(xdr, error))
+			TP_ARGS(xdr, error), \
+			TP_CONDITION(xdr->rqst))
 DEFINE_NFS_XDR_EVENT(nfs_xdr_status);
 DEFINE_NFS_XDR_EVENT(nfs_xdr_bad_filehandle);
 
-- 
2.34.1

