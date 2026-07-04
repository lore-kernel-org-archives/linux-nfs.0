Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9A0F13603C3;
	Sat,  4 Jul 2026 02:05:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783130736; cv=none; b=oeX+tzsh69VOHIxLsiLIJXiLiqxg5T4Av7vBdmpB658fKhSsvA+k7+DMdYxHINeyKfZJnogVxSPy5680pDzt6VToayhF0nBoUMfx9U+Woj1wZWL97cWC8sOI5X5p7R5YmdgZbL1ueQCf+xYuPnFczb85UiMOWQ/humSf774wytc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783130736; c=relaxed/simple;
	bh=iNSHtNtDCYhKS4qjASMsL3fPguj6ybt2uZqYtV3k3CE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=qfCHE+2HQPCQR5N2xpTpDOE3JhSlNDychvu049+mSnXzNE10LJNDbabjYJaTyHBuUefpI0aKS0ubpNxLdPPhkkfcnICC74bz9JwlzfmY5GNMhABkTSHVv1h5Sq2QRlupCYbCrteZ8/k6h5rvs4BM7gkWeDcLsl17pnvoQOw+ufI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TtGtnY4r; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TtGtnY4r"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C04BF1F00A3F;
	Sat,  4 Jul 2026 02:05:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783130735;
	bh=6GCNlj9MTFZEj6SPqOFrCxxnUojhEQz9BikUHyWdTk8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=TtGtnY4rolNFlelW6ECAXDTyxtIUQUyN14Xp/cDCb8xdVY/aeUKKjU1QBKLrZEkM9
	 hLNOAOFYnyHxFHF0DSzQ9jrTTo9+LiAWNpd0AZsA2Ig6IpvmENxffC+zsJtnR8c7YK
	 M58XygNgHV/v4dkeXuSynjMpcME4f93Xs9J7KI571G8E4e2OdVYgAiEPL7qixcrP2v
	 6iaX+AQmrOuHrXKF1ule8LbE6SpgD+wD7E2aqRXVttQD3FNavzfDFUCVAu/ttOZXwl
	 O0YEsn6hzgZjw0hPZvjiqlZklLG38xA8Nxpzm+g4+K/dbGGT7AEji9hYiO/jQOnLsO
	 eW3+dUIWjKV2w==
From: Sasha Levin <sashal@kernel.org>
To: stable@vger.kernel.org
Cc: Sasha Levin <sashal@kernel.org>,
	linux-nfs@vger.kernel.org,
	Chris Mason <clm@meta.com>,
	Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <cel@kernel.org>
Subject: Re: [PATCH 6.6.y 1/2] nfsd: release layout stid on setlease failure
Date: Fri,  3 Jul 2026 22:05:02 -0400
Message-ID: <2026070315-stable-reply-0008@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260702214135.533354-1-cel@kernel.org>
References: <20260702214135.533354-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Thu, Jul 02, 2026 at 05:41:34PM -0400, Chuck Lever wrote:
> From: Chris Mason <clm@meta.com>
>
> commit 30d55c8aabb261bc3f427d6b9aae7ef6206063f9 upstream.

Queued the series for 6.6.y, thanks!

-- 
Thanks,
Sasha
