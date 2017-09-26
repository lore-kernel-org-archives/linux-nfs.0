Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54016 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934627AbdIZNZx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Sep 2017 09:25:53 -0400
Date: Tue, 26 Sep 2017 09:25:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Corentin Labbe <clabbe.montjoie@gmail.com>,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 0/3] nfs_common: misc patchs
Message-ID: <20170926132553.GA25286@fieldses.org>
References: <20170926071407.31719-1-clabbe.montjoie@gmail.com>
 <1506424509.3182.0.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1506424509.3182.0.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 26, 2017 at 07:15:09AM -0400, Jeff Layton wrote:
> On Tue, 2017-09-26 at 09:14 +0200, Corentin Labbe wrote:
> > Hello
> > 
> > The origin of this series is a build warning fix.
> > But reading the code show me two other possible patch.
> > 
> > Regards
> > 
> > Corentin Labbe (3):
> >   nfs_common: fix build warning in grace.c
> >   nfs_common: move locks_in_grace comment at the right place
> >   nfs_common: convert int to bool
> > 
> >  fs/nfs_common/grace.c | 24 ++++++++++++------------
> >  include/linux/fs.h    |  4 ++--
> >  2 files changed, 14 insertions(+), 14 deletions(-)
> > 
> 
> Looks like a reasonable set of cleanups. Probably fine for v4.15?
> 
> Reviewed-by: Jeff Layton <jlayton@redhat.com>

Yep, applying, thanks.

--b.
