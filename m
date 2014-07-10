Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:47284 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751117AbaGJRmQ convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jul 2014 13:42:16 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Trond Myklebust'" <trond.myklebust@primarydata.com>
Cc: "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>
References: <1405002343-15802-1-git-send-email-trond.myklebust@primarydata.com>	<03ba01cf9c52$93b3d000$bb1b7000$@mindspring.com> <CAHQdGtRmWxNsm59eXfVQGiOXO7cXfoV_R2X2UKqY1kJgST_6Nw@mail.gmail.com>
In-Reply-To: <CAHQdGtRmWxNsm59eXfVQGiOXO7cXfoV_R2X2UKqY1kJgST_6Nw@mail.gmail.com>
Subject: RE: [PATCH] NFSv4: Fix OPEN w/create access mode checking
Date: Thu, 10 Jul 2014 10:42:13 -0700
Message-ID: <03c301cf9c66$4931c730$db955590$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Thu, Jul 10, 2014 at 11:21 AM, Frank Filz <ffilzlnx@mindspring.com>
> wrote:
> > Ok, that should work, though what about the case where cinfo is not
> atomic?
> > Even if the server is able to do an atomic open/create, the cinfo
> > might still not be atomic, thus might give a false indication of file
> > create (it doesn't look like the client checks for cinfo.atomic.
> >
> > The result would be that in a busy directory, you COULD call
> > open("some-execute-only-file", O_CREAT | O_RDONLY, 0) to get read
> > access to an execute only file...
> >
> > Ganesha for one can't guarantee atomicity (we can't create a file AND
> > get an updated cinfo from the kernel in a single operation...). So if
> > a check for cinfo.atomic is put in place, the exception would be
> > skipped. (It looks like knfsd may also always set cinfo.atomic to
> > false). Currently, it looks like the only use of file_created is to
> > set FILE_CREATED, and it looks like the only real use of that is to
> > call fsnotify_create, which if that happens to be called for a file that actually
> already existed, would not be horrendous.
> >
> > To cut to the chase, this patch should make all of my tests pass
> > (which my patch in truth did not do), and also for the cases you
> > suggested is correct, suggests this patch is more correct than mine,
> > but might still not be 100% correct...
> 
> Agreed, but it is a best effort. There is nothing other than the cinfo available
> to the client to tell it if the file was just created or not.

Good point. And I guess the only pitfall is that someone could manage to read an execute only file that happens to be in a directory that is busy enough to cause an apparent cinfo change. Such an enterprising person could figure out other ways to read an execute only file (extracting the file data from a network trace, or a custom client).

My tests pass, so consider that an ack for your patch, thanks.

Frank

> > Frank
> >
> >> POSIX states that open("foo", O_CREAT|O_RDONLY, 000) should succeed
> >> if the file "foo" does not already exist. With the current NFS
> >> client, it
> > will fail
> >> with an EACCES error because of the permissions checks in
> >> nfs4_opendata_access().
> >>
> >> Fix is to turn that test off if the server says that we created the file.
> >>
> >> Reported-by: "Frank S. Filz" <ffilzlnx@mindspring.com>
> >> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> >> ---
> >>  fs/nfs/nfs4proc.c | 18 +++++++++++++-----
> >>  1 file changed, 13 insertions(+), 5 deletions(-)
> >>
> >> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c index
> >> d0e0e54fb2b9..70e53a2ac75e 100644
> >> --- a/fs/nfs/nfs4proc.c
> >> +++ b/fs/nfs/nfs4proc.c
> >> @@ -1954,6 +1954,14 @@ static int _nfs4_recover_proc_open(struct
> >> nfs4_opendata *data)
> >>       return status;
> >>  }
> >>
> >> +/*
> >> + * Additional permission checks in order to distinguish between an
> >> + * open for read, and an open for execute. This works around the
> >> + * fact that NFSv4 OPEN treats read and execute permissions as being
> >> + * the same.
> >> + * Note that in the non-execute case, we want to turn off permission
> >> + * checking if we just created a new file (POSIX open() semantics).
> >> + */
> >>  static int nfs4_opendata_access(struct rpc_cred *cred,
> >>                               struct nfs4_opendata *opendata,
> >>                               struct nfs4_state *state, fmode_t
> >> fmode, @@ -1968,14 +1976,14 @@ static int nfs4_opendata_access(struct
> >> rpc_cred *cred,
> >>               return 0;
> >>
> >>       mask = 0;
> >> -     /* don't check MAY_WRITE - a newly created file may not have
> >> -      * write mode bits, but POSIX allows the creating process to write.
> >> -      * use openflags to check for exec, because fmode won't
> >> -      * always have FMODE_EXEC set when file open for exec. */
> >> +     /*
> >> +      * Use openflags to check for exec, because fmode won't
> >> +      * always have FMODE_EXEC set when file open for exec.
> >> +      */
> >>       if (openflags & __FMODE_EXEC) {
> >>               /* ONLY check for exec rights */
> >>               mask = MAY_EXEC;
> >> -     } else if (fmode & FMODE_READ)
> >> +     } else if ((fmode & FMODE_READ) && !opendata->file_created)
> >>               mask = MAY_READ;
> >>
> >>       cache.cred = cred;
> >> --
> >> 1.9.3
> >
> 
> 
> 
> --
> Trond Myklebust
> 
> Linux NFS client maintainer, PrimaryData
> 
> trond.myklebust@primarydata.com

