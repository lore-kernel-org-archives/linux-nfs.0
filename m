Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:40135 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751448AbdKVQtA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Nov 2017 11:49:00 -0500
Cc: mtk.manpages@gmail.com, linux-man@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>,
        Peng Tao <tao.peng@primarydata.com>
Subject: Re: [manpages PATCH] open_by_handle_at: clarifications needed due to
 NFS reexport
To: NeilBrown <neilb@suse.com>
References: <87wp2j1ggu.fsf@notabene.neil.brown.name>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Message-ID: <52c5800b-150a-7ec9-133b-6c32e97249f4@gmail.com>
Date: Wed, 22 Nov 2017 17:48:55 +0100
MIME-Version: 1.0
In-Reply-To: <87wp2j1ggu.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Neil,

On 11/21/2017 10:15 PM, NeilBrown wrote:
> 
> The recent addition of NFS re-export and the possibility of
> using name_to_handle_at() on an NFS filesystem raises issues
> with name_to_handle_at() which have not been properly documented.
> 
> Getting the filehandle for an untriggered automount point is
> arguably meaningless and in certainly not supported by NFS.
> name_to_handle_at() will return -EOVERFLOW even though the
> requested "handle_bytes" is large enough.  This is an unfortunate
> overloading of the error code, but is manageable.
> 
> So clarify this and also note that the mount_id is returned
> when EOVERFLOW is reported.
> 
> Thought: it would be nice if mount_id were returned in the
> EOPNOTSUPP case too.  I guess it is too late to fix that (?).
> 
> Link: https://github.com/systemd/systemd/issues/7082
> Signed-off-by: NeilBrown <neilb@suse.com>

Thanks! Patch applied.

Cheers,

Michael

PS And meta-thanks for thinking to send me the steady small 
stream of man-pages patches that you do.

> ---
>  man2/open_by_handle_at.2 | 25 +++++++++++++++++++++++++
>  1 file changed, 25 insertions(+)
> 
> diff --git a/man2/open_by_handle_at.2 b/man2/open_by_handle_at.2
> index 91300e80fe24..9a30dd2ed476 100644
> --- a/man2/open_by_handle_at.2
> +++ b/man2/open_by_handle_at.2
> @@ -109,6 +109,12 @@ and
>  is set to indicate the required size;
>  the caller can then use this information to allocate a structure
>  of the correct size (see EXAMPLE below).
> +Some care is needed here as
> +.BR EOVERFLOW
> +can also indicate that no filehandle is available for this particular
> +name in a filesystem which does normally support filehandle lookup.
> +This case can be detected when EOVERFLOW is returned without
> +handle_bytes being increased.
>  .PP
>  Other than the use of the
>  .IR handle_bytes
> @@ -193,6 +199,10 @@ Opening the pathname in the fifth field of that record yields a file
>  descriptor for the mount point;
>  that file descriptor can be used in a subsequent call to
>  .BR open_by_handle_at ().
> +.I mount_id
> +is returned both for a successful call and for a call that results
> +in the error
> +.BR EOVERFLOW .
>  .PP
>  By default,
>  .BR name_to_handle_at ()
> @@ -206,6 +216,21 @@ is specified in
>  .I pathname
>  is dereferenced if it is a symbolic link
>  (so that the call returns a handle for the file referred to by the link).
> +.PP
> +.BR name_to_handle_at )
> +does not trigger a mount when the final component of the path is an
> +automount point.  When a filesystem supports both filehandles and
> +automount points, a
> +.BR name_to_handle_at ()
> +call on an automount point will return with error
> +.BR EOVERFLOW
> +without having increased
> +.IR handle_bytes .
> +This can happen since Linux 4.13 with NFS when accessing a directory
> +which is on a separate filesystem on the server.
> +.\" commit 20fa19027286983ab2734b5910c4a687436e0c31
> +In this case the automount can be triggered by adding a "/" to the end
> +of the path.
>  .SS open_by_handle_at()
>  The
>  .BR open_by_handle_at ()
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
