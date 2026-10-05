Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 44C994A1E07;
	Mon,  5 Oct 2026 15:02:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791212553; cv=none; b=g7lAqgeTP+FFrJO3kl7jbbelSoj/nKpPTbuwg0ugJPwDmLnZ+AC2J4N09Ufej/w0cRsBJHuTwFcuVg+zO9WJo18eG9Ui8O9vV0atc2wwLa+iiC19Ga6Qz/lvxdOXjeHHMlRYyyuUPeGJ7nGsCBGGdjHU6Py6ZRrFQKxzA+Oaug4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791212553; c=relaxed/simple;
	bh=GMeQTRnsNyUMYn9rcxfMAinZdLxswWNNhAiZiw0DBl8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=rnYRLxjiEfw5U/NQ0WUgvfG6s+9PxT/dWxeok8jHw+ao/urhc9ZrRpyU0jxk0j5cxP+MhVimWAzHKxDG+FiWOq1lzynD++t1pzt0wTa/xXWcR/xkweiOPNuoUKtksHFHcDSvlCXRxfwjca3lpys6qlCKAu6R/qcJQsWN5CTdgRo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iGVvZ6P2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iGVvZ6P2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9B9C31F000FF;
	Mon,  5 Oct 2026 15:02:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791212552;
	bh=MGjEOvzeZ3Ih2kX2H11rrcnCF9Wuwzhy/T9PbEBXXqA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=iGVvZ6P2KCIoctufVcbl4LlzVDwem+TT7MsQaWnhDjUkzXaUUHWBhDIZwE8ELT7bt
	 y+bZu5ZcDCgPXgYFDJ34eLrHsJL00PbIyhc/L0NkwM2ER4g5PbTeOmUpXPHKuHNqv0
	 Ma3YlRhFt5EnBdQchzn2Qiy2c0AocFSo/u72BxrRiOSeQ4MyLH0CcRGzpMB8aR8jBJ
	 JDsTaW4CG7JkUAH5JUal6PSS5VhzJpPxGRJMU5+X4MU9VKkGTSPPP3QOXWmQdErnGu
	 izchg/lGpjxUT+yt5uJOA5XMk2vzL4GGABDo+hQ+LS+bJW7/zyLZTXDmSfJm1ThM38
	 h+O+tbhBgIVaQ==
From: Chuck Lever <cel@kernel.org>
To: Dairui Zhang <zhangdairui@gmail.com>
Cc: linux-nfs@vger.kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	stable@vger.kernel.org
Subject: Re: [PATCH v3] nfsd: fix READ payload landing one page ahead of the XDR accounting
Date: Mon,  5 Oct 2026 11:02:29 -0400
Message-ID: <179121254174.30960.17650136985188523492.b4-ty@b4>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260929162752.1895270-1-zhangdairui@gmail.com>
References: <20260929162752.1895270-1-zhangdairui@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit


On Wed, 30 Sep 2026 00:27:52 +0800, Dairui Zhang wrote:
> nfsd4_encode_readv() computes the in-page offset
> base = page_len & ~PAGE_MASK and passes it to nfsd_iter_read(),
> which writes the file data at that offset into *rq_next_page.
> After each operation rq_next_page is set to page_ptr + 1, so when
> the reply stream is mid-page the data lands one page ahead of where
> the payload accounting continues (in the current page at base).
> The client is then sent the stale tail of the current page -
> previous RPC payloads, since reply pages are reused without
> zeroing - instead of the file data: an info leak and corrupted
> READ results.
> 
> [...]

Applied, thanks!

[1/1] nfsd: fix READ payload landing one page ahead of the XDR accounting
      commit: a8ac5817d6808a59e15a297e186dd7fd25f27062

Best regards,
-- 
Chuck Lever <cel@kernel.org>
