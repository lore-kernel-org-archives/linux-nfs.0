Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail03-md.ns.itscom.net ([175.177.155.113]:49255 "EHLO
        mail03-md.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948869AbdEZX76 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 May 2017 19:59:58 -0400
From: "J. R. Okajima" <hooanon05g@gmail.com>
Subject: Re: fsetxattr(2) for ACL on nfs
To: Andreas Dilger <adilger@dilger.ca>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
In-Reply-To: <9E1EC8DB-1864-4ABA-8BEB-79C3EA9C4EBF@dilger.ca>
References: <27179.1495751869@jrobl> <9E1EC8DB-1864-4ABA-8BEB-79C3EA9C4EBF@dilger.ca>
Date: Sat, 27 May 2017 08:59:56 +0900
Message-ID: <28291.1495843196@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Andreas Dilger:
> > open("../ro/f_src", O_RDONLY)           = 3
> > fstat(3, {st_mode=S_IFREG|0644, st_size=2, ...}) = 0
> > open("./f_src", O_WRONLY|O_CREAT|O_EXCL, 0600) = 4
> > fstat(4, {st_mode=S_IFREG|0600, st_size=0, ...}) = 0
> > fadvise64(3, 0, 0, POSIX_FADV_SEQUENTIAL) = 0
> > mmap(NULL, 139264, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fcb293f8000
> > read(3, "f\n", 131072)                  = 2
> > write(4, "f\n", 2)                      = 2
> > read(3, "", 131072)                     = 0
> > utimensat(4, NULL, {{1495750885, 0}, {1495750885, 0}}, 0) = 0
> > fgetxattr(3, "system.posix_acl_access", 0x7ffed40196d0, 132) = -1 ENODATA (No data available)
> > fstat(3, {st_mode=S_IFREG|0644, st_size=2, ...}) = 0
> > fsetxattr(4, "system.posix_acl_access", "\x02\x00\x00\x00\x01\x00\x06\x00\xff\xff\xff\xff\x04\x00\x04\x00\xff\xff\xff\xff \x00\x04\x00\xff\xff\xff\xff", 28, 0) = -1 EACCES (Permission denied)
>
> To me this looks like "cp" is broken.  If it gets no POSIX ACL xattr from the
> kernel (ENODATA) for this file, why is it trying to save a POSIX ACL to the
> copy?  That just adds needless overhead, either at the syscall level, or also
> on disk if it is storing ACLs on files that don't need them...

Maybe you are right.
But on v4.11, it succeeded.

open("../ro/f_src", O_RDONLY)           = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=2, ...}) = 0
open("./f_src", O_WRONLY|O_CREAT|O_EXCL, 0600) = 4
fstat(4, {st_mode=S_IFREG|0600, st_size=0, ...}) = 0
fadvise64(3, 0, 0, POSIX_FADV_SEQUENTIAL) = 0
mmap(NULL, 139264, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f3dcf031000
read(3, "f\n", 131072)                  = 2
write(4, "f\n", 2)                      = 2
read(3, "", 131072)                     = 0
utimensat(4, NULL, {{1495842847, 0}, {1495842847, 0}}, 0) = 0
fgetxattr(3, "system.posix_acl_access", 0x7fff63443360, 132) = -1 ENODATA (No data available)
fstat(3, {st_mode=S_IFREG|0644, st_size=2, ...}) = 0
fsetxattr(4, "system.posix_acl_access", "\x02\x00\x00\x00\x01\x00\x06\x00\xff\xff\xff\xff\x04\x00\x04\x00\xff\xff\xff\xff \x00\x04\x00\xff\xff\xff\xff", 28, 0) = 0


J. R. Okajima
