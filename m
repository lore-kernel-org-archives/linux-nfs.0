Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.44
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297401;
	b=zTeCJABkco2qxEeQerQLGGEj1eQs10HoaYT8wDpd1F3eE60WQ5FEDruJgoUiPdv+mKfv
	 doHIS3sflcO6bF6CklYcgeqNAuaSIprI+Xo9lu1KPvDD1atLD3YPSfgYLUQ1L+Bh3HoAz
	 BstACk5qmC4aoyqmSF0LlirXuZEMKSIu+Nmid/yl32cG6sg/SK+sdZs1bSug82z6h88jr
	 RoaWUhBUvyL1Hf1lhD8Phc9lCUW8aOdkoLOWbwR7GCcfgiaZ/gzWVjOycy6rx5jjWOAuF
	 eS0Wdnuz5RijW9kOETRpqxa1cAIHSqTEA0WtfvrCkEfLLbQEGDpSYXMHm1+PG0fIaYg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297401;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=VIRuN5RJjbuv5CSzCNORIV49ClgI3heQ4aV2Bv/ASqI=;
	b=gucyjSCHj2Q5eZsP4DhPhjVFCIeun/6zI9mkz8vB7w6/7aImPTFiaIOSvRZnVj82F+0s
	 QX35UbIUF4l+r3KHWUpE+6/zdstduJVxWGVmuxuYHcR30IFnVoFin+DyhdYgE460Kvn5k
	 giFR9oes16+wLRx6X0f7+0X7qeKPCO1Z9LmGUF83Y2ZN2N7UpZxUFnwqgoFpW8R1yRHTp
	 /rCdavvcZVq2ZLxCGHbRa5UQSOHSdMQbaWKYmbnB/L4UzGYN96e7tENEh8ZVKreS2QmaL
	 6M7AEZGbq1v3nX5ESd/TNu2dxKKsIDiQFUp19c7EiWZsGVHhogwklJKc77uJAIMLVCw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=WZLxBgd3;
	arc=none smtp.remote-ip=209.85.210.44
Received: from mail-ot1-f44.google.com (mail-ot1-f44.google.com [209.85.210.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AF7BC60A3806
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:10:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org AF7BC60A3806
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=WZLxBgd3
Received: by mail-ot1-f44.google.com with SMTP id 46e09a7af769-85a6c747dc9so743827a34.0
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:10:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793297400; x=1793902200; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=VIRuN5RJjbuv5CSzCNORIV49ClgI3heQ4aV2Bv/ASqI=;
        b=WZLxBgd3shKUN9MMxfxeWoZmoSQYqQnLq8nPl6E3Zj9r4MlVGXVCy7M50RgeVTldnT
         QzFj53iiOXruAIVXf1MEj5jDvkLWMdRs3iT0mxxToRMGZ+ayO6ETyGc+nq7PoDNt2Gx9
         YkQkzqm5bSa1e9r7FmarbxkfhbsqrEcIBpWIsHl6SKMsMGlN9zJXSX4ZUIuCdoa5xLj5
         kHaXFxjOYlyyundHMLrv/EY/3B9cJY8Vf0e7+lpfd/dwd4T2l/KhC4HPAoXdrgVCuqBj
         khWsYoU1VSkvWeCLGxvsw8NRcQMwmctajSHnaCdrAon9Ig5dwW+vqWMvyM6NsjeB39Qh
         xHyg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793297400; x=1793902200;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=VIRuN5RJjbuv5CSzCNORIV49ClgI3heQ4aV2Bv/ASqI=;
        b=0o3lI7B1ZhSHJO5ydcTk9alNVwzFvfNjFqVE5PD5ZRJOlfMyAnDrbqPC27OJubp9n5
         j93F4xPQ2QhHvk3+OgcoYr7p59UjERLCMCRMJ3/6ZL1KzqOvgSWYl1XX7Z0vd4sT3bk0
         1aCw1IAfeNNh35/iX8+O0IjWUyJPilo9x1JT8lZGSc1DrNNjKniYESV/xvvcOGuTkqBu
         CuQ61D1j1t3nqs9IzyChmlDzNfXsTJjULu2WZ2QlpBsHStLyA1ITapLsF6ErCFJqpn1V
         lz1IDZV2RHmlv3i5Z5AI+L9/NUWh8JcpaxWBdYjXcCerQXTmXmmz9dNY57zqSS95ns8P
         HAkA==
X-Forwarded-Encrypted: i=1; AKwUvBxBEbgYQSIp+BVq/U28xnrNr1Cs/y/GPUnWpTZuRvhz8ChB6Fd7j0n10wUP5zehjcFF7HUB4gTIV5w=@vger.kernel.org
X-Gm-Message-State: AFq9FYIFlHEQYdHOy74iYTdaAO6QRL62AFsHKzSI1MJJACOREXVjbWVQ
	YdAPj5gcNzz/OZ/Myvwi1Nl+15hvln2KFkKXIjhPVqcSk9B8veulaJFWUEjry2b2J/c=
X-Gm-Gg: AYBFou2Nn2spDFigO20YroPBux0jAyDX52h3DXwlAxop4oBv3LYTQoBw/T00sVcJsSM
	F5QogD3meoL2ZWaezkBeuXlTZWOO3ndI/1lpfdTP6xuiQhaahyaJGuSpKn0PdEU0uqNbcIzJXCd
	uiGBg8HD3aIhySwmF7Nl81tanj9i0zfNnaoTwnICHkFcj4VExEs4FH6WNRqNcML/GVDEB0+rF62
	0Xg1yx6YVwe+k/MV0xv50HzQ3H9Wgbs3L3qzfGdCT2+Hr4vpj7gml5XkB/QpKms/PSyhdGJhEHq
	OvI2kwUuzgL7x26Ih5wATv7lgWS5+3r5QQJpoTWEjFvXki8b7+tjK1ujONr6XnHwkALJCTs2BhH
	L6SNQxAqth3bmUingecfDB9WMekRxL34d7e3/35fhgBkS7KJODDbajjIeb/vnzM5tjfwbzMVN1g
	nN5YEaAHwx0KKii1NSjGvuzhzNzlz8G/hgCQwYoPqkjEkv1/G7+/YzAh+JE2BoabrI/nfLsl4nL
	G5lP62BQvinmsVoChxsD7YFqJEHPvu/Ry6PLSl2waN7aIXTQIASQoAkTv55RVMST4g9pqG0GnX4
	rtFQWdEOuNoBRdtY2qmr3jG7Jc+WTK/xaDVOCA7uHmSnyAIwq/E/KzWiW8BMXHYJtN5pnNDj
X-Received: by 2002:a05:6820:4ccc:b0:6dd:c600:ec2e with SMTP id 006d021491bc7-714ddecf85amr1873577eaf.19.1793297399528;
        Thu, 29 Oct 2026 11:09:59 -0700 (PDT)
Received: from localhost (75-163-200-235.clsp.qwest.net. [75.163.200.235])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-85d354d12f2sm160242a34.17.2026.10.29.11.09.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:09:59 -0700 (PDT)
From: Jonathan Flynn <jonathan.flynn@hammerspace.com>
To: NeilBrown <neil@brown.name>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-doc@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH RFC 01/12] nfs: update a server's capabilities in one step
Date: Thu, 29 Oct 2026 12:09:46 -0600
Message-ID: <20261029180957.387138-2-jonathan.flynn@hammerspace.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261029180957.387138-1-jonathan.flynn@hammerspace.com>
References: <20261028041023.3738553-1-neilb@ownmail.net>
 <20261029180957.387138-1-jonathan.flynn@hammerspace.com>
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

When the client reads a server's capabilities again, on remount, on
migration, or when a later mount reuses a filesystem that is already
mounted, it clears a group of them and then sets again, one at a time,
each one the server still offers.  Anything that tests one of them on
another CPU in between sees it missing: a case-insensitive server looks
case-sensitive, a server that supports security labels looks as if it
does not.

Build the new set first and store it once, as the NFSv3 path already
does.

This was found by an AI coding assistant (Claude Code) reviewing how
the client derives these capabilities, and has not been reproduced.

Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 28 ++++++++++++++++++----------
 1 file changed, 18 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 22a2a4009d..113c199a6f 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3896,6 +3896,7 @@ static bool nfs4_server_delegtime_capable(struct nfs4_server_caps_res *res)
 
 static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle)
 {
+	unsigned int caps;
 	u32 minorversion = server->nfs_client->cl_minorversion;
 	u32 bitmask[3] = {
 		[0] = FATTR4_WORD0_SUPPORTED_ATTRS,
@@ -3953,7 +3954,13 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 				     res.attr_bitmask[2];
 		}
 		memcpy(server->attr_bitmask, res.attr_bitmask, sizeof(server->attr_bitmask));
-		server->caps &=
+		/*
+		 * Build the new set in a local and store it once: a reader of
+		 * server->caps during the probe, such as a remount or migration
+		 * of a mounted filesystem, must not see these capabilities
+		 * cleared and then set again one by one.
+		 */
+		caps = server->caps &
 			~(NFS_CAP_ACLS | NFS_CAP_HARDLINKS | NFS_CAP_SYMLINKS |
 			  NFS_CAP_SECURITY_LABEL | NFS_CAP_FS_LOCATIONS |
 			  NFS_CAP_OPEN_XOR | NFS_CAP_DELEGTIME |
@@ -3961,22 +3968,22 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 		server->fattr_valid = NFS_ATTR_FATTR_V4;
 		if (res.attr_bitmask[0] & FATTR4_WORD0_ACL &&
 				res.acl_bitmask & ACL4_SUPPORT_ALLOW_ACL)
-			server->caps |= NFS_CAP_ACLS;
+			caps |= NFS_CAP_ACLS;
 		if (res.has_links != 0)
-			server->caps |= NFS_CAP_HARDLINKS;
+			caps |= NFS_CAP_HARDLINKS;
 		if (res.has_symlinks != 0)
-			server->caps |= NFS_CAP_SYMLINKS;
+			caps |= NFS_CAP_SYMLINKS;
 		if (res.case_insensitive)
-			server->caps |= NFS_CAP_CASE_INSENSITIVE;
+			caps |= NFS_CAP_CASE_INSENSITIVE;
 		if ((res.attr_bitmask[0] & FATTR4_WORD0_CASE_PRESERVING) &&
 		    !res.case_preserving)
-			server->caps |= NFS_CAP_CASE_NONPRESERVING;
+			caps |= NFS_CAP_CASE_NONPRESERVING;
 #ifdef CONFIG_NFS_V4_SECURITY_LABEL
 		if (res.attr_bitmask[2] & FATTR4_WORD2_SECURITY_LABEL)
-			server->caps |= NFS_CAP_SECURITY_LABEL;
+			caps |= NFS_CAP_SECURITY_LABEL;
 #endif
 		if (res.attr_bitmask[0] & FATTR4_WORD0_FS_LOCATIONS)
-			server->caps |= NFS_CAP_FS_LOCATIONS;
+			caps |= NFS_CAP_FS_LOCATIONS;
 		if (!(res.attr_bitmask[0] & FATTR4_WORD0_FILEID))
 			server->fattr_valid &= ~NFS_ATTR_FATTR_FILEID;
 		if (!(res.attr_bitmask[1] & FATTR4_WORD1_MODE))
@@ -4009,9 +4016,10 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
 
 		if (res.open_caps.oa_share_access_want[0] &
 		    NFS4_SHARE_WANT_OPEN_XOR_DELEGATION)
-			server->caps |= NFS_CAP_OPEN_XOR;
+			caps |= NFS_CAP_OPEN_XOR;
 		if (nfs4_server_delegtime_capable(&res))
-			server->caps |= NFS_CAP_DELEGTIME;
+			caps |= NFS_CAP_DELEGTIME;
+		WRITE_ONCE(server->caps, caps);
 
 		memcpy(server->cache_consistency_bitmask, res.attr_bitmask, sizeof(server->cache_consistency_bitmask));
 		server->cache_consistency_bitmask[0] &= FATTR4_WORD0_CHANGE|FATTR4_WORD0_SIZE;
-- 
2.43.0

