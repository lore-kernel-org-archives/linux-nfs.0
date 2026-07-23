Received: from mail.itouring.de (mail.itouring.de [85.10.202.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 88AFC4908DB
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 19:29:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=85.10.202.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784834946; cv=none; b=nJU1AEz79PzS04jnmRmMW7ruIQFzM6+V5fdmxxfo2NfmvDBVL06+DEubGg5dVgvSjLFVyUNhlWrp+Hxaydks6mj0C/xSqKO22V9e2SkCLX7+CZU0NVLBP44x/lEqH4EaCGm4zJLF9Qxvd/JpjFZRXx1PGldSp6zcs/NpwHWqgwA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784834946; c=relaxed/simple;
	bh=qrVhZZQrwDkl600A0HIVf2ZF2kD9ngWKnIQcpgogrp0=;
	h=Subject:To:References:From:Message-ID:Date:MIME-Version:
	 In-Reply-To:Content-Type; b=pUYMTZ+gDCngTzzSn+6+PjseVMvzcUkOhyCsJWL/EIt6MkM/iRKOQa8RizpkhJUA1ojarcfjqkNz/QS/fX/9jsNEcsFd0F9DgZOfG9Z0/vJqh10+piPaD/+R8gkFvyPVIkMLmVIuFFnjJQMhMrvqQnYIp3tPq2PMJKAHIIG+deI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=applied-asynchrony.com; spf=pass smtp.mailfrom=applied-asynchrony.com; arc=none smtp.client-ip=85.10.202.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=applied-asynchrony.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=applied-asynchrony.com
Received: from tux.applied-asynchrony.com (p5ddd7a22.dip0.t-ipconnect.de [93.221.122.34])
	by mail.itouring.de (Postfix) with ESMTPSA id DF8041577;
	Thu, 23 Jul 2026 21:22:30 +0200 (CEST)
Received: from [192.168.100.221] (hho.applied-asynchrony.com [192.168.100.221])
	by tux.applied-asynchrony.com (Postfix) with ESMTP id 413ED6018AB9A;
	Thu, 23 Jul 2026 21:22:30 +0200 (CEST)
Subject: Re: [BUG] NFSv4.2: futimens() returns success without sending SETATTR
To: Michael <michaely4ng@proton.me>,
 "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <nMlXgkbm-9ZP_fFN16OpzFd4kwNlyXq169-6CoOE4nuHyTsmGaFeJgzuhj3grRboJKg9RapKov2_FJ1E3BCL0oZ7UNzF0pgwwhVC6VOVJYQ=@proton.me>
From: =?UTF-8?Q?Holger_Hoffst=c3=a4tte?= <holger@applied-asynchrony.com>
Organization: Applied Asynchrony, Inc.
Message-ID: <fcffc38c-80fd-ca2f-1b1a-f9d041c6a2c7@applied-asynchrony.com>
Date: Thu, 23 Jul 2026 21:22:30 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
In-Reply-To: <nMlXgkbm-9ZP_fFN16OpzFd4kwNlyXq169-6CoOE4nuHyTsmGaFeJgzuhj3grRboJKg9RapKov2_FJ1E3BCL0oZ7UNzF0pgwwhVC6VOVJYQ=@proton.me>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit

On 2026-07-20 05:18, Michael wrote:
> I am seeing a reproducible NFSv4.2 timestamp issue where an fd-based
> timestamp update returns success but does not appear to send an NFS
> SETATTR operation or update the server-side inode.

Confirmed (also with 7.1.x) and thank you for tracking down the details.
This has been driving me nuts for quite a while, but I could not figure out
whether it's my very historic NFS config, server- or client-side, autofs or
whatever. Thanks for saving me a ton of time wiresharking and stracing.

I got curious to find out when this started, so I went and tried 7.0.0
and voila: reproduces. So it probably happened in the 7.0 merge window,
which matches with my hazy recollection.

Two commits caught my eye:
b8b3002fbfef nfs: split nfs_update_timestamps
761475268fa8 fs: refactor ->update_time handling

The latter is part of a larger vfs series.

Hope that helps someone to find the cause.

cheers
Holger
