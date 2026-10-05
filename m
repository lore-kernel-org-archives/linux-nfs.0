Received: from mail-oo2-f34.google.com (mail-oo2-f34.google.com [74.125.231.162])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D77704AD7FA
	for <linux-nfs@vger.kernel.org>; Mon,  5 Oct 2026 14:46:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.162
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791211584; cv=none; b=YFANdy8tgtIHwSC2GXCgBKaQwxmHF0J9O6JpALnmxMU/LlXn8ZXqnUvZoL0kx3WYxSZ0s4Si3bxZq5+cU21R4hFUM6solOco8QeFLdeIdd7jT9ezsxloXzKuFtMPZddXahCPH5LUQ6+Y6zK2ivAbF1bAkDqpXrlwpSkc2ueeU38=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791211584; c=relaxed/simple;
	bh=lF33JnixRKMey5JuCw9/mIZXf+5lJwF0od6N5XzGdmM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=QvaAi0inXHSue3uOd0REVZSEmn0wALglCmNkoZ6cAuNgdb89ekmVBjof8Sp/zCy3XrIB1RPE17m5JZ1xA6DbiwO46mszbDlqkO6lLXjpsJX7DllgC7mgGf+AivvuEjI9qVbvde+NWDtavg/pKNXeAvu+YlYglU15jT2Ip57Xzo4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=Q6fQPa8m; arc=none smtp.client-ip=74.125.231.162
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Q6fQPa8m"
Received: by mail-oo2-f34.google.com with SMTP id 006d021491bc7-6de64084488so1199756eaf.3
        for <linux-nfs@vger.kernel.org>; Mon, 05 Oct 2026 07:46:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791211572; x=1791816372; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=iIoosdZwxbYNvEuerx6DTloF3skGmZicydSyWBc0wyI=;
        b=Q6fQPa8mpHR/4ipu5G7nDqJo79+xYvw5POHd4f2wsMlqKo74p8fnMKTqadG0Z0Vhg0
         JIqUkiAdpp1bsEg+03+ng0/O4HvbxdZPoH+Yd2i+Val4pMtZ4KphGfO4hd2u57dFfAPZ
         kYQPvg5aZQNC693WzZol3FSoeOQwXCsl8X444kHjFlijD2rL8HWU9gJe3amVaK4PxKkd
         EGg2udKsvlkp96x7qbvp1pHEhBn73v3wkg2qqM8TERIXvaUIeZc/46s/lb7Gb46Cj0Rd
         JtCzk+n+13cA2LeFR6atrEJOpZ8K2HKxaIfITcWevvoD5O98LwZD3S2ZY3IvPn3OEh7t
         1CyA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791211572; x=1791816372;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=iIoosdZwxbYNvEuerx6DTloF3skGmZicydSyWBc0wyI=;
        b=SbXJPn0NLcvyJF+yptqKQxTFCT4x8G4Lkyfi52Wpq6l5tT+uLjdMCdNHFE3V0Mhm2B
         cWRn55S0UvX20jwlJAtoNsXDS677RkUNAKk8rzPylWAPs+JoFCGx/wrjfhvTgQlbWmSI
         psHUE7IMKu0UOsNTjJNjQQStnw+BQsy6m0AVfuN4zfdFjag2JGhFs5sy7Z9WOFgJ/l8f
         Z+VLKsaEksWrKozvJYrmKrWIT4qWBBjp/Pfgi0lq8EjNPzmompiCz/sj7+Wjm4CPo3ER
         r6W9f1UkVEt2xM4MDUolYXlr6kW3z9X1k5JCfMDOuxYH02b9tRpiriAxMnfzPRRAnjsP
         zJJg==
X-Forwarded-Encrypted: i=1; AKwUvBy6W1VPu/Zc+bYQTVraUGsTNlGev/ezrPbZ39rvLbB8xin3kX3ISeRxVigOSm9tBtrOjmrVoTFYLGo=@vger.kernel.org
X-Gm-Message-State: AFuF++leLF7zpWMEX23shDsOKPgmZd35kuO8rVPfMPsQRuM9wXc9vBTV
	j3FnCHertQWW+bW9a/QdarF+cbP+TggCLilgI6O4El5TuTAayiWdJjBQyhlXvNG5yZA=
X-Gm-Gg: AYBFou05IdB8dV67eLMDr9m525wgiuam/+odJAmLYWZR4CAXqgTWiClEbbAt9TpQbik
	JdMaSY0cgfbBLSVnGvLw4/psaAjahHlZXnFeLjuKywbxo8DX1gp+QnIifQ0XOKOuRDFGWAwE2H8
	W3PQ8qfxTE083ObLywx1R2SOzQwut3jF1IiGeN78cEyOR3JSRDUAuHCVdUkWHmjpck1vcQgm+O9
	qd91JCY8kSU5KpwrmuAsn1oJDhygRSdXlOaYPVKO4M2JPrsl4HVsixQLTqkhW7d8awrwn4/1ob/
	4h51+A6HjMDm1f21SDPx5yG5D7iz0RanrnvdPt9QQKwVhz7wHKz5VjoGoggmZBs+biOGoO7+A+p
	tT2pjvnqN86tntJl31/vnTkuBl8U9Izc50xgZt1+4q2x9gPSQnu7b+p/7x0AU1lXe7JVBNzbpQj
	G9QMNC/hiqwKHxHzrfS+gXSfVgaC8TXaIq0oCr35jbV6LFC8E6Hh8w3t8yyJ5MR1wARBrcdgyxF
	lAwaFclzRv0BQ5gYw==
X-Received: by 2002:a05:6820:61b:b0:6df:428f:f181 with SMTP id 006d021491bc7-6df42901d9dmr9562658eaf.69.1791211571486;
        Mon, 05 Oct 2026 07:46:11 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-6df3a9b0f1bsm10276452eaf.7.2026.10.05.07.46.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 05 Oct 2026 07:46:10 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Chuck Lever <cel@kernel.org>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 linux-nfs@vger.kernel.org, Daire Byrne <daire@dneg.com>
Subject: Re: [PATCH RFC 0/2] SUNRPC: dispatch ready transports round-robin
 across clients
Date: Mon, 05 Oct 2026 10:46:08 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <05C0FB93-B5F1-41C7-9559-C4E6554CE8A7@hammerspace.com>
In-Reply-To: <cb5d00b3-008f-4876-b284-c8cbabfea3ad@slotpi15m67>
References: <cover.1790953694.git.bcodding@hammerspace.com>
 <cb5d00b3-008f-4876-b284-c8cbabfea3ad@slotpi15m67>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 4 Oct 2026, at 16:48, Chuck Lever wrote:
> I read through your patches and did not find a problem with the
> SVC_CP_QUEUED handshake or with the client's lifetime. My concern
> is with what the pool takes turns across, and with a few of the
> results.

Hey Chuck - thanks for going through it.  I'll take the results first and
come back to what it takes turns across, because I want to change
direction there.

> The "alone" column worries me more than the loaded ones. With no
> aggressor, the walk takes 36% longer on B and fio loses about 10%.
> ...
> That result and the "alone" column disagree. Can you repeat both on a
> kernel without KASAN, with enough runs to show the variance? If the
> unloaded slowdown is real, we need to know where it comes from.

Those are one run each, which I should have said.  It works out to about
20us per RPC in both the walk and the fio run.  That's a lot more than I
can explain with one more dequeue and a few atomics, so either it's noise
or there's something in there I don't understand yet.  I'll run them
properly without KASAN and find out which.

> Any server with more than one NUMA node gets the diluted result by
> default. I would like to see numbers for a two-node per node
> configuration, and your thoughts on whether the client queue belongs
> to the pool at all.

I'll get the two-node numbers.  I don't have a good answer for the second
part.  Getting it exactly fair across pools means a thread on one node
serving a transport that landed on the other, and I thought that's what
the pools are there to avoid.

> XPT_BUSY might account for part of that. Once a thread dequeues
> the client's only transport, the client is off sp_clients until
> svc_xprt_received() enqueues that transport again. The 8-connection
> client goes back on the tail immediately. A thread that comes free
> in that window takes the other client.

It accounts for nearly all of it.  I was wrong about the load generator.

I still had the trace, so I went back and looked at where the 8-connection
client's dequeues land.  The single connection was dispatched 1275 times
in 3 seconds and every one of those read a full RPC, so it always had a
request waiting.  The thread that took it had it back on the queue a
median 4us later (p90 79us).  Of the other client's 2656 dequeues, 1329
landed inside that window.  While the single connection was actually
queued, the other client got exactly one dequeue ahead of it 92.5% of the
time.  And the dequeues come in clumps, 69% of them within 50us of the one
before.

So the round-robin alternates like it should, and the single connection
loses a turn whenever threads come free faster than it can get back on the
queue.  I'll jitter the service time and see how much of it is left.

> A round is as long as the number of ready clients. With k transports
> queued ahead of it and M clients ready, the close waits about k * M
> dispatches.
> ...
> the connections NFSD most wants to close promptly. Let's dispatch
> XPT_CONN, XPT_CLOSE, and XPT_HANDSHAKE ahead of XPT_DATA within a
> client.

Yep, I compared rounds to transports.  Will do.

> Yes, please. A tracepoint at dequeue that reports the client is
> enough for now.

Ok.

> It is fair by address. That covers more than six movers:
> ...
> Meanwhile a NAT or a re-export gateway with hundreds of users behind
> it gets one turn. A client with many users is held to one turn and a
> client with many addresses is not. The multi-homed client case is
> not something we can easily ignore.

I agree with all of that.  My own mover is one of your examples, it's
NFSv3 and the hosts it runs on have more than one address.  I can bring
back moving the transport and key v4.1 on the clientid, but that does
nothing for v3, and a clientid is cheaper to come by than an address.

You said back in June that the scope of the identity is never going to
cover all the use cases, and I think three rounds of this have shown it.
You wanted a latency floor with no identity at all.  Neil wants it per
client.  Daire wants his workstations ahead of his render farm, and his
re-export servers are your gateway example.  I want all of my movers to
count as one.  I don't think there's an identity the kernel can pick
that's right for all of us, and every time I pick one I change behavior
for people who are happy with what they have today.

So here's what I'd like to try.  Keep the mechanism from this series, but
with nothing configured every transport stays on the anonymous client,
which dispatches in today's order (apart from the control events going
first).  That's the control run from the cover letter: with every load
group on one source address B gives A's numbers back.

Then let the admin say which peers share a turn.  A small table of address
prefixes, matched when the connection is accepted, where each entry either
names a class or says every address under it is its own client.  What I
posted becomes one line of that.  A multi-homed host is a list of its
addresses.  A v4.1 key could come later as another kind of match, and so
could a weight or a limit per class, which is what I think Daire actually
needs.

I know all three of you said no tunables in June.  I'd put this closer to
exports than to a tunable: it tells the server who is who.  Neil floated
an export flag for marking clients on the first thread.  I'd do it through
the nfsd netlink interface so it's per-net and not a module parameter.

It does raise the bar on the cost question.  If nothing is configured then
everyone pays for the two-level queue and gets nothing for it, so the
answer on your "alone" numbers has to be zero, not small.

Would you take something like that?  I'd rather ask before I build it.

Ben
