Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5D75A563299;
	Wed,  9 Sep 2026 13:45:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788961502; cv=none; b=pU6QRaL26MxVpgIY/+xxllrPAHsTlrF3FadWgTOnW2Bypr86lp5vyA8JeRUxboyG0EdRLmfXVRdO1uLDUOP5jSnEdat2Lz+6+lIOhSouBbKvdBsyIS9gr5Xk3GPs520ZxzSCogxSDxn0cVwl36XZ1CWmzvjp3WBwxihKAvD7wTw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788961502; c=relaxed/simple;
	bh=hyvyFx3Hrp8AftpAe7Lv1fh0M0Fz8ztoCuKn9jiiQXM=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Fh1ABlW460nc7RBAsWXvKR/tMuqTMH59MBYDFPmwgL+qjWBmKE56C76+q+O8vlBBGQU+ETiPwvjPG1KtJqgjFWXnwX+Qz9689DNtwZDTu/9+AqfQshrkV608uIOBj690ztkP6xomHZXYKon3k+5Pky/BUmlUT2qTSdeYwzWvMDQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=k8yedqaJ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="k8yedqaJ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 829F41F00A3D;
	Wed,  9 Sep 2026 13:45:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788961501;
	bh=hyvyFx3Hrp8AftpAe7Lv1fh0M0Fz8ztoCuKn9jiiQXM=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=k8yedqaJgOTFkjLsyKu1ZDe87lRhmSqEDREp+KgeI8srQL310iFWMVnwntR26otOH
	 eHerCGJ3TBKZrIBFo+PtmgPeDZYPCNbxhktk+G0m9CGpSbk3o7U07D3Q07PyF/W71V
	 psd4jFcXVyY8al92TTahW66EQSIsJtZc6Eetq+XtDN9xW5CCYSnsBaofeQp6G5FhnY
	 oXbpF/NzMhuJn89p9yg9lFnemouI97forL68yBKaWYTIU0pQ/BD41LmTQHCLkgytnR
	 GS3uBF1wzV4xCrhGkkjFnn0nDzYlk0kiLOOvLvcLNit0FKqjS0ReIqJKhYlaHlu6em
	 Bo1z2bcdl5KbQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 9EC78F40066;
	Wed,  9 Sep 2026 09:44:59 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 09 Sep 2026 09:44:59 -0400
X-ME-Sender: <xms:22KhalRvF3fMXjShW40zzwYEM4tnWZnw2cvGjPTlDOytKBXeBXns-A>
    <xme:22Khapmy_heSYFGidmFx5nXgNBZ1-Ed6aVIFgMlEYFusff8PTJomeeXd_WqsxxT6J
    uODSDGc5qHYb6ccXbS7rR40lA7XKtjeG1qeO-kf1kP3XKRvy5E7eZey>
X-ME-Proxy-Cause: dmFkZTG4WUQZMwjYCLD9UlI1qeoOgcX4SggFe6FfyVpgRNu0o1E1aksAGydR67sMY+0OGa
    RTqopGe06ybSCoNb42xWFYTDl844DaicJ69GlNKqRl7UDGv9EqOxPRoqbL2cBSwbhd2842
    LNr+QCzUDKiltbMEt0cdc53YPoLakn+/GOrhbMi0lHTD2Y2rohbkUSvM/Y699QnxO9kEf5
    /LQJhWfFwu3fup8DC0wto9X8B8tu3KG/F5tJ027uzrefvdorq/UL+gq/CijU+rrwojygbx
    g7V6cn/foyjyuZqpjPYnl5XVd8STcA6Q9799FYV15HPJHONG+jG3f4pzMlqohMRsUGGeU6
    05NjnjL+fcQF6gLHuAeSejclel8grItfxJhogEe1lRwcOguQYr1S/Y/oTibUnXn+Igfotq
    ew0M3USENR0IL9usvarajnJwDHyUHKgq5zH4+ceuJMdFS0pM55OWlyQk5BBzxDRvNtKi1m
    WtQAXL6ZmJb4Wp9vTVbUTznWZ4Z7DmRcGMGhKbJiipUaAFHsX0nDXJWc6IpKUhoO3AdQG+
    ecWrls4bPeB/WIiAYDnOxCaecuyg2ukxZDzUILlsFIOmdm4IpVl0Z1O87jlfW1f0GqEBR7
    zfhKBWI7/SMUpFvusVfO5Gm2Q+LAhZzFPDNLYNvRzHKAuIFvtnFJzGQ1ZzWA
X-ME-Proxy: <xmx:22KhapV1Lil2llXfGcwSPJIrnqw8Le7NfL8MRO5rkz9zrPb7mBp8FQ>
    <xmx:22KhaorpMHDfYyNXmotXjFnT3gBS5T8WJGoWHCUsqRBe2DDPWfRp4Q>
    <xmx:22KharkpakE4TGEI4rbEMut3EG-nQvdL1T1nKwNi2CbBEKLzndZPuw>
    <xmx:22Khao0XJZXI_sgFIMpP3t5_BPiZG8BaEs-RwfZcIDqZjzfjOGqTzA>
    <xmx:22KhaoRDLviMzShlqbvqZbCAXp35O4M2uHZBPpGdb_QVZZ6OW5PK_nvN>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 792FD7811F4; Wed,  9 Sep 2026 09:44:59 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AvkNhIlgtVI3
Date: Wed, 09 Sep 2026 09:44:37 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "David Flynn" <david.flynn@hammerspace.com>
Cc: "Mike Snitzer" <snitzer@kernel.org>, linux-nfs@vger.kernel.org,
 "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>,
 dm-devel@lists.linux.dev, "Jens Axboe" <axboe@kernel.dk>,
 "Jeff Layton" <jlayton@kernel.org>
Message-Id: <701e1251-bd73-49a9-b8c9-8e299b959df6@app.fastmail.com>
In-Reply-To: <B3A1EA3A-00AA-4A56-A644-9AC77FF50CAF@hammerspace.com>
References: <20260908163232.30774-1-snitzer@kernel.org>
 <20260908163448.30841-1-snitzer@kernel.org>
 <20260908163448.30841-5-snitzer@kernel.org>
 <995a853c-2c54-4bd0-9708-f6e0c1be7fd5@slotpi15m67>
 <B3A1EA3A-00AA-4A56-A644-9AC77FF50CAF@hammerspace.com>
Subject: Re: [PATCH 4/4] nfsd: fall back to buffered I/O when a direct write gets
 -EINVAL
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Tue, Sep 8, 2026, at 11:57 PM, David Flynn wrote:
> (Sorry in advance if I=E2=80=99m posting this wrong in some way - litt=
le new to=20
> posting here=E2=80=A6)
>
> Totally agree that NFSD must not interpret generic -EINVAL as an=20
> alignment rejection... But, a boundary check would also excludes=20
> geometries that capable storage stacks could write directly. We want=20
> the actual filesystem/block decision to distinguish unsupported=20
> geometry from a real error, while retaining every working zero-copy=20
> case.

Fair enough, but that's a filesystem-community question, outside
of NFSD's domain. If they can agree to an API contract that NFSD
can use, then I don't have a quibble.

To make your argument, of course, you will need to provide a
real-world use case with an existing in-tree filesystem or device
that can demonstrate what you need.

In the meantime, I'd like to see the narrow issue that Mike
reported addressed in the current code. Fixing the current gate
is not fraught with these deeper architectural issues, and the
fix should be backported to LTS kernels.


--=20
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
