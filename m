Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 02F541DCB24;
	Tue,  9 Jun 2026 00:33:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780965225; cv=none; b=fojRQamG05HY9ewZOdgpWWYuFBm0s/9vMPQYmxqg4GvpLJ+SU4fMhN/TATJlz4GcAPWVfUJKWRXGj9nvBXAk+BddfXgoR091tN2mtu3Yl7VpQYV1n9ywGJ0GBlp0D2nYR1r1z9OX4Edh6YNblNbo9WTjmaA4peaRXoofCYjsSvQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780965225; c=relaxed/simple;
	bh=8RuU++UwisR5fPXlzSFXkEWmO/woXKh12mt3rGjxlKc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=mzwGO0dDSYsm1WeeWRGEDjApqy6rQbDCdcWaQqMQt6FQkWFM1eFZgxQ93dmcQMk2+ztyTa4w7dsiU08yuuant7hoAvye82huzh89Y1dI/Pgr7i7ViBFLclwXMD4uUoSWSOKmljtKwcPMcFhG3KV+Z2h3qXxiF4OXoksj9KWu1SA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dmTUDU2Z; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dmTUDU2Z"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 99C081F00893;
	Tue,  9 Jun 2026 00:33:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780965224;
	bh=rPhf1brFQBHAvLs45E4bbHeOYrSE211UYIuxCAmTF1g=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=dmTUDU2ZlUO4gwkiZWtliHtXJGzfrAshvkbRmyeUnycw+K4qztRaSxRmSTVmwePrY
	 96DZ9UpOX+PiuMqMXJN4x13AK7P9HbSP8fcgh5R0J9Xkm80Kn6MZ8PdOub62USFoeX
	 6P7yL15zFbDDpfpduYQIxPAO1cimmfrrhTfW4vh/muN7m7CulRrbDMcOP35x04cyaf
	 gWsb5ik+DVd/tUn1iQVPlt4wQPDDPOJTvoQ7HflkIcKgB9U/DgHyHGBZl8RGe2eIg/
	 Kd3m4Z+VLULeCWPwsiUPdFrBIAXwJ4/9PEpPgQV7h2hOTek53VRYS2Uz099sk3dYYd
	 6iZXruyrOaGcg==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	David Laight <david.laight.linux@gmail.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Geert Uytterhoeven <geert+renesas@glider.be>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH 1/1] sunrpc: Use "%*phN" to dprintk() a cookie
Date: Mon,  8 Jun 2026 20:33:37 -0400
Message-ID: <178096512225.86595.10611807401110857204.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260608212042.25476-1-david.laight.linux@gmail.com>
References: <20260608212042.25476-1-david.laight.linux@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Mon, 08 Jun 2026 22:20:42 +0100, David Laight wrote:
> Simplifies the code and removes a 'not obviously bounded' strcpy().
> 
> Delete the local function nlmdbg_cookie2a() that did the equivalent.
> 
> There is no need to worry about cookie->len being more than
> NLM_MAXCOOKIELEN (32), the buffer holding it is only that long.
> The existing length checks must pre-date this code being added in 2.4.26.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] lockd: Use "%*phN" to dprintk() a cookie
      commit: 926ef0ef7994232faab29e6b13270d5c88b058f3

--
Chuck Lever <chuck.lever@oracle.com>
