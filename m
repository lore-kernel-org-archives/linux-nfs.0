Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f46.google.com ([209.85.219.46]:64086 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751040Ab2J2OJ3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2012 10:09:29 -0400
Received: by mail-oa0-f46.google.com with SMTP id h16so4676961oag.19
        for <linux-nfs@vger.kernel.org>; Mon, 29 Oct 2012 07:09:29 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 29 Oct 2012 18:09:29 +0400
Message-ID: <CAA91j0VBWhT58iyNDTMXVnMU8skJTEwHyezD_HyhmaqW5+pt3w@mail.gmail.com>
Subject: Effective process GID is ignored when client creates file on NFS
From: Andrey Borzenkov <arvidjaar@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have met application that is badly broken when installed on NFS. The
reason is - it expects files to belong to specific group. It switches
to this group on startup (explicit setgid) and creates files. But
files come out as belonging to GID 0.

I finally reduced it to this trivial script:

=== cut here ===
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

main()
{
        int fd;

        setgid(107);
        fd = open("bar", O_CREAT, 0666);
        close(fd);
}
=== cut here ===

On local storage file comes with GID 107; on NFS file comes with GID 0.

Linux is SLES10 SP3 with relatively old kernel: 2.6.16.60-0.89.1-smp,
server(s) are NetApp with different Data ONTAP versions (7.x and 8.1.1
as the last).

Client passes correct credentials (UID:0, GID:107), but does not
explicitly request file ownership in CREATE call (uid set_it - 0, gid
set_it - 0).

I am not sure whether this is a bug and if yes, on which side. I
appreciate any hint. Thank you!

-andrey
