Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mfb01-md.ns.itscom.net ([175.177.155.109]:41615 "EHLO
        mfb01-md.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938445AbdEYWsA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 May 2017 18:48:00 -0400
Received: from mail02-md.ns.itscom.net (mail02-md.ns.itscom.net [175.177.155.112])
        by mfb01-md.ns.itscom.net (Postfix) with ESMTP id 2C0E8238257
        for <linux-nfs@vger.kernel.org>; Fri, 26 May 2017 07:37:52 +0900 (JST)
From: "J. R. Okajima" <hooanon05g@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org
Subject: fsetxattr(2) for ACL on nfs
Date: Fri, 26 May 2017 07:37:49 +0900
Message-ID: <27179.1495751869@jrobl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since v4.12-rc1, I see an error on NFS3.

$ stat -f .
  File: "."
    ID: 0        Namelen: 255     Type: nfs
Block size: 32768      Fundamental block size: 32768
Blocks: Total: 248        Free: 247        Available: 234
Inodes: Total: 2048       Free: 2020
$ cp ../ro/f_src .
$ rm f_src
rm: remove regular file 'f_src'? y
$ cp -p ../ro/f_src .
cp: preserving permissions for './f_src': Permission denied

(from "cp --help")
  -p                           same as --preserve=mode,ownership,timestamps
      --preserve[=ATTR_LIST]   preserve the specified attributes (default:
                                 mode,ownership,timestamps), if possible
                                 additional attributes: context, links, xattr,
                                 all

By strace, I see fsetxattr(2) for ACL returned the error.
Is this an intentional behaviour?

(from strace)
open("../ro/f_src", O_RDONLY)           = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=2, ...}) = 0
open("./f_src", O_WRONLY|O_CREAT|O_EXCL, 0600) = 4
fstat(4, {st_mode=S_IFREG|0600, st_size=0, ...}) = 0
fadvise64(3, 0, 0, POSIX_FADV_SEQUENTIAL) = 0
mmap(NULL, 139264, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fcb293f8000
read(3, "f\n", 131072)                  = 2
write(4, "f\n", 2)                      = 2
read(3, "", 131072)                     = 0
utimensat(4, NULL, {{1495750885, 0}, {1495750885, 0}}, 0) = 0
fgetxattr(3, "system.posix_acl_access", 0x7ffed40196d0, 132) = -1 ENODATA (No data available)
fstat(3, {st_mode=S_IFREG|0644, st_size=2, ...}) = 0
fsetxattr(4, "system.posix_acl_access", "\x02\x00\x00\x00\x01\x00\x06\x00\xff\xff\xff\xff\x04\x00\x04\x00\xff\xff\xff\xff \x00\x04\x00\xff\xff\xff\xff", 28, 0) = -1 EACCES (Permission denied)
fchmod(4, 0100644)                      = 0
open("/usr/lib/charset.alias", O_RDONLY|O_NOFOLLOW) = -1 ENOENT (No such file or directory)
write(2, "cp: ", 4)                     = 4
write(2, "preserving permissions for './f_"..., 36) = 36
write(2, ": Permission denied", 19)     = 19
write(2, "\n", 1)                       = 1

Additonally, after this error, the shutdown process stops saying
	nfs: server localhost not responding, still trying

Does anyone know which commit causes these problems?


J. R. Okajima
