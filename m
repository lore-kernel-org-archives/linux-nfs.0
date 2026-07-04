Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB71B1A9F87;
	Sat,  4 Jul 2026 02:05:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783130739; cv=none; b=kLS3owfyRXGP5lMMFw54U9Pf7K88X5ixWF3adjCGUgCXU5EcGZ5FrHG0084RH2IGXF3tpPSXZ36v5xHdiAMUFgvHMZV/GG+bNYFyokZlWguiifHBVItVIgRES534tcGEDc0Rd0Ik0C166a26DlLszHlktJOUu/mr+9lnE20Dwjc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783130739; c=relaxed/simple;
	bh=XzgOGwGPehfG/WRUed3ahxUGrLcgClNfBsb22Euby8o=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fPsocXhphP4lD6SFfN11spVX7QFc6X+5s8FdqT2/l+zNkzi6qPDV5b4IyjxIJDcHlTIV446HmkyTcXRugyekXqnXA2jKvoF8OSKBTHOLaNfuiJvEH6WBxsOPaeEmb57UnrZ7vmWjtorBuirEjk4EqW7xB0Vs8C0D4M1eWYe1eyU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iaGCwTsq; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iaGCwTsq"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D0EBF1F000E9;
	Sat,  4 Jul 2026 02:05:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783130738;
	bh=RWcPWzNzjvh23hn9MaR4ON2sVnmrSmQb48jJ25ZOaq0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=iaGCwTsqyrCLvNosJdrB+KIp6GHzdp8fl1/uULXIK8LjIqZOXwPOWBkKZH6t7K0wZ
	 nUrIzJr1Jk3s75hkhda2gsYBlZuzyt2qQ9NVegOoaUc1Co/zChSkG4iAvlJNtNxByi
	 tgTXnIc/j7ihCcbLEEEUmKgVXIjHuXLfzpcVKn8jtUbXx8G7+udas9uIFBloND6zSz
	 19q3E3JWGE97bUcg+9K33mMLG1RYhj6vAayLrKLZNMwJ/q93JdfVx1/4j+uU4c1UBV
	 asv7jVAF1M0SKxec+iBX+5pmAcWiuIfVfR8P1ZM7nlXbi4gQ0bi6c1R7Lf8XZ9oV17
	 JOOcLhFn+S/ig==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	linux-nfs@vger.kernel.org,
	Jeff Layton <jlayton@kernel.org>,
	Chris Mason <clm@meta.com>,
	Chuck Lever <cel@kernel.org>
Subject: Re: [PATCH 5.15.y] nfsd: reset write verifier on deferred writeback errors
Date: Fri,  3 Jul 2026 22:05:05 -0400
Message-ID: <2026070315-stable-reply-0011@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260703033705.1572486-1-cel@kernel.org>
References: <20260703033705.1572486-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Thu, Jul 02, 2026 at 11:37:05PM -0400, Chuck Lever wrote:
> From: Jeff Layton <jlayton@kernel.org>
>
> commit 2090b05803faab8a9fa62fbff871007862cac1b7 upstream.

Queued for 5.15.y, thanks!

-- 
Thanks,
Sasha
