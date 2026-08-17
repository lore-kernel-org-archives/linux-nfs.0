Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DED403F926B;
	Mon, 17 Aug 2026 11:03:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786964615; cv=none; b=UEODOiTXY14LrqTbRstT+7K0qGBsvqkniisEgkNzD0o6eJNjbvinOBGNzW8DBRmsSk0G7Dpsdm5MX/lQpBHgMnEitWXONKLxyKzW5cXYtmBC+SmfiMmVTLfFojeMyVUmGsraZ/YZRdVqSgGA6w0JgPN+Y+ABciD8Kci2L6eey6U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786964615; c=relaxed/simple;
	bh=UC01y+N70K2YYwuhiD63941gnut7CPgk2/EOWTUjvrY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=fPg2OkM/B9bKMSGbNqqP7Md58bClgL7M4v+iFJzVefH+LdpafLzGFEQNhS0tc2C371YjgrPnrMV+dBaziV1rHqnwXZ7DOR7ZaH3mHED53piEfXHLZLBcwB+SNk2a/6x5wptWQVsLSW2QP44AsihILy/Dp1C6RU4V5d9x2jhsXV4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=tLT3QW9b; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=8X8znelA; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=zLM3nScL; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=GgaExUB1; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="tLT3QW9b";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="8X8znelA";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="zLM3nScL";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="GgaExUB1"
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id AA4AA83F70;
	Mon, 17 Aug 2026 11:03:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1786964607; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=7iC/4+DbNi/oVt0tkupTCs6iE9SsTBaX7RuvRMSdNNA=;
	b=tLT3QW9b6/xDV9Ixy4zoLm+Sym5e8UrpRnGsWoBcLJhjPkST6lMELTRxUJUQGpZF0lx6cZ
	CrQzaPfddU0JJoItEfD5PdYMA2htwZJU679KcKyN462F3b1zhN1ApxrzzGiqLBP4jGET9N
	Cns17l2zKnZ4DDxsGjPi8d14DXwFnPY=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1786964607;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=7iC/4+DbNi/oVt0tkupTCs6iE9SsTBaX7RuvRMSdNNA=;
	b=8X8znelAvCLGvHFOr74Pet9Ho88Mm/5toK4DxVXyvYUa9ubhq21sXaTOiQtiIi7tW55O0W
	q6XlLziszMheBACQ==
Authentication-Results: smtp-out1.suse.de;
	dkim=pass header.d=suse.cz header.s=susede2_rsa header.b=zLM3nScL;
	dkim=pass header.d=suse.cz header.s=susede2_ed25519 header.b=GgaExUB1
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1786964603; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=7iC/4+DbNi/oVt0tkupTCs6iE9SsTBaX7RuvRMSdNNA=;
	b=zLM3nScLqmXi359QoWe5LBqf2TSEnkVLmycbkb0qVY3mOjBS//cftPffZe7QxbNmKBXHjk
	PL1/leHGjigoWbJZurYzuZGXlmSL14eEDbPz6Jf3KkUg9nE33E+sV86nBZzSDN2h7wFzWi
	FItMyjngdoagwlKBs+/cNuTpme73IPg=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1786964603;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=7iC/4+DbNi/oVt0tkupTCs6iE9SsTBaX7RuvRMSdNNA=;
	b=GgaExUB129+gqMFavDlXWKVcOKduNpBj1fW8CrvokjGE7BdpSzA4FvYOIcQ0/0rb7Xzw1p
	3eifOk+FRaFWRLCw==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 9FD407941C;
	Mon, 17 Aug 2026 11:03:23 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id VSoAJ3vqgmpoIgAAD6G6ig
	(envelope-from <jack@suse.cz>); Mon, 17 Aug 2026 11:03:23 +0000
Received: by quack3.suse.cz (Postfix, from userid 1000)
	id 3EE52A13B5; Mon, 17 Aug 2026 13:03:19 +0200 (CEST)
Date: Mon, 17 Aug 2026 13:03:19 +0200
From: Jan Kara <jack@suse.cz>
To: NeilBrown <neil@brown.name>
Cc: Miklos Szeredi <miklos@szeredi.hu>, Ian Kent <raven@themaw.net>, 
	Chuck Lever <cel@kernel.org>, Jake Edge <jake@lwn.net>, Ilya Dryomov <idryomov@gmail.com>, 
	Alex Markuze <amarkuze@redhat.com>, Viacheslav Dubeyko <slava@dubeyko.com>, 
	Jan Harkes <jaharkes@cs.cmu.edu>, coda@cs.cmu.edu, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>, Amir Goldstein <amir73il@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <mszeredi@redhat.com>, autofs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, ceph-devel@vger.kernel.org, codalist@coda.cs.cmu.edu, 
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 03/12] fsnotify: don't hold a spin_lock across
 fsnotify_recalc_mask() calls.
Message-ID: <oh2lg2agqxwqopecacq6sfdnky5faxidwsybkvbwbq24r6tw6o@4swfog5ocwwb>
References: <20260803012648.2195405-1-neilb@ownmail.net>
 <20260803012648.2195405-4-neilb@ownmail.net>
 <CAJfpegs-k3skRGiwZvQLzD7OrAK4KL8zwmpmJKyjRHSQ-rqX+Q@mail.gmail.com>
 <178642552869.2852630.11443303758249822243@noble.neil.brown.name>
 <178675372176.2852630.1305553887009521382@noble.neil.brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <178675372176.2852630.1305553887009521382@noble.neil.brown.name>
X-Spam-Score: -4.01
X-Spam-Level: 
X-Rspamd-Action: no action
X-Rspamd-Queue-Id: AA4AA83F70
X-Spamd-Result: default: False [-4.01 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	R_DKIM_ALLOW(-0.20)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	ARC_NA(0.00)[];
	MISSING_XM_UA(0.00)[];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[24];
	MIME_TRACE(0.00)[0:+];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	TO_DN_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	FREEMAIL_CC(0.00)[szeredi.hu,themaw.net,kernel.org,lwn.net,gmail.com,redhat.com,dubeyko.com,cs.cmu.edu,zeniv.linux.org.uk,suse.cz,linux-foundation.org,vger.kernel.org,coda.cs.cmu.edu];
	RCVD_COUNT_THREE(0.00)[3];
	DBL_BLOCKED_OPENRESOLVER(0.00)[suse.com:email,suse.cz:dkim,ownmail.net:email,imap1.dmz-prg2.suse.org:helo,imap1.dmz-prg2.suse.org:rdns];
	RCVD_TLS_LAST(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	DKIM_TRACE(0.00)[suse.cz:+]
X-Rspamd-Server: rspamd1.dmz-prg2.suse.org
X-Spam-Flag: NO

On Sat 15-08-26 10:28:41, NeilBrown wrote:
> On Tue, 11 Aug 2026, NeilBrown wrote:
> > On Tue, 11 Aug 2026, Miklos Szeredi wrote:
> > > On Mon, 3 Aug 2026 at 03:39, NeilBrown <neilb@ownmail.net> wrote:
> > > 
> > > > @@ -116,11 +117,15 @@ static int dnotify_handle_event(struct fsnotify_mark *inode_mark, u32 mask,
> > > >                 else {
> > > >                         *prev = dn->dn_next;
> > > >                         kmem_cache_free(dnotify_struct_cache, dn);
> > > > -                       dnotify_recalc_inode_mask(inode_mark);
> > > > +                       need_recalc = true;
> > > >                 }
> > > >         }
> > > >
> > > > +       if (need_recalc)
> > > > +               need_recalc = dnotify_recalc_inode_mask(inode_mark);
> > > >         spin_unlock(&inode_mark->lock);
> > > > +       if (need_recalc)
> > > > +               fsnotify_recalc_mask(inode_mark->connector);
> > > 
> > > Is the fsnotify_group_lock() held in this case?   I don't see it.
> > 
> > It isn't held.  Doesn't it need to be...
> > It seems to protect marks, so maybe it does.
> > 
> > srcu seems to be used to protect this section, so maybe we can rely on
> > that.
> 
> I dug into this some more, and we do rely on srcu, but don't need the
> extra code below.
> inode_mark->lock doesn't protect inode_mark->connector, so moving the
> dereference out of the lock has no effect.
> srcu_read_lock is taken before we get the ref to the mark, so the mark
> and the connector cannot disappear underneath us.
> A race could result in inode_mark->connector reading as NULL, but
> fsnotify_recalc_mask() checks for NULL, so there is no risk for harm.
> 
> Thanks for encouraging me to dig into this.

Sorry for not replying earlier but I was on vacation. The lifetime rules
around marks & connectors are subtle so we have to be really careful and
dnotify with its single shot marks is peculiar which makes things even
harder. fsnotify_recalc_mask() has a comment about locking in front of it:

/*
 * Calculate mask of events for a list of marks. The caller must make sure
 * connector and connector->obj cannot disappear under us.  Callers achieve
 * this by holding a mark->lock or mark->group->mark_mutex for a mark on this
 * list.
 */

and you very obviously start violating these rules with your changes. Now I
admit I've forgotten all the details why I did it like this so let me
reconstruct it :).

Connector stays alive as long as there's any mark in its list. Both marks
and connectors are protected by the srcu. Mark also has
FSNOTIFY_MARK_FLAG_ATTACHED flag which is set iff the connector->obj is
pointing to valid inode/mount/... FSNOTIFY_MARK_FLAG_ATTACHED changes only
under mark_mutex so that's why mark_mutex is stabilizing the connector (and
also connector->obj). This is what is used by most places calling
fsnotify_recalc_mask(). But dnotify needs to mess with notification mark
mask from event handling and there we cannot take mark_mutex due to lock
ordering constraints. That's where the mark->lock rule comes into play
because mark->lock also needs to be acquired to clear
FSNOTIFY_MARK_FLAG_ATTACHED. That being said this dnotify use of
fsnotify_recalc_mask() still looks somewhat racy because
dnotify_handle_event() can get called after FSNOTIFY_MARK_FLAG_ATTACHED is
cleared.

Anyway if you move fsnotify_recalc_mask() call outside of mark->lock, you
seem to make the race with dnotify clearing the mark from 
fcntl_dirnotify() easier to hit. Now in the notification path the inode
itself is guaranteed to stay alive and the rest is protected by the SRCU so
there's no direct UAF. But fsnotify_recalc_mask() simply isn't prepared for
the connector changing under it due to object getting detached and so we
could end up doing weird things like NULL ptr derefs or similar stuff.

So this call to fsnotify_recalc_mask() from dnotify needs a more careful
handling. Which is sad because I doubt anybody still uses dnotify...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
