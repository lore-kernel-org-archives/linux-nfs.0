Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D53C733C182
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 07:19:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784791169; cv=none; b=RnXKh/yJk+KCeZx4cuXhjyDq+Py88pIbh58fAZnE/+lKo3TBHBpv0mTIShtXRwrAbgqb0/1gIgJ10/q4X7Mp0TlSEXxdx5CWC+lO+yE1a8N7+d53qdBEiezFPz/pO6G7CNSO4WeLAYZZVujlN8uTONNKWOCBObpoBRf1i4rpKmI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784791169; c=relaxed/simple;
	bh=FqG++2aqT+GsRBiRhO0Sak98kjYWuPyYH35Jm57J5YM=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=vF8wypmfLVDgpr62sfQf9cRaJwA9Qq6SRGx3F64j2N9JjlN2X379Hf3ySH5rlRnd4bHDp4+16z8R1ovruvufpbP9XVcwZ96rXoY4IlM7jLu2bikSB61qp39YX2N4KZM2M/fKPdSlD9trReMl/oymQIPr+uBw38uyZpuKwJEr/5w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de; spf=pass smtp.mailfrom=suse.de; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=2BUP4NqP; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=8bZbumMs; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=TuuX1SmJ; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=IjkjRG9U; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="2BUP4NqP";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="8bZbumMs";
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="TuuX1SmJ";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="IjkjRG9U"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id DD0633E4D;
	Thu, 23 Jul 2026 07:19:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1784791154; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=EODZ9+++oP4vf1fhSwHUyf2b+PlhxtgH2TJFwTfnvjI=;
	b=2BUP4NqPdEID0U7/wHQZ/9G2GxejcMewD4D28EctvBYJTSz61w3aoA0D00xeq+SUDWr9hg
	rBJvfThpPQyNT2PF0jb7fP36kVgE/mcNv6GzzWsDLLnF0mNrT7AeqMS/+5ta2HLc6mlL5J
	QMPOn+dqq/o7OKVO/Rq6RCk+yjebPwI=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1784791154;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=EODZ9+++oP4vf1fhSwHUyf2b+PlhxtgH2TJFwTfnvjI=;
	b=8bZbumMsjTGOxao8BvV5TFdialbq+zEFQSXpqgkQTy6aQ5rDCdaixlKPu53LA0TiVWxFL2
	fQ3l7N+1mXWnXWAA==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1784791152; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=EODZ9+++oP4vf1fhSwHUyf2b+PlhxtgH2TJFwTfnvjI=;
	b=TuuX1SmJtnPnP3r1hcmi2h28bAuN3OwmUuqW5ISRkUfW+nSIh5VLJG69URCk5WMCxSp7bx
	moMpGjXVljRaTv/RwKBDBf5nR0ccdEIgaG2GizxepJr8EIFzJSt0FodM7/2kHRL+K08xTD
	A8bL76VvpLf179MctXkROZQVMUZ+vOI=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1784791152;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=EODZ9+++oP4vf1fhSwHUyf2b+PlhxtgH2TJFwTfnvjI=;
	b=IjkjRG9UM5nfGdx5e/TBGacMq1GN8rqX4ryFr1kKNqcllAR3Whlsdty2vpyV+Re2Xm24Aj
	3oW5BOLSauGqGaBA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 6D8CB779B5;
	Thu, 23 Jul 2026 07:19:12 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id G0DWGHDAYWo7PQAAD6G6ig
	(envelope-from <hare@suse.de>); Thu, 23 Jul 2026 07:19:12 +0000
Message-ID: <9c88fc7e-5853-436f-881f-20074a3c9279@suse.de>
Date: Thu, 23 Jul 2026 09:19:12 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH net-next v2 0/6] Deliver TLS control records to kernel
 read_sock consumers
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
Content-Language: en-US
From: Hannes Reinecke <hare@suse.de>
In-Reply-To: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Spam-Score: -2.80
X-Spam-Level: 
X-Spam-Flag: NO
X-Spamd-Result: default: False [-2.80 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
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
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.de:email,suse.de:mid]

On 7/20/26 4:27 PM, Chuck Lever wrote:
> When kTLS is active, kernel consumers of the read_sock API cannot
> see TLS control records: tls_sw_read_sock() rejects Alerts and
> Handshake records with -EINVAL. A consumer that needs those records
> falls back to sock_recvmsg() with ancillary buffers, which is why
> NFSD's svcsock runs a MSG_CTRUNC recovery dance on every receive.
> 
> This series adds a read_sock_rectype proto_ops method that delivers
> non-data records through a separate callback, then converts its first
> consumer, NFSD's svcsock, to use it. NFS client (xprtsock), NVMe
> target, and NVMe host are meant to move onto the same mechanism in
> later series. The existing read_sock data path is unchanged.
> 
> The improvement is more than cosmetic. All of these consumers need
> to handle TLS Alert messages efficiently and securely (in particular,
> for KeyUpdate). A few design points worth mentioning:
> 
> - The new sk_read_rectype_actor_t callback does not share the data
>    actor's byte-counting contract. It returns 0 to consume a record or
>    a negative value to requeue it and stop delivery. The return is
>    never a byte count. svc_tcp_rectype_actor() relies on this,
>    returning 0 to consume every non-data record while stopping the
>    read loop through desc->count on a fatal alert.
> 
> - The no-data cap (patch 1) is a prerequisite, not a stand-alone fix.
>    Once control records reach read_sock, a record carrying no payload
>    stops advancing the caller's read descriptor, so a peer streaming
>    such records would pin the socket lock and the kernel receive
>    context for as long as the flood lasts. Bounding consecutive
>    no-data records supplies the return boundary a system call would
>    otherwise provide. The cap is scoped to tls_sw_read_sock() alone:
>    splice and recvmsg run in the caller's own context, reschedule, and
>    drop the lock on return, so they need nothing.
> 
> - The svcsock conversion is split so the new path can be reviewed
>    against the old. The old path is then removed by the last patch
>    in the series.
> 
> - read_sock_rectype has no direct userspace entry point, so its
>    selftest coverage (patch 4) drives the shared decryption and
>    rx_list delivery pipeline through the recvmsg and splice paths
>    instead.
> 
> ---
> Changes in v2:
> - Renamed the read_sock_cmsg proto_ops method to read_sock_rectype.
> - Non-data records now use a record-type actor, not RFC cmsg-style.
> - Bound no-data records so they can't pin the socket lock (new patch 1).
> - Added selftests for data/control record interleaving (new patch 4).
> - Link to v1: https://lore.kernel.org/r/20260217222033.1929211-1-cel@kernel.org
> 
> ---
> Chuck Lever (6):
>        net/tls: Bound consecutive no-data records in tls_sw_read_sock()
>        net: Introduce read_sock_rectype proto_ops for control record delivery
>        tls: Implement read_sock_rectype for kTLS software path
>        selftests/tls: Add tests for data/control record interleaving
>        SUNRPC: Use read_sock_rectype for svcsock TCP receives
>        SUNRPC: Remove sock_recvmsg path from svcsock TCP receives
> 
>   include/linux/net.h               |  28 +++
>   net/sunrpc/svcsock.c              | 381 +++++++++++++++++---------------------
>   net/tls/tls.h                     |   3 +
>   net/tls/tls_main.c                |   5 +
>   net/tls/tls_sw.c                  |  54 +++++-
>   tools/testing/selftests/net/tls.c | 298 ++++++++++++++++++++++++++++-
>   6 files changed, 556 insertions(+), 213 deletions(-)
> ---
> base-commit: 298bb2b8903323f6ef2eab4819a2e477765f0ff1
> change-id: 20260327-tcp-read-sock-778a49660ff7
> 
> Best regards,
> --
> Chuck Lever <cel@kernel.org>
> 
> 

Good stuff. I was tempted to say 'We need it', but meanwhile we found
during spec review that the REPLACETLSPSK mechanism as defined in the
spec is at odds with the TLS KeyUpdate.
So while we (from the NVMe side) might be wanting to use it eventually,
we first have to figure out how to interact sanely between the NVMe
and TLS layer.

And I don't feel qualified to judge on NFS/SunRPC details, so didn't
dare to do a review here.

Cheers,

Hannes
-- 
Dr. Hannes Reinecke                  Kernel Storage Architect
hare@suse.de                                +49 911 74053 688
SUSE Software Solutions GmbH, Frankenstr. 146, 90461 Nürnberg
HRB 36809 (AG Nürnberg), GF: I. Totev, A. McDonald, W. Knoblich
