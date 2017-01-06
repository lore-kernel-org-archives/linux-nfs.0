Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:35243 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750715AbdAFRts (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jan 2017 12:49:48 -0500
Received: by mail-it0-f47.google.com with SMTP id c20so17568836itb.0
        for <linux-nfs@vger.kernel.org>; Fri, 06 Jan 2017 09:49:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170105142439.GB9922@paperthin-usb.laas.fr>
References: <20170105142439.GB9922@paperthin-usb.laas.fr>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 6 Jan 2017 12:49:47 -0500
Message-ID: <CAN-5tyFLO+gWCG5aSg3tCFVt4VFzSbdFhw=z9jb2P3SDMsVL+Q@mail.gmail.com>
Subject: Re: problem with open(name, O_RDWR|O_CREAT|O_EXCL, 0666) on NetApp servers
To: Matthieu Herrb <matthieu.herrb@laas.fr>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

That is a rather old NetApp release. Perhaps they've fix something.
I've just tried their latest 9.0 release and 4.9 upstream kernel and
file is created with 0644.

On Thu, Jan 5, 2017 at 9:24 AM, Matthieu Herrb <matthieu.herrb@laas.fr> wrote:
> Hi,
>
> After upgrading my machine to Ubuntu 16.04, I noticed that 'git clone'
> started creating files with wrong mode (0700 instead of 0644
> typically) on NFSv4 partitions mounted from our NetApp servers.
>
> I've first tracked this down to the fact that git uses
>
>  open(name, O_RDWR|O_CREAT|O_EXCL, 0666);
>
> to create files. If O_EXCL is not present, the files are created
> normally.
>
> I've tried various kernels from Ubuntu and the problems appeared
> between their 4.2.0-42-generic kernel-image (as found on willy) and
> the 4.4.0 kernels found on xenial. I tried building 4.9 from
> kernel.org and the problem is also there.
>
> I've then bisected the kernel to figure out that this is caused by the
> following commit:
>
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=5334c5bdac926c5f8d89729beccb46fe88eda9e7
>
> ie NFS: Send attributes in OPEN request for NFS4_CREATE_EXCLUSIVE4_1
>
> Our NetApp filers are running:
>
> NetApp Release 8.2.3P3 7-Mode: Tue Apr 28 14:48:22 PDT 2015
>
> Any idea on how to fix the problem (either on the NetApp side, or on
> Linux kernel side)?
>
> Appended is a small program to reproduce the issue:
>
> Thanks in advance,
>
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <err.h>
> #include <fcntl.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <string.h>
> #include <unistd.h>
>
> /*
>  * Demonstrate file creation bug on NFS v4 and linux kernel 4.4+
>  *
>  * mktemp() is used on purpose.
>  */
> int
> main(int argc, char *argv[])
> {
>         const char *name = argv[1];
>         char tmp[] = "./tmpXXXXXXXXXX";
>         struct stat buf;
>         mode_t expected;
>         int fd, i, n = 40;
>
>         umask(S_IWGRP | S_IWOTH);
>         expected = 0666 & ~(S_IWGRP | S_IWOTH);
>         if (argv[1] == NULL)
>                 name = mktemp(tmp);
>         for (i = 0; i < n; i++) {
>                 fd = open(name, O_RDWR|O_CREAT|O_EXCL, 0666);
>                 if (fd < 0)
>                         err(1, "open %s", name);
>                 memset(&buf, 0, sizeof(buf));
>                 if (stat(name, &buf) < 0)
>                         err(1, "stat %s", name);
>                 if ((buf.st_mode & (S_IRWXU|S_IRWXG|S_IRWXO)) != expected)
>                         printf("%s: %o\n", name,
>                             (int)buf.st_mode & (S_IRWXU|S_IRWXG|S_IRWXO));
>                 else
>                         printf("%s: ok\n", name);
>                 unlink(name);
>         }
>         exit(0);
> }
> --
> Matthieu Herrb
