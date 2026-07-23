Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 27F253E1692
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 07:14:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784790863; cv=none; b=rPpJaLYHkM/R2DWMnkVUpp8Xth4qolY+l5by5uL6lEGjcNWG+bPBvE0PTypDWpDuwkDtvKvEFZG7Ujmt9q4OLHWMjrdhkM4ElGG84FR0Q/SSBsPZHroCTtdtgdlmStWfDduOAwMUrguZUYSAPI3DnVuMdIeK/zzBbj8gnC2ij6w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784790863; c=relaxed/simple;
	bh=uxMJMwC5W4/tPb1yKBayEfTHhcz6pzpPP35gfAazED4=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=erYtvZDWziPFvVw4XlD9N2G+MBRr/2lN7ZX5yjgQmWdimq21klLWrhLDZNLj9sNLNpxkVq5JvqPeibsNSmaUidHpTL4WP8ZMMoF1+V8T6Rs0/PThCgvGiie4av1+LM+LdVSOfU5wgQMZ/PlCFECzUeZOhUI3BDE/RkDMvIBfXT4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de; spf=pass smtp.mailfrom=suse.de; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=M+NKBuBa; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=75kYK/pZ; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=mf5hPNJ3; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=6Rmye2gb; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="M+NKBuBa";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="75kYK/pZ";
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="mf5hPNJ3";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="6Rmye2gb"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id DB4507AF3C;
	Thu, 23 Jul 2026 07:14:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1784790858; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=v4JeYG1Hbl6I+NOuo0CyCcDFROPWmsqAeY31ibbeFsE=;
	b=M+NKBuBaj5l2wQX8rhTz0/aga3mkVl56eqvEheoDEb6VWc3IlM8dm4Y+O4gwFTDp9lLdaH
	93jHjo8afKgBLOCnAEewSfUqCGtuhe5PpMY9qAh0Y1x5+HJ9riWK+flLvicLQr7KtVZUUE
	VyCsYbqCoMi8160e0QekFfJt1QfO7sk=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1784790858;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=v4JeYG1Hbl6I+NOuo0CyCcDFROPWmsqAeY31ibbeFsE=;
	b=75kYK/pZcOJdX26TmWJNF94HsM2ELln84D+ZGecIh4TmYi0GzXmXm7vtE/F2WI5LTl8VMP
	uBDU48mC49yogLCA==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1784790857; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=v4JeYG1Hbl6I+NOuo0CyCcDFROPWmsqAeY31ibbeFsE=;
	b=mf5hPNJ326De7xczYn1pvEdWYJb/nATfwO7BlPSakPu0UntKXwLhIwk0wHSodw//Wca75o
	drEzxXlRkgOa6NRVTzwyFpHwqo/MaBXVdonm4vCuG4fpeVjN0IHW0Hky+9d8SWPTaI4CWv
	IypIxvVma9RmlQCczgqPVRojztNBG9w=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1784790857;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=v4JeYG1Hbl6I+NOuo0CyCcDFROPWmsqAeY31ibbeFsE=;
	b=6Rmye2gboc13WQ5hEWcVvn/lujzwuZFFXGAyAZBCKpdoiz7JVY5WtojmZmr5U8a1GC/VJ9
	Tmte8MauE2XIjyDw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 612F6779B5;
	Thu, 23 Jul 2026 07:14:17 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id tsb5FUm/YWpSOAAAD6G6ig
	(envelope-from <hare@suse.de>); Thu, 23 Jul 2026 07:14:17 +0000
Message-ID: <77756ade-5d55-4719-b9e6-7874bddd77c7@suse.de>
Date: Thu, 23 Jul 2026 09:14:17 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH net-next v2 2/6] net: Introduce read_sock_rectype
 proto_ops for control record delivery
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
 <20260720-tcp-read-sock-v2-2-29545d034f3c@kernel.org>
Content-Language: en-US
From: Hannes Reinecke <hare@suse.de>
In-Reply-To: <20260720-tcp-read-sock-v2-2-29545d034f3c@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Spamd-Result: default: False [-2.80 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	NEURAL_HAM_SHORT(-0.20)[-0.998];
	MIME_GOOD(-0.10)[text/plain];
	TAGGED_RCPT(0.00)[];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	MIME_TRACE(0.00)[0:+];
	RCPT_COUNT_TWELVE(0.00)[16];
	ARC_NA(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	FREEMAIL_TO(0.00)[kernel.org,redhat.com,gmail.com,queasysnail.net,brown.name,oracle.com,talpey.com];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	TO_DN_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	MID_RHS_MATCH_FROM(0.00)[];
	RCVD_TLS_ALL(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.de:mid,suse.de:email,oracle.com:email]
X-Spam-Flag: NO
X-Spam-Score: -2.80
X-Spam-Level: 

On 7/20/26 4:27 PM, Chuck Lever wrote:
> From: Chuck Lever <chuck.lever@oracle.com>
> 
> Kernel TCP consumers that use the read_sock interface
> (proto_ops.read_sock) cannot receive TLS control messages (Alerts,
> Handshake records) when kTLS is active. The current
> tls_sw_read_sock() method rejects non-data records with -EINVAL, and
> the sk_read_actor_t callback has no channel for delivering record-
> type metadata.
> 
> Four kernel subsystems are affected: NFSD (sunrpc svcsock), NFS
> client (sunrpc xprtsock), NVMe target (nvmet-tcp), and NVMe host
> (nvme-tcp). Each of these either falls back to the sock_recvmsg()
> API or lacks TLS alert handling entirely.
> 
> A new read_sock_rectype method in struct proto_ops provides a
> separate code path that delivers non-data TLS records to a callback,
> without changing the behavior seen by existing read_sock consumers.
> 
> The new sk_read_rectype_actor_t callback type extends the
> sk_read_actor_t signature with a rectype parameter carrying the
> protocol-layer record type (for example, TLS_RECORD_TYPE_ALERT). The
> record-type callback returns 0 to consume a record or a negative
> value to requeue it and stop delivery; unlike the data callback, its
> return value does not count bytes.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>   include/linux/net.h | 28 ++++++++++++++++++++++++++++
>   1 file changed, 28 insertions(+)
> 
> diff --git a/include/linux/net.h b/include/linux/net.h
> index 277188a40c72..7a19a743a617 100644
> --- a/include/linux/net.h
> +++ b/include/linux/net.h
> @@ -198,6 +198,13 @@ struct sk_buff;
>   struct proto_accept_arg;
>   typedef int (*sk_read_actor_t)(read_descriptor_t *, struct sk_buff *,
>   			       unsigned int, size_t);
> +/* rectype carries the transport record type, for example a
> + * TLS_RECORD_TYPE_* value.
> + */
> +typedef int (*sk_read_rectype_actor_t)(read_descriptor_t *,
> +				       struct sk_buff *,
> +				       unsigned int, size_t,
> +				       u8 rectype);
>   typedef int (*skb_read_actor_t)(struct sock *, struct sk_buff *);
>   
>   
> @@ -264,6 +271,27 @@ struct proto_ops {
>   	 */
>   	int		(*read_sock)(struct sock *sk, read_descriptor_t *desc,
>   				     sk_read_actor_t recv_actor);
> +	/*
> +	 * read_sock_rectype splits delivery across two callbacks:
> +	 * recv_actor for data records, per the sk_read_actor_t
> +	 * convention, and rectype_actor for all other records,
> +	 * with rectype identifying each. A NULL rectype_actor
> +	 * leaves non-data records pending. rectype_actor returns 0
> +	 * to consume a record or negative to leave it pending for
> +	 * redelivery and stop delivery; the negative return is a
> +	 * backpressure signal, not a fatal error. Both callbacks
> +	 * report errors and early stop the way recv_actor does:
> +	 * by setting desc->count to 0 and recording the reason in
> +	 * desc->error, per the read_descriptor_t convention and
> +	 * independent of the return value. The return value reports
> +	 * only data bytes consumed by recv_actor; the caller
> +	 * detects an error or early stop via desc->count and
> +	 * desc->error.
> +	 */
> +	int		(*read_sock_rectype)(struct sock *sk,
> +					     read_descriptor_t *desc,
> +					     sk_read_actor_t recv_actor,
> +					     sk_read_rectype_actor_t rectype_actor);
>   	/* This is different from read_sock(), it reads an entire skb at a time. */
>   	int		(*read_skb)(struct sock *sk, skb_read_actor_t recv_actor);
>   	int		(*sendmsg_locked)(struct sock *sk, struct msghdr *msg,
> 

Naming is a bit odd, but hey.

Reviewed-by: Hannes Reinecke <hare@kernel.org>

Cheers,

Hannes
-- 
Dr. Hannes Reinecke                  Kernel Storage Architect
hare@suse.de                                +49 911 74053 688
SUSE Software Solutions GmbH, Frankenstr. 146, 90461 Nürnberg
HRB 36809 (AG Nürnberg), GF: I. Totev, A. McDonald, W. Knoblich
