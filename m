Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B20883F7A9F;
	Mon, 21 Sep 2026 08:45:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789980361; cv=none; b=cjOT7MdsL7tC2eBG5ekgt0d499q3apwh4TjfU9SHDzzBSWNhqBJp2O9gPWMRibkXFWfRu4FqX7z4L8l4M3w/zlLr6/+6vRDQxO2zOZWqQzCxmTGCDmAOyXl52EUqUSDez4BsZl0e0YLIGqYGLK9sZ/PFwdoaykoCh2PtcD1DUjg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789980361; c=relaxed/simple;
	bh=q/GA7RIUKoUpc7ll85w4cXb03Aiy9VtPdrVtny7NFdA=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=mcIxxEbebs3n2JgKEoc02C2rIsmT53/d7yOFsOt+e0P1moPEbYpyQbfiYxgW7EZLt5ViizBrzeY+PLOXbrUpUqziAtYs2KoKc8AXsQvG/jQPkdcpNCxEyUKjz2GKwAoYT2zoInwSoInkR1VPc5UlYQ+HhSJcLTPq3P8wUeShlN0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de; spf=pass smtp.mailfrom=suse.de; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=jD4VX/Rj; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=nd6EU74b; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=0+MiTwzZ; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=0R0PN64c; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="jD4VX/Rj";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="nd6EU74b";
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="0+MiTwzZ";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="0R0PN64c"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 748F521BDB;
	Mon, 21 Sep 2026 08:45:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1789980352; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=c4DAMKNsSE+Sj7sNz5K0pvC/5VdwD0F7bZEold/uo08=;
	b=jD4VX/Rjvh7kpRuZlWiIN6JBa+gZHBgbiJCCYZohvnU6ALQxaLV6YrQnXzyfZorbvpJNeH
	pAtTEdcrYYAqFtysIPxiwyE25ojuvhiyhSZ6sv3q46oW6IDMhLFpWAITO3uOOd5uhYmlg6
	MOpdJwbu9HInLQ0kjw6odxWMbbxo5d0=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1789980352;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=c4DAMKNsSE+Sj7sNz5K0pvC/5VdwD0F7bZEold/uo08=;
	b=nd6EU74b3d7f5qdoVAiw7cciIwSH9OaflcDy9CkfDvquRyIXPpCiT6PQbSOayU0CBKj3xy
	Qe8lljSIoNZpwWDQ==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1789980348; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=c4DAMKNsSE+Sj7sNz5K0pvC/5VdwD0F7bZEold/uo08=;
	b=0+MiTwzZuEe61BExfomM6pS7woR79Kq75PrG0ylOatPvSONwFX3ciEnOCgkShk4Jriwxc0
	4pJBxqAAQtf3GTGjQNhWSIk9hD7FsxkDEI3e5QaQPULyGxF2RelCVcmi8KVm3x433j8zwi
	FmUkTXSISnUuJAnra7WNfMaviyZgZ6c=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1789980348;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=c4DAMKNsSE+Sj7sNz5K0pvC/5VdwD0F7bZEold/uo08=;
	b=0R0PN64cICqpUhKSe/Q/QZ4WOfZzXwR2jyZq+Q8SfYaH+5+llIiE+kaDTreUCiWR2TarFh
	CwYd//E7rfJZtfBA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id B909B1368D;
	Mon, 21 Sep 2026 08:45:47 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id wzjKIrvusGq5SgAAD6G6ig
	(envelope-from <hare@suse.de>); Mon, 21 Sep 2026 08:45:47 +0000
Message-ID: <5a7830fd-7823-476b-84aa-3b01ca81ccdf@suse.de>
Date: Mon, 21 Sep 2026 10:45:47 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH RFC 0/5] NFS: isolate mTLS client credentials by network
 namespace
To: Benjamin Coddington <ben.coddington@hammerspace.com>,
 Chuck Lever <cel@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>,
 Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>,
 Simon Horman <horms@kernel.org>, Jonathan Corbet <corbet@lwn.net>,
 Shuah Khan <skhan@linuxfoundation.org>, Randy Dunlap
 <rdunlap@infradead.org>, Christian Brauner <brauner@kernel.org>,
 David Howells <dhowells@redhat.com>, Sagi Grimberg <sagi@grimberg.me>,
 linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org,
 linux-doc@vger.kernel.org
References: <20260918-nfs-mtls-identity-v1-0-197e568d78a7@kernel.org>
 <2FBF57B6-FBB6-498F-A1F4-695D52EB89E9@hammerspace.com>
Content-Language: en-US
From: Hannes Reinecke <hare@suse.de>
In-Reply-To: <2FBF57B6-FBB6-498F-A1F4-695D52EB89E9@hammerspace.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Spam-Level: 
X-Spam-Score: -4.30
X-Spam-Flag: NO
X-Spamd-Result: default: False [-4.30 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	NEURAL_HAM_SHORT(-0.20)[-0.995];
	MIME_GOOD(-0.10)[text/plain];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	MIME_TRACE(0.00)[0:+];
	ARC_NA(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[20];
	MID_RHS_MATCH_FROM(0.00)[];
	RCVD_TLS_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	FROM_HAS_DN(0.00)[];
	TO_DN_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.de:email,suse.de:mid]

On 9/18/26 7:21 PM, Benjamin Coddington wrote:
> On 18 Sep 2026, at 10:05, Chuck Lever wrote:
> 
>> An xprtsec=mtls mount names its client certificate and private key
>> by keyring serial, and tlshd reads those keys with its own
>> credentials. Each key therefore has to grant user read permission,
>> and any tlshd on the host that learns a serial can read it. Nothing
>> separates one network namespace's credentials from another's.
>>
>> This series makes the network namespace the isolation domain. The
>> RFC thread asked whether the user or mount namespace is the better
>> binding. tlshd services the handshake socket of one network
>> namespace, so that is the namespace it already lives in.
>>
>>    https://lore.kernel.org/linux-nfs/20260602154740.49861-1-cel@kernel.org/
>>
>> The keyring is held in struct nfs_net rather than found by name,
>> because /proc/keys is not namespace scoped. Its serial travels with
>> each handshake instead (patches 3-4), and tlshd's possession of that
>> keyring is what lets a provisioned key grant no user read permission
>> at all. Both ends of the link exist today, in tls_handshake_accept()
>> and in tlshd. The handshake genetlink ABI and the cert_serial= and
>> privkey_serial= mount options do not change.
>>
>> Still open is how userspace names the kernel-held keyring. Patch 5
>> prototypes a request_key type handled in the kernel and tagged
>> KEY_TYPE_NET_DOMAIN. A keyctl modeled on KEYCTL_GET_PERSISTENT, or a
>> read-only attribute on the netns-tagged nfs_client sysfs kobject,
>> would do the same job if the keyrings maintainers prefer one. Keys
>> that userspace adds are quota-charged by user namespace while the
>> keyring lives in nfs_net. Confirmation that this is sane when the
>> two boundaries differ would be welcome.
>>
>> nfstlskey, the provisioning tool that consumes the key type, is
>> merged in https://github.com/oracle/ktls-utils/ .
>>
>> Tested on one Fedora VM acting as both NFS client and NFSD, with
>> tlshd from ktls-utils 1.4.0: NFSv4.2 mounts with xprtsec=tls, with
>> xprtsec=mtls using the identity in tlshd.conf, and with xprtsec=mtls
>> using serials that nfstlskey provisioned.
> 
> I think this is the old upcall/namespace problem that's never been generally
> solved (as far as I know).  Here's a shameless plug to potentially revive
> the original "key agent" concept which solves this in a general way.
> 
> The idea is - user space processes (tlshd) register themselves as key-agents
> that can satisfy request-key.  A key agent represents itself as a key-type,
> and the appropriate key agent is consulted for request-key if the calling
> process has that agent's key in its keyrings.
> 
> Otherwise, this solution looks good - but without a general solution to this
> problem, other folks building on keyrings will keep trying to solve this
> problem.
> 
Not sure. Basic problem with the 'upcall' mechanism is that it needs to
execute a userspace program by the time of the upcall.
And that (trivially) requires
a) a usable userspace to be present
and
b) the correct program to be be available

And that needs to happen at a time when the connection is _known_ to be
non-functional (otherwise you would not need to do an upcall).
So there's a likelyhood that this connection serves to userspace we are
about to access, and the whole thing stalls.

With tlshd we have the benefit that the daemon is always running, so
we don't have this issue.

Cheers,

Hannes
-- 
Dr. Hannes Reinecke                  Kernel Storage Architect
hare@suse.de                                +49 911 74053 688
SUSE Software Solutions GmbH, Frankenstr. 146, 90461 Nürnberg
HRB 36809 (AG Nürnberg), GF: I. Totev, A. McDonald, W. Knoblich
