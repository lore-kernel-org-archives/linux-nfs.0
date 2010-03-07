From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 3/3] mountd: fix crossmnt options in v2/v3 case
Date: Mon, 8 Mar 2010 10:10:14 +1100
Message-ID: <20100308101014.14e635b2@notabene.brown>
References: <20100307200607.GA13006@fieldses.org>
	<1267992481-13332-1-git-send-email-bfields@citi.umich.edu>
	<1267992481-13332-2-git-send-email-bfields@citi.umich.edu>
	<1267992481-13332-3-git-send-email-bfields@citi.umich.edu>
	<20100308082516.260e5f70@notabene.brown>
	<20100307215826.GA14104@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:59341 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750931Ab0CGXKX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Mar 2010 18:10:23 -0500
In-Reply-To: <20100307215826.GA14104@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 7 Mar 2010 16:58:26 -0500
"J. Bruce Fields" <bfields@citi.umich.edu> wrote:

> On Mon, Mar 08, 2010 at 08:25:16AM +1100, Neil Brown wrote:
> > On Sun,  7 Mar 2010 15:08:01 -0500
> > "J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> > 
> > > The extra cache entries added here all get the options of the parent
> > > export.  This is incorrect, since once of the children may be explicitly
> > > exported with different options, and the parent crossmnt shouldn't
> > > override the explicit child export.
> > > 
> > > What's more, this is unnecessary, since in the newcache case we'll
> > > request these on demand when we need them.
> > 
> > Are you sure that removing this doesn't break something else?
> 
> Maybe so--thanks for looking at this.
> 
> > It was explicitly added in commit 323d1c4d69b65ab36d, apparently for a good
> > reason.
> > 
> > Also, it shouldn't be causing the problem described as cache_export_ent
> > should only be called where 'exp' is the lowest (furthest from the root)
> > export for any directory in 'path'.
> 
> Hm.  Is nfsd_fh() following that rule?

Hmmm... maybe not.  However when it doesn't it should log a warning
"%s and %s have same filehandle for %s, using first"

Maybe we need better choice between options there.  Maybe we should choose
the longest e_path??


> 
> > So any child mounts that are found should not be explicitly exported.
> >
> > This code is needed to handle a case where you have
> > /a /a/b /a/b/c all mount points, /a is exported with crossmnt,
> > and a mount request comes in for /a/b/c (or /a/b).
> > mountd needs to get the filehandle for /a/b/c, so that filesystem must be
> > exported to the kernel.
> 
> Yes, I didn't look carefully enough.  I think I must have assumed the
> first dump_to_cache did that.  But wouldn't it be sufficient to just do:
> 
> 	dump_to_cache(f, domain, path, e_path);
s/e_path/exp/
> 
> (as in the below) instead of also running through all the parents?

That sounds credible.. I wonder why I didn't think of that at the time.

My thoughts stray to lookups of ".." and whether they could use the wrong
export.  I don't think that can in any sane configuration.

> 
> > We cannot really on upcalls filling in that
> > information as doing so would cause mountd to deadlock - it asks the kernel
> > for a filehandle, the kernel asks it for export information, and mountd is
> > single-threaded...
> 
> Don't we have this problem already, then?  The export cache really is
> just a cache, and we should be prepared for a given entry to be purged
> at any time.
> 

Yes, it is a cache, but things don't get pushed out when it is 'full', so you
can expect items to stay out their expiry time.  So if you add something
with  an expiry 30 minutes in the future, you can usually expect it to still
be there in 30 seconds.

If someone ran "exportfs -f" at exactly the wrong time you might be able to
deadlock mountd (I'd have to double-check to be sure), but that is very
different from mountd acting in a way which leads directly to a deadlock.

NeilBrown


> --b.
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 7dec468..f682a9b 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -810,53 +810,13 @@ int cache_export_ent(char *domain, struct exportent *exp, char *path)
>  	if (!f)
>  		return -1;
>  
> -	err = dump_to_cache(f, domain, exp->e_path, exp);
> +	err = dump_to_cache(f, domain, path, exp);
>  	if (err) {
>  		xlog(L_WARNING,
>  		     "Cannot export %s, possibly unsupported filesystem or"
>  		     " fsid= required", exp->e_path);
>  	}
