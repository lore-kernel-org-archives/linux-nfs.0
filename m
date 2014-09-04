Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:65296 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbaIDMtl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 08:49:41 -0400
Received: by mail-qg0-f42.google.com with SMTP id q107so840395qgd.29
        for <linux-nfs@vger.kernel.org>; Thu, 04 Sep 2014 05:49:40 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 4 Sep 2014 08:49:38 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Steven Whitehouse <swhiteho@redhat.com>,
        cluster-devel <cluster-devel@redhat.com>
Subject: Re: [PATCH v2 01/17] locks: consolidate "nolease" routines
Message-ID: <20140904084938.2664bf0a@tlielax.poochiereds.net>
In-Reply-To: <CAHQdGtTqG8aW-cte2PW6pVw+OeCXATgr1BZwdhponuWMjzNg8g@mail.gmail.com>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
	<1409834323-7171-2-git-send-email-jlayton@primarydata.com>
	<CAHQdGtTqG8aW-cte2PW6pVw+OeCXATgr1BZwdhponuWMjzNg8g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 4 Sep 2014 08:41:51 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Thu, Sep 4, 2014 at 8:38 AM, Jeff Layton <jlayton@primarydata.com> wrote:
> > GFS2 and NFS have setlease routines that always just return -EINVAL.
> > Turn that into a generic routine that can live in fs/libfs.c.
> >
> > Cc: Trond Myklebust <trond.myklebust@primarydata.com>
> > Cc: <linux-nfs@vger.kernel.org>
> > Cc: Steven Whitehouse <swhiteho@redhat.com>
> > Cc: <cluster-devel@redhat.com>
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  fs/gfs2/file.c     | 22 +---------------------
> >  fs/libfs.c         | 16 ++++++++++++++++
> >  fs/nfs/file.c      | 13 +------------
> >  fs/nfs/internal.h  |  1 -
> >  fs/nfs/nfs4file.c  |  2 +-
> >  include/linux/fs.h |  1 +
> >  6 files changed, 20 insertions(+), 35 deletions(-)
> 
> Acked-by: Trond Myklebust <trond.myklebust@primarydata.com>
> 

Thanks. While spinning this up, I did have a momentary pause to wonder
if -ENOLCK would be a better return value here.

It would make it easier to distinguish this from from "oops, I passed
in bogus arguments". For now, I'll leave it as -EINVAL, but it's
something to consider...

-- 
Jeff Layton <jlayton@primarydata.com>
