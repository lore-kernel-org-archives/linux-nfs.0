Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:33588 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932419AbbHGR0x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Aug 2015 13:26:53 -0400
Received: by ykoo205 with SMTP id o205so94169881yko.0
        for <linux-nfs@vger.kernel.org>; Fri, 07 Aug 2015 10:26:52 -0700 (PDT)
Date: Fri, 7 Aug 2015 13:26:49 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 06/18] nfsd: hook up nfsd_read to the nfsd_file cache
Message-ID: <20150807132649.47f05970@synchrony.poochiereds.net>
In-Reply-To: <55C4CEF0.6040004@gmail.com>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
	<1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
	<1438809216-4846-7-git-send-email-jeff.layton@primarydata.com>
	<55C4CEF0.6040004@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 7 Aug 2015 23:29:52 +0800
Kinglong Mee <kinglongmee@gmail.com> wrote:

> 
> On 8/6/2015 05:13, Jeff Layton wrote:
> > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> > ---
> >  fs/nfsd/vfs.c | 20 +++++++-------------
> >  1 file changed, 7 insertions(+), 13 deletions(-)
> > 
> > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > index 59234d1d8d8e..fd688c86af66 100644
> > --- a/fs/nfsd/vfs.c
> > +++ b/fs/nfsd/vfs.c
> > @@ -980,20 +980,14 @@ out_nfserr:
> >  __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
> >  	loff_t offset, struct kvec *vec, int vlen, unsigned long *count)
> >  {
> > -	struct file *file;
> > -	struct raparms	*ra;
> > -	__be32 err;
> > -
> > -	err = nfsd_open(rqstp, fhp, S_IFREG, NFSD_MAY_READ, &file);
> > -	if (err)
> > -		return err;
> > -
> > -	ra = nfsd_init_raparms(file);
> > -	err = nfsd_vfs_read(rqstp, file, offset, vec, vlen, count);
> > -	if (ra)
> > -		nfsd_put_raparams(file, ra);
> 
> Drop the raparms here ?
> 
> 

I'm not sure I understand your question. Are you asking why I dropped
the raparms from this code?

If so, the reason is that we shouldn't need it any longer. We only keep
that cache now because we do an open for every READ RPC. With this, a
streaming read should end up using the same struct file, at least as
long as there's not _too_ long a delay between READ RPCs. The normal
vfs readahead machinery should work properly with this change.

I'd like to eventually have us hook this up to the nfs4_file cache as
well. I stopped short of that here since I didn't need that immediately
for what I'm working on, but it should be possible to make the
nfs4_file cache use the nfsd_file cache instead of calling dentry_open
directly. Once we do that, then I don't think we'll need the raparms
cache at all anymore.

> > -	fput(file);
> > +	__be32			err;
> > +	struct nfsd_file	*nf;
> >  
> > +	err = nfsd_file_acquire(rqstp, fhp, NFSD_MAY_READ, &nf);
> > +	if (err == nfs_ok)
> > +		err = nfsd_vfs_read(rqstp, nf->nf_file, offset, vec, vlen,
> > +					count);
> > +	nfsd_file_put(nf);
> >  	return err;
> >  }
> >  
> > 


-- 
Jeff Layton <jlayton@poochiereds.net>
