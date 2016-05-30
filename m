Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:59116 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932192AbcE3PvS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 May 2016 11:51:18 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id DBDA2280A1C
	for <linux-nfs@vger.kernel.org>; Mon, 30 May 2016 17:51:15 +0200 (CEST)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id CFBCA1643
	for <linux-nfs@vger.kernel.org>; Mon, 30 May 2016 17:51:15 +0200 (MEST)
Date: Mon, 30 May 2016 17:51:15 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Message-ID: <345347427.15123988.1464623475380.JavaMail.zimbra@desy.de>
In-Reply-To: <1897196982.15107146.1464620758631.JavaMail.zimbra@desy.de>
References: <1897196982.15107146.1464620758631.JavaMail.zimbra@desy.de>
Subject: Re: Infinit LAYOUTGET with mmap
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



re-sending, as it never arrived....

----- Original Message -----
> From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
> To: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
> Sent: Monday, May 30, 2016 5:05:59 PM
> Subject: Infinit LAYOUTGET with mmap

> Dear NFS developers,
> 
> On my test system I hit a behavior of the nfs client with
> kernel 4.4 which I haven't seen before.
> 
> 
> Here is a minimal example to reproduce the issue:
> 
> ============= bug.c =====================
> 
> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <fcntl.h>
> #include <sys/mman.h>
> 
> 
> int main(int argc, char* argv[])
> {
> 
>    int *m;
>    int fd;
>    int err;
> 
>    fd = open(argv[1], O_CREAT| O_RDWR, O_TRUNC, 0666);
>    if (fd < 0) {
>        perror("failed to open file");
>        exit(1);
>    }
> 
>    err = ftruncate(fd, 4096);
>    if (err) {
>        perror("cant set filesize");
>        exit(2);
>    }
> 
>    m = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
>    if (m == MAP_FAILED) {
>        perror("failed to map the file");
>        exit(2);
>    }
> 
>    m[1] = 0;
> 
>    err = munmap(m, 4096);
>    if (err) {
>        perror("failed to unmap the file");
>    }
> 
>    close(fd);
> }
> =============== end of example ================
> 
> 
> 
> When  running this code, client send an OPEN with share_access
> OPEN4_SHARE_ACCESS_BOTH. But later calient sends LAYOUTGET with IOMODE_READ
> followed by GETDEVICEINFO.
> 
> This combination of LG+GDI remain for ever. The capture file is attached.
> 
> My guess it that client expects RW layout.
> 
> Kernel: 4.4.9-300.fc23.x86_64. I will try with upstream as well.
> 
> Thanks a lot,
>    Tigran.
