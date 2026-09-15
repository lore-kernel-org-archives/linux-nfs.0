Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F5FB4CE679;
	Tue, 15 Sep 2026 19:08:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789499313; cv=none; b=aF69ahHhyKHidlMxtfPXJtRwyXqh9zf8NFIFb/1DKf13sdKUvp3lYYDYQBK4MbKCrZzSoWz1yMl6+WXAZMtEoMJV5qNYveaz+M4WrxdTPTvEs/1SmYeEdXGIlKrX9zqdYFhUT5K6/AkbZazCGxDSOM62C9qaR5iRATp2xSJNwkw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789499313; c=relaxed/simple;
	bh=cstNuBy6IWBPoEwOkEGVXV7VD5dnRufM61HlcQkWSeE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=hlZZuvKFYGVJnS5gY4BJnR6Y37F6Skwh6F7GSSrX1SdOyIHXZs/iH3bkZsipw7KANOnaQJVns3ml4gylALwTm4Bv1VULpYeH9a1xxYddpppIjFt881mLRPYpcfqA/XtACnu3tL+ue5NGbw8R6ZQMn6CtDk9s4whUaYiL7BNZHII=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VemIR81W; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VemIR81W"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CE1751F00898;
	Tue, 15 Sep 2026 19:08:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789499312;
	bh=mh4xyUKx6xg3VO+ryB06svrB7IXUGG5aSSSbLIr+xOM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=VemIR81WYuX28cp8NIiC/Z3yVSr1UFm8YHYthHLnYn0vbx32kxzLCX+0jLTqV7k1d
	 lhyPf5dQ74LWiZF3sAJxoka6KzZmrO/s7q0qBFCP3TUDQAZD4rx+uqSkgQcEuE5NNR
	 wjbxkQts47qPPgPc0piiEyW95ihgjH794pq0WD/AmTsQwN2TudGBPTmrCjEul9dUlo
	 n0tn2NyvNcoOaypet00RxrAltWPDZyoZb0x9u9Ds+//jpRTb5vZWRoQJ5IzuYBj+u0
	 G5F6d5SHD+lapLbAwQcalL0EUotJgMWFbSAU5JXTBthF/F1/ciznlrgaWY8GPv2tGO
	 GvWVJoCWoGd4Q==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Aldo Ariel Panzardo <qwe.aldo@gmail.com>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] nfsd: use xdr_encode_opaque_fixed for all GETXATTR fragments
Date: Tue, 15 Sep 2026 15:08:25 -0400
Message-ID: <178949928869.1538756.216536293446757123.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260915173902.3184534-1-qwe.aldo@gmail.com>
References: <20260915173902.3184534-1-qwe.aldo@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Tue, 15 Sep 2026 14:39:01 -0300, Aldo Ariel Panzardo wrote:
> nfsd4_vbuf_to_stream() already uses xdr_encode_opaque_fixed() when the
> final fragment is shorter than a page, but the preceding memcpy() in the
> loop body does not clear XDR padding.
> 
> When the last fragment happens to be exactly PAGE_SIZE the short-fragment
> branch is never entered, and the loop exits through the normal buflen
> path.  If that final page-sized reservation is not word-aligned within
> the XDR stream, its padding bytes are left stale.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: use xdr_encode_opaque_fixed for all GETXATTR fragments
      commit: 802e78a4db687ee132ae9c71992490c201fdc39e

--
Chuck Lever

