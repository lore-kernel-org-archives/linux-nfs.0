Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D550035028E
	for <linux-nfs@vger.kernel.org>; Wed, 11 Feb 2026 10:39:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770806382; cv=none; b=mzOLTD218G4EggJ1NTBWadykQ44oCfIM9nRiWxCC8AdvpyMEuXkKYLklVqiJohnE4TZZIP/+Vhmn9LqNT6p03ly6g42I1gT+oSb0v4JMSsao+lEmH1eOyVT8IeDxdyjDKAJkGXb5e5g79ZvTdZeCfgYsGd42zQCeaFw0zGQxUKc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770806382; c=relaxed/simple;
	bh=OsH4kYm7T/euzazdoD33A41bErU7ls/8r2lTHp+N37Y=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=HsTfANhHvpQDygbRhKeYpviR/Nod+YhHtOeR8Hsv2lYbZ9eu+SRWLRbMeMUmIqYSOPzyeYSNsdp+Wxml2UPLVFBSHtwkwD+VIiORy4kHDT0jSIFCW0ElVInhUCta4KA0Z9SHD+beI7Q/EVLn4vrsvLv3jF7VIXv/EjVbs90bvH8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=BmUBboYW; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=by39V2TH; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=0Qfw5mJC; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=z/UMqHF7; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="BmUBboYW";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="by39V2TH";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="0Qfw5mJC";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="z/UMqHF7"
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id E03665BD05;
	Wed, 11 Feb 2026 10:39:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1770806379; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=y76NacrGFKNA67jm3GBX5fGDdHrRzA908Y/YQr7KcHE=;
	b=BmUBboYWPK+YFbU/jweWKyIiUAweeNXYSTX1fb3ioA82XPtGMDyhfkU7hzRjYdDX6yjo6X
	BeUu5WcFU45hHpGE8oPLjrvZRt0V32MUGIHUsf8pNtCt64kKmLgOKjpmy7+EBfzWu7XdN3
	zOKg6uHuRlpSN5eZ+sXnL3mQN4S9nng=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1770806379;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=y76NacrGFKNA67jm3GBX5fGDdHrRzA908Y/YQr7KcHE=;
	b=by39V2THiRrSEIe+rir0v6aSPkDRc8KCONGaVuv9Nts2jJFfk8kzHZO3UTQCF0EaA+Cnxj
	64QImSNnfLUywxCg==
Authentication-Results: smtp-out2.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=0Qfw5mJC;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b="z/UMqHF7"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1770806378; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=y76NacrGFKNA67jm3GBX5fGDdHrRzA908Y/YQr7KcHE=;
	b=0Qfw5mJCxxyf0ABiPJVAehjEN8j26xUmtsMN3J935cFGujMLU634JBTrpXQag2QG8iDRxl
	6140cVo5sZHQtw7vwGlIlhM8/babUB9qURsDOMS4RnS5VMC+Zqi6b/OKTqtXLAvDfPZdEp
	REvU2t1zZz7PT+8lMhAC5x6DUP/OvpE=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1770806378;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=y76NacrGFKNA67jm3GBX5fGDdHrRzA908Y/YQr7KcHE=;
	b=z/UMqHF7kR5+32lfphNTIcisbuVsCE222LlnL3EjP+ih0t7xz7nIVSqi+Rl/Ir7ySjNauZ
	CybE1xdlTiN0TvCA==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id C9D7113A95;
	Wed, 11 Feb 2026 10:39:38 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id SexBMWpcjGnGMAAAD6G6ig
	(envelope-from <jack@suse.cz>); Wed, 11 Feb 2026 10:39:38 +0000
Received: by quack3.suse.cz (Postfix, from userid 1000)
	id 8F98AA0A4E; Wed, 11 Feb 2026 11:39:30 +0100 (CET)
Date: Wed, 11 Feb 2026 11:39:30 +0100
From: Jan Kara <jack@suse.cz>
To: Kundan Kumar <kundan.kumar@samsung.com>
Cc: jaegeuk@kernel.org, chao@kernel.org, agruenba@redhat.com, 
	trondmy@kernel.org, anna@kernel.org, hch@lst.de, brauner@kernel.org, jack@suse.cz, 
	viro@zeniv.linux.org.uk, djwong@kernel.org, pankaj.raghav@linux.dev, 
	linux-f2fs-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, gfs2@lists.linux.dev, 
	linux-nfs@vger.kernel.org, gost.dev@samsung.com, anuj20.g@samsung.com, vishak.g@samsung.com, 
	joshi.k@samsung.com, mcgrof@kernel.org
Subject: Re: [PATCH 1/4] writeback: prep helpers for dirty-limit and
 writeback accounting
Message-ID: <ddx62wlkv6hjirl5kf3szghllvgfkmrhp226bj3lxklskdyk6i@k3spugopk5rl>
References: <20260211070057.22001-1-kundan.kumar@samsung.com>
 <CGME20260211070537epcas5p11bcbdc3d5ab68e1b9b7ec68feda22487@epcas5p1.samsung.com>
 <20260211070057.22001-2-kundan.kumar@samsung.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260211070057.22001-2-kundan.kumar@samsung.com>
X-Spam-Score: -4.01
X-Spamd-Result: default: False [-4.01 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	R_DKIM_ALLOW(-0.20)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	ARC_NA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	RCPT_COUNT_TWELVE(0.00)[21];
	TO_DN_SOME(0.00)[];
	MISSING_XM_UA(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:rdns,imap1.dmz-prg2.suse.org:helo,suse.cz:dkim,suse.cz:email,suse.com:email,samsung.com:email];
	RCVD_COUNT_THREE(0.00)[3];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	SPAMHAUS_XBL(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	RCVD_TLS_LAST(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	DKIM_TRACE(0.00)[suse.cz:+]
X-Spam-Level: 
X-Rspamd-Action: no action
X-Rspamd-Queue-Id: E03665BD05
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Spam-Flag: NO

On Wed 11-02-26 12:30:54, Kundan Kumar wrote:
> Add helper APIs needed by filesystems to avoid poking into writeback
> internals.
> 
> Suggested-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Kundan Kumar <kundan.kumar@samsung.com>
> Signed-off-by: Anuj Gupta <anuj20.g@samsung.com>

Looks sensible. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  include/linux/backing-dev.h | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/include/linux/backing-dev.h b/include/linux/backing-dev.h
> index 0c8342747cab..4165ad3ddf00 100644
> --- a/include/linux/backing-dev.h
> +++ b/include/linux/backing-dev.h
> @@ -78,6 +78,17 @@ static inline s64 wb_stat_sum(struct bdi_writeback *wb, enum wb_stat_item item)
>  
>  extern void wb_writeout_inc(struct bdi_writeback *wb);
>  
> +static inline int bdi_wb_dirty_exceeded(struct backing_dev_info *bdi)
> +{
> +	return bdi->wb.dirty_exceeded;
> +}
> +
> +static inline void bdi_wb_stat_mod(struct backing_dev_info *bdi,
> +				   enum wb_stat_item item, s64 amount)
> +{
> +	wb_stat_mod(&bdi->wb, item, amount);
> +}
> +
>  /*
>   * maximal error of a stat counter.
>   */
> -- 
> 2.25.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
