Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:36987 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751803AbbAIRQp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Jan 2015 12:16:45 -0500
Date: Fri, 9 Jan 2015 18:16:41 +0100
From: Christoph Hellwig <hch@lst.de>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com,
        thomas.haynes@primarydata.com, trond.myklebust@primarydata.com,
        Sachin Bhamare <sachin.bhamare@primarydata.com>
Subject: Re: [PATCH 09/18] nfsd: implement pNFS operations
Message-ID: <20150109171641.GA17464@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de> <1420561721-9150-10-git-send-email-hch@lst.de> <20150108164851.03b64e16@synchrony.poochiereds.net> <20150109100551.GA23173@lst.de> <20150109085130.0f862d24@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150109085130.0f862d24@synchrony.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 09, 2015 at 08:51:30AM -0800, Jeff Layton wrote:
> Ok, it'd be good to document that in some comments then for the sake of
> posterity (maybe it is later in the set -- I haven't gotten to the end
> yet).

What kinds of comments do you expect?  Not implementing unused features
of a protocol should be the default for anything in Linux.

> Now, that said...I think that your ROC semantics are wrong here. You
> also have to take delegations into account. [1]
> 
> Basically the semantics that you want are that nfsd should do all of
> the ROC stuff on last close iff there are no outstanding delegations or
> on delegreturn iff there are no opens.
> 
> What we ended up doing in the unreleased code we have was to create a
> new per-client and per-file object (that we creatively called an
> "odstate"). An open stateid and a delegation stateid would hold a
> reference to this object which is put when those stateids are freed.
> When its refcount goes to zero, then we'd free any outstanding layouts
> on the file for that client and free the object.
> 
> You probably want to do something similar here.
> 
> [1]: Tom and Trond mentioned that there's a RFC5661 errata pending for
>      this, but I don't see it right offhand.

It would be good to look at the errata.  While the idea of keeping
layouts around longer makes sense, I would only expect to do this
if they layout state was created based on a delegation stateid, not
a lock or open stateid.  In that case having the layouts hang off
the "parent" stateid might be another option.
