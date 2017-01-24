Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41766 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750716AbdAXQsf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jan 2017 11:48:35 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Matthieu Herrb" <matthieu.herrb@laas.fr>
Cc: linux-nfs@vger.kernel.org
Subject: Re: problem with open(name, O_RDWR|O_CREAT|O_EXCL, 0666) on NetApp
 servers
Date: Tue, 24 Jan 2017 11:48:33 -0500
Message-ID: <45F25643-F51D-4CA0-AC7D-55B6D6D6FE22@redhat.com>
In-Reply-To: <20170105142439.GB9922@paperthin-usb.laas.fr>
References: <20170105142439.GB9922@paperthin-usb.laas.fr>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Matthieu, are you willing to test this one:

http://marc.info/?l=linux-nfs&m=148527567624411&w=2

Ben

On 5 Jan 2017, at 9:24, Matthieu Herrb wrote:

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
> 	const char *name = argv[1];
> 	char tmp[] = "./tmpXXXXXXXXXX";
> 	struct stat buf;
> 	mode_t expected;
> 	int fd, i, n = 40;
>
> 	umask(S_IWGRP | S_IWOTH);
> 	expected = 0666 & ~(S_IWGRP | S_IWOTH);
> 	if (argv[1] == NULL)
> 		name = mktemp(tmp);
> 	for (i = 0; i < n; i++) {
> 		fd = open(name, O_RDWR|O_CREAT|O_EXCL, 0666);
> 		if (fd < 0)
> 			err(1, "open %s", name);
> 		memset(&buf, 0, sizeof(buf));
> 		if (stat(name, &buf) < 0)
> 			err(1, "stat %s", name);
> 		if ((buf.st_mode & (S_IRWXU|S_IRWXG|S_IRWXO)) != expected)
> 			printf("%s: %o\n", name,
> 			    (int)buf.st_mode & (S_IRWXU|S_IRWXG|S_IRWXO));
> 		else
> 			printf("%s: ok\n", name);
> 		unlink(name);
> 	}
> 	exit(0);
> }
> -- 
> Matthieu Herrb
