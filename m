Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f172.google.com ([209.85.160.172]:36568 "EHLO
	mail-yk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076AbbG3QUy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jul 2015 12:20:54 -0400
Received: by ykay190 with SMTP id y190so38044062yka.3
        for <linux-nfs@vger.kernel.org>; Thu, 30 Jul 2015 09:20:53 -0700 (PDT)
Date: Thu, 30 Jul 2015 12:20:48 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: do nfs4_check_fh in nfs4_check_file instead of
 nfs4_check_olstateid
Message-ID: <20150730122048.3ec42317@tlielax.poochiereds.net>
In-Reply-To: <20150730155135.GB1073@infradead.org>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
	<1438264341-18048-2-git-send-email-jeff.layton@primarydata.com>
	<20150730155135.GB1073@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 30 Jul 2015 08:51:35 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> >  		return status;
> > @@ -4628,6 +4625,10 @@ nfs4_check_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct nfs4_stid *s,
> >  	struct file *file;
> >  	__be32 status;
> >  
> > +	status = nfs4_check_fh(fhp, s);
> > +	if (status)
> > +		return status;
> > +
> 
> This means we check the file handle for all stateids now, not just
> open and lock stateids.  That seems reasonable to me but should be
> mentioned in the changelog.

This code is only called from nfs4_preprocess_stateid_op (which I
typoed in the changelog -- maybe Bruce can fix that). Anything other
than an open, lock or delegation stateid is explicitly rejected before
this point.

So, this just adds this check to delegation stateids (which is
necessary I think). That is mentioned in the changelog though. Do you
think it needs more elaboration or is that sufficient?

-- 
Jeff Layton <jlayton@poochiereds.net>
