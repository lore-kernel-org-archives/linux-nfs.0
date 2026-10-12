Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0D8EB3B14AD;
	Mon, 12 Oct 2026 14:59:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791817162; cv=none; b=Ymz4L+suLLgeLeyJxMzxLz0ze6aL7pi2/oI49lIYT5VC21NXFBrHheQmgHlw6ymNJ/CV6jIAeyH+f5emT8c7w1AxY6cu9ClzhpEMmI4Xi4O0UHZAS8Yii+P0QYhUmHzfnBhaNgeyr6N7Gd5lmjYBfsokH7USBuT1vT2g8QIfRcw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791817162; c=relaxed/simple;
	bh=MF3F4UMe3Js7PwZ4BA+1HMWzk2oMjPJVfzJ4kqmZEtk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MHzgyr1LUT2uWlJ79VSLRR98hH7X7VnYd81edmTjHxpLbvU1wzkTI+tbDFGuJRTgRYe4MVFyD8u6HkWBF9yWGr/BrsNd1GVOHjAyclmsEUbT4S23v0S/i0/qK1Mj4+djvcJGGFVoMOh4/gJgIJkAsrpSV+Mn9EikGuigQHiyFfA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=F2KhjTt9; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="F2KhjTt9"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D4B531F0089B;
	Mon, 12 Oct 2026 14:59:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791817161;
	bh=zcQh6KprGRmf65l8r52FQ60YCnOB+p5DNK4CKEwYKd4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=F2KhjTt9m3VLJ+I0PQz7Vog+nNcXRTrE0yPpjI2vhYkUcsG1IhNPjOFHHhv3lUgHD
	 QWgj6iBX2tD8Ce+dDS763SFovv8mk0hBGATnFrHIWqZ/VD+bKVi4F2bXGsG9fObU2i
	 hN63q570VFdYMmfimhXeYUg7d02AlfeTe1NyPzSnnjaqGcE6Xs9e3TIN3WVlGvSty0
	 PAv97XH8Rs0U/WNq4Y6ztkkV7cFZo9jM+k6XZXNX0LViQCCde+2xVKd3AmJUImPf0l
	 78p/n/9IPhOpXXa8jZuH6lW43Nxb4xYyD65XFOGeao6uDf/Phf87UbPj10C11S4Jlm
	 9xHbovjivZcWA==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	Lubos Rendek <l.rendek@proxmox.com>,
	regressions@lists.linux.dev,
	=?UTF-8?q?Fabian=20Gr=C3=BCnbichler?= <f.gruenbichler@proxmox.com>
Subject: Re: [REGRESSION] 7.2.4: nfsd sends CB_OFFLOAD with all-zero stateid, async NFSv4.2 COPY never completes
Date: Mon, 12 Oct 2026 10:59:17 -0400
Message-ID: <2026-10-12-1-daily-reply-0001-nfsd-cb-offload-zero-stateid@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <1791797151.oll70jtyaa.astroid@yuna.none>
References: <1791797151.oll70jtyaa.astroid@yuna.none>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> AFAICT (for 7.2.x) you queued a full pick of
>
> f307b4f7ed17 nfsd: split nfsd4_copy into transient and durable async copy objects
>
> in
>
> 0b2963340727 nfsd: split nfsd4_copy into transient and durable async copy objects
>
> despite Jeff stating the following up-thread:
>
>> We should probably just take Lubos' two-line fix as a separate one-off
>> patch for stable. Backporting the COPY code refactor is too risky IMO.
>
> Was this intentional, or an accident?

That was not what Jeff recommended, thanks for catching it. The full pick is
now dropped from the 7.2 and 6.18 queues.

Jeff, Chuck: could one of you send that fix as a proper signed-off patch for
7.2.y and 6.18.y?

-- 
Thanks,
Sasha
