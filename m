Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56329 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752725Ab2DZPw5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 11:52:57 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAH2r5mv1Lijdwk5zsQwYJr4Etb6fhrRyNXm-iFCQX+HecboGrQ@mail.gmail.com>
References: <CAH2r5mv1Lijdwk5zsQwYJr4Etb6fhrRyNXm-iFCQX+HecboGrQ@mail.gmail.com> <20120419140558.17272.74360.stgit@warthog.procyon.org.uk> <CAH2r5ms4WQV3DnTvqNN=2N71Cj8UHwj8Z6+RHXgrAOv6mSoyQg@mail.gmail.com> <20656.1335450358@redhat.com>
To: Steve French <smfrench@gmail.com>
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-ext4@vger.kernel.org,
        wine-devel@winehq.org, kfm-devel@kde.org, nautilus-list@gnome.org,
        linux-api@vger.kernel.org, libc-alpha@sourceware.org
Subject: Re: [PATCH 0/6] Extended file stat system call
Date: Thu, 26 Apr 2012 16:52:15 +0100
Message-ID: <24787.1335455535@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve French <smfrench@gmail.com> wrote:

> >> Would it be better to make the stable vs volatile inode number an attribute
> >> of the volume or something returned by the proposed xstat?
> >
> > I'm not sure what you mean by a stable vs a volatile inode number.
> 
> Both NFS and CIFS (and SMB2) can return inode numbers or equivalent unique
> identifier, but in the case of CIFS some old servers don't support the calls
> which return inode numbers (or don't return them for all file system types,
> Windows FAT?) so in these cases cifs has to create inode numbers on the fly
> on the client.  inode numbers created on the client are not "stable" they can
> change on unmount/remount (which can cause problems for backup applications).

In the volatile case you'd probably want to unset XSTAT_INO in st_mask as the
inode number is a local fabrication.  However, since there is a remote file ID,
we could add an XSTAT_INFO_FILE_ID flag to indicate there's a standard xattr
holding this.  On CIFS this could be the servername + pathname, on NFS this
could be the server address + FH on AFS the cell+volID+FID+uniquifier for
example.  That's independent of xstat, however, and wouldn't be returned as
it's a blob that could be quite large.

I presume in some cases, there is not a unique file ID that persists across
rename.

> Similarly NFSv4 does not require that servers always return stable inode
> numbers (that will never change) and introduced a concept of "volatile file
> handle."

Can I presume the inode number cannot be considered stable if the NFS4 FH is
non-volatile?  Furthermore, can I presume NFS2/3 inode numbers are supposed to
be stable?

> Basically the question is whether it is worth reporting a flag on the call
> which returns the inode number to indicate that the inode number is "stable"
> (would not change on reboot or reconnection) or "volatile."  Since the
> majority of NFS and SMB2 servers can return stable inode numbers, I don't
> feel strongly about the need for an indicator of "stable" vs. "volatile" but
> I mention it because backup and migration applications mention this (if inode
> numbers are volatile, they may have to check for hardlinks differently for
> example)

It may be that unsetting XSTAT_INO if you've fabricated the inode number
locally is sufficient.

> >> > Handle remote filesystems being offline and indicate this with
> >> > XSTAT_INFO_OFFLINE.
> >>
> >> You already have support for an indicator for offline files (HSM),

Which indicator is this?  Or do you mean XSTAT_INFO_OFFLINE?

> >> would XSTAT_INFO_OFFLINE be intended for the case
> >> where the network session to the server is disconnected
> >> (and in which you case the application does not want to reconnect)?
> >
> > Hmmm...  Interesting question.  Both NTFS and CIFS have an offline
> > attribute (which is where I originally got this from) - but should I have a
> > separate indicator to indicate the client can't access a server over a
> > network (ie. we've gone to disconnected operation on this file)?
> > E.g. should there be a XSTAT_INFO_DISCONNECTED too?
> 
> my reaction is no, since it adds complexity.  If you do a stat on a
> disconnected volume (where the network is temporarily down) reconnection will
> be attempted.  If reconnection fails then the xstat will either fail or be
> retried forever depending on the value of "hard" vs. "soft" mount flag.

I was thinking of how to handle disconnected operation, where you can't just
sit there and churn waiting for the server to come back or give an error.  On
the other hand, as long as there's some spare space in the struct, we can deal
with that later when we actually start to implement D/O.

David
