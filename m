Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795114116;
	b=e+BDv3v/oYI3opgyXshua/NQtAuNTy2LGlDU4U9w0xwqKu9kY46f8GfptsKiWznAfArG
	 pnO981b9Ez50wqAszouB6JJOL322vOfaFAgc+mnu/HdQb2fw+haxrfXFsmLbUvLbcqwjO
	 M+CVxg31kjn6TgpnFnSbHXnl/JTNGBZcje3ry+4dLDs+Zqyl9dHCem6BdvLbSi3a7fmlZ
	 lTVG9QqlnElY4hc2pyam37joC+7C6J2KWUEqxrPVqOo2nscY1flAwa34BshD9sErVnhyf
	 3GPW4OsVr3ox0pYzNNZ2G/7CACFcFuBk9KDozWGkFN3KTw541tJEZpeHDan8dFfSspg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795114116;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=ynqFemkZ8+FyY/931uvypNF4NLOO/wM9Jm6QQkFsPAI=;
	b=hXeRUXIxGv9OcB5OyUQ7Ia8hESHKEbLP40StwqqhUQTOUhXvGFQv2ZTkO8Dot8DfSWF1
	 oW+sqJ47PaN2qf2Ciz/K4Hi7BFIULnh3X4kNXmzHUazEpclSZp72MvlTjPaJbEP5yC/+B
	 4OZZtKsgCzhaodnIGA9UTR1uNv0nE00CPVPQNPwo2xz8shBrn3qvbZAXPL1GP/3+vBnei
	 ykZFJVusPjQpCZhc7evSwkAFsjP6WkRfi5QACBDTJDWYtPG3ilIAPdveLtWw5ZQ99+zh7
	 vaOzdgDAbmKPyeuuoD9Ualz5ZTAQsywk+NGe5M/58OwlSlArlyRz7YJenefhYWnTLHQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Hv4enhpk;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 58F12606A33A;
	Thu, 19 Nov 2026 18:48:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Hv4enhpk
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AFF861F000C4;
	Thu, 19 Nov 2026 18:48:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795114116;
	bh=ynqFemkZ8+FyY/931uvypNF4NLOO/wM9Jm6QQkFsPAI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Hv4enhpkJneDS1sYfUR5jkKSUpGXp+9L20o/6TA3s+b03BYYvXdAX5YjLwh1rvv8b
	 DXDuSlkp7u8lqh1BRsh8Gkx6mmrqhL8cm9StKp2qTgoscBeU9NG567tfaju5PYjUsJ
	 TEoHtcGgLU4YlQTqFE/JnYRXNi0t7IUg4YKviqLfWWnGzFkcQHQa9zuUEMsk+78tJP
	 odkCvZmDxooeED9KGE0FnY96x/PZAAYw/ke/IqHWJkkXlAfYlKsXzc0hEvIyG9jNuU
	 RyqgCPyiVrH9nIzeGY8gSsKp7l9bIBDsLkPZo/Vng+eQOGAxzjaoeWQm4bWHg+H/cd
	 hZSHKD83Wlc9w==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Anna Schumaker <Anna.Schumaker@netapp.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NFSD: Reject a COPY whose source and destination are the same file
Date: Thu, 19 Nov 2026 13:48:33 -0500
Message-ID: <179511410793.43030.2716809282684639561.b4-ty@b4>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261119-nfsd-copy-same-file-v1-1-ef18e53a00d0@kernel.org>
References: <20261119-nfsd-copy-same-file-v1-1-ef18e53a00d0@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Thu, 19 Nov 2026 09:42:56 -0800, Jeff Layton wrote:
> RFC 7862 Section 15.2.3 says that COPY MUST fail with NFS4ERR_INVAL
> when SAVED_FH and CURRENT_FH refer to the same file, whatever the
> ranges. NFSD never checks for this. A same-file COPY with
> non-overlapping ranges succeeds, and one with overlapping ranges fails
> only because the VFS rejects it.
> 
> The overlap-only rule applies to CLONE (Section 15.13.3), so leave
> nfsd4_verify_copy() alone. Instead, check in nfsd4_setup_intra_ssc(),
> after both stateids are verified. For an inter-server copy, SAVED_FH
> names a file on another server, so that path is not affected.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] NFSD: Reject a COPY whose source and destination are the same file
      commit: c235ae9d5057e37ed83de15b27fd8b8174a032d0

--
Chuck Lever <cel@kernel.org>
