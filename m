Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=195.37.145.25
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792655425;
	b=QU1tCXWVVxmpZhXV4RtL5ffDzKmgTMZKpJJR9FGfqjX46RuxpF1YZBxmeR9VzZWc3q/8
	 nHsj39/Ntag7+NoDffOFPrAopuBIDSkaG46cueevgOXCJH002NTzE/pC+6jA5NVXMmvxC
	 4hcC9OiysTyFzsL68pUriSyA1ubietQFjAqQv8xoROIZj5D+K+9nlxZzYLGiQ5gIp7hU+
	 aLdZU/8SgEyb3C71icbmw/3vubPad4lNnbQvr/v7UU+e5GJn+jqmRJR3zzfahmiVm4ozC
	 +JB9Z+eb+6bvT1EyUNJK/pN2BAoUcpr+MuXLiXcwyRsvgJM1nWUugxEQun7aXKR/NBA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792655425;
	h=DMARC-Filter:Received:Message-ID:Date:MIME-Version:User-Agent:
	 Subject:To:Cc:References:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding;
	bh=QV+zN2xUewUmdQImdTxG7PLvSY4gZjRJOD9j8lRSP+Q=;
	b=2XPqzool8/QHCkEZ0g86P4zmN29rumAxFfcMwBIsubv9hf+YLMMhxKmvN3XGjhdX7CNc
	 stL6dQ5v7+oEpLoiioi8MNp+JmpJ07QbygX7fjdLmXwH6RrzmEu6z8cp1htvLuoEKsl1i
	 N6nbJwa+RJ5TNlOkyrNuGAc22I2O4a1KSqXGQHEBqT87PpPW79mocpY5Z3lKH7tED2NO9
	 t3KQeqWFfqvywvJ67+8YL4p9vvNcGBNMfgIBi10eIHzjmcsuVwxBT+tyr10z/RMQRa+s0
	 HemceRX3zyql3C48aVgLwIwxQSIyKvzvuy7Myfecg5QZwTSqzaK4h4jKRNxAX9BtSvg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=iap-kborn.de;
	spf=pass smtp.mailfrom=iap-kborn.de;
	arc=none smtp.remote-ip=195.37.145.25
Received: from mailx.iap-kborn.de (mailx.iap-kborn.de [195.37.145.25])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2CCF4606A31B;
	Thu, 22 Oct 2026 07:50:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2CCF4606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=iap-kborn.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=iap-kborn.de
Received: from [195.37.145.130] (pcdueff.iap-kborn.de [195.37.145.130])
	by mailx.iap-kborn.de (Postfix) with ESMTPSA id 1483E3B90E3;
	Thu, 22 Oct 2026 09:50:15 +0200 (CEST)
Message-ID: <4ca06c28-d4f1-4876-a9e7-16488c18a380@iap-kborn.de>
Date: Thu, 22 Oct 2026 09:50:15 +0200
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
> ...
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

we have independently observed what appears to be the same NFSv4.1 
client hang against Microsoft Server for NFS, but with several important 
differences from the May 2026 report:

- the mounts are HARD, not soft
- sec=krb5 (RPCSEC_GSS), not AUTH_SYS
- observed on Linux 5.15 and Linux 6.8 clients
- Windows Server for NFS is from the Windows Server 2019 / build 17763 
family
- the trigger is strongly correlated with a Windows/NFS server restart, 
especially two rapid consecutive restarts during Windows servicing

Mount options:
   vers=4.1,rw,hard,timeo=1200,retrans=5,sec=krb5,proto=tcp

We currently have two affected clients preserved in the hung state.

Client A (Linux 5.15):
   nfsv4 SEQUENCE ... q:xprt_pending
   two nfsv4 GETATTR tasks ... q:ForeChannel Slot table

All of these use the same TCP transport to the Windows NFS server.

Client B (Linux 6.8):
   nfsv4 SEQUENCE ... q:xprt_pending

The NFS state-manager thread is blocked in:
   nfs4_drain_slot_tbl
   nfs4_reset_session
   nfs4_state_manager
   nfs4_run_state_manager

`lease_expired` continuously increases on the affected clients.

A 135-second tcpdump on Client B showed only TCP ACK packets between client
and server and no NFS RPC payload. The same SEQUENCE XID remained blocked on
q:xprt_pending before and after the capture.

Windows-side state at the same time:
- healthy Linux clients: TotalSessions=1 and an NFS session exists
- affected clients: the client record may still exist, but TotalSessions=0;
   Get-NfsSession and Get-NfsOpenFile return no objects
- one affected client is no longer listed by Get-NfsMountedClient at all,
   while the Linux client still waits on the stale local NFSv4.1 state

Historical correlation:
We have more than two independent incidents where the Windows NFS 
service/server was
restarted twice in rapid succession. In both cases one Linux client 
entered a
persistent abnormal NFS client state immediately afterwards. In the current
incident multiple Linux clients are affected while other clients recovered
normally.

This seems to indicate a client-side recovery deadlock: the server is 
back and
TCP is healthy, but the Linux client no longer sends useful NFS traffic 
because
a SEQUENCE/session slot never drains, and the state manager can wait 
indefinitely
in nfs4_drain_slot_tbl.

Questions:
1. Is there a known path where an outstanding NFSv4.1 SEQUENCE RPC can 
remain on
    xprt_pending while session recovery waits for the corresponding slot 
to drain?
2. Should nfs4_drain_slot_tbl be able to wait indefinitely in this 
situation?
3. When the server has lost the old session and is reachable again, 
should the
    client force teardown/recreation of the local session rather than 
waiting for
    the old slot forever?
4. Is there an existing patch or additional tracepoint/debug data that 
would be
    useful while we still have affected clients preserved in the hung state?

The May 2026 report appears closely related:
https://www.spinics.net/lists/kernel/msg6188959.html

We can provide the full SUNRPC debugfs output, mountstats, state-manager 
stacks,
Windows NFS session output, tcpdump, and timestamps of both server restart
incidents.

Regards,
Peter Schubert
