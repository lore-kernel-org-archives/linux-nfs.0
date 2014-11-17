Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:38918 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134AbaKQWHI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Nov 2014 17:07:08 -0500
MIME-Version: 1.0
From: Steve French <smfrench@gmail.com>
Date: Mon, 17 Nov 2014 16:06:46 -0600
Message-ID: <CAH2r5muERU4zTCV0ZP+m38mHgynr90iktr5_pJMBVgRaDQON0w@mail.gmail.com>
Subject: xfstest generic/035 and rename
To: "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Cc: fstests@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xfstest generic/035 fails on nfs (various ways) and cifs and smb3
(differently) and brings up interesting problems with how fstat works.

The test case is quite simple, t_rename_overwrite is the key piece of
code - which basically does open a directory, rename over it and fstat
the now deleted directory (and checks that it has a link count of zero
since it is going to be deleted as soon as it is closed)

fd = open(path2, O_RDONLY);
if (fd == -1)
err(1, "open(\"%s\")", path2);

res = rename(path1, path2);
if (res == -1)
err(1, "rename(\"%s\", \"%s\")", path1, path2);

res = fstat(fd, &stbuf);
if (res == -1)
err(1, "fstat(%i)", fd);

if (stbuf.st_nlink != 0) {
fprintf(stderr, "nlink of %s to %s is %lu, should be 0\n", path1,
path2, stbuf.st_nlink);
return 1;
}

Local file systems work whether source and target are files or
directories. NFS fails with "stale file handle" when you pass in a
directory and with an invalid link count (1 instead of 0) when you
pass in a file.    CIFS and SMB3 return the link count as two for the
directory case because fstat calls getattr (which ends up as a path
based call which gets a dentry) and so we end up looking up the wrong
thing (the newly renamed file, instead of the still open target which
has been deleted).   This works for cifs for the file case (renaming a
file over a file) but not for smb3 (since we don't fallback code to
handle access denied on rename - at least not yet, it needs to be
added).

But it brings up obvious questions:
- why does getattr use a dentry rather than a file handle when called
from fstat?
- is NFS posix compliant by returning "stale file handle" (seems
reasonable to me) on a getattr of an overwritten directory?
- should NFS fix the case where the target is a file and has the wrong
link count?
-- 
Thanks,

Steve
