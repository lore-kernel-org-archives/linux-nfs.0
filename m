Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:42403 "EHLO
	elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750733AbaGJFWN convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jul 2014 01:22:13 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Trond Myklebust'" <trond.myklebust@primarydata.com>
Cc: "'Linux NFS Mailing List'" <linux-nfs@vger.kernel.org>,
        "'Linux Kernel mailing list'" <linux-kernel@vger.kernel.org>
References: <1404942892-18323-1-git-send-email-ffilzlnx@mindspring.com>	<CAHQdGtSUwScEdUeKT1w+-ynqNz-e1=YvDBtdu_k=_6yndFZSVQ@mail.gmail.com>	<033801cf9bc7$0d7ee190$287ca4b0$@mindspring.com>	<CAHQdGtQjCYV2jE7FGu-J+02xp25uaUUVv8uzcs5sfbKXBbVk6A@mail.gmail.com>	<CAHQdGtTkTh4MQJk6bec46OjsyZHnEGGws3b_2HA+kszzOHM-pw@mail.gmail.com>	<037801cf9bf7$1c039d20$540ad760$@mindspring.com> <CAHQdGtSmEO8pyw+1FMmQcRgHwRufedzLRwonksueWcFSf4cm8A@mail.gmail.com>
In-Reply-To: <CAHQdGtSmEO8pyw+1FMmQcRgHwRufedzLRwonksueWcFSf4cm8A@mail.gmail.com>
Subject: RE: [PATCH 1/1] Fix permission checking by NFS client for open-create with mode 000
Date: Wed, 9 Jul 2014 22:22:04 -0700
Message-ID: <037d01cf9bfe$e411e450$ac35acf0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> On Thu, Jul 10, 2014 at 12:26 AM, Frank Filz <ffilzlnx@mindspring.com>
> wrote:
> >> On Wed, Jul 9, 2014 at 7:06 PM, Trond Myklebust
> >> <trond.myklebust@primarydata.com> wrote:
> >> > On Wed, Jul 9, 2014 at 6:42 PM, Frank Filz
> >> > <ffilzlnx@mindspring.com>
> >> wrote:
> >> >>> On Wed, Jul 9, 2014 at 5:54 PM, Frank S. Filz
> >> >>> <ffilzlnx@mindspring.com>
> >> >>> wrote:
> >> >>> > From: "Frank S. Filz" <ffilzlnx@mindspring.com>
> >> >>> >
> >> >>> > The NFS v4 client sends a COMPOUND with an OPEN and an
> ACCESS.
> >> >>> >
> >> >>> > The ACCESS is required to verify an open for read is actually
> >> >>> > allowed because RFC 3530 indicates OPEN for read only must
> >> >>> > succeed for an execute only file.
> >> >>> >
> >> >>> > The old code expected to have read access if the requested
> >> >>> > access was O_RDWR.
> >> >>> >
> >> >>> > We can expect the OPEN to properly permission check as long as
> >> >>> > the open is O_WRONLY or O_RDWR.
> >> >>> >
> >> >>> > Signed-off-by: Frank S. Filz <ffilzlnx@mindspring.com>
> >> >>> > ---
> >> >>> >  fs/nfs/nfs4proc.c | 25 ++++++++++++++++++++-----
> >> >>> >  1 file changed, 20 insertions(+), 5 deletions(-)
> >> >>> >
> >> >>> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c index
> >> >>> > 4bf3d97..9742054 100644
> >> >>> > --- a/fs/nfs/nfs4proc.c
> >> >>> > +++ b/fs/nfs/nfs4proc.c
> >> >>> > @@ -1966,15 +1966,30 @@ static int nfs4_opendata_access(struct
> >> >>> rpc_cred *cred,
> >> >>> >                 return 0;
> >> >>> >
> >> >>> >         mask = 0;
> >> >>> > -       /* don't check MAY_WRITE - a newly created file may not have
> >> >>> > -        * write mode bits, but POSIX allows the creating process to
> write.
> >> >>> > -        * use openflags to check for exec, because fmode won't
> >> >>> > -        * always have FMODE_EXEC set when file open for exec. */
> >> >>> > +       /* Don't trust the permission check on OPEN if open for
> >> >>> > + exec or
> >> for
> >> >>> > +        * read only. Since FMODE_EXEC doesn't go across the
> >> >>> > + wire, the
> >> server
> >> >>> > +        * has no way to distinguish between an open to read an
> >> >>> > + executable
> >> >>> file
> >> >>> > +        * and an open to read a readable file. Write access is
> >> >>> > + properly
> >> checked
> >> >>> > +        * and permission SHOULD always be granted if the file
> >> >>> > + was created as
> >> >>> a
> >> >>> > +        * result of this OPEN, no matter what mode the file
> >> >>> > + was created
> >> with.
> >> >>> > +        *
> >> >>> > +        * NOTE: If the case of a OPEN CREATE READ-ONLY with a
> >> >>> > + mode that
> >> >>> does
> >> >>> > +        *       not allow read access, this test will produce an incorrect
> >> >>> > +        *       EACCES error.
> >> >>> > +        */
> >> >>> >         if (openflags & __FMODE_EXEC) {
> >> >>> >                 /* ONLY check for exec rights */
> >> >>> >                 mask = MAY_EXEC;
> >> >>> > -       } else if (fmode & FMODE_READ)
> >> >>> > +       } else if (!(fmode & FMODE_WRITE)) {
> >> >>> > +               /* In case the file was execute only, check for read
> permission
> >> >>> > +                * ONLY if write access was not requested. It is expected
> that
> >> >>> > +                * an OPEN for write will fail if the file is execute only.
> >> >>> > +                * Note that if the file was newly created, the fmode
> SHOULD
> >> >>> > +                * include FMODE_WRITE, especially if the file will be
> created
> >> >>> > +                * with a restrictive mode.
> >> >>> > +                */
> >> >>> >                 mask = MAY_READ;
> >> >>> > +       }
> >> >>>
> >> >>> This looks wrong. AFAICS it will allow you to open an existing
> >> >>> file which has - wx permissions (i.e. no read permissions) for
> O_RDWR.
> >> >>> That should not be permitted under POSIX rules.
> >> >>
> >> >> The server permission checks the OPEN, this only affects the
> >> >> subsequent
> >> ACCESS.
> >> >>
> >> >> The server will fail the OPEN with NFS4_ERR_ACCESS if the open is
> >> >> for
> >> read/write and the file has write-execute permission.
> >> >
> >> > RFC3530bis draft 33 (6.2.1.3.1.  Discussion of Mask Attributes)
> >> > states that for both the OPEN and the READ operations, "Servers
> >> > SHOULD allow a user the ability to read the data of the file when
> >> > only the ACE4_EXECUTE access mask bit is allowed". RFC5561 has the
> >> > same language.
> >>
> >> Oops. Sorry, the correct sub-sub-sub-sub-....paragraph is this one:
> >>
> >>          Permission to execute a file.
> >>
> >>          Servers SHOULD allow a user the ability to read the data of the
> >>          file when only the ACE4_EXECUTE access mask bit is allowed.
> >>          This is because there is no way to execute a file without
> >>          reading the contents.  Though a server may treat ACE4_EXECUTE
> >>          and ACE4_READ_DATA bits identically when deciding to permit a
> >>          READ operation, it SHOULD still allow the two bits to be set
> >>          independently in ACLs, and MUST distinguish between them when
> >>          replying to ACCESS operations.  In particular, servers SHOULD
> >>          NOT silently turn on one of the two bits when the other is set,
> >>          as that would make it impossible for the client to correctly
> >>          enforce the distinction between read and execute permissions.
> >>
> >>
> >> > To me that translates as saying that the server SHOULD accept an
> >> > OPEN(SHARE_ACCESS_READ|SHARE_ACCESS_WRITE) request in the
> above
> >> > situation.
> >>
> >> Same conclusion, though....
> >
> > When I read that paragraph, my interpretation is that OPEN (and READ)
> should be permission checked normally, however, if ONLY execute
> permission is granted, and the OPEN is read only (and READ of course is read
> only) then permission would be granted for the purpose of execution. But if
> any other combination of bits was allowed, then the paragraph doesn't
> apply. Thus an OPEN SHARE_ACCESS_READ | SHARE_ACCESS_WRITE must
> fail since write access was not granted (if it was, the exception doesn't apply
> to my reading).
> >
> 
> Where does that paragraph say anything about SHARE_WRITE, or even
> mention the word "only"?
> 
> All it says is that as far as the OPEN and READ operations are concerned,
> ACE4_EXECUTE == ACE4_READ_DATA, whereas for the ACCESS operation,
> they differ.

I'm reading the "only" in the first sentence:

"Servers SHOULD allow a user the ability to read the data of the file when only the ACE4_EXECUTE access mask bit is allowed."

But to entertain the idea that I'm reading too much into that sentence, let's go back to the situation:

File does not already exist
Application on client makes an open("/nfs4mnt/foo", O_CREAT | O_RDWR, 0) system call

What can we do between the server and client to assure success of that call. It works on local filesystems. It works over NFS v3. But it fails, at least with the Linux NFS v4 client.

With the Linux NFS v4 client, the following does succeed (because actual read access was granted):

open("/nfs4mnt/foo", O_CREAT | O_RDWR, 0400)

And the client can write to the file.

On the other hand, going back to my interpretation of the sentence, that is indeed the interpretation the Linux knfsd server is taking, because my little test case works as I expect it with the changes I proposed, in that and open("/nfs4mnt/foo", O_RDWR) fails even if the file has -wx------ permissions (and looking at wireshark traces, I see that indeed the OPEN fails if read permission is not granted, but execute permission is granted and write access was requested.

Ok, here is the relevant code from fs/nfsd/vfs.c:

        /* Allow read access to binaries even when mode 111 */
        if (err == -EACCES && S_ISREG(inode->i_mode) &&
             (acc == (NFSD_MAY_READ | NFSD_MAY_OWNER_OVERRIDE) ||
              acc == (NFSD_MAY_READ | NFSD_MAY_READ_IF_EXEC)))
                err = inode_permission(inode, MAY_EXEC);

So if the caller had requested write access, it does not check for MAY_EXEC.

Frank


