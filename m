Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8D103372EDD
	for <linux-nfs@vger.kernel.org>; Wed, 10 Jun 2026 07:06:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781075214; cv=none; b=r+zwQCSqUF5IVReOZTA8JHQBPUKUjkvi9WWZU8VqLVTdwQHFzButxZmpBLtjc4B4Yb+4CB+2WqrK31SLx4kG/fT7fOQL6TUB5+SJ/mdcqst80kUZSUXvq3qFUYhU2rZ3KlRUv6Fia6V+HBWf8Dce81uvJEF6For+nN5sZuLqun4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781075214; c=relaxed/simple;
	bh=uwEoaXiN/XXygk3f43wDiGsyQIn9DxeM52TsPBk93n0=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=EMjv4HEs431jFUvmb8Yiz8XrRIbcNEW8fl2dcNl7fsN8P6Qnq1trQgpKDmyCl1WPAMT/ifoaaOQnxLoe0QZAgLEIDprOR/anJofr/ZmGkO1sJ7B2AmhuQ+sAkT0eHaJCpmD95kaZ3r0vefU7NcCng89HzSCG2WG+gM6rG4SO7ns=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de; spf=pass smtp.mailfrom=suse.de; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=vZoXLgsL; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=vNI9vXR/; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=vZoXLgsL; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=vNI9vXR/; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="vZoXLgsL";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="vNI9vXR/";
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="vZoXLgsL";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="vNI9vXR/"
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id B550D75CA8;
	Wed, 10 Jun 2026 07:06:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1781075211; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=I1gAeOLgTuEAAzcY5bQb3xMUyBqJE6jmw0ao7FkdqP8=;
	b=vZoXLgsLK4JO+rXIi83jANeHzQ1nk6ZkXFQTTnc1Nn24iSwELqTySg7dIUWyHB5DJz49px
	2c5X9QP/7achVuMUZ7eAcU5IoKt5PKJbx7Jski0vm+l/G31eCu1aviXddmqSAgr8/l0Taw
	dffP1fHPyTZTarKZ68uw4ja23h1Kaj4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1781075211;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=I1gAeOLgTuEAAzcY5bQb3xMUyBqJE6jmw0ao7FkdqP8=;
	b=vNI9vXR/WONDlg1KHtdE1YuXYMq4I1NH8lfuV1jwMzRgCiSEakWJ2s4vt6TglmRHhr7yA/
	4Kwqp5rpv1zsRvBA==
Authentication-Results: smtp-out2.suse.de;
	dkim=pass header.d=suse.de header.s=susede2_rsa header.b=vZoXLgsL;
	dkim=pass header.d=suse.de header.s=susede2_ed25519 header.b="vNI9vXR/"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1781075211; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=I1gAeOLgTuEAAzcY5bQb3xMUyBqJE6jmw0ao7FkdqP8=;
	b=vZoXLgsLK4JO+rXIi83jANeHzQ1nk6ZkXFQTTnc1Nn24iSwELqTySg7dIUWyHB5DJz49px
	2c5X9QP/7achVuMUZ7eAcU5IoKt5PKJbx7Jski0vm+l/G31eCu1aviXddmqSAgr8/l0Taw
	dffP1fHPyTZTarKZ68uw4ja23h1Kaj4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1781075211;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=I1gAeOLgTuEAAzcY5bQb3xMUyBqJE6jmw0ao7FkdqP8=;
	b=vNI9vXR/WONDlg1KHtdE1YuXYMq4I1NH8lfuV1jwMzRgCiSEakWJ2s4vt6TglmRHhr7yA/
	4Kwqp5rpv1zsRvBA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 03A1E779A7;
	Wed, 10 Jun 2026 07:06:50 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id GD8JOwoNKWr+LgAAD6G6ig
	(envelope-from <hare@suse.de>); Wed, 10 Jun 2026 07:06:50 +0000
Message-ID: <d14fff89-3c7b-40ea-9380-e8c37499916e@suse.de>
Date: Wed, 10 Jun 2026 09:06:50 +0200
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
 <922040b0-f87e-484d-9f7b-78098024ad04@suse.de>
 <2dc23995-3ff9-4714-ac6c-d70255b15687@app.fastmail.com>
Content-Language: en-US
From: Hannes Reinecke <hare@suse.de>
In-Reply-To: <2dc23995-3ff9-4714-ac6c-d70255b15687@app.fastmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Spam-Flag: NO
X-Rspamd-Action: no action
X-Spam-Level: 
X-Spamd-Result: default: False [-3.01 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	R_DKIM_ALLOW(-0.20)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-0.999];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	RCPT_COUNT_TWELVE(0.00)[29];
	FREEMAIL_TO(0.00)[kernel.org,gmail.com,davemloft.net,google.com,redhat.com,lwn.net,linuxfoundation.org,linux-foundation.org,queasysnail.net,kernel.dk,lst.de,grimberg.me,nvidia.com,brown.name,oracle.com,talpey.com];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	RCVD_TLS_ALL(0.00)[];
	DKIM_TRACE(0.00)[suse.de:+];
	RCVD_COUNT_TWO(0.00)[2];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	TO_DN_SOME(0.00)[];
	MID_RHS_MATCH_FROM(0.00)[];
	TAGGED_RCPT(0.00)[];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	R_RATELIMIT(0.00)[to_ip_from(RLhu34id7c3duw89qhx7eswje4)];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.de:email,suse.de:dkim,suse.de:mid,imap1.dmz-prg2.suse.org:helo,imap1.dmz-prg2.suse.org:rdns]
X-Rspamd-Server: rspamd2.dmz-prg2.suse.org
X-Rspamd-Queue-Id: B550D75CA8
X-Spam-Score: -3.01

On 6/9/26 15:35, Chuck Lever wrote:
> 
> On Tue, Jun 9, 2026, at 2:45 AM, Hannes Reinecke wrote:
>> On 6/5/26 19:34, Chuck Lever wrote:
>>> From: Chuck Lever <chuck.lever@oracle.com>
>>>
>>> Access control mechanisms sometimes need to match metadata tags
>>> between a session and a resource. A tagset provides efficient
>>> membership testing and set intersection operations for this purpose.
>>>
>>> The implementation uses a sorted array of string pointers. Unlike
>>> hash tables, sorted arrays support efficient intersection without
>>> needing to iterate one set and probe the other. Unlike rbtrees,
>>> they require no per-element node allocation, minimizing memory
>>> overhead for small sets typical of resource tagging.
>>>
>> [ .. ]
>>
>>
>> Isn't this overcomplicating matters?
>> In the end, this a list of strings.
>> Wouldn't a simple rbtree holding the strings be sufficient?
>> (And quicker to lookup :-)
> 
> This isn't overcomplicating matters.
> 
> Consider that a TLS session might have several, even dozens of
> tags. An NFSD export might also have a dozen or more tags.
> 
> We need a mechanism that will compute the intersection of those
> two sets efficiently -- that is not a simple lookup. Keeping a
> set of tags in a list or in an r-b tree would require MxN look
> up operations to compute that intersection.
> 
It sure would. But we're dealing with a comparative small number
of entries (later patches cap it to 64), so runtime really is of
no concern.

But let me see if I can come up with an alternative implementation
using rb trees.

> 
>> Also see my comment in the previous patch. I really would make
>> 'tags' a nested attribute, and then parsing the 'tags' attribute
>> would be simple iteration over the tags.
> 
> I leave it to Jakub to decide the best approach for passing tags
> via the netlink protocol.
> 
> 
Sure.

>> (And don't name it tagset. That will be confusing the hell of out
>> of any storage folks, where a tagset is something completely
>> different.)
> 
> Since the primary operation on this container is "intersection",
> set makes the most sense. Stringset?
> 
> 
Better.

Cheers,

Hannes
-- 
Dr. Hannes Reinecke                  Kernel Storage Architect
hare@suse.de                                +49 911 74053 688
SUSE Software Solutions GmbH, Frankenstr. 146, 90461 Nürnberg
HRB 36809 (AG Nürnberg), GF: I. Totev, A. McDonald, W. Knoblich
