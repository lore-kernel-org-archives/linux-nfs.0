Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8CF883E0749
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 07:11:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784790671; cv=none; b=b1w0+fWr2Gw0LHyVraaUHphgI+x1jffN0bn0AVrJTMUvrpK++t/zVwYX6nDn2Hn23CIijyLGW/1fRWNJ10h+tWogGliYm6ScVUH3IlXuIOMRVBfbN/jLnQVx0I4ZqjjpBghQr7ILkkJpEYr0hFRFIUvJKax0g1SOwPXKS56F/A0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784790671; c=relaxed/simple;
	bh=f5E+dOCwOx0RiauSvRPBcwecN0mdygZg/0b/OtDAPbA=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=r+uPnROj53goj0Zt72osMk6G+vbDmjbKV8nhfXM3pxpiaU5+C4Ofg/HV/Nrofcv1+6XrlcnDbOMu20cC9MNnawMJ8OlhiP8MPRCe+y/bQa6TIuKLKESLxSdFilelGeKksW12yVxWP59ZRn8NdEN9sqSmHMfTTZqZ7gVl262aueg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de; spf=pass smtp.mailfrom=suse.de; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=sCokvfMl; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=7SOGszTb; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=o8Xx31TZ; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=5gaaDsS0; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="sCokvfMl";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="7SOGszTb";
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="o8Xx31TZ";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="5gaaDsS0"
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id ED5A27AF3C;
	Thu, 23 Jul 2026 07:11:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1784790664; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=1vBic9fzEbY2RTI7IGcScLgVaEbp4PemRL1Z+QTakxg=;
	b=sCokvfMlX+WQJ6keLjyUIfMCNrjfPbMG7rTgGqI/ELcFfJYHObSIFuzAj7nXjI2gJqOuFx
	Wa5BSpXM4+mZcP/ovoHiKpa3uGLzbSq7eXJZvXLzDBWYNe3qUAG3JgWMdu6br0BZs4GefF
	ajLmEi4jYLOuEgH4sxsj9bm2END+FQ4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1784790664;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=1vBic9fzEbY2RTI7IGcScLgVaEbp4PemRL1Z+QTakxg=;
	b=7SOGszTbEYgUFQsGbNcRqjicPaQiWqUSvbDR9eMo56ff9Tjjt5/ywRKWdQVHpcAS504knP
	cMEFsBSSIoDz9WBw==
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.de header.s=susede2_rsa header.b=o8Xx31TZ;
	dkim=pass header.d=suse.de header.s=susede2_ed25519 header.b=5gaaDsS0
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1784790663; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=1vBic9fzEbY2RTI7IGcScLgVaEbp4PemRL1Z+QTakxg=;
	b=o8Xx31TZpG8BN1ny4W81YiZ/Np0P4oe/1uUH+Qb+1hiGS9FWctH/xJXB9wfkWMhzlIhipU
	xO3sQanvpCwEMELZtOax2KtQIBfGPGt/0e4aXq7AWSRnf7oGVsbnWPSbVvJUBBVs9D1ULW
	s5siCmsKxlqzSEg/7pOMxMjPqefVN54=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1784790663;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=1vBic9fzEbY2RTI7IGcScLgVaEbp4PemRL1Z+QTakxg=;
	b=5gaaDsS027UoxFokIWZ1OXzL1HnvsifktYUFOoYXX2w6QrivZ/Q8128qXtIJXvhyB5rNl1
	1f1eU2aIu/O0NoAA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 8B3CA779B5;
	Thu, 23 Jul 2026 07:11:03 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id tREJIIe+YWpiNQAAD6G6ig
	(envelope-from <hare@suse.de>); Thu, 23 Jul 2026 07:11:03 +0000
Message-ID: <b9d60674-1ba7-4f23-beee-4ddfffd4dda9@suse.de>
Date: Thu, 23 Jul 2026 09:11:03 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH net-next v2 1/6] net/tls: Bound consecutive no-data
 records in tls_sw_read_sock()
To: Chuck Lever <cel@kernel.org>, Jakub Kicinski <kuba@kernel.org>,
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>,
 John Fastabend <john.fastabend@gmail.com>,
 Sabrina Dubroca <sd@queasysnail.net>, Shuah Khan <shuah@kernel.org>,
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>,
 Tom Talpey <tom@talpey.com>
Cc: netdev@vger.kernel.org, kernel-tls-handshake@lists.linux.dev,
 linux-kselftest@vger.kernel.org, linux-nfs@vger.kernel.org
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
 <20260720-tcp-read-sock-v2-1-29545d034f3c@kernel.org>
Content-Language: en-US
From: Hannes Reinecke <hare@suse.de>
In-Reply-To: <20260720-tcp-read-sock-v2-1-29545d034f3c@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Spamd-Result: default: False [-3.01 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	R_DKIM_ALLOW(-0.20)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	FREEMAIL_TO(0.00)[kernel.org,redhat.com,gmail.com,queasysnail.net,brown.name,oracle.com,talpey.com];
	ARC_NA(0.00)[];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	RCPT_COUNT_TWELVE(0.00)[16];
	MIME_TRACE(0.00)[0:+];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	RCVD_TLS_ALL(0.00)[];
	DKIM_TRACE(0.00)[suse.de:+];
	RCVD_COUNT_TWO(0.00)[2];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	TO_DN_SOME(0.00)[];
	DNSWL_BLOCKED(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	TAGGED_RCPT(0.00)[];
	MID_RHS_MATCH_FROM(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.de:email,suse.de:mid,suse.de:dkim]
X-Spam-Flag: NO
X-Spam-Score: -3.01
X-Spam-Level: 
X-Rspamd-Queue-Id: ED5A27AF3C
X-Rspamd-Server: rspamd2.dmz-prg2.suse.org
X-Rspamd-Action: no action

On 7/20/26 4:27 PM, Chuck Lever wrote:
> A record that delivers no payload -- an empty TLS 1.3 data record
> today, a control record once read_sock_rectype() lands -- leaves
> tls_sw_read_sock() in its loop without advancing the caller's read
> descriptor. A peer that streams such records keeps the receive loop
> running, and the socket lock held, for as long as the records
> arrive.
> 
> Cap the number of consecutive no-data records consumed per call. The
> count resets on any record that delivers bytes, so a normal stream
> is unaffected; a peer supplying only empty records is bounded to
> TLS_RX_NODATA_LIMIT iterations before the call returns 0. read_sock
> consumers treat that as "no progress, re-poll" rather than EOF, so
> the connection stays up and makes progress once real data arrives.
> 
> Only tls_sw_read_sock() needs this cap. Its consumers drive the receive
> loop from kernel context -- a work item or service thread holding the
> socket lock across the whole call with no return to userspace -- so an
> unbounded empty-record stream keeps that context and the lock pinned
> for as long as the flood lasts. The cap supplies the return boundary
> that a system call would otherwise provide. tls_sw_splice_read()
> and tls_sw_recvmsg() already have one: they run in the calling task's
> context, reschedule while draining the socket backlog (cond_resched()
> in __release_sock()), and drop the socket lock when the call returns. A
> flood there costs the caller only its own scheduler time, so the cap
> would add nothing.
> 
> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
>   net/tls/tls_sw.c | 13 +++++++++++++
>   1 file changed, 13 insertions(+)
> 
This is technically a fix, so it might be worthwhile sending it
on its own.

Otherwise:

Reviewed-by: Hannes Reinecke <hare@kernel.org>

Cheers,

Hannes
-- 
Dr. Hannes Reinecke                  Kernel Storage Architect
hare@suse.de                                +49 911 74053 688
SUSE Software Solutions GmbH, Frankenstr. 146, 90461 Nürnberg
HRB 36809 (AG Nürnberg), GF: I. Totev, A. McDonald, W. Knoblich
