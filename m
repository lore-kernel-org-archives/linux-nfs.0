Received: from relay.yourmailgateway.de (relay.yourmailgateway.de [188.68.63.162])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 62C2A3E1CF8
	for <linux-nfs@vger.kernel.org>; Fri, 31 Jul 2026 08:41:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=188.68.63.162
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785487264; cv=none; b=cqTPAaH6vLSbkfJjUw53ShEeQz2OOvFE378zBrzaJZyAcMZ/UXkOuP7/l97oinbwO94+cHixDetvFBKVC5yXDsBa2k/1wC5JuGZFVu/0rUXwihIWm0N60/ye2DiY3beOIxYYB+LVrxgs8nzI58uibEnnAxRB91EHX5cq439rfmY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785487264; c=relaxed/simple;
	bh=k8yEr2LUG/IgwwWTcoQt6kA5eTc4ZZbyariA3qmajX0=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=GwJBIrAuWZJbb5wTJ1sFVrnDyTzA9bI6N8Fv2PaaIT9A/elbTYr5p8iPdMM1OJfrMFSAL9P7HE1lEKAC7r5+ckLXuGfuLurFsK+aY3tJ5qt5DIIAqCRMrfbHfz4Zi4OmXajVIwjXZPq6zha0c9svQNLy8EAkkcrWmRnItu8eJ+c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=leemhuis.info; spf=pass smtp.mailfrom=leemhuis.info; dkim=pass (2048-bit key) header.d=leemhuis.info header.i=@leemhuis.info header.b=Yzwyyu+j; arc=none smtp.client-ip=188.68.63.162
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=leemhuis.info
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=leemhuis.info
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=leemhuis.info header.i=@leemhuis.info header.b="Yzwyyu+j"
Received: from mors-relay-8201.netcup.net (localhost [127.0.0.1])
	by mors-relay-8201.netcup.net (Postfix) with ESMTPS id 4hBKKQ1cdPz4Dlj;
	Fri, 31 Jul 2026 10:40:58 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=leemhuis.info;
	s=key2; t=1785487258;
	bh=k8yEr2LUG/IgwwWTcoQt6kA5eTc4ZZbyariA3qmajX0=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To:From;
	b=Yzwyyu+jKrzf84RmkOslQRFqXt3EQm0du1qL+l1ZhCz+DXey3wBf4AMxdD2aMcle2
	 mRnJmse/556k3Szubigh0BQHlJg608/ZzKhdes0p53DDvGZ7KWnO9x1JDIJGpxrJzW
	 YS0i2/sf+NqcYttUEr4uv6+EviK21jtaTW6iARH3l8mIIpZU8AEn9tKdZSIsNx8K9f
	 T1Q2JtVjWUtS9KjY4L6FgtWlhmjXlbejkkYysG1f28pNdZf4yDdSreLBk8tPhcZnON
	 dt9ItQwVS0/Bb/F2qA4D0PKwm7Hr7XywWhShXFjKe7mQO9WZaHoknqCLFKGJ08styJ
	 9Vssb3sPas+YA==
Received: from policy02-mors.netcup.net (unknown [46.38.225.35])
	by mors-relay-8201.netcup.net (Postfix) with ESMTPS id 4hBKKQ0vVLz4Dkd;
	Fri, 31 Jul 2026 10:40:58 +0200 (CEST)
Received: from mxe9fb.netcup.net (unknown [10.243.12.53])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by policy02-mors.netcup.net (Postfix) with ESMTPS id 4hBKKP3DRQz8sbD;
	Fri, 31 Jul 2026 10:40:57 +0200 (CEST)
Received: from [IPV6:2a02:8108:8984:1d00:a0cf:1912:4be:477f] (unknown [IPv6:2a02:8108:8984:1d00:a0cf:1912:4be:477f])
	by mxe9fb.netcup.net (Postfix) with ESMTPSA id 7B9CB5FBC4;
	Fri, 31 Jul 2026 10:40:52 +0200 (CEST)
Authentication-Results: mxe9fb;
        spf=pass (sender IP is 2a02:8108:8984:1d00:a0cf:1912:4be:477f) smtp.mailfrom=regressions@leemhuis.info smtp.helo=[IPV6:2a02:8108:8984:1d00:a0cf:1912:4be:477f]
Received-SPF: pass (mxe9fb: connection is authenticated)
Message-ID: <38643fbd-3031-49ea-92bf-0870bfe5353e@leemhuis.info>
Date: Fri, 31 Jul 2026 10:40:50 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [BUG] NFSv4.2: futimens() returns success without sending SETATTR
To: Matt Kinni <matt@cipixia.com>, Michael Yang <michaely4ng@proton.me>,
 "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: =?UTF-8?Q?Holger_Hoffst=C3=A4tte?= <holger@applied-asynchrony.com>,
 Linux kernel regressions list <regressions@lists.linux.dev>
References: 
 <nMlXgkbm-9ZP_fFN16OpzFd4kwNlyXq169-6CoOE4nuHyTsmGaFeJgzuhj3grRboJKg9RapKov2_FJ1E3BCL0oZ7UNzF0pgwwhVC6VOVJYQ=@proton.me>
 <fcffc38c-80fd-ca2f-1b1a-f9d041c6a2c7@applied-asynchrony.com>
 <rW3QLccRCVEh1K5wdSXYsXqoy7-0LhDI_yFdXIxHj9L8v9BfBdI1U3RM4eAqhktqrOiL25N_JPtUBygWz1v3yxT3OBnZxjSTtW9Pyk9Ngmk=@proton.me>
 <7ddc02d8-fa98-4d89-b2c7-0048fe9cfa10@cipixia.com>
From: Thorsten Leemhuis <regressions@leemhuis.info>
Content-Language: de-DE, en-US
In-Reply-To: <7ddc02d8-fa98-4d89-b2c7-0048fe9cfa10@cipixia.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
X-PPP-Message-ID: <178548725279.2637876.8974072583028928877@mxe9fb.netcup.net>
X-Rspamd-Server: rspamd-worker-8404
X-Rspamd-Queue-Id: 7B9CB5FBC4
X-NC-CID: iJtKiqlm8oBYkijMKgYa/Bt0jblBeDKTp98Qrr8s38iZ9hOQQ/Q=

On 7/31/26 07:40, Matt Kinni wrote:
> On 2026-07-24 at 21:07 (-0700), Michael Yang wrote:
>> I've found this report (https://bugzilla.proxmox.com/show_bug.cgi?
>> id=7621) where the problem manifested as early as 6.17.x and 7.0.x
>> (but is not present on the 6.12.88 LTS kernel), and is isolated to
>> NFSv4.2.
>>
>> I can confirm with client mount option vers=4.1, the timestamps update
>> successfully on the server.
> 
> I'm also seeing this same issue on Fedora 44 with kernel 7.0.8 and nfs-
> utils 2.8.7.
Did anyone bisect this (or try reverting the two commits that Holger
mentioned earlier)? Seems this is needed to get the attention of the
developers -- especially if it's really a VFS issue, as they won't see
the report on a nfs list.

Ciao, Thorsten
