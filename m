Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58366 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752020AbeBBVTE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Feb 2018 16:19:04 -0500
Date: Fri, 2 Feb 2018 16:19:03 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kenneth Dsouza <kdsouza@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfs4_getfacl: Add support to accept more paths
Message-ID: <20180202211903.GB6635@fieldses.org>
References: <CAA_-hQKxopVaXHT+m3CpTfjNZjbMaYO-1D2DM1CFKZxJa4050Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAA_-hQKxopVaXHT+m3CpTfjNZjbMaYO-1D2DM1CFKZxJa4050Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, one nit:

On Sat, Feb 03, 2018 at 02:03:31AM +0530, Kenneth Dsouza wrote:
> Update man page with information for multiple file path support.
> 
> Signed-off-by: Kenneth D'souza <kdsouza@redhat.com>
> ---
>  man/man1/nfs4_getfacl.1     |  7 ++++++-
>  nfs4_getfacl/nfs4_getfacl.c | 18 +++++++++---------
>  2 files changed, 15 insertions(+), 10 deletions(-)
> 
> diff --git a/man/man1/nfs4_getfacl.1 b/man/man1/nfs4_getfacl.1
> index fc092be..b556e1a 100644
> --- a/man/man1/nfs4_getfacl.1
> +++ b/man/man1/nfs4_getfacl.1
> @@ -9,7 +9,7 @@
>  nfs4_getfacl \- get NFSv4 file/directory access control lists
>  .SH SYNOPSIS
>  .B nfs4_getfacl [-H]
> -.I file
> +file ...
>  .SH DESCRIPTION
>  .B nfs4_getfacl
>  will display the NFSv4 Access Control List (ACL) for
> @@ -28,6 +28,7 @@ The output format for an NFSv4 file ACL, e.g., is:
>  .RS
>  .nf
> 
> +# file: /somedir
>  A::OWNER@:rwatTnNcCy
>  A::alice@nfsdomain.org:rxtncy
>  A::bob@nfsdomain.org:rwadtTnNcCy
> @@ -42,6 +43,10 @@ In the example output above, the user
> `alice@nfsdomain.org' has the equivalent
>  of "read" and "execute" permissions, `bob@nfsdomain.org' has "read" and
>  "write", and both `GROUP@' and `EVERYONE@' have "read".
> 
> +.B nfs4_getfacl
> +reads a list of files from standard input. The ACL listings of
> +multiple files are separated by blank lines.
> +

The list of files comes from the command line arguments, not standard
input, right?

I've modified the man page slightly but otherwise taken your patch
unchanged; result is pushed out to git now, let me know if it looks OK
to you.

--b.
