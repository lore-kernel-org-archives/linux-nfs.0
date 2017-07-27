Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:34105 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751125AbdG0IoI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jul 2017 04:44:08 -0400
Received: by mail-lf0-f52.google.com with SMTP id g25so73668133lfh.1
        for <linux-nfs@vger.kernel.org>; Thu, 27 Jul 2017 01:44:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1501142364-14033-1-git-send-email-chunyu.wang.1995@gmail.com>
References: <1501142364-14033-1-git-send-email-chunyu.wang.1995@gmail.com>
From: ChunYu Wang <chunwang@redhat.com>
Date: Thu, 27 Jul 2017 16:44:06 +0800
Message-ID: <CAOm2TWyKnJYPDXKtBmVJTUiWQUBvPognsoNhu+6tEeuMsJCEhA@mail.gmail.com>
Subject: Re: [PATCH] rpcdebug: Add proper free() to avoid memory leak
To: ChunYu Wang <chunyu.wang.1995@gmail.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Multiple this kind of scenes can be found in nfs-utils and can be
reproduced easily with valgrind, if this kind of issue should be
resolved, maybe a series of similar patches are necessary.

---> Try to reproduce:
[chunwang@bootp rpcdebug]$ valgrind rpcdebug -h

---> valgrind report before patch:
==14199== HEAP SUMMARY:
==14199==     in use at exit: 8 bytes in 1 blocks
==14199==   total heap usage: 1 allocs, 0 frees, 8 bytes allocated
==14199==
==14199== LEAK SUMMARY:
==14199==    definitely lost: 0 bytes in 0 blocks
==14199==    indirectly lost: 0 bytes in 0 blocks
==14199==      possibly lost: 0 bytes in 0 blocks
==14199==    still reachable: 8 bytes in 1 blocks
==14199==         suppressed: 0 bytes in 0 blocks

--> valgrind report after patch:
==14200==
==14200== HEAP SUMMARY:
==14200==     in use at exit: 0 bytes in 0 blocks
==14200==   total heap usage: 1 allocs, 1 frees, 8 bytes allocated
==14200==
==14200== All heap blocks were freed -- no leaks are possible

On Thu, Jul 27, 2017 at 3:59 PM, ChunYu Wang <chunyu.wang.1995@gmail.com> wrote:
> rpcdebug.c use char* cdename to store program name:
>
>     cdename = malloc(strlen(basename(argv[0])));
>     strcpy(cdename, basename(argv[0]));
>
> It is better to free before exit to avoid potential leaks.
>
> Signed-off-by: ChunYu Wang <chunyu.wang.1995@gmail.com>
> ---
>  tools/rpcdebug/rpcdebug.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
>
> diff --git a/tools/rpcdebug/rpcdebug.c b/tools/rpcdebug/rpcdebug.c
> index 68206cc..722ab4d 100644
> --- a/tools/rpcdebug/rpcdebug.c
> +++ b/tools/rpcdebug/rpcdebug.c
> @@ -131,6 +131,7 @@ main(int argc, char **argv)
>                 print_flags(stdout, module, ~(unsigned int) 0, 1);
>         }
>
> +       free(cdename);
>         return 0;
>  }
>
> @@ -221,6 +222,7 @@ find_flag(char **module, char *name)
>                                 "please specify the module name using\n"
>                                 "the -m option.\n",
>                                 cdename, name);
> +                       free(cdename);
>                         exit(1);
>                 }
>                 value = flagmap[i].value;
> @@ -238,6 +240,7 @@ find_flag(char **module, char *name)
>                         fprintf(stderr,
>                                 "%s: unknown flag %s\n",
>                                 cdename, name);
> +               free(cdename);
>                 exit(1);
>         }
>
> @@ -255,10 +258,12 @@ get_flags(char *module)
>
>         if ((sysfd = open(filename, O_RDONLY)) < 0) {
>                 perror(filename);
> +               free(cdename);
>                 exit(1);
>         }
>         if ((len = read(sysfd, buffer, sizeof(buffer))) < 0) {
>                 perror("read");
> +               free(cdename);
>                 exit(1);
>         }
>         close(sysfd);
> @@ -278,14 +283,17 @@ set_flags(char *module, unsigned int value)
>         len = sprintf(buffer, "%d", value);
>         if ((sysfd = open(filename, O_WRONLY)) < 0) {
>                 perror(filename);
> +               free(cdename);
>                 exit(1);
>         }
>         if ((ret = write(sysfd, buffer, len)) < 0) {
>                 perror("write");
> +               free(cdename);
>                 exit(1);
>         }
>         if (ret < len) {
>                 fprintf(stderr, "error: short write in set_flags!\n");
> +               free(cdename);
>                 exit(1);
>         }
>         close(sysfd);
> @@ -359,6 +367,7 @@ usage(int excode, char *module)
>           else
>             fprintf(stderr, "       (use %s -vh to get a list of modules and valid flags)\n", cdename);
>         }
> +       free(cdename);
>         exit (excode);
>  }
>
> --
> 2.1.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
