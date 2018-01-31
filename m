Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48940 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752727AbeAaUQF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 Jan 2018 15:16:05 -0500
Date: Wed, 31 Jan 2018 15:16:05 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kenneth Dsouza <kdsouza@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs4_getfacl: Add support to accept more paths
Message-ID: <20180131201605.GC3814@fieldses.org>
References: <CAA_-hQKaiEBUmKZj_o9fv-MOSvTgffACP8TrPPXGwk6x=MwkCA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAA_-hQKaiEBUmKZj_o9fv-MOSvTgffACP8TrPPXGwk6x=MwkCA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 31, 2018 at 12:53:04AM +0530, Kenneth Dsouza wrote:
> Currently, nfs4_getfacl accepts only a single path at a time, which
> makes us run the command several times.
> This patch will help us to list (ACL) on multiple files at a  time.
>  nfs4getfacl file ...

Looks fine, thanks.

Just a couple whitespace nits:

> diff --git a/nfs4_getfacl/nfs4_getfacl.c b/nfs4_getfacl/nfs4_getfacl.c
> index 5363096..bbbbb62 100644
> --- a/nfs4_getfacl/nfs4_getfacl.c
> +++ b/nfs4_getfacl/nfs4_getfacl.c
> @@ -48,17 +48,13 @@ int main(int argc, char **argv)
>  {
>         struct nfs4_acl *acl;
>         int res = 1;
> -

No need to delete that blank line.

> +       int count = 1;
>         execname = basename(argv[0]);
> 
>         if (argc < 2) {
>                 fprintf(stderr, "%s: you must specify a path.\n", execname);
>                 usage(0);
>                 goto out;
> -       } else if (argc > 2) {
> -               fprintf(stderr, "%s: currently, you may only specify a
> single path.\n", execname);
> -               usage(0);
> -               goto out;
>         } else if (!strcmp(argv[1], "-?") || !strcmp(argv[1], "-h") ||
> !strcmp(argv[1], "--help")) {
>                 usage(1);
>                 res = 0;
> @@ -68,12 +64,15 @@ int main(int argc, char **argv)
>                 res = 0;
>                 goto out;
>         }
> -       acl = nfs4_acl_for_path(argv[1]);
> +       for (counter = 1; counter < agrc; counter++)    {
> +       acl = nfs4_acl_for_path(argv[counter]);
>         if (acl != NULL) {
> +               printf("\n# file: %s\n", argv[counter]);
>                 nfs4_print_acl(stdout, acl);
>                 nfs4_free_acl(acl);
>                 res = 0;
>         }

Fix the indentation here (the body of the loop should be indented.)

Actually the patch looks like the whitespace has been mangled somehow.
(For example the indentation is all tabs, not spaces, in the original.)

You might check
https://www.kernel.org/doc/html/v4.11/process/email-clients.html
and see if it has any hints for your email client.

--b.

> +       }
>  out:
>         return res;
>  }
> -- 
> 1.8.3.1
