Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34276 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752116AbdKXIfN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Nov 2017 03:35:13 -0500
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <873754zh4v.fsf@notabene.neil.brown.name>
References: <87wp2j1ggu.fsf@notabene.neil.brown.name> <52c5800b-150a-7ec9-133b-6c32e97249f4@gmail.com>
 <873754zh4v.fsf@notabene.neil.brown.name>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Fri, 24 Nov 2017 09:34:51 +0100
Message-ID: <CAKgNAkh+oDszm=_P5qFsU3azE6qRczc6o6jjCHzaQSwPvsXkYg@mail.gmail.com>
Subject: Re: [manpages PATCH] open_by_handle_at.2: clarify MAX_HANDLE_SZ
To: NeilBrown <neilb@suse.com>
Cc: linux-man <linux-man@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Neil,

On 24 November 2017 at 00:53, NeilBrown <neilb@suse.com> wrote:
>
> As hinted in the kernel source, MAX_HANDLE_SZ is a hint
> rather than a promise:
>
>     /* limit the handle size to NFSv4 handle size now */
>     #define MAX_HANDLE_SZ 128
>
> Note the "now" (probably should be "for now").
> So change the description to make this clear.

Thanks! Applied.

Cheers,

Michael


> Reported-by: Lennart Poettering <lennart@poettering.net>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  man2/open_by_handle_at.2 | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/man2/open_by_handle_at.2 b/man2/open_by_handle_at.2
> index 79987308bf3e..f3473d24fa50 100644
> --- a/man2/open_by_handle_at.2
> +++ b/man2/open_by_handle_at.2
> @@ -91,7 +91,8 @@ field should be initialized to contain the allocated size for
>  .BR MAX_HANDLE_SZ ,
>  defined in
>  .IR <fcntl.h> ,
> -specifies the maximum possible size for a file handle.)
> +specifies the maximum expected size for a file handle. It is not a
> +guaranteed upper limit as future filesystems may require more space.)
>  Upon successful return, the
>  .IR handle_bytes
>  field is updated to contain the number of bytes actually written to
> --
> 2.14.0.rc0.dirty
>



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
