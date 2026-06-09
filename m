Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5ABFC244661;
	Tue,  9 Jun 2026 00:33:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780965227; cv=none; b=sC5P05KF/MlXCyg9g9yr0z6bF14pMu0+ajjQ/7YsDswPNxC89fkrXlTO38SZ0alSuwYf1O9FTQajSDPgStSOLoBWXEQmtLUdnwUl+fZbWQy7Cv7z9IIZneTUgYs0IExBkAB+UUa2QdZC6n0+pxkuvy6xfVC+vmNRY5lOAiuhoxA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780965227; c=relaxed/simple;
	bh=t8gEdjbrs6qgE0T05yWWf+zBdM3rY8wM+GccnVr1ZFw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=A3jHFUnwLnGwhvTdp/oDP+34ov0/Atrp1nrPtuKkA9XLrQ/kQAdVSpxUXSkG3vpxQDaKAPChUmLyyYYUBz9MQUlf7ZRCqSACFP+luUlEoeHaO/xqM2BWMZWnHyma7EkIJVHltU256/THWC8IyDFKy3Fyi3qXFb2yu3oTPxEdDbc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZODzerro; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZODzerro"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D9BDD1F00899;
	Tue,  9 Jun 2026 00:33:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780965226;
	bh=YuDJfJJTRs3UGqZWaxi44T79ItiIkoQpI092YqffL3E=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ZODzerroKrElQpgiYs7ZyrZeFuZ/lXdg7gpSRRE4E6lwrOOFK+t4uKaAsmig7dkgs
	 kGlydAKYDv9ZPW/J478CYPs0snXBTvoKFFJBsyCWFVZGaMXqmMSnm8tj4iya+4Xk3b
	 sPC8xK1esKeHVJYHHyMwUResT23pi5JoFD/Ky829OQzKtU05jG0MCXuWTupmecWGgg
	 90SvJDG0UafPP0qVa7zT671rkQ26LFmDh7B0myT3IhVjzlX0mhOksD6vqnN1IlaRFx
	 HXsKHL7MSXwmXsINazzs3HSwLqOrfH7/zPbEGtyI3QyuFtiR9l1xA9EHLNlogSgzxv
	 5gNsrgaT69ZOQ==
From: Chuck Lever <cel@kernel.org>
To: Kees Cook <kees@kernel.org>,
	linux-hardening@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	david.laight.linux@gmail.com
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Arnd Bergmann <arnd@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Trond Myklebust <trondmy@kernel.org>
Subject: Re: [PATCH net-next] net/sunrpc/svcauth_unix: Use strscpy() to copy strings into arrays
Date: Mon,  8 Jun 2026 20:33:38 -0400
Message-ID: <178096512223.86595.14618546480318543216.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260608095523.2606-16-david.laight.linux@gmail.com>
References: <20260608095523.2606-16-david.laight.linux@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Mon, 08 Jun 2026 10:55:00 +0100, david.laight.linux@gmail.com wrote:
> Replacing strcpy() with strscpy() ensures that overflow of the target
> buffer cannot happen.

Applied to nfsd-testing, thanks!

[1/1] net/sunrpc/svcauth_unix: Use strscpy() to copy strings into arrays
      commit: cea9ba4f71e82766d782ed423c99bb12a69bbdf0

--
Chuck Lever <chuck.lever@oracle.com>
