Received: from mail-oo1-f42.google.com (mail-oo1-f42.google.com [209.85.161.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7CA404A2614
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 11:05:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788519937; cv=none; b=DacKkvtIIPz7qJuWqwwveecMiZqrQXLjvgeD15k6PE7JpsYvssN3DOAvorpizH63kVljgrC4oHKt0L47246hLySyvfe1H91+CHi0lOsS2n50OagtZ44AMeQvyHDj5yaLeCnFhyONMwi+8JMO7/d1AfMLp34O4l0+7yoNM/gzPMY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788519937; c=relaxed/simple;
	bh=vtvlCiLIxNVZw/5tzOwmDK/FurtYgAJDRHsxvGLZK1o=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=t457TCDGDqhk2lU6Uqp+qe6N/m3uU8x/wjOWQf+nk+5POa2p2cCRxISVolEwSov0rF1F5hyE2NS/a6Fw79LQCiRC4zhGfcQQ8+xpwTQO3IaPqyKb1eEV5L72am04rcI8SrbFnA9/UCdXGdPgWlQeRDvYtbA4dh4kNCjj5s/Rclo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=n96n9eBW; arc=none smtp.client-ip=209.85.161.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="n96n9eBW"
Received: by mail-oo1-f42.google.com with SMTP id 006d021491bc7-6b1b3d7f10eso587182eaf.3
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 04:05:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1788519935; x=1789124735; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=UuWL5RJF3Jl/ekyrXLP7vBFpUV2c4qa2+/pFXhLEnNU=;
        b=n96n9eBWd5RTXg/+L84GDOsKsCleOUZTimiROQlbsK6fW8ldv4X1ddSU3tg14B7ya4
         kEyCgLMDna137RmAx6kasTLOl+l3rKNYseaS6atqEtpIntMrRZe8G06cU2S6LeMkRqDM
         2CmS73fy/t4qfU16Dgg01ITRhOYmI5r63VnAurSh2aE+C2lvT6IkCd5MEcSkuQqVvZ/D
         4r3m9fDEkX+dQuoYRtAmYbUmqGitEncBZ3e6aWiIvaIV1xrCqpG79jPxMd7lS8BOzGD4
         NSlBXIEbBiVYhmNPc07wNcyUHB2ciw7gA0SiehlZHTvnzXCLYc669+QJgOQNr6TP50ph
         +8TA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788519935; x=1789124735;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=UuWL5RJF3Jl/ekyrXLP7vBFpUV2c4qa2+/pFXhLEnNU=;
        b=menfexyGm0Xa9w9/a9AkdjL/PFMIB/GJH7T1pAwSTr61igFAGNsXuoGtpu6WImRY6w
         A+T/m/jyUSh9DeaiHFSAOP+Xmmr0cgH77wjnE6LrtUT56cPyklNR3JdXblwUOB+P7S/x
         fHVg73ENZOBGndld4EWE8bDdTBqlqduKJZHc37R0Lz5Zy3gn68+jya72DnMNnkxZMj+F
         Bh5w8dtwQ0QZV9E8dmosWfPjeQDXVKH9SSssEBVFD3BFg2dN5mA+iPqiS2O37eVB3xGp
         S9GXxbWMAsT40aLYA/o2sQRcikKt7Wz0JvMvuOPjq6Nq2rbt+4HeAI68qYHLGCwr7HGe
         eIEA==
X-Forwarded-Encrypted: i=1; AKwUvBwVh0j5MhKPcWpLjHiFMzyFSQvWOAZ1h2ilwENz2woZI/loXq1kj5Pgb393sQ7mxNyQspdmb1HA8DI=@vger.kernel.org
X-Gm-Message-State: AFuF++nt8Jp4s3hXz6+oS5fxNA/kBPmondAmhMQJmyBUUMJDAtO09Guq
	tAaW6xEzU0bdIWAzAf8UTSKJQx3yoakeGtVyFktlhd3LUn5eeyoHPo3y
X-Gm-Gg: AYBFou2hMrEZHxDRwvv9ZGF8u193uIJPnknmRQQOvJurlvzMsLD5Zl4Xkvn6S2Doxti
	LzCMFo38gm4Vi6BdQy9CX0lSsjP21QUkhtxIhtCrpf1yz6uXEsD3gadQPxY9G5mNq34HpwWslvj
	BzkSZ4o0hWaFAfnp0yyzX9nW8BzB17QOEAGPsAnRDxkLI1+BOUjgV+3JhFIQl374ghQzX9afbgB
	yZuJfFnzQtNTueDGyXcUMdqYfTSpBkxcZWKEnN9/sgzifRJ0nuBowe24LQmNwFarQPPVo7uJeez
	KOMlibKMFcZP4xZS23VUlKeOpdVK4ESeYovC3/CNRTOwH5HoXwWO6Vnx4j86M+i61ywS9AqQopZ
	c3zcchrq1xzVSo4RwxUUwhG/Ig6XUQYJYVgYGIpYkK6sVoga7vt0Xy6PVsbqc/012z+0du2mmp7
	MP5mDdp9UbYESu+S1iyQrc1SMcTE6WzdCT+LdG7zZ1zNOowMcFvNm4/P2uzQYWEqTtPx33p1w6U
	6OkYZ4+F/dAyeZdPIM22eqwUg==
X-Received: by 2002:a05:6820:f015:b0:6b1:445d:aaef with SMTP id 006d021491bc7-6b6fa4e0611mr3688897eaf.2.1788519935275;
        Fri, 04 Sep 2026 04:05:35 -0700 (PDT)
Received: from volcano9f6e-hostos.amd.com ([165.204.217.251])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-333c9db92b1sm5220280eec.9.2026.09.04.04.05.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 04:05:34 -0700 (PDT)
From: Hemanth Selam <hemanth.selam@gmail.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfsd: fix typos in comments
Date: Fri,  4 Sep 2026 16:35:17 +0530
Message-ID: <20260904110519.15207-3-hemanth.selam@gmail.com>
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

Fix typos in comments, reported by scripts/checkpatch.pl using the
misspelling list in scripts/spelling.txt.  Only touches comments, no code
changes.

Assisted-by: Cursor:claude-opus-5
Signed-off-by: Hemanth Selam <hemanth.selam@gmail.com>
---
 fs/nfsd/nfs4callback.c | 2 +-
 fs/nfsd/nfsctl.c       | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index a901bbe67e03..d616bbd66b79 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -536,7 +536,7 @@ static void update_cb_slot_table(struct nfsd4_session *ses, u32 target)
  *		void;
  *	};
  *
- * Our current back channel implmentation supports a single backchannel
+ * Our current back channel implementation supports a single backchannel
  * with a single slot.
  */
 static int decode_cb_sequence4resok(struct xdr_stream *xdr,
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index adb032b7311a..489de0c0f0a6 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -556,7 +556,7 @@ nfsd_print_version_support(struct nfsd_net *nn, char *buf, int remaining,
 		supported = false;
 	if (minor == 0 && supported)
 		/*
-		 * special case for backward compatability.
+		 * special case for backward compatibility.
 		 * +4.0 is never reported, it is implied by
 		 * +4, unless -4.0 is present.
 		 */
-- 
2.48.1

