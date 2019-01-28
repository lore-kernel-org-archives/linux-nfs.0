Return-Path: <SRS0=moqZ=QE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5402AC282CC
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Jan 2019 03:04:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1D45F20C01
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Jan 2019 03:04:03 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726597AbfA1DEC convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 27 Jan 2019 22:04:02 -0500
Received: from mail-lj1-f193.google.com ([209.85.208.193]:33052 "EHLO
        mail-lj1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726575AbfA1DEC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Jan 2019 22:04:02 -0500
Received: by mail-lj1-f193.google.com with SMTP id v1-v6so12950615ljd.0
        for <linux-nfs@vger.kernel.org>; Sun, 27 Jan 2019 19:04:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=ro7vQYb1a/UjWGFN9itKpA7NMb0bqyEMmKAauEk+jfM=;
        b=VFa2M/0B6TMO/1Tlr/WMQT56Q4nSOBdQHa5U3YLv5FfOZc3z1cmUb+9PT+cIrtUy7I
         LEu7Tj7bcEwHN5H6A/rIUE9Bzkhd5wcHE3ecrxI+dpd/RNeI9CNvAHM0vFUQbBNcp17D
         lI/1qCWzLH4qihWv52K3YssBcQNRTSVtdQT1PanW+6EFm4cgzhXlQmC2AmccD7PpEQQD
         HyJRc7wJsf5sGz3pDy7ch7eC1Y/vhG6b5YJXfnKHj5MF5R7NxdpOBz508n6kctsvfp0R
         DCXI9R75tzBM330IAhyv/ObEQgijTnc6Vw5GAaJeXRhQMkdSuNqfwZzQACeuVkDOmUmj
         aomg==
X-Gm-Message-State: AJcUukf3TmTf0SG1dEEngn2IFqVdcWZkJnkkmLrNgD9DLFdTEIZKmvSI
        FnV7s5u9eGVJYyGhRnt3JslBiPC8IbKI8cN6VhOBP3Nl
X-Google-Smtp-Source: ALg8bN4/6NSUrUhLnk5Omun6xbEUwSITel3u/hou086AjaMeJvBGTSQ9w6jVWdxIsKN2qeWonLyhhCa+F3ZBGArfpqs=
X-Received: by 2002:a2e:9a16:: with SMTP id o22-v6mr15718735lji.112.1548644638993;
 Sun, 27 Jan 2019 19:03:58 -0800 (PST)
MIME-Version: 1.0
References: <20181205021051.8700-1-kdsouza@redhat.com>
In-Reply-To: <20181205021051.8700-1-kdsouza@redhat.com>
From:   Kenneth Dsouza <kdsouza@redhat.com>
Date:   Mon, 28 Jan 2019 08:33:47 +0530
Message-ID: <CAA_-hQKJ7jTq44_qc3wHApthV-k28Sn4Fudgh71Adwj-iYb=-g@mail.gmail.com>
Subject: Re: [PATCH] Add support for -L(logical) and -P(physical) option in nfs4_getfacl.
To:     linux-nfs@vger.kernel.org
Cc:     "J. Bruce Fields" <bfields@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Ping ?

On Wed, Dec 5, 2018 at 7:41 AM Kenneth D'souza <kdsouza@redhat.com> wrote:
>
> Signed-off-by: Kenneth D'souza <kdsouza@redhat.com>
> ---
>  man/man1/nfs4_getfacl.1     | 18 +++++++++++++-
>  nfs4_getfacl/nfs4_getfacl.c | 47 +++++++++++++++++++++++++++++++++----
>  2 files changed, 59 insertions(+), 6 deletions(-)
>
> diff --git a/man/man1/nfs4_getfacl.1 b/man/man1/nfs4_getfacl.1
> index 83067c9..940a2b5 100644
> --- a/man/man1/nfs4_getfacl.1
> +++ b/man/man1/nfs4_getfacl.1
> @@ -8,7 +8,7 @@
>  .SH NAME
>  nfs4_getfacl \- get NFSv4 file/directory access control lists
>  .SH SYNOPSIS
> -.B nfs4_getfacl [-HR]
> +.B nfs4_getfacl [-HRLP]
>  file ...
>  .SH DESCRIPTION
>  .B nfs4_getfacl
> @@ -28,6 +28,22 @@ flag is specified,
>  .B nfs4_getfacl
>  will list the NFSv4 ACLs of all files and directories recursively.
>
> +If the
> +.BR -L / --logical
> +flag is specified,
> +.B nfs4_getfacl
> +will follow symbolic links to directories. The default behavior is to follow
> +symbolic link arguments, and skip symbolic links encountered in subdirectories.
> +Only effective in combination with -R.
> +
> +If the
> +.BR -P / --physical
> +flag is specified,
> +.B nfs4_getfacl
> +will not follow symbolic links to directories. This also skips symbolic link
> +arguments.
> +Only effective in combination with -R.
> +
>  The output format for an NFSv4 file ACL, e.g., is:
>  .RS
>  .nf
> diff --git a/nfs4_getfacl/nfs4_getfacl.c b/nfs4_getfacl/nfs4_getfacl.c
> index 5a9c911..dd5c1b9 100644
> --- a/nfs4_getfacl/nfs4_getfacl.c
> +++ b/nfs4_getfacl/nfs4_getfacl.c
> @@ -46,9 +46,19 @@ static void usage(int);
>  static void more_help();
>  static char *execname;
>  static void print_acl_from_path();
> +static int walk_type = 0;
> +static void logical();
>
>  static int recursive(const char *fpath, const struct stat *sb, int tflag, struct FTW *ftwbuf)
>  {
> +       if ((tflag == FTW_SL) && (walk_type == 2))
> +                return 0;
> +
> +        if ((tflag == FTW_SL) && (walk_type == 1)) {
> +                logical(fpath);
> +                return 0;
> +        }
> +
>         print_acl_from_path(fpath);
>         return 0;
>  }
> @@ -56,14 +66,16 @@ static int recursive(const char *fpath, const struct stat *sb, int tflag, struct
>  static struct option long_options[] = {
>          {"more-help",    0, 0, 'H' },
>          {"help",         0, 0, 'h' },
> -        {"recursive",     0, 0, 'R' },
> +        {"recursive",    0, 0, 'R' },
> +       {"logical",      0, 0, 'L' },
> +       {"physical",     0, 0, 'P' },
>          { NULL,          0, 0, 0,  },
>  };
>
>  int main(int argc, char **argv)
>  {
>         int opt, res = 1;
> -        int do_recursive = 0;
> +        int flag, do_recursive = 0;
>
>         execname = basename(argv[0]);
>
> @@ -73,7 +85,7 @@ int main(int argc, char **argv)
>                 goto out;
>         }
>
> -       while ((opt = getopt_long(argc, argv, "HR?h", long_options, NULL)) != -1) {
> +       while ((opt = getopt_long(argc, argv, "HR?hLP", long_options, NULL)) != -1) {
>                 switch(opt) {
>                         case 'H':
>                                 more_help();
> @@ -84,6 +96,22 @@ int main(int argc, char **argv)
>                                 do_recursive = 1;
>                                 break;
>
> +                       case 'L':
> +                                if (walk_type != 0) {
> +                                        fprintf(stderr, "More than one walk type specified\n");
> +                                        goto out;
> +                                }
> +                                walk_type = 1;  /* Follow all symbolic links */
> +                                break;
> +
> +                        case 'P':
> +                                if (walk_type != 0) {
> +                                       fprintf(stderr, "More than one walk type specified\n");
> +                                        goto out;
> +                                }
> +                                walk_type = 2;  /* Skip all symbolic links */
> +                                break;
> +
>                         default:
>                                 usage(1);
>                                 res = 0;
> @@ -99,7 +127,10 @@ int main(int argc, char **argv)
>
>         for(; optind < argc; optind++) {
>                 if(do_recursive) {
> -                       if (nftw(argv[optind], recursive, 20, 0) == -1)
> +                       if (walk_type == 2 || walk_type == 1)
> +                        flag = FTW_PHYS;
> +
> +                       if (nftw(argv[optind], recursive, 20, flag) == -1)
>                                 printf("Invalid filename: %s\n", argv[optind]);
>                 }
>                 else
> @@ -121,11 +152,17 @@ static void print_acl_from_path(const char *fpath)
>         }
>  }
>
> +static void logical(const char *fpath)
> +{
> +        if (nftw(fpath, recursive, 20, 0) == -1)
> +                printf("Invalid filename: %s\n", fpath);
> +}
> +
>  static void usage(int label)
>  {
>         if (label)
>                 fprintf(stderr, "%s %s -- get NFSv4 file or directory access control lists.\n", execname, VERSION);
> -       fprintf(stderr, "Usage: %s [-R] file ...\n  -H, --more-help\tdisplay ACL format information\n  -?, -h, --help\tdisplay this help text\n  -R --recursive\trecurse into subdirectories\n", execname);
> +       fprintf(stderr, "Usage: %s [-RPL] file ...\n  -H, --more-help\tdisplay ACL format information\n  -?, -h, --help\tdisplay this help text\n  -R, --recursive\trecurse into subdirectories\n  -L, --logical\t\tlogical walk, follow symbolic links\n  -P, --physical\tphysical walk, do not follow symbolic links\n", execname);
>  }
>
>  static void more_help()
> --
> 2.17.2
>
