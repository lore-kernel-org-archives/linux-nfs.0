Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794239610;
	b=ugL8FbfePY9OrWX2FzWno7UnIvW2rV3oaSl5Jnam9ri4x7Ci1EQbakEmPBGYeaoaMIlT
	 VPijBQ4XQZDYCYezOB8P89RS+1hTf4hGZLb7708qXlSnSatTPS2t3JeqJtCNcKvTLrznv
	 Ne7eHCrjDI3YTn5ulfFSfdbqoAT+ZVOwJZgK9JNKhOxC0FjJ/70HxCCjFTowBroEezjLk
	 MO8Ky5iVkvee1vLna6vNfAhGbyGe2iCv9vSSCuFesICvTufRdWNoBRlzsxcIF4YkBE1+h
	 YA95oRSp9oc/NNf/y1SidpIWY1214R3fRIyJxWs2mQtM8pUJdOVzIeBiGM6U0kMskkg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794239610;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=JjCSXoSw+BGZL7xX4IQFIvPROupCQYEx6ydgnJvXYoc=;
	b=lWpEyVpHlwT5Egq1ZrpYRlYABB2Bw0h1GZ6DWLguJkjRWfVPlVV/1ACX6WSYNrWkkgB9
	 1FNeHwc8vDBl7nnJJWu5JAGQnCgM+IWo1dvs5ZBmLGayeSt13h9bSsTtJJJXXXM41/UpS
	 USqrZsp3RufKxPbfYwmo9qPn3tvbvTP+W9mA56YicqTnoCYwHkj+rn7vFMIR2ItN9puuf
	 2PUoxfzPmIeuRwPvqTo9s7EtTAL8smH+WscDQuCKh3BbHUU6t6kOyo7nUaGVJshgYuRLi
	 apkFNpCJKpr7GkeJzwJ37f5+p5gEuCm9Jm4kb+2UPG5Bja3dXF3aAy2m/91GKqYeluw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nFT7vJuS;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 79CE5606A325;
	Mon,  9 Nov 2026 15:53:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nFT7vJuS
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4133C1F008A2;
	Mon,  9 Nov 2026 15:53:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794239610;
	bh=JjCSXoSw+BGZL7xX4IQFIvPROupCQYEx6ydgnJvXYoc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=nFT7vJuSEgymrn8/fjwDMeRDgM13zIL2TH23mING0HweNdr1vO+FVwDOgDEkG42vY
	 DR3ZPX4FDHuzwfWg/NXpzFy7DvmtpkRz0l3pE3REyAQCDppQmrOJrF8U3lUwx5ogt3
	 bMRpqeIeQT6r61ALafqf6HDmlggG9R8hbK5z+u3PWFTZyI3plhkxvt5VMZqGrzxGbj
	 OkEWRH5WOGpWvbAU617zP4awqRFjkfXXGqjiEKH4rIP+X7J87iyYXd913/OZ4jplvg
	 rtBWKL6pCqO2qM7HekT7pQfTaOKImnqTfa3nMmDlqsyg7lRXVst9XWsNTQ6q/lUbKa
	 v2A2nH+R84YSg==
From: Sasha Levin <sashal@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: Sasha Levin <sashal@kernel.org>,
	stable@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Joseph Qi <joseph.qi@linux.alibaba.com>
Subject: Re: [PATCH 6.6.y] nfsd: fix NULL dereference in nfsd4_free_layout_stateid()
Date: Mon,  9 Nov 2026 10:52:45 -0500
Message-ID: <2026-11-09-1-daily-reply-0003-nfsd-layout-6.6@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261109084932.3861080-1-joseph.qi@linux.alibaba.com>
References: <20261109084932.3861080-1-joseph.qi@linux.alibaba.com>
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

> nfsd: fix NULL dereference in nfsd4_free_layout_stateid()

Queued for 6.6, thanks.

-- 
Thanks,
Sasha
