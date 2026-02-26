Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F380F362127
	for <linux-nfs@vger.kernel.org>; Thu, 26 Feb 2026 13:33:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772112786; cv=none; b=IiXSoQUQ02muuBzTcBRzA6IRDyM6EH0iXtXuRBZ7QF5x7zDCk3Oo1EPQmO9Wpb9b9C9GGmZNULZJNbDCm8A4b7h20K20YC3o+Se6QGz3C2WXfqCi4+NHreH7nljSNf1ifWWtR04mp1MDW/N/JUW63uGozsg4NwAX6H1Tb+NP9ig=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772112786; c=relaxed/simple;
	bh=icM4sWmEUXc517pw/21Vdp7W9VDjo99t0kDWbhlImgM=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=AKwBPs5liRvHTTEtT8zdaqj0uxJmoeNMLrf3mUT6gi96+HTuZFaozbJvH/TAIBKrRc+T8wPoga1XQtKvcL5RKeNDc80EgXbjtJjzMUNYY+Aaroqej5LzYdBexo+rC71R4jUeqWOChlmefd9En+5GWID+nH4WD9nWbpYJRH9t0SU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=y+q9NdJG; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=4IojGsaJ; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=y+q9NdJG; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=4IojGsaJ; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="y+q9NdJG";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="4IojGsaJ";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="y+q9NdJG";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="4IojGsaJ"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id 24FCA1FAD4;
	Thu, 26 Feb 2026 13:32:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1772112779; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=DqeshdE86FdxvwODzfcSa0evwotA046BXGucN70U7O4=;
	b=y+q9NdJGg7TPdS33AsrHYvX/yNo8C3X6rGlWzN7dR90ITYRobGSn3ZNzNz1CKna9r+2KZl
	SdDTdxS1YmAvGghxHX0ss8CMg35m5DitpUYOP5ZEmAoNJ+o413x5W33XOkvh3xkWmbc54o
	2aLV/lKecM1P7ANwg0g+avwI4j4ye8Q=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1772112779;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=DqeshdE86FdxvwODzfcSa0evwotA046BXGucN70U7O4=;
	b=4IojGsaJfgqpae2U79zkBQzOJA+mxWqzdQmb+O2OK9r+KlNrs6HprhykRJ5dlgicMIVn/G
	X8eChwVI6vUf6LAw==
Authentication-Results: smtp-out2.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1772112779; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=DqeshdE86FdxvwODzfcSa0evwotA046BXGucN70U7O4=;
	b=y+q9NdJGg7TPdS33AsrHYvX/yNo8C3X6rGlWzN7dR90ITYRobGSn3ZNzNz1CKna9r+2KZl
	SdDTdxS1YmAvGghxHX0ss8CMg35m5DitpUYOP5ZEmAoNJ+o413x5W33XOkvh3xkWmbc54o
	2aLV/lKecM1P7ANwg0g+avwI4j4ye8Q=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1772112779;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=DqeshdE86FdxvwODzfcSa0evwotA046BXGucN70U7O4=;
	b=4IojGsaJfgqpae2U79zkBQzOJA+mxWqzdQmb+O2OK9r+KlNrs6HprhykRJ5dlgicMIVn/G
	X8eChwVI6vUf6LAw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 1A1753EA62;
	Thu, 26 Feb 2026 13:32:59 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id c71XBotLoGl+XQAAD6G6ig
	(envelope-from <jack@suse.cz>); Thu, 26 Feb 2026 13:32:59 +0000
Received: by quack3.suse.cz (Postfix, from userid 1000)
	id CF0EAA0A27; Thu, 26 Feb 2026 14:32:54 +0100 (CET)
Date: Thu, 26 Feb 2026 14:32:54 +0100
From: Jan Kara <jack@suse.cz>
To: Chuck Lever <cel@kernel.org>
Cc: Amir Goldstein <amir73il@gmail.com>, Jan Kara <jack@suse.com>, 
	NeilBrown <neilb@ownmail.net>, Jeff Layton <jlayton@kernel.org>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <dai.ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	Chuck Lever <chuck.lever@oracle.com>, Christian Brauner <brauner@kernel.org>
Subject: Re: [PATCH v3 1/3] fs: add umount notifier chain for filesystem
 unmount notification
Message-ID: <jxyalrg3a2yjtjfmdylncg7fz63jstbq6pwhhqlaaxju5sk72f@55lb7mfucc5i>
References: <20260224163908.44060-1-cel@kernel.org>
 <20260224163908.44060-2-cel@kernel.org>
 <20260226-alimente-kunst-fb9eae636deb@brauner>
 <CAOQ4uxhEpf1p3agEF7_HBrhUeKz1Fb_yKAQ0Pjo0zztTJfMoXA@mail.gmail.com>
 <1165a90b-acbf-4c0d-a7e3-3972eba0d35a@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1165a90b-acbf-4c0d-a7e3-3972eba0d35a@kernel.org>
X-Spam-Score: -3.80
X-Spam-Level: 
X-Spamd-Result: default: False [-3.80 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	ARC_NA(0.00)[];
	MISSING_XM_UA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	RCPT_COUNT_TWELVE(0.00)[12];
	URIBL_BLOCKED(0.00)[suse.com:email,imap1.dmz-prg2.suse.org:helo];
	FREEMAIL_ENVRCPT(0.00)[gmail.com,ownmail.net];
	TO_DN_SOME(0.00)[];
	FROM_HAS_DN(0.00)[];
	FREEMAIL_CC(0.00)[gmail.com,suse.com,ownmail.net,kernel.org,redhat.com,oracle.com,talpey.com,vger.kernel.org];
	RCVD_COUNT_THREE(0.00)[3];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.com:email]
X-Spam-Flag: NO

On Thu 26-02-26 08:27:00, Chuck Lever wrote:
> On 2/26/26 5:52 AM, Amir Goldstein wrote:
> > On Thu, Feb 26, 2026 at 9:48 AM Christian Brauner <brauner@kernel.org> wrote:
> >> Another thing: These ad-hoc notifiers are horrific. So I'm pitching
> >> another idea and I hope that Jan and Amir can tell me that this is
> >> doable...
> >>
> >> Can we extend fsnotify so that it's possible for a filesystem to
> >> register "internal watches" on relevant objects such as mounts and
> >> superblocks and get notified and execute blocking stuff if needed.
> >>
> > 
> > You mean like nfsd_file_fsnotify_group? ;)
> > 
> >> Then we don't have to add another set of custom notification mechanisms
> >> but have it available in a single subsystem and uniformely available.
> >>
> > 
> > I don't see a problem with nfsd registering for FS_UNMOUNT
> > event on sb (once we add it).
> > 
> > As a matter of fact, I think that nfsd can already add an inode
> > mark on the export root path for FS_UNMOUNT event.
> 
> There isn't much required here aside from getting a synchronous notice
> that the final file system unmount is going on. I'm happy to try
> whatever mechanism VFS maintainers are most comfortable with.

Yeah, then as Amir writes placing a mark with FS_UNMOUNT event on the
export root path and handling the event in
nfsd_file_fsnotify_handle_event() should do what you need?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
