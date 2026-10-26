Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.37.145.25
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793000759;
	b=jAnU1MaLl0fcfD67Yc7vJpib6+83z24qZBCv53QP7izDWLgY74Luz3TGMAy7z1dm54JA
	 iReDv0/NJ7FFBwEnkBqWo88vEoM/uGZ5xwOzaWtk4naXobIt4G9b3x7jXFCSOrufaU51Q
	 X7pBq/V2wFJa4Bx0YwfkXlgfBHP0jbTmF30dKGYhpWsQ4ZJ0E0shGapf3/MdHLfaPItqL
	 ICZYbn3N1aABhntjbPZHR7Hksef1a+MT+u2a/cYmLu77cj3TP3eOe0C38pu+sc5yys083
	 9upEIG4kVM0Azay4Owakvkmh1I8NG98TYY4buleCAYuLiav2GcNWlUUD/aABaCgREjg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793000759;
	h=DMARC-Filter:Received:Message-ID:Date:MIME-Version:User-Agent:
	 Subject:To:Cc:References:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=fhYNs4xAZegSXJ//rS+5G8q1eKnnok6UpzM/4/hfWLs=;
	b=ZFwaV21oIw37G4E6D+a42vlMKBnwQK4thlwoNvEYcaPYR/luq7kOg5D54+qOCy8+27eS
	 4d2P9TA9W6AzV4P44PN6gTe/q7wxV3EuM7rLvBIsKZhYQY6taxM3hQi2IBDNdOtWq+3Ds
	 oXJUYBEvm7Wu/vrC55C4SHFEttCS8XVduXKgLams+S8JJZ6CyP53rfLXxla8S+PiuiQVm
	 R2NFAI+GDP4acZXtmX+30Kr9khPiQP6fgRCW1kRP6C9H4V0jl9WxHvPnt9R3CtoMzH6Io
	 XT1M8pHFvCvvKwVq9zB43u63fL294uQ3ZzhyRp5pwhSKftGSDPnyc3z97mbEA99HOSQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=iap-kborn.de;
	spf=pass smtp.mailfrom=iap-kborn.de;
	arc=none smtp.remote-ip=195.37.145.25
Received: from mailx.iap-kborn.de (mailx.iap-kborn.de [195.37.145.25])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3E03C606A31B;
	Mon, 26 Oct 2026 07:45:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3E03C606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=iap-kborn.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=iap-kborn.de
Received: from [195.37.145.130] (pcdueff.iap-kborn.de [195.37.145.130])
	by mailx.iap-kborn.de (Postfix) with ESMTPSA id 9D36F3BB5D2;
	Mon, 26 Oct 2026 08:45:54 +0100 (CET)
Message-ID: <9a8d698b-afd4-41a2-98f6-e062d33d71ff@iap-kborn.de>
Date: Mon, 26 Oct 2026 08:45:54 +0100
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [BUG] NFSv4.1 client hang in nfs4_drain_slot_tbl under concurrent
 workload against Windows NFS server
To: =?UTF-8?B?6YOt546y5YW0?= <guolingxing@supcon.com>,
 Rick Macklem <rick.macklem@gmail.com>
Cc: Lionel Cons <lionelcons1972@gmail.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org
References: <552f72d1.1c692.19e389e8ea4.Coremail.guolingxing@supcon.com>
From: Peter Schubert <schubert@iap-kborn.de>
In-Reply-To: <552f72d1.1c692.19e389e8ea4.Coremail.guolingxing@supcon.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit


Am 18.05.2026 um 03:06 schrieb 郭玲兴:
>   Hi Rick, hi Lionel
>
> ..
>
> Regarding the "soft" mount option: understood. We will retest
> with a hard mount as well.
>
> One question is whether the observed behavior is expected.
> Even if a soft mount contributes to the problem, is it expected
> that a single RPC timeout can leave the client in a state with
> no forward progress, blocked in nfs4_drain_slot_tbl, and with
> lease renewal no longer occurring? Or would that more likely
> indicate a client-side recovery bug?
>
>
> Thanks,
> Guo Lingxing
>
>
Hi,

We performed one additional recovery test before rebooting the affected 
client.
On Windows, the affected client still existed with |TotalSessions=0|, 
but no session or open files.
We explicitly ran |Revoke-NfsMountedClient|for that client ID. The 
client record disappeared completely on the server.
More than one 120-second NFSv4.1 lease period later, Windows still had 
no client/session for that host, while the Linux NFS state-manager 
remained blocked in |nfs4_drain_slot_tbl|and did not create a new session.
This suggests that once the client reaches this state, removing all 
server-side client/session state does not trigger recovery; the Linux 
client remains stuck waiting on its old local session state.

Regards,
Peter Schubert

