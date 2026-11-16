Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=131.169.56.154
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794868901;
	b=wtZysDTi1wWbDMr+gnv8CQZxkUrdxJV+j7YXf4f23BGeXyAW9wor4aMCuQi9XUu3Ubhb
	 psH+e+YEaY9PqX7UnjwZG3N6ZDKzCn4wdpFonOFrWf3aHztNpHdEc6Z2SUDBo5bA6YAl7
	 rOB9N86zorkipPpCDBbwY2W1vdfXhuS+JTNbH0ClVjFpNFtTyqi1Nah9KX90k1uE1KiMT
	 SGsjecr9p9nz7Ywnm0U9PpFUjCKFpbESZvyWCMS+KmtpjhnljjIznzOhVmgGs/cy4mddj
	 2Yuq43w+Uz5Mcvfp7NpG3EZ7cO3wsm90V1gyu3FHYLijRg9uHBIcS/5KJG2g1EnEMSw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794868901;
	h=DMARC-Filter:Received:DKIM-Filter:DKIM-Signature:Received:Received:
	 Received:Received:Received:Received:Received:Date:From:To:Subject:
	 User-Agent:In-Reply-To:References:Message-ID:MIME-Version:
	 Content-Type:Content-Transfer-Encoding;
	bh=rhzmCiKBSAxWiKXjmw4Mj4UW2CjDVTe7KB9ef0ejPwQ=;
	b=BZrU+z4InupOAKYmGmvGm75ghtyNG06R7JiPnaevNy1vysd58NUE94sqkrw9EdVPwYME
	 6fgJ6SYI70PS8j+6PjNFHL6+5HcYgoLD71kfRtWYaLEDerBahn0Ng+jxhwtqvv5A68JX+
	 zPCoNbS86YNPz7ecjlr5IE0egy7puy3YTO57vgQalSKcov0Q6CzBykQGUY/u7xHXXmMPv
	 4K2+IV6m8s3YL4YtEUZZ1omOWgzKFIVxjjrMWNTb2YFNxsaErieB1y9NSbfI6X+lhGza+
	 1v7INk8bdK6TDfE35bEqm8b5WY9iSLL3n/WsBcqpPDvbUDNDTPBrp8FQYcOVEjHve7w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=desy.de;
	spf=pass smtp.mailfrom=desy.de;
	dkim=pass header.d=desy.de header.i=@desy.de header.a=rsa-sha256 header.s=default header.b=kYOr1RRZ;
	arc=none smtp.remote-ip=131.169.56.154
Received: from smtp-o-1.desy.de (smtp-o-1.desy.de [131.169.56.154])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E3172606A329
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 22:41:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E3172606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=desy.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=desy.de header.i=@desy.de header.a=rsa-sha256 header.s=default header.b=kYOr1RRZ
Received: from smtp-buf-3.desy.de (smtp-buf-3.desy.de [IPv6:2001:638:700:1038::1:a6])
	by smtp-o-1.desy.de (Postfix) with ESMTP id 60E4C11F749
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 23:41:32 +0100 (CET)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-1.desy.de 60E4C11F749
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
	t=1794868892; bh=rhzmCiKBSAxWiKXjmw4Mj4UW2CjDVTe7KB9ef0ejPwQ=;
	h=Date:From:To:Subject:In-Reply-To:References:From;
	b=kYOr1RRZtMmJ47QFK3ErZCFfA8LLYYEpIWmxEmp9y6CM+VPfmB65SnbNvqbBInpSR
	 rRGBn+L2K1DJRiH1FdUqYG9NP9cxD4isb0OuDOG3th/OIR2cLcSNoFddMqZClEk18n
	 qwM008DjmrFLYAsgZS9mORKgrTcQBX6V6t1mfj/Y=
Received: from smtp-m-2.desy.de (smtp-m-2.desy.de [131.169.56.130])
	by smtp-buf-3.desy.de (Postfix) with ESMTP id 46DA5C0040;
	Mon, 16 Nov 2026 23:41:32 +0100 (CET)
Received: from b1722.mx.srv.dfn.de (b1722.mx.srv.dfn.de [IPv6:2001:638:d:c302:acdc:1979:2:e7])
	by smtp-m-2.desy.de (Postfix) with ESMTP id 3B028160062;
	Mon, 16 Nov 2026 23:41:32 +0100 (CET)
Received: from smtp-intra-1.desy.de (smtp-intra-1.desy.de [131.169.56.82])
	by b1722.mx.srv.dfn.de (Postfix) with ESMTP id A4803160059;
	Mon, 16 Nov 2026 23:41:31 +0100 (CET)
Received: from z-prx-2.desy.de (z-prx-2.desy.de [131.169.10.29])
	by smtp-intra-1.desy.de (Postfix) with ESMTP id 730D180046;
	Mon, 16 Nov 2026 23:41:31 +0100 (CET)
Received: from localhost (localhost [IPv6:::1])
	by z-prx-2.desy.de (Postfix) with ESMTP id 645AA60544;
	Mon, 16 Nov 2026 23:41:31 +0100 (CET)
Received: from z-prx-2.desy.de ([IPv6:::1])
 by localhost (z-prx-2.desy.de [IPv6:::1]) (amavis, port 10026) with ESMTP
 id Ppqx1sO8fmvW; Mon, 16 Nov 2026 23:41:31 +0100 (CET)
Received: from ehlo.thunderbird.net (p200300e3b7001f00e29f867186111a65.dip0.t-ipconnect.de [IPv6:2003:e3:b700:1f00:e29f:8671:8611:1a65])
	by z-prx-2.desy.de (Postfix) with ESMTPSA id 4D177600B8;
	Mon, 16 Nov 2026 23:41:30 +0100 (CET)
Date: Mon, 16 Nov 2026 23:41:28 +0100
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>,
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Subject: Re: NFS client leaks -ERESTARTSYS into userland
User-Agent: Thunderbird for Android
In-Reply-To: <99d4032b341ae5a08b10f059289f21d3dd08079d.camel@kernel.org>
References: <99d4032b341ae5a08b10f059289f21d3dd08079d.camel@kernel.org>
Message-ID: <BEB57898-BEE3-4F56-BF80-A965939DD545@desy.de>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Jeff,

I am pretty sure this is an artifact of my changes=2E=20

https://lore=2Ekernel=2Eorg/linux-nfs/707767179=2E31268962=2E1760982877695=
=2EJavaMail=2Ezimbra@desy=2Ede/

I will follow up=2E

Best regards,
  Tigran=20

On November 16, 2026 11:14:55 PM GMT+01:00, Jeff Layton <jlayton@kernel=2E=
org> wrote:
>We had a report internally of ERESTARTSYS leaking into userland after
>killing a process stuck waiting for a missing NFS server=2E
>
>I've got a draft patch, but agentic review keeps finding issues with it
>and I don't have the cycles at the moment to chase this down=2E I had
>claude put together a reproducer (attached), which seems to work=2E I've
>attached the draft patch too, but it's still a bit rough=2E
>
>Cheers,
