Received: from mail-pf1-f225.google.com (mail-pf1-f225.google.com [209.85.210.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2447238E8AB
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 23:23:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.225
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788564226; cv=none; b=ORhOhidc3y6JWHsM/VLKZSIMja5rYrXATpQt1Kh1/7sYJmvl+BQrbjtfMYcXBbLm12EWSdepfHHAC5und5VuLOA54ToIEcCi8cEFDazrOU8hYuVtBMp+0C81raM+4r28+8Z2EwQLCpN3mBDldjYk7+mLCZSX/Zlj7ZzKTXijIPY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788564226; c=relaxed/simple;
	bh=1D/6Tr5xBcXUuHizxCrM5fO+eUcmJoNR2aK9tSGyl/k=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=s8mcADI1EeMH2bubjHvFJk3oQarEDc/NBH3dffMOBcr+E2jeL9hfu3cLX4Z9nAyhdR+jDL+0a3Y5L5mOzKaOERiDVPy8RQ3A4zeBLO5nzZTbHZSetjKtUfUb7wRSXOvdBczw0lqS+mwfMpEOkQDH4xAj38APUqCrUaoieO1y+qM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com; spf=pass smtp.mailfrom=everpuredata.com; dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b=yAE/0u7+; arc=none smtp.client-ip=209.85.210.225
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b="yAE/0u7+"
Received: by mail-pf1-f225.google.com with SMTP id d2e1a72fcca58-84e27035206so1377999b3a.3
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 16:23:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1788564224; x=1789169024; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=1D/6Tr5xBcXUuHizxCrM5fO+eUcmJoNR2aK9tSGyl/k=;
        b=yAE/0u7+VHGr4bWCbQNrzOItj33W7N4Ee3rgPgfi/NnNKw+gYNmyJq2lHHmN3sYeHe
         Q1Dcm/52Vb+E02e+3DQbMRaOP+JPdOVFYG9tCL3NTjqjfTdF20tJtbCf/rltRTykSCXP
         qfULlKkb/ljU8wRa/Oy0bZhOcqEOaZYohIDCLW5LfoDrYpkzR+D+rWCmn3SbKSa1uL2t
         1bS4sPJ0Tq1C25Skc+Pq5qBZVnUJWN0urOdSDND4y1aV8rRww3bDYdbwlflanwa67mGP
         AQ62U+H7Spc7pfbS0NEmODLfl4nob17Vc7H2T+oQ4j0BBrtzMohC418QFNNbWzapLMYZ
         nqCw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788564224; x=1789169024;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=1D/6Tr5xBcXUuHizxCrM5fO+eUcmJoNR2aK9tSGyl/k=;
        b=SLrT0B/XHBEQvT4Q1yrG2hvy/tvVRYGMZGq6q+NKr89Zzf3GY73QwH3FEJeLdrjCOi
         6E8DyrSNkhcGgmPeTJ2QC0FL0vNwicud24XVsPKBcNeWo8HVMJlFcLKwFxAO25VHJpBT
         0GvrvXsEsv5tWC1b9/AVE7gDXzVs/5Qx2NOU0hOVQrdz0PrBljPGv3PyZinnq7d0bw+O
         dHh08zsXd8PnwgObbGIh2yTBqlRalpgMAn5LAE9U2vYfE8FB05LnnQqX+0xIFdoKnRtf
         y1pjixljYY8gxsYe5PIBRsPt5WD0T8EIpcQhngHshLySCg4pSKKYwSY3b5soWETi+tMY
         5JvA==
X-Forwarded-Encrypted: i=1; AKwUvBxKLETgFAQcm4Dj7YXRr+t7anjlb7Af8Qw/0LOsZeHfgpRFE4ISMDNHfbSDVtdkr1u6x7DvGp5MmCQ=@vger.kernel.org
X-Gm-Message-State: AFuF++lydDVzAh3k0YVeGmeRkcQrPdokbTTcZ2VdDkZQU0z2tQKyj85x
	j5C64UxOUx8k/eHLSCOsV3Kqq6gYf3J2bp+9phQ1Tbm/Qh8pUkXWqtQ8DC5km78V+o+Zrm6uB2G
	HN6AkjZ72hDPPkORyR1i8jONRNfYA7regpC0Z
X-Gm-Gg: AYBFou2rdL69C+hZFgsq7vtxhqUk5g77b3Y9/cyoPV/ULXbS7xTMOwIuGKH6JInq/+N
	NTKRAMauNGWOBOBlSL3rRzPUJ6feSsyJeOJbTCeOwmmINmrQGp6Sn/HqUTObbyGZmG68fao3Wxd
	szHypahjh5Uaqwc27yjWiVfM2N49j16rYNiDkKeXQTLMZHdzZX1mWpUW8/tzebSAv4RA0Zd0Ozi
	VXV/d6bTytfdEi7GwB7Cp8kMO7gt3ilQ42zJe4/k49GrS+2gl6KRix7cRDmb2bZEhpkxSsKis0M
	ttaalNGjahvpcAM7jiINYQilwl59EhE+CmFa8W8EtgTc70VG/UXT9dYkyZu+WBfkgXxAh5HqOrQ
	MF53OaWMw5CFkKChfM8TRQTWp9KyJ5mqX+yDI31A=
X-Received: by 2002:a05:6a00:2c94:b0:848:3f07:c5a2 with SMTP id d2e1a72fcca58-86167aab584mr11848768b3a.4.1788564224491;
        Fri, 04 Sep 2026 16:23:44 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id d2e1a72fcca58-86150750808sm1257514b3a.4.2026.09.04.16.23.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 16:23:44 -0700 (PDT)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 0239C340200;
	Fri,  4 Sep 2026 16:23:43 -0700 (PDT)
From: Tim Menninger <tmenninger@everpuredata.com>
To: Chuck Lever <cel@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Tejun Heo <tj@kernel.org>,
	Lai Jiangshan <jiangshanlai@gmail.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eric Badger <ebadger@everpuredata.com>,
	Jon Curley <jcurley@everpuredata.com>
Subject: Re: [PATCH RFC 6/8] SUNRPC: Reduce rpciod workqueue contention
Date: Fri,  4 Sep 2026 23:23:42 +0000
Message-Id: <20260904232342.1907377-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <336623df-ead4-4802-91c5-aa3e785f2971@slotpi15m67>
References: <336623df-ead4-4802-91c5-aa3e785f2971@slotpi15m67>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

I realized the bad state correlates with where the RDMA CQs' completion
work runs.

This client has 16 RDMA transports and 32 CQs. The CQs receive 32
consecutive completion vectors out of the mlx5 device's 63-vector ring.
Depending on the global round-robin starting point, all 32 CQ workers can
execute on NUMA node 0, or they can split 17/15 between the two NUMA nodes.

On unpatched mainline (940de590b839 without your patch set), I tested five
consecutive allocation windows. On three of those, all 32 CQs executed on
NUMA node 0. On the other two they fell with a 17/15 split. All five
sustained ~46 GB/s.

With your v2 applied, all-local windows fall to roughly 24-28 GB/s while
split windows sustain ~46 GB/s.

I also tested this by changing only mlx5 IRQ affinity. I redirected
completion vectors 20-34 from node 0 to CPUs 24-38 on node 1. CQ allocation
windows 5-36 and 6-37, which would otherwise be entirely local and slow,
then sustained ~46 GB/s with their CQs split 17/15 across the nodes.

So the CQ allocation determines whether the regression is exposed, but
mainline is insensitive to that placement. The series introduces the
performance sensitivity. This also explains why v2 appeared
nondeterministic with respect to the rpciod affinity scope alone.
