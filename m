Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4DEAA3D75DC
	for <linux-nfs@vger.kernel.org>; Tue,  9 Jun 2026 06:41:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780987268; cv=none; b=DmmJ/ERWelSl71ZvT61uYlZb0NE9+AiAqjA1PSOoWDGFjQk8zN2LPf3D0lgIaPVvPf7xGkdJqari/8doo6/c746A2QouB7oEIgpeBTKvFoeEfY6NzbvXb9w8bKOh0VZfbMnaHpOiyWL+dJMbTJSU2vuSDwlYmHNh9Hmyg3EO1Kc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780987268; c=relaxed/simple;
	bh=1i6O7smi8pGqu1NkRTlp9NFuy+eH84BhR9S9/Of+6b0=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=DqPfKhRO59lHaoH8B79UOMiP7y9UVStrdCGFFZmibUfmq2IpjQSaBkHB40poQrGsM6rinNIcxHpcMpnEilHHSz9jYOf0JQrkkH167/+8oQHEIvm6J0rNbSegnozLozu84nSaytRRcioQiGihEkp6BjDUR0DMq2NW76jp9Aun+Qo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de; spf=pass smtp.mailfrom=suse.de; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=uO+CVRNC; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=69E88WFq; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=tSSm9SWF; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=ykD56Yw/; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="uO+CVRNC";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="69E88WFq";
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="tSSm9SWF";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="ykD56Yw/"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 4148375A1E;
	Tue,  9 Jun 2026 06:41:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1780987263; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=cO0TS6ZXRdzfE2WsluHxfQNoDvWGY14VYEsWciA7wwQ=;
	b=uO+CVRNCVQNPJGpGo84zxPmocmTGbnUhLoV8MliKlsH5YGkBncbjbLtHmHzhuiUlBaE39k
	6rsIaaAb24XnvKmTz6o9XzykF8goFUncuhmQpARCvUBO9MVrYdjbFLqOxoExqdsxfrPDDv
	enrS7D3C6um5GeOY4wldYZWstn26Gt0=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1780987263;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=cO0TS6ZXRdzfE2WsluHxfQNoDvWGY14VYEsWciA7wwQ=;
	b=69E88WFqJZAWV1eGCkfLrbih0oqp1SWf7BqiFsJtOw7J250qXVOYQxQ3aaGk7B0xOWQ4R3
	PXvjETXgf1pLGrBA==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1780987262; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=cO0TS6ZXRdzfE2WsluHxfQNoDvWGY14VYEsWciA7wwQ=;
	b=tSSm9SWFlcl2Oz2TziMuAy9qLSMcs8sSmKLFGOflXo/jRrD6zFo9rQaUjYAirvWHuw4Rg0
	37jC5Cor11PKXjm7lqVtYkCxAWFa7mqkzjlCtfnMkQ+X71UoC04Mj2yhCpL4vSPG1CtbvP
	70nR/doZeKmuA2T2PAOZJjNvT/5GEwY=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1780987262;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=cO0TS6ZXRdzfE2WsluHxfQNoDvWGY14VYEsWciA7wwQ=;
	b=ykD56Yw/RLLYbvoR3fovvfzZeSZOKIYyDCd6BMcQ4FOCCQt9KQlPhvrM0OxtxU0Uvirzmw
	o2rybcBNgv+BYsBQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 64393779A7;
	Tue,  9 Jun 2026 06:41:01 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id fDHdFn21J2oAbwAAD6G6ig
	(envelope-from <hare@suse.de>); Tue, 09 Jun 2026 06:41:01 +0000
Message-ID: <40199ef9-416e-4a58-908a-ed514dfd6ff2@suse.de>
Date: Tue, 9 Jun 2026 08:41:00 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 2/9] handshake: Add tags to "done" downcall
To: Chuck Lever <cel@kernel.org>, Donald Hunter <donald.hunter@gmail.com>,
 Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 Eric Dumazet <edumazet@google.com>, Paolo Abeni <pabeni@redhat.com>,
 Simon Horman <horms@kernel.org>, Jonathan Corbet <corbet@lwn.net>,
 Shuah Khan <skhan@linuxfoundation.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 John Fastabend <john.fastabend@gmail.com>,
 Sabrina Dubroca <sd@queasysnail.net>, Keith Busch <kbusch@kernel.org>,
 Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>,
 Sagi Grimberg <sagi@grimberg.me>, Chaitanya Kulkarni <kch@nvidia.com>,
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>,
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>,
 Anna Schumaker <anna@kernel.org>
Cc: kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org,
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org,
 Chuck Lever <chuck.lever@oracle.com>
References: <20260605-tls-session-tags-v1-0-47bd1d94d552@oracle.com>
 <20260605-tls-session-tags-v1-2-47bd1d94d552@oracle.com>
Content-Language: en-US
From: Hannes Reinecke <hare@suse.de>
In-Reply-To: <20260605-tls-session-tags-v1-2-47bd1d94d552@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Spam-Flag: NO
X-Spam-Score: -2.80
X-Spamd-Result: default: False [-2.80 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	URIBL_BLOCKED(0.00)[suse.de:email,suse.de:mid,oracle.com:email,imap1.dmz-prg2.suse.org:helo];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	ARC_NA(0.00)[];
	FREEMAIL_TO(0.00)[kernel.org,gmail.com,davemloft.net,google.com,redhat.com,lwn.net,linuxfoundation.org,linux-foundation.org,queasysnail.net,kernel.dk,lst.de,grimberg.me,nvidia.com,brown.name,oracle.com,talpey.com];
	RCPT_COUNT_TWELVE(0.00)[29];
	MIME_TRACE(0.00)[0:+];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	RCVD_TLS_ALL(0.00)[];
	R_RATELIMIT(0.00)[to_ip_from(RLh3g55kcpku8oef9ktzra4k57)];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	TO_DN_SOME(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	TAGGED_RCPT(0.00)[];
	MID_RHS_MATCH_FROM(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,oracle.com:email,suse.de:email,suse.de:mid]
X-Spam-Level: 

On 6/5/26 19:34, Chuck Lever wrote:
> From: Chuck Lever <chuck.lever@oracle.com>
> 
> We'd like tlshd to tag certificates according to admin-defined
> characteristics. The tag list is to be returned on a successful
> handshake. Upper Layer Protocols (such as NFS) can then authorize
> access based on the set of tags returned to the kernel.
> 
> For example, suppose NFSD wants to restrict access to an export to
> only clients that present certificates whose issuer DN contains
> "O=Oracle". tlshd can parse incoming certificates, and add an
> "oraclegroup" tag to handshakes where a client presents a
> certificate with "O=Oracle" somewhere in its Issuer field. NFSD can
> then be configured to look for that tag and permit access only when
> it is present. NFSD needs no knowledge of x.509 certificates.
> 
> This patch plumbs in the netlink protocol elements for tlshd to
> return a list of tags to the kernel when a TLS or QUIC handshake
> succeeds. Subsequent patches add tag extraction and storage in
> the handshake layer.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>   Documentation/netlink/specs/handshake.yaml | 11 +++++++++++
>   include/uapi/linux/handshake.h             |  3 +++
>   net/handshake/genl.c                       |  5 +++--
>   3 files changed, 17 insertions(+), 2 deletions(-)
> 
Not sure if I agree with this; to my untrained eye the 'tag' attribute 
is just a string, and someone else will have to parse that. But we
are at the netlink level here, so we _can_ have nested tags.
Wouldn't it be better to make 'tags' a nested tag (ie a list of tags)
such that we can avoid parsing in the caller/consumer?

Cheers,

Hannes
-- 
Dr. Hannes Reinecke                  Kernel Storage Architect
hare@suse.de                                +49 911 74053 688
SUSE Software Solutions GmbH, Frankenstr. 146, 90461 Nürnberg
HRB 36809 (AG Nürnberg), GF: I. Totev, A. McDonald, W. Knoblich
