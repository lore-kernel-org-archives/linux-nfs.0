Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BBDBA372EEE;
	Sat,  4 Jul 2026 02:05:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783130740; cv=none; b=SOkwPmpHaG5Uij6Oy1ealeu0P62XGyAD9/xzVgN6QFi8XQ6LtrIYj+071KW9huoSJet73zhauf2wCYHV0T5FjpPoqi+ixJfXLuEvtG/ls65stZfP60CdadxlGIW26r8tEDyKNfLlxZnlWXgtEIDADTOCkc/8XI/Hp2g4paLTvjA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783130740; c=relaxed/simple;
	bh=Fo2SNl3WiRSCFV6uKCXzWoQmzx9lOUi1m/poFPkA544=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=hXallEsb75jAqvsnf0Oxc77mSSNJi2EmJvx6asoC6phbA9BM/xY1G78/qvjhU+4BGVOrnU1LBDFYmxPuwyRcA+gy/dQEjndXWNZuBncOnvH+3jImjWrjZpW7NpWECdJz8ZAdJjXqCYq6kZyV3g5T6/Nj9Dxt9/uR/0wgvRaCzCI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OeFAP0pT; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OeFAP0pT"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D8C8E1F00A3A;
	Sat,  4 Jul 2026 02:05:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783130739;
	bh=76fzJZQMN3aLIBNZ+Pzbf0nTDBaVFx1fV3JNVFQtLII=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=OeFAP0pTnNanusy2krWR12QwIQFh8ULLdbVdYVd5Zt1LtKxixpnpUP9DOOEQzSUQV
	 QhvNEG4tm4L19ELqImRfgA1WeDl+BjkpU1+SA0gK+KWu6sVyjxxXkrzmdJ4HHW6M0u
	 EJRro9QN9JISxhZRxC0BK+i5NSkg08MeRBO3/HlqbvH0sc8oytlazOxxtEu+raw7t/
	 zO/Coafw2H2ui4JcJJ/popXZyOnlBPqi4jSxZuOyMX3lhrYJwEUPVnHvtrkAJHNVs4
	 B9QZ58ZFyIXEbMboIpLKhhBmBjrgO2P7plfHtydA6n5VnxHDxrHgD7by0z7doiqQQN
	 e+pu66L6kOY0A==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	linux-nfs@vger.kernel.org,
	Chris Mason <clm@meta.com>,
	Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <cel@kernel.org>
Subject: Re: [PATCH 5.10.y] nfsd: release layout stid on setlease failure
Date: Fri,  3 Jul 2026 22:05:06 -0400
Message-ID: <2026070315-stable-reply-0012@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260703033954.1602126-1-cel@kernel.org>
References: <20260703033954.1602126-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Thu, Jul 02, 2026 at 11:39:54PM -0400, Chuck Lever wrote:
> From: Chris Mason <clm@meta.com>
>
> commit 30d55c8aabb261bc3f427d6b9aae7ef6206063f9 upstream.

Queued for 5.10.y, thanks!

-- 
Thanks,
Sasha
