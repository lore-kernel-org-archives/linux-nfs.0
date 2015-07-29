Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36682 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754053AbbG2Vsg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Jul 2015 17:48:36 -0400
Date: Thu, 30 Jul 2015 07:48:24 +1000
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 1/9 v8] fs_pin: Initialize value for fs_pin explicitly
Message-ID: <20150730074824.6b7faedd@noble>
In-Reply-To: <20150729194155.GC21949@fieldses.org>
References: <55B5A012.1030006@gmail.com>
	<55B5A04D.8090905@gmail.com>
	<20150729102519.16f2f70d@noble>
	<20150729194155.GC21949@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 29 Jul 2015 15:41:55 -0400 "J. Bruce Fields"
<bfields@fieldses.org> wrote:

> On Wed, Jul 29, 2015 at 10:25:19AM +1000, NeilBrown wrote:
> > On Mon, 27 Jul 2015 11:06:53 +0800 Kinglong Mee <kinglongmee@gmail.com>
> > wrote:
> > 
> > > Without initialized, done in fs_pin at stack space may
> > > contains strange value.
> > > 
> > > v8, same as v3
> > > Adds macro for header file
> > > 
> > > Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> > 
> > Reviewed-by: NeilBrown <neilb@suse.com>
> > 
> > It would be really good if some of these early patches could be applied
> > to the relevant trees so they appear in -next and we only need to keep
> > reviewing the more interesting code at the end.
> 
> This patch seems a little bikeshed-y.  I'd rather just drop it or save
> it for some other day.  It's not necessary to the series.

???

I accept that:


> > > @@ -1,3 +1,6 @@
> > > +#ifndef _LINUX_FS_PIN_H
> > > +#define _LINUX_FS_PIN_H
> > > +
> > >  #include <linux/wait.h>

could be a little bike-shed-y, not that I've seen much bike shedding
going on.

However:
> > >  
> > >  struct fs_pin {
> > > @@ -16,9 +19,12 @@ static inline void init_fs_pin(struct fs_pin *p, void (*kill)(struct fs_pin *))
> > >  	INIT_HLIST_NODE(&p->s_list);
> > >  	INIT_HLIST_NODE(&p->m_list);
> > >  	p->kill = kill;
> > > +	p->done = 0;
> > >  }
> > >  

is quite important.
Without that assignment we would probably need to rename the function to
   init_most_of_fs_pin
or
   init_fs_pin_if_already_zeroed
or maybe just
   __init_fs_pin
with the time honoured interpretation that it sort-of does what the
name says, but maybe not exactly how you think and please use with care.

Then in nfsd code we would need to add the assignment ourselves, or use
kzalloc where it would otherwise be completely unnecessary.


Thanks for accepting the other patches!

NeilBrown

