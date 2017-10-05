Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43037 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750965AbdJEOua (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Oct 2017 10:50:30 -0400
Date: Thu, 5 Oct 2017 16:50:27 +0200
From: Jan Kara <jack@suse.cz>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "jack@suse.cz" <jack@suse.cz>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>
Subject: Re: Why is NFS using a_ops->freepage?
Message-ID: <20171005145027.GA31299@quack2.suse.cz>
References: <20171005083657.GA28132@quack2.suse.cz>
 <1507210761.20822.2.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1507210761.20822.2.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu 05-10-17 13:39:23, Trond Myklebust wrote:
> Hi Jan,
> 
> On Thu, 2017-10-05 at 10:36 +0200, Jan Kara wrote:
> > Hello,
> > 
> > I'm doing some work in page cache handling and I have noticed that
> > NFS is
> > the only user of mapping->a_ops->freepage callback. From a quick look
> > I
> > don't see why isn't NFS using ->releasepage / ->invalidatepage
> > callback as
> > all other filesystems do? I agree you would have to set PagePrivate
> > bit for
> > those to get called for the directory mapping however that would seem
> > like
> > a cleaner thing to do anyway - in fact you do have private data in
> > the
> > page.  Just they are not pointed to by page->private but instead are
> > stored
> > as page data... Am I missing something?
> > 
> > 								Honza
> 
> I'm not understanding your point. delete_from_page_cache() doesn't call
> releasepage AFAICS.

No, but before getting to delete_from_page_cache() the filesystem is
guaranteed to get either ->invalidatepage or ->releasepage callback called
(if it defines them). And at that point the page is already locked and on
its way to be destroyed. So my point was you could use these callbacks
instead to achieve the same...

If you are afraid of races, I don't think those can happen for NFS. Page
can be destroyed either because of truncate - at that point there's no risk
of anyone else looking at that page for directories (i_rwsem) - or because
of page reclaim - at which point we are guaranteed nobody else holds a
reference to the page and new reference cannot be acquired.


								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
