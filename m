Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.223.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 146A23AEF55
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2026 16:22:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.130
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787156541; cv=none; b=OvoE+47fNHLY4DzInxwcg3WTQFL3UGNrIdBb+aBrZ/aRlTjFEDFcj69728G8PUb5DDx6nmqwVnu0ZpF7vddi7MMAP0zdZs2VSYNKtoIdITYcHhp3BkdV43OVETGLvgDuRebElDMjvy/TdrwARa2bDCKCjFzkUWmUEY8r28S+QPk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787156541; c=relaxed/simple;
	bh=e4te6h1xyKimsYHS9NrVH8StXNN6311Dja1qqzHnV9M=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=sDkMFITtOptLikfcLn5zPnD4UAWG+Boff/hTibSwfVwGqJpJrGzHSlLLSFYTKx7UO/ErMtxPaPn+Qsyaqdy5jlqSSrtfsnSN/hfQnJ3XLH40thAb55/Siz7xITey9rr+tk4n6U5oBlicW0cqAeD5OllAU+OJ531wtWIjxshyHGc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz; spf=pass smtp.mailfrom=suse.cz; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=j8q6mCXI; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=hyYcSR4a; dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b=bxIAAPKL; dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b=reXrUwm5; arc=none smtp.client-ip=195.135.223.130
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.cz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="j8q6mCXI";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="hyYcSR4a";
	dkim=pass (1024-bit key) header.d=suse.cz header.i=@suse.cz header.b="bxIAAPKL";
	dkim=permerror (0-bit key) header.d=suse.cz header.i=@suse.cz header.b="reXrUwm5"
Received: from imap1.dmz-prg2.suse.org (unknown [10.150.64.97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out1.suse.de (Postfix) with ESMTPS id 350AE84BC1;
	Wed, 19 Aug 2026 16:21:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1787156517; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=T1evlEEbS2b/TA3EU/6Mj1NCP1qai81FxW/EFcSpZ9U=;
	b=j8q6mCXI1nw7iDKfKA/IBKRJ/gj4fXnnuVCIkMeMWnzEH5k54fLSIF0tQcycugnnlHMZM0
	eYdk56mFKiywdkhGnJ0p5f8SOoNGj8VDyGC9A3elNJ5GGKtkEmeJeRj1lGDPIOPjaZUZOm
	4nmHAgqteSrofLb0glhacsEY0y473z4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1787156517;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=T1evlEEbS2b/TA3EU/6Mj1NCP1qai81FxW/EFcSpZ9U=;
	b=hyYcSR4afNGPf3HKVBOIcs+J+QO6ompXlbapH3BrnKpqlviPl5lv+vrd/lrlpJdxXQoAFs
	JXT8j4yTmJxRM+Bg==
Authentication-Results: smtp-out1.suse.de;
	none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
	t=1787156513; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=T1evlEEbS2b/TA3EU/6Mj1NCP1qai81FxW/EFcSpZ9U=;
	b=bxIAAPKLjAO3HiF65kO7N3cSjcXBTrTYtyCERUZgif8ix0UttXbflT+HBDYwSqU8OCUlpB
	Abwx7To8ooeox9p/C7mwIlBI73TUESbPLiLl3Dr6cAr3XgEykzsIZARgFU3N7LIy5M4YHX
	BFtTcypgwaeKp3cftxvLXwyjQblBe4k=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
	s=susede2_ed25519; t=1787156513;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=T1evlEEbS2b/TA3EU/6Mj1NCP1qai81FxW/EFcSpZ9U=;
	b=reXrUwm5pR4toueCWGOOymu2pbgpYfUJzOtU4fy4Z1lxmXJxiTm5AmVl+Nwms4oW4NkKph
	n3RMD4dgNdXqJ0DQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 0ECCB2F81;
	Wed, 19 Aug 2026 16:21:53 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id fnkwAyHYhWq3eAAAD6G6ig
	(envelope-from <jack@suse.cz>); Wed, 19 Aug 2026 16:21:53 +0000
Received: by quack3.suse.cz (Postfix, from userid 1000)
	id 9805AA13B2; Wed, 19 Aug 2026 18:21:48 +0200 (CEST)
Date: Wed, 19 Aug 2026 18:21:48 +0200
From: Jan Kara <jack@suse.cz>
To: Amir Goldstein <amir73il@gmail.com>
Cc: NeilBrown <neil@brown.name>, Jan Kara <jack@suse.cz>, 
	Miklos Szeredi <miklos@szeredi.hu>, Ian Kent <raven@themaw.net>, Chuck Lever <cel@kernel.org>, 
	Jake Edge <jake@lwn.net>, Ilya Dryomov <idryomov@gmail.com>, 
	Alex Markuze <amarkuze@redhat.com>, Viacheslav Dubeyko <slava@dubeyko.com>, 
	Jan Harkes <jaharkes@cs.cmu.edu>, coda@cs.cmu.edu, Alexander Viro <viro@zeniv.linux.org.uk>, 
	Christian Brauner <brauner@kernel.org>, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Miklos Szeredi <mszeredi@redhat.com>, autofs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	ceph-devel@vger.kernel.org, codalist@coda.cs.cmu.edu, linux-fsdevel@vger.kernel.org, 
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 03/12] fsnotify: don't hold a spin_lock across
 fsnotify_recalc_mask() calls.
Message-ID: <zos6dvjft7djeb7rox7zbeowaawfy3vl2ddp6o2iwnkfjnrjah@eu2lil7wihue>
References: <20260803012648.2195405-1-neilb@ownmail.net>
 <20260803012648.2195405-4-neilb@ownmail.net>
 <CAJfpegs-k3skRGiwZvQLzD7OrAK4KL8zwmpmJKyjRHSQ-rqX+Q@mail.gmail.com>
 <178642552869.2852630.11443303758249822243@noble.neil.brown.name>
 <178675372176.2852630.1305553887009521382@noble.neil.brown.name>
 <oh2lg2agqxwqopecacq6sfdnky5faxidwsybkvbwbq24r6tw6o@4swfog5ocwwb>
 <CAOQ4uxgtKvKmPaK8rPAZDSwu0Hr9JAmqJi0a1VX_Rg7jDo8HrQ@mail.gmail.com>
 <178709583480.2852630.4575326968116183366@noble.neil.brown.name>
 <CAOQ4uxj6O8Ukbn-vWU-o+zOAYyofokCTAGnSifSDh9-PACCTdg@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAOQ4uxj6O8Ukbn-vWU-o+zOAYyofokCTAGnSifSDh9-PACCTdg@mail.gmail.com>
X-Spam-Score: -3.80
X-Spam-Level: 
X-Spam-Flag: NO
X-Spamd-Result: default: False [-3.80 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	MID_RHS_NOT_FQDN(0.50)[];
	NEURAL_HAM_SHORT(-0.20)[-0.999];
	MIME_GOOD(-0.10)[text/plain];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	ARC_NA(0.00)[];
	MISSING_XM_UA(0.00)[];
	MIME_TRACE(0.00)[0:+];
	FREEMAIL_TO(0.00)[gmail.com];
	RCPT_COUNT_TWELVE(0.00)[24];
	RCVD_COUNT_THREE(0.00)[3];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	DKIM_SIGNED(0.00)[suse.cz:s=susede2_rsa,suse.cz:s=susede2_ed25519];
	FROM_HAS_DN(0.00)[];
	FREEMAIL_CC(0.00)[brown.name,suse.cz,szeredi.hu,themaw.net,kernel.org,lwn.net,gmail.com,redhat.com,dubeyko.com,cs.cmu.edu,zeniv.linux.org.uk,linux-foundation.org,vger.kernel.org,coda.cs.cmu.edu];
	TO_DN_SOME(0.00)[];
	FROM_EQ_ENVFROM(0.00)[];
	RCVD_TLS_LAST(0.00)[];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,suse.com:email]

On Wed 19-08-26 11:09:08, Amir Goldstein wrote:
> On Wed, Aug 19, 2026 at 1:30 AM NeilBrown <neilb@ownmail.net> wrote:
> > On Mon, 17 Aug 2026, Amir Goldstein wrote:
> > > Maybe this is the way out.
> > >
> > > dnotify_recalc_inode_mask() can only remove bits from i_fsnotify_mask,
> > > so it is an optimization.
> > >
> > > If we just remove fsnotify_recalc_mask() call from
> > > dnotify_recalc_inode_mask(), then i_fsnotify_mask will be updated when
> > > dnotify_mask gets removed eventually.
> >
> > I had thought something along these lines too.  I don't think we need to
> > drop all of fsnotify_recalc_mask(), only the
> > fsnotify_conn_set_children_dentry_flags() part that walks the d_children
> > list.  And that only happens when we add to the mask, not when bits are
> > cleared.  So maybe the fsnotify_conn_set_children_dentry_flags() simply
> > never happens in this context so it doesn't need fixing.

I agree with the "fsnotify_conn_set_children_dentry_flags() never happens
from this path" part. I'm not sure I follow the "it doesn't need fixing"
part - do you mean you will just not touch where dnotify calls
fsnotify_recalc_mask()? In that case I agree.

> > I would prefer to make that clear from the code with a patch like the
> > following.

Definitely.

> > Note that I'm not (yet) convinced by the locking argument, but maybe we
> > don't need to pursue it.

Not sure what you mean here...

> > diff --git a/fs/notify/dnotify/dnotify.c b/fs/notify/dnotify/dnotify.c
> > index 9fb73bafd41d..be66d4142563 100644
> > --- a/fs/notify/dnotify/dnotify.c
> > +++ b/fs/notify/dnotify/dnotify.c
> > @@ -75,7 +75,7 @@ static void dnotify_recalc_inode_mask(struct fsnotify_mark *fsn_mark)
> >                 return;
> >         fsn_mark->mask = new_mask;
> >
> > -       fsnotify_recalc_mask(fsn_mark->connector);
> > +       fsnotify_recalc_mask_inatomic(fsn_mark->connector);
> 
> I don't think skipping update_children is correct when called
> from fcntl_dirnotify().

Yes, it is not. Dnotify places mark on directory and sets FS_EVENT_ON_CHILD
so it depends on dentry flags to be updated from fcntl_dirnotify().

> From 73bbfcd1b21a0fc723999aee36af662f36ba4dd2 Mon Sep 17 00:00:00 2001
> From: Amir Goldstein <amir73il@gmail.com>
> Date: Wed, 19 Aug 2026 10:56:40 +0200
> Subject: [PATCH] fsnotify: update children flags only when adding mask bits
> 
> Since we only ever set the PARENT_WATCHED flag from
> fsnotify_recalc_mask(), there is never a need to update children flags
> when removing mark mask bits only when adding them.
> 
> Fixes: 172e422ffea20 ("fsnotify: clear PARENT_WATCHED flags lazily")
> Signed-off-by: Amir Goldstein <amir73il@gmail.com>

Looks good to me, Neil will you pick this into your series or should I pick
the patch into my tree rightaway?

> diff --git a/fs/notify/mark.c b/fs/notify/mark.c
> index b2640d836a712..731e430f2f3c6 100644
> --- a/fs/notify/mark.c
> +++ b/fs/notify/mark.c
> @@ -317,20 +317,21 @@ static void fsnotify_conn_set_children_dentry_flags(
>  }
>  
>  /*
> - * Calculate mask of events for a list of marks. The caller must make sure
> - * connector and connector->obj cannot disappear under us.  Callers achieve
> - * this by holding a mark->lock or mark->group->mark_mutex for a mark on this
> - * list.
> + * Calculate mask of events for a list of marks.
> + * If @update_children is true, update children dentry flags if needed.
> + * The caller must make sure connector and connector->obj cannot disappear under
> + * us.  Callers achieve this by holding a mark->lock or mark->group->mark_mutex
> + * for a mark on this list.
>   */
> -void fsnotify_recalc_mask(struct fsnotify_mark_connector *conn)
> +void fsnotify_recalc_mask(struct fsnotify_mark_connector *conn,
> +			  bool update_children)
>  {
> -	bool update_children;

As a side note once Neil allows the dentry iteration to sleep, we should
document in the comment above that mark->lock can be used only for
!update_children case and perhaps assert it in the function as well.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
