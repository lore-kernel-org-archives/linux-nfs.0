Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:39968 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161799AbcE3S3p convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 May 2016 14:29:45 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 37E25280943
	for <linux-nfs@vger.kernel.org>; Mon, 30 May 2016 20:29:42 +0200 (CEST)
Received: from ZITSWEEP4.win.desy.de (zitsweep4.win.desy.de [131.169.97.98])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 2093313E9B
	for <linux-nfs@vger.kernel.org>; Mon, 30 May 2016 20:29:41 +0200 (MEST)
Date: Mon, 30 May 2016 20:29:41 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-ID: <814812120.15151348.1464632981013.JavaMail.zimbra@desy.de>
In-Reply-To: <1464631095.13639.6.camel@poochiereds.net>
References: <1897196982.15107146.1464620758631.JavaMail.zimbra@desy.de> <345347427.15123988.1464623475380.JavaMail.zimbra@desy.de> <1464631095.13639.6.camel@poochiereds.net>
Subject: Re: Infinit LAYOUTGET with mmap
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

the 4.7 have the same behavior...

capture file: https://desycloud.desy.de/public.php?service=files&t=5e26a8d73ed6aacbdbf49e4c8f1cc01a&download

Tigran.

----- Original Message -----
> From: "Jeff Layton" <jlayton@poochiereds.net>
> To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>, "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
> Cc: "Trond Myklebust" <trond.myklebust@primarydata.com>
> Sent: Monday, May 30, 2016 7:58:15 PM
> Subject: Re: Infinit LAYOUTGET with mmap

> On Mon, 2016-05-30 at 17:51 +0200, Mkrtchyan, Tigran wrote:
>> 
>> re-sending, as it never arrived....
>> 
>> ----- Original Message -----
>> > 
>> > From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
>> > To: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
>> > Sent: Monday, May 30, 2016 5:05:59 PM
>> > Subject: Infinit LAYOUTGET with mmap
>> > 
>> > Dear NFS developers,
>> > 
>> > On my test system I hit a behavior of the nfs client with
>> > kernel 4.4 which I haven't seen before.
>> > 
>> > 
>> > Here is a minimal example to reproduce the issue:
>> > 
>> > ============= bug.c =====================
>> > 
>> > #include <stdio.h>
>> > #include <stdlib.h>
>> > #include <unistd.h>
>> > #include <fcntl.h>
>> > #include <sys/mman.h>
>> > 
>> > 
>> > int main(int argc, char* argv[])
>> > {
>> > 
>> >    int *m;
>> >    int fd;
>> >    int err;
>> > 
>> >    fd = open(argv[1], O_CREAT| O_RDWR, O_TRUNC, 0666);
>> >    if (fd < 0) {
>> >        perror("failed to open file");
>> >        exit(1);
>> >    }
>> > 
>> >    err = ftruncate(fd, 4096);
>> >    if (err) {
>> >        perror("cant set filesize");
>> >        exit(2);
>> >    }
>> > 
>> >    m = mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
>> >    if (m == MAP_FAILED) {
>> >        perror("failed to map the file");
>> >        exit(2);
>> >    }
>> > 
>> >    m[1] = 0;
>> > 
>> >    err = munmap(m, 4096);
>> >    if (err) {
>> >        perror("failed to unmap the file");
>> >    }
>> > 
>> >    close(fd);
>> > }
>> > =============== end of example ================
>> > 
>> > 
>> > 
>> > When  running this code, client send an OPEN with share_access
>> > OPEN4_SHARE_ACCESS_BOTH. But later calient sends LAYOUTGET with
>> > IOMODE_READ
>> > followed by GETDEVICEINFO.
>> > 
>> > This combination of LG+GDI remain for ever. The capture file is
>> > attached.
>> > 
>> > My guess it that client expects RW layout.
>> > 
>> > Kernel: 4.4.9-300.fc23.x86_64. I will try with upstream as well.
>> > 
>> > Thanks a lot,
>> >    Tigran.
> 
> No capture attached, but 4.7 should be getting a major overhaul to the
> LAYOUTGET retry handling code. You may want to re-test with a bleeding
> edge kernel and see if the problem is still present.
> 
> Cheers,
> --
> Jeff Layton <jlayton@poochiereds.net>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
