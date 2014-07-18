Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f65.google.com ([209.85.192.65]:55862 "EHLO
	mail-qg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935058AbaGRRXo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jul 2014 13:23:44 -0400
Received: by mail-qg0-f65.google.com with SMTP id z60so899760qgd.0
        for <linux-nfs@vger.kernel.org>; Fri, 18 Jul 2014 10:23:43 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 18 Jul 2014 13:23:41 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 09/10] nfsd: clean up nfs4_set_delegation
Message-ID: <20140718132341.3be55ad1@f20.localdomain>
In-Reply-To: <20140718171930.GA12375@infradead.org>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
	<1405696416-32585-10-git-send-email-jlayton@primarydata.com>
	<20140718171930.GA12375@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 18 Jul 2014 10:19:30 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> > +nfs4_set_delegation(struct nfs4_client *clp, struct svc_fh *fh,
> > +		    struct nfs4_file *fp)
> >  {
> > -	int status = 0;
> > +	int status;
> > +	struct nfs4_delegation *dp;
> >  
> >  	if (fp->fi_had_conflict)
> > -		return -EAGAIN;
> > +		return ERR_PTR(-EAGAIN);
> > +
> > +	dp = alloc_init_deleg(clp, fh);
> > +	if (!dp)
> > +		return ERR_PTR(-ENOMEM);
> > +
> >  	get_nfs4_file(fp);
> 
> Seems like we should pass the file pointer to alloc_init_deleg as well
> so it can set that one one up and grab the reference without any lock?
> 
> Otherwise looks good,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

I actually started to do a patch that did that, but the error handling
turned out to be a little twisted. Might be reasonable for a future
cleanup though.

-- 
Jeff Layton <jlayton@primarydata.com>
