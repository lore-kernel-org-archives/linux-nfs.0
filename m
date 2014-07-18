Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f66.google.com ([209.85.192.66]:34346 "EHLO
	mail-qg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030643AbaGRSqX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jul 2014 14:46:23 -0400
Received: by mail-qg0-f66.google.com with SMTP id a108so914825qge.5
        for <linux-nfs@vger.kernel.org>; Fri, 18 Jul 2014 11:46:20 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 18 Jul 2014 14:46:16 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 01/10] nfsd: Protect the nfs4_file delegation fields
 using the fi_lock
Message-ID: <20140718144616.0bc1d806@tlielax.poochiereds.net>
In-Reply-To: <20140718155402.GA23745@infradead.org>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
	<1405696416-32585-2-git-send-email-jlayton@primarydata.com>
	<20140718155402.GA23745@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 18 Jul 2014 08:54:02 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> > +out_unlock:
> > +	spin_unlock(&fp->fi_lock);
> > +	spin_unlock(&state_lock);
> > +out_fput:
> > +	if (filp)
> > +		fput(filp);
> 
> I don't think fput can be NULL here.
> 

Correct. I'll fix that...

> >  static int nfs4_set_delegation(struct nfs4_delegation *dp, struct nfs4_file *fp)
> >  {
> > +	int status = 0;
> > +
> >  	if (fp->fi_had_conflict)
> >  		return -EAGAIN;
> >  	get_nfs4_file(fp);
> > +	spin_lock(&state_lock);
> > +	spin_lock(&fp->fi_lock);
> >  	dp->dl_file = fp;
> > +	if (!fp->fi_lease) {
> > +		spin_unlock(&fp->fi_lock);
> > +		spin_unlock(&state_lock);
> >  		return nfs4_setlease(dp);
> > +	}
> >  	atomic_inc(&fp->fi_delegees);
> >  	if (fp->fi_had_conflict) {
> > +		status = -EAGAIN;
> > +		goto out_unlock;
> >  	}
> >  	hash_delegation_locked(dp, fp);
> > +out_unlock:
> > +	spin_unlock(&fp->fi_lock);
> >  	spin_unlock(&state_lock);
> > +	return status;
> 
> I have to admit that I didn't have time to go through all the
> surrounding code yet, but is there error handling correct here,
> i.e. no need to rop the file reference and cleanup dp->dl_file for any
> error or race case?
> 

No, we take a reference to the nfs4_file and then immediately set
dl_file. At that point, once we put the delegation's final reference it
will put the file reference.

So, I *think* the error handling is now correct, but please do sanity
check me on this if you're able.

-- 
Jeff Layton <jlayton@primarydata.com>
