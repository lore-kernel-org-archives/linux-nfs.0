Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f49.google.com ([209.85.192.49]:33845 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbaGVRxP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jul 2014 13:53:15 -0400
Received: by mail-qg0-f49.google.com with SMTP id j107so1130qga.22
        for <linux-nfs@vger.kernel.org>; Tue, 22 Jul 2014 10:53:14 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 22 Jul 2014 13:53:12 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        hch@infradead.org
Subject: Re: [PATCH 0/4] nfsd: don't let nfs4_file pin down the inode when
 it has no open state
Message-ID: <20140722135312.33d5b7aa@tlielax.poochiereds.net>
In-Reply-To: <20140722175155.GB27277@fieldses.org>
References: <1406047784-1578-1-git-send-email-jlayton@primarydata.com>
	<20140722175155.GB27277@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 22 Jul 2014 13:51:55 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Jul 22, 2014 at 12:49:40PM -0400, Jeff Layton wrote:
> > This is a port of the patches that Trond sent last night onto the
> > current tip of Bruce's for-3.17 branch. It basically changes how
> > nfs4_file objects are hashed. Instead of using the inode pointer (and
> > pinning down an inode in the process), it uses the filehandle. This
> > allows us to avoid taking an inode reference directly for the nfs4_file.
> > It now only takes them indirectly by virtue of struct file objects in
> > the fi_fds array.
> 
> Looks reasonable on a quick skim.
> 
> It might make sense to get rid of dl_fh at some point?
> 
> --b.
> 

Yeah, I think that should be doable. I'll look at rolling that into the
delegation patches.


> > 
> > If this looks good, I'll resend the unmerged delegation overhaul
> > patches, rebased on top of this series.
> > 
> > Trond Myklebust (4):
> >   nfsd: Store the filehandle with the struct nfs4_file
> >   nfsd: Use the filehandle to look up the struct nfs4_file instead of
> >     inode
> >   nfsd: nfs4_check_fh - make it actually check the filehandle
> >   nfsd: Do not let nfs4_file pin the struct inode
> > 
> >  fs/nfsd/nfs4state.c | 68 +++++++++++++++++++++++++++++++----------------------
> >  fs/nfsd/state.h     |  3 ++-
> >  2 files changed, 42 insertions(+), 29 deletions(-)
> > 
> > -- 
> > 1.9.3
> > 


-- 
Jeff Layton <jlayton@primarydata.com>
