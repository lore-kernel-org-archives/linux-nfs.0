Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:36426 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221AbbCWPaO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Mar 2015 11:30:14 -0400
Received: by yhjf44 with SMTP id f44so70233562yhj.3
        for <linux-nfs@vger.kernel.org>; Mon, 23 Mar 2015 08:30:13 -0700 (PDT)
Date: Mon, 23 Mar 2015 11:30:08 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: trond.myklebust@primarydata.com, hch@infradead.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] nfsd: fix use-after-free oops in v4.0 (and some
 other minor cleanups)
Message-ID: <20150323113008.6992a961@tlielax.poochiereds.net>
In-Reply-To: <20150323151257.GA15183@fieldses.org>
References: <1427122424-8078-1-git-send-email-jeff.layton@primarydata.com>
	<20150323151257.GA15183@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 23 Mar 2015 11:12:57 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Mar 23, 2015 at 10:53:41AM -0400, Jeff Layton wrote:
> > After staring at this code for a _long_ time, I think I've finally found
> > the source of the use-after-free oops that HCH spotted. The first patch
> > in this series should fix that.  The other two patches are just cleanups
> > that I generated while staring at the code.
> > 
> > The first one obviously needs to go into v4.0 (and stable) ASAP. The
> > other two can wait for v4.1.
> 
> Zowie, thanks!  It's a relief to have this one found....--b.
> 

Definitely a relief. Just to reiterate what you spotted on IRC too, it
looks like there's a similar bug in alloc_init_lock_stateowner so we'll
need a patch for that as well.

> > 
> > Jeff Layton (3):
> >   nfsd: return correct openowner when there is a race to put one in the
> >     hash
> >   nfsd: remove bogus setting of status in nfsd4_process_open2
> >   nfsd: remove unused status arg to nfsd4_cleanup_open_state
> > 
> >  fs/nfsd/nfs4proc.c  | 2 +-
> >  fs/nfsd/nfs4state.c | 5 ++---
> >  fs/nfsd/xdr4.h      | 2 +-
> >  3 files changed, 4 insertions(+), 5 deletions(-)
> > 
> > -- 
> > 2.1.0
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Jeff Layton <jlayton@poochiereds.net>
