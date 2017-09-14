Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33481 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751420AbdINNi5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Sep 2017 09:38:57 -0400
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <87valci55j.fsf@notabene.neil.brown.name>
References: <87bmnmrai9.fsf@notabene.neil.brown.name> <1502430944.3822.1.camel@primarydata.com>
 <1502449309.4950.2.camel@redhat.com> <87zib3niqn.fsf@notabene.neil.brown.name>
 <1502705432.4978.1.camel@redhat.com> <877ey4nsep.fsf@notabene.neil.brown.name>
 <1502883253.4847.6.camel@redhat.com> <1e4665a6-30d6-c16a-760a-2892fb147760@redhat.com>
 <878tihmora.fsf@notabene.neil.brown.name> <2e289bba-677b-cc50-5fa3-2d24d1f6b858@redhat.com>
 <87h8x1l9qp.fsf@notabene.neil.brown.name> <733c15c2-ffbb-9a89-90ec-3ba1d574590e@redhat.com>
 <87r2w3jdn5.fsf@notabene.neil.brown.name> <42ba2fa5-d756-d70f-370c-c2fe1a61c5bf@redhat.com>
 <87inhdk3rq.fsf@notabene.neil.brown.name> <CAKgNAki1SYjr7-6g-i3shGjQRjwy81gS0QisfZRy-x-bHFtXmA@mail.gmail.com>
 <87valci55j.fsf@notabene.neil.brown.name>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Thu, 14 Sep 2017 15:38:34 +0200
Message-ID: <CAKgNAkinKkG8cR1ng0V3K1D9QNQ9MSeNkPpvpeGSUd5RqFiwSw@mail.gmail.com>
Subject: Re: [PATCH manpages] stat.2: correct AT_NO_AUTOMOUNT text and general revisions.
To: NeilBrown <neilb@suse.com>
Cc: Ian Kent <ikent@redhat.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "mkoutny@suse.com" <mkoutny@suse.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        David Howells <dhowells@redhat.com>,
        "H. Peter Anvin" <hpa@zytor.com>,
        Michael Kerrisk <mtk.manpages@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil,

On 25 August 2017 at 07:32, NeilBrown <neilb@suse.com> wrote:
>
> Expand on the relationship between fstatat() and the other
> three functions, and improve the description of AT_NO_AUTOMOUNT.
> Specifically, both  stat() and lstat() act the same way
> with respect to automounts, and that behavior matches
> fstatat with the AT_NO_AUTOMOUNT flag.
>
> The text in the NOTES is removed and places with the text for
> AT_NO_AUTOMOUNT to improve cohesion.
>
> New text for a difference to be introduced in 4.14.

Has the 4.14 piece gone in?

Cheers,

Michael

> Cc: Ian Kent <ikent@redhat.com>
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>
> Thanks Ian and Michael.  I considered your input and read
> through the whole again, and came up with this which is
> quite different to what I suggested before.
>
> If this patch is applied, the result probably shouldn't be released
> until the relevant patch actually lands in Linus's tree.
>
> NeilBrown
>
>
>  man2/stat.2 | 37 ++++++++++++++++++++++++-------------
>  1 file changed, 24 insertions(+), 13 deletions(-)
>
> diff --git a/man2/stat.2 b/man2/stat.2
> index d8a9e76b3d9f..c6dddfe0d3a7 100644
> --- a/man2/stat.2
> +++ b/man2/stat.2
> @@ -260,9 +260,12 @@ For further information on the above fields, see
>  .SS fstatat()
>  The
>  .BR fstatat ()
> -system call operates in exactly the same way as
> +system call is a more general interface for accessing file information
> +which can still provide exactly the behavior of each of
>  .BR stat (),
> -except for the differences described here.
> +.BR lstat (),
> +and
> +.BR fstat ().
>  .PP
>  If the pathname given in
>  .I pathname
> @@ -272,6 +275,8 @@ referred to by the file descriptor
>  (rather than relative to the current working directory of
>  the calling process, as is done by
>  .BR stat ()
> +and
> +.BR lstat ()
>  for a relative pathname).
>  .PP
>  If
> @@ -284,7 +289,9 @@ then
>  .I pathname
>  is interpreted relative to the current working
>  directory of the calling process (like
> -.BR stat ()).
> +.BR stat ()
> +and
> +.BR lstat ()).
>  .PP
>  If
>  .I pathname
> @@ -307,7 +314,11 @@ is an empty string, operate on the file referred to by
>  flag).
>  In this case,
>  .I dirfd
> -can refer to any type of file, not just a directory.
> +can refer to any type of file, not just a directory, and
> +the behavior of
> +.BR fstatat ()
> +is similar to that of
> +.BR fstat ().
>  If
>  .I dirfd
>  is
> @@ -324,6 +335,8 @@ Don't automount the terminal ("basename") component of
>  if it is a directory that is an automount point.
>  This allows the caller to gather attributes of an automount point
>  (rather than the location it would mount).
> +Since Linux 4.14, also don't instantiate a non-existent name in an
> +on-demand directory such as used for automounter indirect maps.
>  This flag can be used in tools that scan directories
>  to prevent mass-automounting of a directory of automount points.
>  The
> @@ -333,6 +346,13 @@ This flag is Linux-specific; define
>  .B _GNU_SOURCE
>  .\" Before glibc 2.16, defining _ATFILE_SOURCE sufficed
>  to obtain its definition.
> +Both
> +.BR stat ()
> +and
> +.BR lstat ()
> +act as though
> +.B AT_NO_AUTOMOUNT
> +was set.
>  .TP
>  .B AT_SYMLINK_NOFOLLOW
>  If
> @@ -474,15 +494,6 @@ fields may be less portable.
>  The interpretation differs between systems,
>  and possibly on a single system when NFS mounts are involved.)
>  .SH NOTES
> -On Linux,
> -.BR lstat ()
> -will generally not trigger automounter action, whereas
> -.BR stat ()
> -will (but see the description of the
> -.BR fstatat ()
> -.B AT_NO_AUTOMOUNT
> -fag, above).
> -.\"
>  .SS Timestamp fields
>  Older kernels and older standards did not support nanosecond timestamp
>  fields.
> --
> 2.14.0.rc0.dirty
>



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
