Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f179.google.com ([209.85.216.179]:35226 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932399AbaLLTAn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Dec 2014 14:00:43 -0500
Received: by mail-qc0-f179.google.com with SMTP id c9so5878570qcz.38
        for <linux-nfs@vger.kernel.org>; Fri, 12 Dec 2014 11:00:42 -0800 (PST)
Date: Fri, 12 Dec 2014 14:00:39 -0500
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Thomas Haynes <thomas.haynes@primarydata.com>
Subject: Re: [PATCH] nfs: guard fs/nfs/internal.h against multiple inclusion
Message-ID: <20141212140039.11995450@tlielax.poochiereds.net>
In-Reply-To: <CAHQdGtSvzyUqrO7yoZPAHBTb7pU-GJtvhQoXvdNONmo4LtfE+w@mail.gmail.com>
References: <1418395818-22062-1-git-send-email-jlayton@primarydata.com>
	<20141212095804.675912b9@tlielax.poochiereds.net>
	<CAHQdGtRVUR9K=phK=kQtMvE+0tStBUhocuzqBGTC2psr6_mhmA@mail.gmail.com>
	<CAHQdGtSvzyUqrO7yoZPAHBTb7pU-GJtvhQoXvdNONmo4LtfE+w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 12 Dec 2014 13:58:10 -0500
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Fri, Dec 12, 2014 at 10:50 AM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
> > On Fri, Dec 12, 2014 at 9:58 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
> >> On Fri, 12 Dec 2014 09:50:18 -0500
> >> Jeff Layton <jlayton@primarydata.com> wrote:
> >>
> >>> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> >>> Cc: Thomas Haynes <thomas.haynes@primarydata.com>
> >>> ---
> >>>  fs/nfs/internal.h | 4 ++++
> >>>  1 file changed, 4 insertions(+)
> >>>
> >>> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> >>> index efaa31c70fbe..ffef459f0b4f 100644
> >>> --- a/fs/nfs/internal.h
> >>> +++ b/fs/nfs/internal.h
> >>> @@ -1,6 +1,8 @@
> >>>  /*
> >>>   * NFS internal definitions
> >>>   */
> >>> +#ifndef      __FS_NFS_INTERNAL_H
> >>
> >> Gyah...sorry for the whitespace typo above. Want me to resend with that
> >> tab turned into a space?
> >
> > That's OK. I'll manage somehow :-)
> >
> >>> +#define __FS_NFS_INTERNAL_H
> >>>
> >>>  #include "nfs4_fs.h"
> >>>  #include <linux/mount.h>
> >>> @@ -629,3 +631,5 @@ static inline u32 nfs_fhandle_hash(const struct nfs_fh *fh)
> >>>       return 0;
> >>>  }
> >>>  #endif
> >>> +
> >>> +#endif       /* __FS_NFS_INTERNAL_H */
> >>
> >>
> >> --
> >> Jeff Layton <jlayton@poochiereds.net>
> >
> 
> So, having rethought this a little, I think I'd prefer to keep the
> current status. Right now, we catch all instances of someone
> incorrectly including this file in another header by virtue of the
> fact that the duplicate include will cause a compile error.
> 

Fair enough. The problem that we saw with it turns out to be a bug in a
different patch under development so it's not really required.

Thanks,
-- 
Jeff Layton <jlayton@poochiereds.net>
