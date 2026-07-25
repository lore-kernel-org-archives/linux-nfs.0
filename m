Received: from mail-43101.protonmail.ch (mail-43101.protonmail.ch [185.70.43.101])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6F0675464D
	for <linux-nfs@vger.kernel.org>; Sat, 25 Jul 2026 04:07:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.70.43.101
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784952443; cv=none; b=DdsPK3TJ+Dnw6VTOZyXHQHu2njbNKBZwGJC2sAOjamGzaYygjT7TNpI0OsnVeM+2Y5dCA5bpbQ6iyNA1uA65COjEdhQiopiMRwRXk0uHvns6lo92Sdj3GKWRuKSiC8h0+GKoFux5L88ol9UXI5AUMfw4oQ4+vmATqWgvSqx6+g0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784952443; c=relaxed/simple;
	bh=waHeaBngq8beLW9dG3BqWmzCtPTdrjNN9VqOoPteiIc=;
	h=Date:To:From:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=RoWNf6UXA16DgJpFUEP6pnp5LAL7Wd/rCAQFOlxcjPOffC7Ltr8hXSB39ncXzk2ddmWpbMOdItFfvPjA3ZQg4pNK2bPc7AQsP94TNXQMsZcvFPby6Q6Viinvg3c1gjzg9NIY6Iu3En97AVdXgNLtBuUdQAK97QTjH13Buk+msFI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=proton.me; spf=pass smtp.mailfrom=proton.me; dkim=pass (2048-bit key) header.d=proton.me header.i=@proton.me header.b=YifZheQr; arc=none smtp.client-ip=185.70.43.101
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=proton.me
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=proton.me
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=proton.me header.i=@proton.me header.b="YifZheQr"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=proton.me;
	s=protonmail; t=1784952429; x=1785211629;
	bh=waHeaBngq8beLW9dG3BqWmzCtPTdrjNN9VqOoPteiIc=;
	h=Date:To:From:Cc:Subject:Message-ID:In-Reply-To:References:
	 Feedback-ID:From:To:Cc:Date:Subject:Reply-To:Feedback-ID:
	 Message-ID:BIMI-Selector;
	b=YifZheQrRl9t5ywtA2lR6jnd2gDxmpdkYKhMOlmXqXcXdjY7SQzKTpCS9sK2cStg3
	 bqiAIDrK6moSAQvq1YhGhetAS23M8gK6gnKMfBoKCAXw+LwPa2StmapxKQ2AySApTS
	 TydQquiaen0WZCH0VLz7PTBawVwnvDmJHwEd4un20DXZVBharQ2PUTs+fxRWM39IaD
	 AbTQoeMtLM5ff77Mn4z+9Ts63sFSxqhjPTNqb3w/Fb1qu4Rz7FMpLpjch92bgf6YKa
	 F6j9buOrwwzdu03PxEzk+1uUbaGdAaWOHKrfqD1xCkYyJRCaOx/Z5C1kzZVr/UVz75
	 WXVi4bN2+eKnA==
Date: Sat, 25 Jul 2026 04:07:04 +0000
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Michael Yang <michaely4ng@proton.me>
Cc: =?utf-8?Q?Holger_Hoffst=C3=A4tte?= <holger@applied-asynchrony.com>
Subject: Re: [BUG] NFSv4.2: futimens() returns success without sending SETATTR
Message-ID: <rW3QLccRCVEh1K5wdSXYsXqoy7-0LhDI_yFdXIxHj9L8v9BfBdI1U3RM4eAqhktqrOiL25N_JPtUBygWz1v3yxT3OBnZxjSTtW9Pyk9Ngmk=@proton.me>
In-Reply-To: <fcffc38c-80fd-ca2f-1b1a-f9d041c6a2c7@applied-asynchrony.com>
References: <nMlXgkbm-9ZP_fFN16OpzFd4kwNlyXq169-6CoOE4nuHyTsmGaFeJgzuhj3grRboJKg9RapKov2_FJ1E3BCL0oZ7UNzF0pgwwhVC6VOVJYQ=@proton.me> <fcffc38c-80fd-ca2f-1b1a-f9d041c6a2c7@applied-asynchrony.com>
Feedback-ID: 153107444:user:proton
X-Pm-Message-ID: 89b4b7bc4f4a9e7a5c107f07b471268a5068b079
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Friday, 24 July 2026 at 05:22, Holger Hoffst=C3=A4tte <holger@applied-as=
ynchrony.com> wrote:

> Confirmed (also with 7.1.x) and thank you for tracking down the details.
> This has been driving me nuts for quite a while, but I could not figure o=
ut
> whether it's my very historic NFS config, server- or client-side, autofs =
or
> whatever. Thanks for saving me a ton of time wiresharking and stracing.

Thanks for the confirmation.=20

I've found this report (https://bugzilla.proxmox.com/show_bug.cgi?id=3D7621=
) where the problem manifested as early as 6.17.x and 7.0.x (but is not pre=
sent on the 6.12.88 LTS kernel), and is isolated to NFSv4.2.=20

I can confirm with client mount option vers=3D4.1, the timestamps update su=
ccessfully on the server.


Regards,
Michael
