Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 05C66371CEE
	for <linux-nfs@vger.kernel.org>; Wed, 10 Jun 2026 06:28:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781072907; cv=none; b=lhv86xmAaOME+6hM8vcNgV9hoN7Yqb5fZca1X1eMhqgY4wxyef4KD+a1hh+FLGkGji9KlNxlj5/OD0eLglL1bPfy28Tqqu71w+H9eA14i2kVUKlx/AZmrjArp4n/UHVvrYvSdN4m+e0R1hATBtBNbpkOvv/jhaKsasBweN86mTg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781072907; c=relaxed/simple;
	bh=DyTeYd9vnRDq8G0JZHC8wrAMUnfSahzSGTPtCFrWgkA=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=L9glwglnQVTwluB47ldQmLgI3c1QbY0LvvWeERR7LagwRjbhgfupFT+TTZXKpELnSZzd8WsCaMtzbnVi87r7rYoF71oXpRvONNnHBzvK9EvlTItar/6XlTutUZ8+OF4DWfRnstBn/lcB6xkY0R6STD77Nu6ZAx6xmXZirPCocgw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de; spf=pass smtp.mailfrom=suse.de; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=1eZ8uAO1; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=FvImT5ig; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=1eZ8uAO1; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=FvImT5ig; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="1eZ8uAO1";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="FvImT5ig";
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="1eZ8uAO1";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="FvImT5ig"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 21A8175CAD;
	Wed, 10 Jun 2026 06:28:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1781072904; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=aKq54TbrhGR2RKbLwCmDopNOKQM89rNy60MxYSxRYSA=;
	b=1eZ8uAO1kHm49tmPC2q3ED8xJp6MTDoBYt3oiFtF0oq5WNgnWiF1P/FKgUSJ6a9oo/G+51
	fg6/mFVSq8bIdzLPD9WhpdjEJZjVHG2SFIDaKdpkp4K/aPyM4p8oz+hZdUi2UEYBhr1SQb
	SusT2Qk82FNHUVs/l644QPNTZqagX8o=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1781072904;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=aKq54TbrhGR2RKbLwCmDopNOKQM89rNy60MxYSxRYSA=;
	b=FvImT5igKlFgdnlITdLU9XlJzw0zRtVBqFn4Tf16atqsboP7hMxBBPdvO+NkqI9z6v+gk5
	OAf7cU7/g6UporCg==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1781072904; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=aKq54TbrhGR2RKbLwCmDopNOKQM89rNy60MxYSxRYSA=;
	b=1eZ8uAO1kHm49tmPC2q3ED8xJp6MTDoBYt3oiFtF0oq5WNgnWiF1P/FKgUSJ6a9oo/G+51
	fg6/mFVSq8bIdzLPD9WhpdjEJZjVHG2SFIDaKdpkp4K/aPyM4p8oz+hZdUi2UEYBhr1SQb
	SusT2Qk82FNHUVs/l644QPNTZqagX8o=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1781072904;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=aKq54TbrhGR2RKbLwCmDopNOKQM89rNy60MxYSxRYSA=;
	b=FvImT5igKlFgdnlITdLU9XlJzw0zRtVBqFn4Tf16atqsboP7hMxBBPdvO+NkqI9z6v+gk5
	OAf7cU7/g6UporCg==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 48848779A7;
	Wed, 10 Jun 2026 06:28:23 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id TSJhDwcEKWp+CQAAD6G6ig
	(envelope-from <hare@suse.de>); Wed, 10 Jun 2026 06:28:23 +0000
Message-ID: <f967eb48-9e54-497a-b5dc-ade6fa6c49d3@suse.de>
Date: Wed, 10 Jun 2026 08:28:22 +0200
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
 <40199ef9-416e-4a58-908a-ed514dfd6ff2@suse.de>
 <7b5276ff-cceb-446c-97ec-65ad80689495@app.fastmail.com>
Content-Language: en-US
From: Hannes Reinecke <hare@suse.de>
In-Reply-To: <7b5276ff-cceb-446c-97ec-65ad80689495@app.fastmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Spam-Flag: NO
X-Spam-Score: -2.80
X-Spamd-Result: default: False [-2.80 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	NEURAL_HAM_SHORT(-0.20)[-0.999];
	MIME_GOOD(-0.10)[text/plain];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	FREEMAIL_TO(0.00)[kernel.org,gmail.com,davemloft.net,google.com,redhat.com,lwn.net,linuxfoundation.org,linux-foundation.org,queasysnail.net,kernel.dk,lst.de,grimberg.me,nvidia.com,brown.name,oracle.com,talpey.com];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[29];
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
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.de:email,suse.de:mid]
X-Spam-Level: 

On 6/9/26 16:29, Chuck Lever wrote:
> 
> On Tue, Jun 9, 2026, at 2:41 AM, Hannes Reinecke wrote:
>> On 6/5/26 19:34, Chuck Lever wrote:
>>> We'd like tlshd to tag certificates according to admin-defined
>>> characteristics. The tag list is to be returned on a successful
>>> handshake. Upper Layer Protocols (such as NFS) can then authorize
>>> access based on the set of tags returned to the kernel.
>>>
>>> For example, suppose NFSD wants to restrict access to an export to
>>> only clients that present certificates whose issuer DN contains
>>> "O=Oracle". tlshd can parse incoming certificates, and add an
>>> "oraclegroup" tag to handshakes where a client presents a
>>> certificate with "O=Oracle" somewhere in its Issuer field. NFSD can
>>> then be configured to look for that tag and permit access only when
>>> it is present. NFSD needs no knowledge of x.509 certificates.
>>>
>>> This patch plumbs in the netlink protocol elements for tlshd to
>>> return a list of tags to the kernel when a TLS or QUIC handshake
>>> succeeds. Subsequent patches add tag extraction and storage in
>>> the handshake layer.
> 
>> Not sure if I agree with this; to my untrained eye the 'tag' attribute
>> is just a string, and someone else will have to parse that. But we
>> are at the netlink level here, so we _can_ have nested tags.
>> Wouldn't it be better to make 'tags' a nested tag (ie a list of tags)
>> such that we can avoid parsing in the caller/consumer?
> 
> Had some time to digest your comment a little more...
> 
> The tag attribute is declared "multi-attr: true", so it is already a
> list rather than a single delimited string. tlshd emits one
> HANDSHAKE_A_DONE_TAG attribute per tag, and the kernel receives each
> tag as a separate netlink attribute. There is no string to split in
> the consumer; the parsing you are worried about does not happen.
> 
> This matches remote-auth directly above it, which is likewise a
> multi-attr scalar list in the same DONE message.
> 
> A nested attribute earns its keep when each list element is a
> structured record with several sub-fields to group. A tag is a single
> string, so nesting would add a container attribute, a second
> attribute-set, and a nested policy without making anything on the
> consumer side simpler. If a tag later needs to carry structured
> metadata, nesting becomes the right tool, but that is not in scope for
> this series.
> 
Ah. So one can have several 'tag' attributes in one 'done' downcall?
That's perfect.

So you can add my:

Reviewed-by: Hannes Reinecke <hare@kernel.org>

Cheers,

Hannes
-- 
Dr. Hannes Reinecke                  Kernel Storage Architect
hare@suse.de                                +49 911 74053 688
SUSE Software Solutions GmbH, Frankenstr. 146, 90461 Nürnberg
HRB 36809 (AG Nürnberg), GF: I. Totev, A. McDonald, W. Knoblich
