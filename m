From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 6/9] sunrpc/cache: retry cache lookups that return
	-ETIMEDOUT
Date: Thu, 3 Dec 2009 11:57:29 -0500
Message-ID: <20091203165729.GB1393@fieldses.org>
References: <20090909062539.20462.67466.stgit@notabene.brown> <20090909063254.20462.41616.stgit@notabene.brown> <20091202221127.GB18690@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40099 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754924AbZLCQ4X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Dec 2009 11:56:23 -0500
In-Reply-To: <20091202221127.GB18690@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 02, 2009 at 05:11:27PM -0500, J. Bruce Fields wrote:
> On Wed, Sep 09, 2009 at 04:32:54PM +1000, NeilBrown wrote:
> > @@ -793,9 +793,18 @@ exp_find_key(svc_client *clp, int fsid_type, u32 *fsidv, struct cache_req *reqp)
> >  	memcpy(key.ek_fsid, fsidv, key_len(fsid_type));
> >  
> >  	ek = svc_expkey_lookup(&key);
> > + again:
> >  	if (ek == NULL)
> >  		return ERR_PTR(-ENOMEM);
> >  	err = cache_check(&svc_expkey_cache, &ek->h, reqp);
> > +	if (err == -ETIMEDOUT) {
> > +		struct svc_expkey *prev_ek = ek;
> > +		ek = svc_expkey_lookup(&key);
> > +		if (ek != prev_ek)
> > +			goto again;
> > +		if (ek)
> > +			cache_put(&ek->h, &svc_expkey_cache);
> > +	}
> 
> This is very subtle.  (We're comparing to a pointer which may not
> actually point to anything any more.)  And it's repeated in every
> caller.  Is there any simpler way to handle this?

Actually, is it even right?  After the cache_check:

> >  	err = cache_check(&svc_expkey_cache, &ek->h, reqp);

we no longer hold a reference on ek, so it could be freed.  There's no
reason that address couldn't then be reused for something else.  It's
even possible that a new entry could be created at the same address
here.  So:

> > +	if (err == -ETIMEDOUT) {
> > +		struct svc_expkey *prev_ek = ek;
> > +		ek = svc_expkey_lookup(&key);

the "ek" that's returned might well equal prev_ek,

> > +		if (ek != prev_ek)
> > +			goto again;

but that doesn't necessarily imply that this is the same object that
used to exist at that address.  So we could still return an ek which
isn't actually a positive cache entry.

Am I missing something?

--b.

> > +		if (ek)
> > +			cache_put(&ek->h, &svc_expkey_cache);
> > +	}

> 
> --b.
> 
> >  	if (err)
> >  		return ERR_PTR(err);
> >  	return ek;
