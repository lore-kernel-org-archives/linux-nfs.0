Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 28F274B0CAA;
	Tue, 15 Sep 2026 19:08:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789499312; cv=none; b=GP4UNXrCxk1RgY2/7e5oheB4N9MkKCucq4MGSgCaIPGaIoc0lu3xk97aM+0IPEpyLsG8UTImREJBROmltmOQ7iqzL9Ywf67s8946WdeXS8/qRjIZOT3ATi5dL75kmardQ/KRyI01GUhEFcp3vcs836I9tdw4fwVIORtqEWzQinw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789499312; c=relaxed/simple;
	bh=RXQ/MnkwklGCqiLSyrrVBvJhVbHPPmEkxw1+FzuI8D8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=PznWV72yf7Vp2hmW3ZRX4A8iGqoq4OBIgV34R3pHfJK/Fh/MpM/5Ss3gTiw8D6zFGzf5quNj07UDS+YGbaLtH9RP64rlhIrXOCKTWR0ZockjXIDDxT39SnCHSLnN/txD5gfTPSeXLFKjcZ0vH9pOUwDL+2mYA7FKufjH3QGTcwU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RePqDtfR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RePqDtfR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3CC4A1F000FF;
	Tue, 15 Sep 2026 19:08:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789499310;
	bh=tffMPwkY7qNDZKlEudkFMsJ00vzmBe5ME9dit8HXbaM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=RePqDtfRTavuM4FWsMuZD/b5TbYXe8GDd1Jle3HUiULc/xX8oWLm2mFF16w274M4P
	 H1cVcezz5kU52B7dXHBlbI1wq2UESo/nop7Qt2Ar+HBbiex50FDLnK+XVZzz6icUrS
	 4Fc8zHpc0IWcBvjSq8J5wNFleTRq9R+JbUGQt0QAqsO6XNQEJx98zoZl2YwQcpLoD2
	 H2+Ajf0YFHWQJPXT8yd7pt1GvTuLfLUiOuTXf0ide6MalAc/OIivnOBxHbnh84HaFb
	 NarMTimgDRLcWvNYJlmIVi58uq4D4a60eM3/HyZ6pZ5IPSAzuV7lBAeKOE9KQjX7rk
	 Pmk+Xz+LQE+Pg==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Aldo Ariel Panzardo <qwe.aldo@gmail.com>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] nfsd: clear XDR padding in GETXATTR replies
Date: Tue, 15 Sep 2026 15:08:23 -0400
Message-ID: <178949928866.1538756.14948071313409220825.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260915160119.3105745-1-qwe.aldo@gmail.com>
References: <20260915160119.3105745-1-qwe.aldo@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Tue, 15 Sep 2026 13:01:19 -0300, Aldo Ariel Panzardo wrote:
> nfsd4_vbuf_to_stream() uses a raw memcpy() for the first fragment of an
> attribute value. xdr_reserve_space() aligns the reservation but does not
> initialize the extra bytes. If the complete value fits in that fragment,
> the loop that clears padding for the final fragment is never entered.
> 
> A remote client reading an attribute whose length is not a multiple of
> four can therefore receive one to three stale bytes from the response
> page.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: clear XDR padding in GETXATTR replies
      commit: 37f0c2bea92e2c37a3ea0bb93a357336883a84a4

--
Chuck Lever

