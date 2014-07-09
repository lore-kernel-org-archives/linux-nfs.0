Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-kukur.atl.sa.earthlink.net ([209.86.89.65]:55344 "EHLO
	elasmtp-kukur.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756693AbaGIWma convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jul 2014 18:42:30 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Trond Myklebust'" <trond.myklebust@primarydata.com>
Cc: "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>,
        "'Linux Kernel mailing list'" <linux-kernel@vger.kernel.org>
References: <1404942892-18323-1-git-send-email-ffilzlnx@mindspring.com> <CAHQdGtSUwScEdUeKT1w+-ynqNz-e1=YvDBtdu_k=_6yndFZSVQ@mail.gmail.com>
In-Reply-To: <CAHQdGtSUwScEdUeKT1w+-ynqNz-e1=YvDBtdu_k=_6yndFZSVQ@mail.gmail.com>
Subject: RE: [PATCH 1/1] Fix permission checking by NFS client for open-create with mode 000
Date: Wed, 9 Jul 2014 15:42:22 -0700
Message-ID: <033801cf9bc7$0d7ee190$287ca4b0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Wed, Jul 9, 2014 at 5:54 PM, Frank S. Filz <ffilzlnx@mindspring.com>
> wrote:
> > From: "Frank S. Filz" <ffilzlnx@mindspring.com>
> >
> > The NFS v4 client sends a COMPOUND with an OPEN and an ACCESS.
> >
> > The ACCESS is required to verify an open for read is actually allowed
> > because RFC 3530 indicates OPEN for read only must succeed for an
> > execute only file.
> >
> > The old code expected to have read access if the requested access was
> > O_RDWR.
> >
> > We can expect the OPEN to properly permission check as long as the
> > open is O_WRONLY or O_RDWR.
> >
> > Signed-off-by: Frank S. Filz <ffilzlnx@mindspring.com>
> > ---
> >  fs/nfs/nfs4proc.c | 25 ++++++++++++++++++++-----
> >  1 file changed, 20 insertions(+), 5 deletions(-)
> >
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c index
> > 4bf3d97..9742054 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -1966,15 +1966,30 @@ static int nfs4_opendata_access(struct
> rpc_cred *cred,
> >                 return 0;
> >
> >         mask = 0;
> > -       /* don't check MAY_WRITE - a newly created file may not have
> > -        * write mode bits, but POSIX allows the creating process to write.
> > -        * use openflags to check for exec, because fmode won't
> > -        * always have FMODE_EXEC set when file open for exec. */
> > +       /* Don't trust the permission check on OPEN if open for exec or for
> > +        * read only. Since FMODE_EXEC doesn't go across the wire, the server
> > +        * has no way to distinguish between an open to read an executable
> file
> > +        * and an open to read a readable file. Write access is properly checked
> > +        * and permission SHOULD always be granted if the file was created as
> a
> > +        * result of this OPEN, no matter what mode the file was created with.
> > +        *
> > +        * NOTE: If the case of a OPEN CREATE READ-ONLY with a mode that
> does
> > +        *       not allow read access, this test will produce an incorrect
> > +        *       EACCES error.
> > +        */
> >         if (openflags & __FMODE_EXEC) {
> >                 /* ONLY check for exec rights */
> >                 mask = MAY_EXEC;
> > -       } else if (fmode & FMODE_READ)
> > +       } else if (!(fmode & FMODE_WRITE)) {
> > +               /* In case the file was execute only, check for read permission
> > +                * ONLY if write access was not requested. It is expected that
> > +                * an OPEN for write will fail if the file is execute only.
> > +                * Note that if the file was newly created, the fmode SHOULD
> > +                * include FMODE_WRITE, especially if the file will be created
> > +                * with a restrictive mode.
> > +                */
> >                 mask = MAY_READ;
> > +       }
> 
> This looks wrong. AFAICS it will allow you to open an existing file which has -
> wx permissions (i.e. no read permissions) for O_RDWR. That should not be
> permitted under POSIX rules.

The server permission checks the OPEN, this only affects the subsequent ACCESS.

The server will fail the OPEN with NFS4_ERR_ACCESS if the open is for read/write and the file has write-execute permission.

See the test program I subsequently posted. The program demonstrates that open O_RDWR on a mode=0333 file fails as expected. (Tested on both Ganesha and knfsd).

Frank


