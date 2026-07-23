Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 37EB13DEAF2
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 07:14:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784790892; cv=none; b=UDgwOGGziO3IP++53yEFs9dhiAXzprzyJhOJGZTw8euS8UxWz0lxRcDkVL9aOsLXXtuesh4cZMv8jJp8oM4tPApsHEVeozb1B0MdKSQ2g+gtCbO3Uep9huo77RuomantF6ts8SpKdcyfyxNTjr3QKqmJwI56TbJW2tl/VJCkAsU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784790892; c=relaxed/simple;
	bh=t4I7dYPungufxr6o83XMm3iYpYFcGW1l+lz3kZoSxfM=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=lWE7MOhjuqz1v09M46Rvk0cpGMBphp9R60Mj02crhYhXuPkkJ/Vd0vtObz3i055yicVAPMbULEcfQJ2GAjaVQU7dmXnzthfcNdxRX91DQc1OkPieC4w+Gdt6hfrVBrIF6tQy3qNj1TcdTQF77V3I+UDhK/EL0QtDGw9se/oWYUk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de; spf=pass smtp.mailfrom=suse.de; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=EiLElavO; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=ZMbARPrD; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=EiLElavO; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=ZMbARPrD; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="EiLElavO";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="ZMbARPrD";
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="EiLElavO";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="ZMbARPrD"
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id AA6B23E4C;
	Thu, 23 Jul 2026 07:14:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1784790887; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Af0gSRg8u34XhddRbsZaot6XHDGEy5XbiB7n4KmuiEo=;
	b=EiLElavO9c590fRwMgEb8HOVbkEednyhsB3V42S1EO+m16+21eUp49jIDRtYG6ZPsoI0A8
	v/1PoLTCKYgyiJfmambU9pUX3zG3KeTIeiZB3griKTmy2+HF94xjXsBTykKGT7T1Pjz0X9
	ExdleK7tjP1NjOOv4Pj/C45xG9JuRW0=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1784790887;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Af0gSRg8u34XhddRbsZaot6XHDGEy5XbiB7n4KmuiEo=;
	b=ZMbARPrD1qdvf+NWZRQHXjKYwJL2VUOM8uckaGj8i/3HJrSy2DIUmzD09PiuUUkT6LOPLO
	ioAAlsHufH7msfCQ==
Authentication-Results: smtp-out2.suse.de;
	dkim=pass header.d=suse.de header.s=susede2_rsa header.b=EiLElavO;
	dkim=pass header.d=suse.de header.s=susede2_ed25519 header.b=ZMbARPrD
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1784790887; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Af0gSRg8u34XhddRbsZaot6XHDGEy5XbiB7n4KmuiEo=;
	b=EiLElavO9c590fRwMgEb8HOVbkEednyhsB3V42S1EO+m16+21eUp49jIDRtYG6ZPsoI0A8
	v/1PoLTCKYgyiJfmambU9pUX3zG3KeTIeiZB3griKTmy2+HF94xjXsBTykKGT7T1Pjz0X9
	ExdleK7tjP1NjOOv4Pj/C45xG9JuRW0=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1784790887;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Af0gSRg8u34XhddRbsZaot6XHDGEy5XbiB7n4KmuiEo=;
	b=ZMbARPrD1qdvf+NWZRQHXjKYwJL2VUOM8uckaGj8i/3HJrSy2DIUmzD09PiuUUkT6LOPLO
	ioAAlsHufH7msfCQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 51D7C779B5;
	Thu, 23 Jul 2026 07:14:47 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id 6sjPEme/YWr4OAAAD6G6ig
	(envelope-from <hare@suse.de>); Thu, 23 Jul 2026 07:14:47 +0000
Message-ID: <4038dcf8-bab8-48d1-864d-8dc7c978dcc6@suse.de>
Date: Thu, 23 Jul 2026 09:14:46 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH net-next v2 3/6] tls: Implement read_sock_rectype for kTLS
 software path
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
 <20260720-tcp-read-sock-v2-3-29545d034f3c@kernel.org>
Content-Language: en-US
From: Hannes Reinecke <hare@suse.de>
In-Reply-To: <20260720-tcp-read-sock-v2-3-29545d034f3c@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Spam-Score: -3.01
X-Spam-Level: 
X-Rspamd-Action: no action
X-Rspamd-Queue-Id: AA6B23E4C
X-Spamd-Result: default: False [-3.01 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	SUSPICIOUS_RECIPS(1.50)[];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	R_DKIM_ALLOW(-0.20)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	MIME_TRACE(0.00)[0:+];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	FREEMAIL_TO(0.00)[kernel.org,redhat.com,gmail.com,queasysnail.net,brown.name,oracle.com,talpey.com];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[16];
	ARC_NA(0.00)[];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	RCVD_TLS_ALL(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	TO_DN_SOME(0.00)[];
	DNSWL_BLOCKED(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	TAGGED_RCPT(0.00)[];
	MID_RHS_MATCH_FROM(0.00)[];
	DKIM_TRACE(0.00)[suse.de:+];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.de:mid,suse.de:email,suse.de:dkim,oracle.com:email,imap1.dmz-prg2.suse.org:helo,imap1.dmz-prg2.suse.org:rdns]
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Spam-Flag: NO

On 7/20/26 4:27 PM, Chuck Lever wrote:
> From: Chuck Lever <chuck.lever@oracle.com>
> 
> tls_sw_read_sock() rejects non-data records (alerts, handshake
> messages) with -EINVAL. Kernel consumers that need TLS alert
> delivery, such as NFSD, NFS client, and NVMe target, must fall back
> to the sock_recvmsg() API to receive control messages via CMSG.
> 
> Implement the new read_sock_rectype() method for these consumers,
> delivering non-data records to a callback through the kTLS software
> receive path.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>   net/tls/tls.h      |  3 +++
>   net/tls/tls_main.c |  5 +++++
>   net/tls/tls_sw.c   | 41 ++++++++++++++++++++++++++++++++++++-----
>   3 files changed, 44 insertions(+), 5 deletions(-)
> 
Reviewed-by: Hannes Reinecke <hare@kernel.org>

Cheers,

Hannes
-- 
Dr. Hannes Reinecke                  Kernel Storage Architect
hare@suse.de                                +49 911 74053 688
SUSE Software Solutions GmbH, Frankenstr. 146, 90461 Nürnberg
HRB 36809 (AG Nürnberg), GF: I. Totev, A. McDonald, W. Knoblich
