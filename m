Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f43.google.com ([209.85.216.43]:49243 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691AbbAIQvf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jan 2015 11:51:35 -0500
Received: by mail-qa0-f43.google.com with SMTP id v10so2748086qac.2
        for <linux-nfs@vger.kernel.org>; Fri, 09 Jan 2015 08:51:34 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 9 Jan 2015 08:51:30 -0800
To: Christoph Hellwig <hch@lst.de>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com,
        thomas.haynes@primarydata.com, trond.myklebust@primarydata.com,
        Sachin Bhamare <sachin.bhamare@primarydata.com>
Subject: Re: [PATCH 09/18] nfsd: implement pNFS operations
Message-ID: <20150109085130.0f862d24@synchrony.poochiereds.net>
In-Reply-To: <20150109100551.GA23173@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
	<1420561721-9150-10-git-send-email-hch@lst.de>
	<20150108164851.03b64e16@synchrony.poochiereds.net>
	<20150109100551.GA23173@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 9 Jan 2015 11:05:51 +0100
Christoph Hellwig <hch@lst.de> wrote:

> On Thu, Jan 08, 2015 at 04:48:51PM -0800, Jeff Layton wrote:
> > > +	nfsd4_return_all_file_layouts(stp->st_stateowner->so_client,
> > > +				      stp->st_stid.sc_file);
> > > +
> > 
> > Shouldn't the above be conditional on whether the lg_roc was true?
> 
> There is no support for non-lg_roc layouts at the moment.
> 
> In general I've avoided adding code that isn't used, as they can't
> be tested and thus most likely won't work.

Ok, it'd be good to document that in some comments then for the sake of
posterity (maybe it is later in the set -- I haven't gotten to the end
yet).

Now, that said...I think that your ROC semantics are wrong here. You
also have to take delegations into account. [1]

Basically the semantics that you want are that nfsd should do all of
the ROC stuff on last close iff there are no outstanding delegations or
on delegreturn iff there are no opens.

What we ended up doing in the unreleased code we have was to create a
new per-client and per-file object (that we creatively called an
"odstate"). An open stateid and a delegation stateid would hold a
reference to this object which is put when those stateids are freed.
When its refcount goes to zero, then we'd free any outstanding layouts
on the file for that client and free the object.

You probably want to do something similar here.

[1]: Tom and Trond mentioned that there's a RFC5661 errata pending for
     this, but I don't see it right offhand.

-- 
Jeff Layton <jlayton@primarydata.com>
