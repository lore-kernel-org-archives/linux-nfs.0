Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:46657 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935449AbdLRQq4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Dec 2017 11:46:56 -0500
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] fcntl.2, read.2, write.2: document "Lost locks" as cause
 for EIO.
To: NeilBrown <neilb@suse.com>
References: <87lgi7nttp.fsf@notabene.neil.brown.name>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <df9a18ce-c412-44aa-d475-77521a7252c5@gmail.com>
Date: Mon, 18 Dec 2017 17:46:52 +0100
MIME-Version: 1.0
In-Reply-To: <87lgi7nttp.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Neil

There's a piece of your patch I don't understand. Please see below.

On 12/13/2017 05:19 AM, NeilBrown wrote:
> 
> If an advisory lock is lost, then read/write requests on any
> affected file descriptor can return EIO - for NFSv4 at least.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  man2/fcntl.2 | 24 ++++++++++++++++++++++++
>  man2/read.2  |  9 +++++++++
>  man2/write.2 |  9 +++++++++
>  3 files changed, 42 insertions(+)
> 
> diff --git a/man2/fcntl.2 b/man2/fcntl.2
> index 67642384154c..6e6e26f66aa0 100644
> --- a/man2/fcntl.2
> +++ b/man2/fcntl.2
> @@ -669,6 +669,30 @@ and
>  Mandatory locking is not specified by POSIX.
>  Some other systems also support mandatory locking,
>  although the details of how to enable it vary across systems.
> +.SS Lost locks
> +When an advisory lock is obtained on a networked filesystem such as
> +NFS it is possible that the lock might get lost.
> +This may happen due to administrative action on the server, or due to a
> +network partition which lasts long enough for the server to assume

What does "network partition which lasts long enough" mean?
I think this perhaps needs to be clarified a little. At least,
I don't understand it.

Cheers,

Michael


> +that the client is no longer functioning.
> +.PP
> +When the filesystem determines that a lock has been lost, future
> +.BR read (2)
> +or
> +.BR write (2)
> +requests may fail with the error
> +.BR EIO .
> +This error will persist until the lock is removed or the file
> +descriptor is closed.
> +Since Linux 3.12,
> +.\" commit ef1820f9be27b6ad158f433ab38002ab8131db4d
> +this happens at least for NFSv4 including all minor versions.
> +.PP
> +Some versions of Unix send a signal
> +.RB ( SIGLOST )
> +in this circumstance.
> +Linux does not define this signal, and does not provide any
> +asynchronous notification of lost locks.
>  .SS Managing signals
>  .BR F_GETOWN ,
>  .BR F_SETOWN ,
> diff --git a/man2/read.2 b/man2/read.2
> index f2e1379865df..0fea86e523a5 100644
> --- a/man2/read.2
> +++ b/man2/read.2
> @@ -163,6 +163,15 @@ or its process group
>  is orphaned.
>  It may also occur when there is a low-level I/O error
>  while reading from a disk or tape.
> +A further possible cause of
> +.B EIO
> +on networked filesystems is when an advisory lock had been taken
> +out on the file descriptor and this lock has been lost.
> +See the
> +.I "Lost locks"
> +section of
> +.BR fcntl (2)
> +for further details.
>  .TP
>  .B EISDIR
>  .I fd
> diff --git a/man2/write.2 b/man2/write.2
> index 796cae8ba221..621a484dc3a2 100644
> --- a/man2/write.2
> +++ b/man2/write.2
> @@ -197,6 +197,15 @@ be reported by a subsequent
>  (whether or not they were also reported by
>  .BR write (2)).
>  .\" commit 088737f44bbf6378745f5b57b035e57ee3dc4750
> +An alternate cause of
> +.B EIO
> +on networked filesystems is when an advisory lock had been taken out
> +on the file descriptor and this lock has been lost.
> +See the
> +.I "Lost locks"
> +section of
> +.BR fcntl (2)
> +for further details.
>  .TP
>  .B ENOSPC
>  The device containing the file referred to by
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
