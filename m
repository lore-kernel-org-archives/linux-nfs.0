Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:49040 "EHLO
        mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751966AbdINKtD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Sep 2017 06:49:03 -0400
Received: by mail-qk0-f181.google.com with SMTP id a128so6278098qkc.5
        for <linux-nfs@vger.kernel.org>; Thu, 14 Sep 2017 03:49:03 -0700 (PDT)
Message-ID: <1505386139.4870.10.camel@redhat.com>
Subject: Re: [RFC PATCH manpages] write.2, fsync.2, close.2: update
 description of error codes
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.com>,
        "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jlayton@kernel.org" <jlayton@kernel.org>
Cc: linux-man@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Date: Thu, 14 Sep 2017 06:48:59 -0400
In-Reply-To: <87ingm9n04.fsf@notabene.neil.brown.name>
References: <20170720194227.7830-1-jlayton@kernel.org>
         <1503683981.22608.0.camel@redhat.com>
         <87h8wsiog4.fsf@notabene.neil.brown.name>
         <1503920855.4563.12.camel@redhat.com>
         <87pobfgo9q.fsf@notabene.neil.brown.name>
         <1504004058.4679.7.camel@redhat.com>
         <87efrjb2mn.fsf@notabene.neil.brown.name>
         <1504784132.4954.12.camel@redhat.com>
         <1504796087.3561.7.camel@primarydata.com>
         <874ls9diij.fsf@notabene.neil.brown.name>
         <1505126785.4916.7.camel@redhat.com>
         <87poawc390.fsf@notabene.neil.brown.name>
         <1505229616.28831.26.camel@redhat.com>
         <87efrbbne1.fsf@notabene.neil.brown.name>
         <1505305391.4822.13.camel@redhat.com>
         <87ingm9n04.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-09-14 at 09:50 +1000, NeilBrown wrote:
> Since 4.13, errors from writeback are more reliably reported
> to all file descriptors that might be relevant.
> 
> Add notes to this effect, and also add details about ENOSPC and EDQUOT
> which can be delayed in a similar manner to EIO - for NFS in particular.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> This is my summary of recent changes, and details that have been made
> clear during the exploration of those changes.
> 
> I haven't mentioned the fact that EPERM can be returned by
> write/fsync/close on NFS if the permissions on the server are changed.
> We probably should ... are there other errors that are worth mentioning
> along with EPERM, ENOSPC, EDQUOT ??
> 
> Thanks,
> NeilBronw
> 

Many thanks for doing this! It was on my to-do list. Comments below:

> 
>  man2/close.2 |  9 +++++++++
>  man2/fsync.2 | 19 ++++++++++++++++++-
>  man2/write.2 | 20 +++++++++++++++++---
>  3 files changed, 44 insertions(+), 4 deletions(-)
> 
> diff --git a/man2/close.2 b/man2/close.2
> index 751ec322b1f1..9776c839b8b6 100644
> --- a/man2/close.2
> +++ b/man2/close.2
> @@ -82,6 +82,15 @@ call was interrupted by a signal; see
>  .TP
>  .B EIO
>  An I/O error occurred.
> +.TP
> +.BR ENOSPC ", " EDQUOT
> +On NFS, these errors are not normally reported against the first write
> +which exceeds the available storage space, but instead against a
> +subsequent
> +.BR write (2),
> +.BR fsync (2),
> +or
> +.BR close (2).
>  .PP
>  See NOTES for a discussion of why
>  .BR close ()
> diff --git a/man2/fsync.2 b/man2/fsync.2
> index f1a01301da0f..e706a08d360d 100644
> --- a/man2/fsync.2
> +++ b/man2/fsync.2
> @@ -120,12 +120,29 @@ is set appropriately.
>  is not a valid open file descriptor.
>  .TP
>  .B EIO
> -An error occurred during synchronization.
> +An error occurred during synchronization.  This error may relate
> +to data written to some other file descriptor on the same file.
> +.\" commit 088737f44bbf6378745f5b57b035e57ee3dc4750
> +Since Linux 4.13 errors from write-back will be reported to
> +all file descriptors that might have written the data which triggered
> +the error, and which are still open.

This is a little awkward. How could we report to a fd that was no longer
open? How about:

"Since Linux 4.13, errors from write-back will be reported to all file
descriptors that were open at the time that the error was recorded."

>   Some filesystems (e.g. NFS)
> +keep close track of which data came through which file descriptor,
> +and give more precise reporting.  Other filesystems (e.g. most local
> +filesystems) will report errors to all file descriptors on the same
> +file.
>  .TP
>  .BR EROFS ", " EINVAL
>  .I fd
>  is bound to a special file (e.g., a pipe, FIFO, or socket)
>  which does not support synchronization.
> +.TP
> +.BR ENOSPC ", " EDQUOT
> +.I fd
> +is bound to a file on NFS or another filesystem which does not allocate
> +space at the time of a
> +.BR write (2)
> +system call, and some previous write failed due to insufficient
> +storage space.
>  .SH CONFORMING TO
>  POSIX.1-2001, POSIX.1-2008, 4.3BSD.
>  .SH AVAILABILITY
> diff --git a/man2/write.2 b/man2/write.2
> index 6a39b5b5541d..1a9a86b03b04 100644
> --- a/man2/write.2
> +++ b/man2/write.2
> @@ -47,7 +47,7 @@ write \- write to a file descriptor
>  .BR write ()
>  writes up to
>  .I count
> -bytes from the buffer pointed
> +bytes from the buffer starting at
>  .I buf
>  to the file referred to by the file descriptor
>  .IR fd .
> @@ -181,6 +181,14 @@ or the file offset is not suitably aligned.
>  .TP
>  .B EIO
>  A low-level I/O error occurred while modifying the inode.
> +This error may relate to data written by an earlier
> +.BR write (2),
> +which may have been issued to a different file descriptor on
> +the same file.  Since Linux 4.13 errors from write-back will
> +be reported to all file descriptors that might have
> +written the data which triggered the error, and which are still
> +open.


This is where things get a little more vague.

Some filesystems will return errors on a subsequent write(2) when
previous writeback has failed -- some don't. In either case though,
write(2) should never advance your errseq_t cursor, so only an fsync
will "clear" an earlier error.

I'm not sure how best to convey that in the manpages though.

> +.\" commit 088737f44bbf6378745f5b57b035e57ee3dc4750
>  .TP
>  .B ENOSPC
>  The device containing the file referred to by
> @@ -222,8 +230,14 @@ unsigned and signed integer data types specified by POSIX.1.
>  A successful return from
>  .BR write ()
>  does not make any guarantee that data has been committed to disk.
> -In fact, on some buggy implementations, it does not even guarantee
> -that space has successfully been reserved for the data.
> +On some filesystems, including NFS, it does not even guarantee
> +that space has successfully been reserved for the data.  In the case,
> +some errors might be delayed to a future
> +.BR write (2)
> +or to
> +.BR fsync (2)
> +or even
> +.BR close (2).
>  The only way to be sure is to call
>  .BR fsync (2)
>  after you are done writing all your data.

-- 
Jeff Layton <jlayton@redhat.com>
