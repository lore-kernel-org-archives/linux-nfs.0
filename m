Received: from mail-ed1-f100.google.com (mail-ed1-f100.google.com [209.85.208.100])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9A4C950129D
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 13:54:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.100
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791899642; cv=none; b=TY9r66SLUeNpWTRaufdG4NPGctk+AOEzCa0gjYssoMDeStMwu+Mtyvkofb9CSVRs1LH6CCR58sIxJFjVo1S+xeC4QSasieBmxSJD5f2ySxbvXEqufPbTn8s1BZ7jMM8nQPYn5t1ceE2iNU6RF2JiwG4z5+2w+wuc8y0xNBD1J04=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791899642; c=relaxed/simple;
	bh=o5J0+KXNco+IJMhpygQn4co2RmjJwRnix60H1smEcio=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=P2jRhA+4ALc6zhyu3yGaPn/qcNSR6sclYi+Azf6c7OjHUVjKUtGfl0gvA7RqkS1Y5ByYrCYIoit2EYfSNB11JhdVNR9Y15huA8gdoQNrrFxvJMde2/s82dMPaRtkvCaKtNFbWkuC27hFXShL+pfsY9OH2s7tooYqfdPCpErK+FY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com; spf=pass smtp.mailfrom=everpuredata.com; dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b=D3dqb1/K; arc=none smtp.client-ip=209.85.208.100
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=everpuredata.com header.i=@everpuredata.com header.b="D3dqb1/K"
Received: by mail-ed1-f100.google.com with SMTP id 4fb4d7f45d1cf-6a0a4aa99bdso3741445a12.1
        for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 06:54:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1791899639; x=1792504439; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=o5J0+KXNco+IJMhpygQn4co2RmjJwRnix60H1smEcio=;
        b=D3dqb1/KWcsWP36meYm7JFOuKng01U8Mw8BLzrdyXcRt6Yabl0D/pQDe/O9LpmcDQP
         E5JkSbqGHk3RhITF4noBsH85ct3vp9YC0fHnEbTDJ0hTrL2+1Jg/hDaBEC4vjqc8YeeY
         tBBTnfZSJXH0Bi/cvt+6Wrk2kooy+tEVrPxPCti2enoDeDmWP85OdowWGqVbUr0g/Y3u
         gLnYpbxIX6B1fVYNzXMqvLGpDyC1nNirMyaEyofHkU/hwzgRC0IvQWP2oo+VoHheLUWt
         y0RB4ynO4N9id7LvFyTqKsNkrprUdoOX4fXhC0Aqwj/Au9DeQi/LZ89byj0rgxMfgPnb
         JzjA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791899639; x=1792504439;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=o5J0+KXNco+IJMhpygQn4co2RmjJwRnix60H1smEcio=;
        b=hVXI9ATWOBcP21bGw3y4I3o3V82xzkMjOkCwIzyGtVD6zauOr4I2eRpxg+DBaRy5l2
         7XBpjjz3axqgi/ga9LeYCEUCXA4gfKIeCzVPpkNW4quHyFDxrQZd4GPIMqsEYBrNVX6A
         mDy683Hq2sxbIwuCH6n2BEFRyin9A4finbT+ETifhm5xUZL38dOUCcfRRFWfVZre7TPf
         YgBQCSUxyz3Yk3tqRX3jLS5p8iR0DmIX2nbTSlZiPJUlprtX6eDE3ZXoJ0hniTzzKF6r
         tB5mAfnteyidsF9HYIZ1tJ0vHD3mD48hfYq6S64wiMvARea4/2KUQ8TUYK6UmCfLcKHN
         zeAw==
X-Gm-Message-State: AFq9FYIecCi0Cr6GWaDmCIsZ3ADcY05ed1yCMf5kok/NZkkE7kPOLqkn
	g1hkvVBbEk0vCjDXRZq5TkBVM6B2CkbX6nHZdYBXEvOBjSg3Y3NH/3f6veK6lDm64JZbhBLN0Dz
	jN1Ao6HcbVslVhUMmiNKJKaRdvmG4CaBRMGUO
X-Gm-Gg: AYBFou1ReONmS/rH0EXrXPnVYJP6si9bCVCq6NMHqWkY/oRqu1fPLvI51ydicNP8wxp
	Y3fFH0LDJQ2Vn0rh0qJS6jrVWDbxVDLOGQXlljrVR2PlWLFjvR5MBtpkH3G8b8FrTg83LK4csVr
	fgvO99jbicb9VDytFNOnypZi9ceGgYxg9/NIMXaQsTrgY968KFpNU38Phj4RXJfjQUmlOoyAVh4
	V0iXo52m9yCof/RbaKV0VFxy2ZE5selVSuhmhztXxbCUEHuNBs+s/nMGQDfA5sCfT3qzLqkUKA0
	9LiG33J2NxlwrmhVIZs6JGM0AgxBo2phO6sc7oi2lmmIY4K2DU+qhPh8IdcIduPyUW2+JEiWHDQ
	JDxe1HmRwedQUffiH3TdA04mhNskvKvMLOLDOEkQ=
X-Received: by 2002:a05:6402:52c6:b0:6b1:d8e4:f93 with SMTP id 4fb4d7f45d1cf-6b1d8e42e76mr3457752a12.33.1791899638750;
        Tue, 13 Oct 2026 06:53:58 -0700 (PDT)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.128])
        by smtp-relay.gmail.com with ESMTPS id 4fb4d7f45d1cf-6b179dd06b7sm2768511a12.13.2026.10.13.06.53.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 13 Oct 2026 06:53:58 -0700 (PDT)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 40832340324;
	Tue, 13 Oct 2026 06:53:27 -0700 (PDT)
From: Tim Menninger <tmenninger@everpuredata.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	Eric Badger <ebadger@everpuredata.com>,
	Jon Curley <jcurley@everpuredata.com>
Subject: Re: [PATCH] NFSv4/pNFS: Preserve layoutreturn seqid while lsegs drain
Date: Tue, 13 Oct 2026 13:53:27 +0000
Message-Id: <20261013135327.1695983-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.34.1
In-Reply-To: <20260921235520.502987-1-tmenninger@everpuredata.com>
References: <20260921235520.502987-1-tmenninger@everpuredata.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi Trond, Anna,

Please hold off on applying this patch for now.

Further testing has revealed incomplete recovery under sustained
pNFS/RDMA I/O. Some workload ranks remain slow after DS recovery, even
with the reconnect loop gone.

I have not yet established whether this patch is incorrect or exposes
another layout-recovery issue.

Apologies for the noise.

Thanks,
Tim
