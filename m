Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49962 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751033AbdEaUcM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 May 2017 16:32:12 -0400
Date: Wed, 31 May 2017 16:32:11 -0400
To: "J. R. Okajima" <hooanon05g@gmail.com>
Cc: Andreas Dilger <adilger@dilger.ca>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: fsetxattr(2) for ACL on nfs
Message-ID: <20170531203211.GB23526@fieldses.org>
References: <27179.1495751869@jrobl>
 <9E1EC8DB-1864-4ABA-8BEB-79C3EA9C4EBF@dilger.ca>
 <28291.1495843196@jrobl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <28291.1495843196@jrobl>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's a known bug, I've been slow to get it upstream, apologies, I'll try
to get it in for -rc4.

--b.

On Sat, May 27, 2017 at 08:59:56AM +0900, J. R. Okajima wrote:
> Andreas Dilger:
> > > open("../ro/f_src", O_RDONLY)           = 3
> > > fstat(3, {st_mode=S_IFREG|0644, st_size=2, ...}) = 0
> > > open("./f_src", O_WRONLY|O_CREAT|O_EXCL, 0600) = 4
> > > fstat(4, {st_mode=S_IFREG|0600, st_size=0, ...}) = 0
> > > fadvise64(3, 0, 0, POSIX_FADV_SEQUENTIAL) = 0
> > > mmap(NULL, 139264, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7fcb293f8000
> > > read(3, "f\n", 131072)                  = 2
> > > write(4, "f\n", 2)                      = 2
> > > read(3, "", 131072)                     = 0
> > > utimensat(4, NULL, {{1495750885, 0}, {1495750885, 0}}, 0) = 0
> > > fgetxattr(3, "system.posix_acl_access", 0x7ffed40196d0, 132) = -1 ENODATA (No data available)
> > > fstat(3, {st_mode=S_IFREG|0644, st_size=2, ...}) = 0
> > > fsetxattr(4, "system.posix_acl_access", "\x02\x00\x00\x00\x01\x00\x06\x00\xff\xff\xff\xff\x04\x00\x04\x00\xff\xff\xff\xff \x00\x04\x00\xff\xff\xff\xff", 28, 0) = -1 EACCES (Permission denied)
> >
> > To me this looks like "cp" is broken.  If it gets no POSIX ACL xattr from the
> > kernel (ENODATA) for this file, why is it trying to save a POSIX ACL to the
> > copy?  That just adds needless overhead, either at the syscall level, or also
> > on disk if it is storing ACLs on files that don't need them...
> 
> Maybe you are right.
> But on v4.11, it succeeded.
> 
> open("../ro/f_src", O_RDONLY)           = 3
> fstat(3, {st_mode=S_IFREG|0644, st_size=2, ...}) = 0
> open("./f_src", O_WRONLY|O_CREAT|O_EXCL, 0600) = 4
> fstat(4, {st_mode=S_IFREG|0600, st_size=0, ...}) = 0
> fadvise64(3, 0, 0, POSIX_FADV_SEQUENTIAL) = 0
> mmap(NULL, 139264, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f3dcf031000
> read(3, "f\n", 131072)                  = 2
> write(4, "f\n", 2)                      = 2
> read(3, "", 131072)                     = 0
> utimensat(4, NULL, {{1495842847, 0}, {1495842847, 0}}, 0) = 0
> fgetxattr(3, "system.posix_acl_access", 0x7fff63443360, 132) = -1 ENODATA (No data available)
> fstat(3, {st_mode=S_IFREG|0644, st_size=2, ...}) = 0
> fsetxattr(4, "system.posix_acl_access", "\x02\x00\x00\x00\x01\x00\x06\x00\xff\xff\xff\xff\x04\x00\x04\x00\xff\xff\xff\xff \x00\x04\x00\xff\xff\xff\xff", 28, 0) = 0
> 
> 
> J. R. Okajima
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
