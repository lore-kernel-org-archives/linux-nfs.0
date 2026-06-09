Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 51F203A9D9D
	for <linux-nfs@vger.kernel.org>; Tue,  9 Jun 2026 06:45:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780987548; cv=none; b=iMk/GOiD80HNvnKN7kaRdaPk9UYeepwLW+ZNM8RdU2axan06e9rz25ZBxZ8nEtUW1skaQAEOiyGt26IXqTxB6o1zxLFpWlwi064l/FPqdURTyE+APmRrYufCkfNjfyNSbawH6QzEmc5i32Z/uqpPErktLIc6FC736XYdk6ING3E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780987548; c=relaxed/simple;
	bh=TZHij+sHzxWRaLcax1yKJ12Z6RCZ0MzJXnnSo4nJHzg=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=WBQFnWjCpLfmT/x8viovAXlrHiaVAUeRJwIvdSo4VS49CKxRDxV0TVz4UrUNIF3OfqLEaEUjmAAgm0XbHL6Zcuh8XrkuOU5ZakK7T6y6cP7oyeysoUmj2NtNpXGdUzk+jUPDyDf0PcSg4lbkf4FwyWQ8/WtwaWn80D9yDByWeX4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de; spf=pass smtp.mailfrom=suse.de; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=SKiLIrZq; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=ZRrSLdzZ; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=SKiLIrZq; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=ZRrSLdzZ; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="SKiLIrZq";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="ZRrSLdzZ";
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="SKiLIrZq";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="ZRrSLdzZ"
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id A09B97597E;
	Tue,  9 Jun 2026 06:45:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1780987545; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=pLICxNOop1LCTkqezsKIYOVdjWbIGVWX4I0nXjFhOOQ=;
	b=SKiLIrZqKZ7cl3NhV1T1ZFB1nf6K1bTDwcgMw5bP9zdDz4U3QHIGJwtyiymR9GaxTXOXcj
	bWpfICz3AgD9M1QwXjB8rkE8IAhzjpGT/JWtg3o8IKnukUQ2zLOTLXwzbb6gqN8B4TgA7I
	g6H6/DzgsZswKdIrDSOEBHH1xjmevbQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1780987545;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=pLICxNOop1LCTkqezsKIYOVdjWbIGVWX4I0nXjFhOOQ=;
	b=ZRrSLdzZBf+cg6ETdaqDWLO1Qt/DOwrFD/JCpocPaSIsiR0MdttvwkQa/ClzWUnuppgDQU
	v1ndNBoKv0lxsTAA==
Authentication-Results: smtp-out2.suse.de;
	dkim=pass header.d=suse.de header.s=susede2_rsa header.b=SKiLIrZq;
	dkim=pass header.d=suse.de header.s=susede2_ed25519 header.b=ZRrSLdzZ
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1780987545; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=pLICxNOop1LCTkqezsKIYOVdjWbIGVWX4I0nXjFhOOQ=;
	b=SKiLIrZqKZ7cl3NhV1T1ZFB1nf6K1bTDwcgMw5bP9zdDz4U3QHIGJwtyiymR9GaxTXOXcj
	bWpfICz3AgD9M1QwXjB8rkE8IAhzjpGT/JWtg3o8IKnukUQ2zLOTLXwzbb6gqN8B4TgA7I
	g6H6/DzgsZswKdIrDSOEBHH1xjmevbQ=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1780987545;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=pLICxNOop1LCTkqezsKIYOVdjWbIGVWX4I0nXjFhOOQ=;
	b=ZRrSLdzZBf+cg6ETdaqDWLO1Qt/DOwrFD/JCpocPaSIsiR0MdttvwkQa/ClzWUnuppgDQU
	v1ndNBoKv0lxsTAA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id A07A6779A7;
	Tue,  9 Jun 2026 06:45:44 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id BTS6JZi2J2rFcwAAD6G6ig
	(envelope-from <hare@suse.de>); Tue, 09 Jun 2026 06:45:44 +0000
Message-ID: <922040b0-f87e-484d-9f7b-78098024ad04@suse.de>
Date: Tue, 9 Jun 2026 08:45:44 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH 3/9] lib: Add a "tagset" data structure
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
 <20260605-tls-session-tags-v1-3-47bd1d94d552@oracle.com>
Content-Language: en-US
From: Hannes Reinecke <hare@suse.de>
In-Reply-To: <20260605-tls-session-tags-v1-3-47bd1d94d552@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Rspamd-Action: no action
X-Rspamd-Queue-Id: A09B97597E
X-Spam-Flag: NO
X-Spam-Score: -3.01
X-Spam-Level: 
X-Spamd-Result: default: False [-3.01 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	R_DKIM_ALLOW(-0.20)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	URIBL_BLOCKED(0.00)[oracle.com:email,suse.de:dkim,suse.de:email,suse.de:mid,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	FREEMAIL_TO(0.00)[kernel.org,gmail.com,davemloft.net,google.com,redhat.com,lwn.net,linuxfoundation.org,linux-foundation.org,queasysnail.net,kernel.dk,lst.de,grimberg.me,nvidia.com,brown.name,oracle.com,talpey.com];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	RCPT_COUNT_TWELVE(0.00)[29];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	RCVD_TLS_ALL(0.00)[];
	DKIM_TRACE(0.00)[suse.de:+];
	RCVD_COUNT_TWO(0.00)[2];
	DNSWL_BLOCKED(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	TO_DN_SOME(0.00)[];
	MID_RHS_MATCH_FROM(0.00)[];
	TAGGED_RCPT(0.00)[];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	R_RATELIMIT(0.00)[to_ip_from(RLhu34id7c3duw89qhx7eswje4)];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[oracle.com:email,imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.de:dkim,suse.de:email,suse.de:mid]
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org

On 6/5/26 19:34, Chuck Lever wrote:
> From: Chuck Lever <chuck.lever@oracle.com>
> 
> Access control mechanisms sometimes need to match metadata tags
> between a session and a resource. A tagset provides efficient
> membership testing and set intersection operations for this purpose.
> 
> The implementation uses a sorted array of string pointers. Unlike
> hash tables, sorted arrays support efficient intersection without
> needing to iterate one set and probe the other. Unlike rbtrees,
> they require no per-element node allocation, minimizing memory
> overhead for small sets typical of resource tagging.
> 
[ .. ]


Isn't this overcomplicating matters?
In the end, this a list of strings.
Wouldn't a simple rbtree holding the strings be sufficient?
(And quicker to lookup :-)

Also see my comment in the previous patch. I really would make
'tags' a nested attribute, and then parsing the 'tags' attribute
would be simple iteration over the tags.

(And don't name it tagset. That will be confusing the hell of out
of any storage folks, where a tagset is something completely
different.)

Cheers,

Hannes
-- 
Dr. Hannes Reinecke                  Kernel Storage Architect
hare@suse.de                                +49 911 74053 688
SUSE Software Solutions GmbH, Frankenstr. 146, 90461 Nürnberg
HRB 36809 (AG Nürnberg), GF: I. Totev, A. McDonald, W. Knoblich
