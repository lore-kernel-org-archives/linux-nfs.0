Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f67.google.com ([209.85.192.67]:54148 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934955AbaGPTED (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 15:04:03 -0400
Received: by mail-qg0-f67.google.com with SMTP id f51so307518qge.6
        for <linux-nfs@vger.kernel.org>; Wed, 16 Jul 2014 12:04:02 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 16 Jul 2014 15:04:01 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 06/10] nfsd: Protect the nfs4_file delegation fields
 using the fi_lock
Message-ID: <20140716150401.00757454@tlielax.poochiereds.net>
In-Reply-To: <20140716180943.GA6920@infradead.org>
References: <1405521125-2303-1-git-send-email-jlayton@primarydata.com>
	<1405521125-2303-7-git-send-email-jlayton@primarydata.com>
	<20140716180943.GA6920@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 16 Jul 2014 11:09:43 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> >  	dp->dl_stid.sc_type = NFS4_CLOSED_DELEG_STID;
> > +	spin_lock(&fp->fi_lock);
> >  	list_del_init(&dp->dl_perclnt);
> >  	list_del_init(&dp->dl_recall_lru);
> > -	spin_lock(&fp->fi_lock);
> >  	list_del_init(&dp->dl_perfile);
> >  	spin_unlock(&fp->fi_lock);
> > -	spin_unlock(&state_lock);
> >  	if (fp) {
> >  		nfs4_put_deleg_lease(fp);
> > -		put_nfs4_file(fp);
> >  		dp->dl_file = NULL;
> >  	}
> > +	spin_unlock(&state_lock);
> > +	put_nfs4_file(fp);
> >  }
> 
> Unless I've missed something put_nfs4_file does not handle a NULL
> pointer argument in the current tree, so this needs a NULL check
> for fp.
> 

Well spotted, I'll fix that...

> > +	spin_lock(&state_lock);
> > +	/* Did the lease get broken before we took the lock? */
> > +	status = -EAGAIN;
> > +	if (!file_has_lease(fl->fl_file))
> > +		goto out_unlock;
> 
> So if the delegation we just tried to add got broken, but someone else
> managed to add one this would also return true.  But could that happen
> either in real life or in theory?  Shouldn't we instead have an
> atomic flag on the delegation that it got broken which we could check
> here?
> 

Hmm...maybe. It's a very unlikely race though, and I think the same
sort of race exists today. In fact, it's worse today since we don't do
any checking of the validity of the lease after acquiring it now.

The flag sounds like a good idea, but the code is structured completely
wrong for it currently. The delegation is only hashed after we get a
lease, so the lease break wouldn't find anything to set a flag on.

Quite frankly, I _really_ do not want to have to rework the locking in
the delegation code yet again. I think this scheme is an improvement
over what we have now, even if it's not 100% perfect.

Once we get the scalability set done, I'd like to go back and overhaul
the delegation code. There are a lot of ugly warts here, but fixing
them is really a separate project in its own right.

-- 
Jeff Layton <jlayton@primarydata.com>
