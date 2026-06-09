Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C2C2DCA4E
	for <linux-nfs@vger.kernel.org>; Tue,  9 Jun 2026 06:33:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780986838; cv=none; b=PE/MnA93hY6VYJPqKbOPz9SjLqWERb1xb/P7mDGwvKMTHpwO6Ew+JZmAG6BLvq/1ijdsvX8yR5HkAxiegEVTdZgRDz/Vvddiwr7QpkRJRKD+CMhROumdMy0hZNRAncwVC6qBdkqvgphD8j95l6rlBypXz1ZDm0Q/KPn+PICjCdc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780986838; c=relaxed/simple;
	bh=NcfAmqX1/Os0ct/tHp8ao3ztXfVLp7vHO87xAKg7398=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=Wd1LrAgle6Y4YupbCUwgBcWi6TowIEtxfZXuUUe1berqcrEdexMsfgHA2gRAebx6eyFVXJlOrbhiARHR4cFYdi0QjVkhl/XP/G8TyZcLhBhzpDumW8Di/Mr8T9xLSIBWkrghNzj0+bP8FJNdnZwcck9UHy72/nfaHzG6HHvcIag=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de; spf=pass smtp.mailfrom=suse.de; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=lKukEZ87; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=QHhtorVo; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=hFGuxsAa; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=VJ07OCIE; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="lKukEZ87";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="QHhtorVo";
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="hFGuxsAa";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="VJ07OCIE"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id CCBAB7592E;
	Tue,  9 Jun 2026 06:33:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1780986834; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=PKE/uJBVyB0X5nsgiFUDFtCb4ApOZevyMfjAVJep4rg=;
	b=lKukEZ87WWZmMipW14oKd7IhQm4fBnD5z5ctJNtn8hFmJmZjtoiZfCUUBot+0jUeYdPKLk
	/CWBlr8/7e7Oh2nmgY6kZgG5HXegnSx0f5/Unc2MZg+WPz4bs9wzBGCWvzArgnSWWIaOPX
	4TudyXUP9Uk/E/4mx7t5xUqqiIxgUS4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1780986834;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=PKE/uJBVyB0X5nsgiFUDFtCb4ApOZevyMfjAVJep4rg=;
	b=QHhtorVoQUFH+xxQ7+SaTamZTisHr8Hb2pX4X2O6JHW6DYb2H064FXyYQqWAugqJchSgb0
	nd+Dij86ZrIpw5Cg==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1780986832; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=PKE/uJBVyB0X5nsgiFUDFtCb4ApOZevyMfjAVJep4rg=;
	b=hFGuxsAa0fiKdlWgGQ64jSSnHiO2GYSYcjGAMZ5FbJLZZRNRXrLXqR0+G3OcbLVBUMAllm
	cy3ziTM8tQ7TcXN8HaAANFk3YoESL6V6CkTrSRMC8YNde7lfr0KZAVXV0uQ0GVCtTHDCDR
	B5HLrKg9IcnmR1GZr1z/RgCwr6WF8tY=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1780986832;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=PKE/uJBVyB0X5nsgiFUDFtCb4ApOZevyMfjAVJep4rg=;
	b=VJ07OCIEqFLFTnFasawkxz8V90kT9RgZK+wrs1Z0AAzC/7ndDZ3CtsRQ+HrCUJwJxAiMA5
	O1uVKxBeq1UG8NDQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 94C62779A7;
	Tue,  9 Jun 2026 06:33:51 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id yxStIs+zJ2qBaAAAD6G6ig
	(envelope-from <hare@suse.de>); Tue, 09 Jun 2026 06:33:51 +0000
Message-ID: <e578fbb5-2184-4052-a9db-b363ae758e3c@suse.de>
Date: Tue, 9 Jun 2026 08:33:51 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 1/9] handshake: Require admin permission for DONE command
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
 <20260605-tls-session-tags-v1-1-47bd1d94d552@oracle.com>
Content-Language: en-US
From: Hannes Reinecke <hare@suse.de>
In-Reply-To: <20260605-tls-session-tags-v1-1-47bd1d94d552@oracle.com>
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
	RCPT_COUNT_TWELVE(0.00)[29];
	TO_DN_SOME(0.00)[];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	MIME_TRACE(0.00)[0:+];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	TAGGED_RCPT(0.00)[];
	ARC_NA(0.00)[];
	FREEMAIL_TO(0.00)[kernel.org,gmail.com,davemloft.net,google.com,redhat.com,lwn.net,linuxfoundation.org,linux-foundation.org,queasysnail.net,kernel.dk,lst.de,grimberg.me,nvidia.com,brown.name,oracle.com,talpey.com];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	R_RATELIMIT(0.00)[to_ip_from(RLh3g55kcpku8oef9ktzra4k57)];
	RCVD_TLS_ALL(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	MID_RHS_MATCH_FROM(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	URIBL_BLOCKED(0.00)[oracle.com:email,imap1.dmz-prg2.suse.org:helo,suse.de:email,suse.de:mid];
	RCVD_COUNT_TWO(0.00)[2];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.de:email,suse.de:mid,imap1.dmz-prg2.suse.org:helo,oracle.com:email]
X-Spam-Level: 

On 6/5/26 19:34, Chuck Lever wrote:
> From: Chuck Lever <chuck.lever@oracle.com>
> 
> ACCEPT and DONE are the two downcalls of the handshake genl
> family, both intended for use by the trusted handshake agent
> (tlshd). ACCEPT already requires GENL_ADMIN_PERM; DONE has
> no privilege check at all.
> 
> The fd-lookup in handshake_nl_done_doit() only confirms that
> some pending handshake request exists for the supplied sockfd;
> it does not authenticate the sender. An unprivileged process
> that guesses or observes a valid sockfd can therefore submit
> a DONE with HANDSHAKE_A_DONE_STATUS == 0, leaving the kernel
> consumer to proceed as if the handshake succeeded. A non-zero
> status on a forged DONE tears down a legitimate in-flight
> handshake before tlshd can report its real result.
> 
> A subsequent patch teaches the DONE handler to carry session
> tags consumed for access control. That work makes closing the
> existing gap a prerequisite, but the gap itself predates tags.
> 
> Fixes: 3b3009ea8abb ("net/handshake: Create a NETLINK service for handling handshake requests")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>   Documentation/netlink/specs/handshake.yaml | 1 +
>   net/handshake/genl.c                       | 2 +-
>   2 files changed, 2 insertions(+), 1 deletion(-)
> 
Reviewed-by: Hannes Reinecke <hare@kernel.org>

Cheers,

Hannes
-- 
Dr. Hannes Reinecke                  Kernel Storage Architect
hare@suse.de                                +49 911 74053 688
SUSE Software Solutions GmbH, Frankenstr. 146, 90461 Nürnberg
HRB 36809 (AG Nürnberg), GF: I. Totev, A. McDonald, W. Knoblich
