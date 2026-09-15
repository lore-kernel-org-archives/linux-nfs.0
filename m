Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 949394A263C;
	Tue, 15 Sep 2026 13:56:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789480602; cv=none; b=Faad5fnL3kq16fkyd9v1X5b4bBxkfb6benRi1KGOeIHm9DnjoRemVjhcfCODBwLgkHUjLJGAFtnUa6S4uFSra9XefAlHEOF+3/ZlgBNzTFS++T5iRnkX3Qs+4Zn0mvvIb5t5BEnCi/HVNhVWFRgKBcbkg6WgLcTW6Ah/Dm4wiKY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789480602; c=relaxed/simple;
	bh=hlVuAqoTZoPF6dE9e8ruGMTS+jYmOtXqwPNeAEXaFpE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=ik4dVVe6qy+zww7vPF8L4bDrK4zS6PiNdBmUAHTd9qbcOtHpjSUgvWA4NctzfouKyUtaG+wi7JQYsZ1qKeFtVIaBjkl+Vh7Ps/hNz0iEVbPTp5cpM4MyQ/lNedJ5x/FrPiaVDsvDJwAIQYz8roW6kzU7t2d4/cW63B2mnClCFjY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RUVk5vGX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RUVk5vGX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 38B791F00893;
	Tue, 15 Sep 2026 13:56:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789480599;
	bh=Jc4nx+Zn8Bf8du3OMyUcsplHpkf66ZLbdrJ77R8vacI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=RUVk5vGXcc8cnHsnZuUYnZav0BkKxppz6Q9ewDXK3gWaglJL/CL3wFlbEme7Q+7hH
	 vBRBtakUVEpQi02SYbPqy7HU/WaLZPVlgS4scqehdTfBY77FQOo6VEG3AbpiImfa30
	 jIFYJqcIDZorVXpBG9UR/hO/e9yCdWZ72/ap8iedigBo2kMelcbdt1HxmBUrlOqM/D
	 IEuE1ONZssyVSSK1TSzBvGY9kei69BquFK0a2spLPw4fNG4GmJ5fyqZkhg4sFEMTwO
	 qYjna5cd1XO+4Hs1YBI/GvjMPKWYbf1E/guMUCCm4OazxYwvd9xtaxTDWcpc7BtjqT
	 2kNA/Z0Zcroaw==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Aldo Ariel Panzardo <qwe.aldo@gmail.com>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] nfsd: propagate SETXATTR value decode errors
Date: Tue, 15 Sep 2026 09:56:36 -0400
Message-ID: <178948058842.1050566.15909141985888769689.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260915125636.2849626-1-qwe.aldo@gmail.com>
References: <20260915125636.2849626-1-qwe.aldo@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Tue, 15 Sep 2026 09:56:36 -0300, Aldo Ariel Panzardo wrote:
> nfsd4_decode_setxattr() stores the status returned while assembling a
> non-empty attribute value, but then unconditionally returns nfs_ok. An
> allocation failure can therefore leave a NULL value buffer paired with a
> non-zero length and allow compound processing to continue.
> 
> Return the decoder status so that the operation stops on the original
> error.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: propagate SETXATTR value decode errors
      commit: f6c38392f815da751d4330adad2b937586a0f0fa

--
Chuck Lever

