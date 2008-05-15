From: "Adam Olsen" <arolsen@gmail.com>
Subject: Re: NFS+GD issues on kernel 2.6.24, but not 2.6.22
Date: Thu, 15 May 2008 09:55:16 -0600
Message-ID: <2473b43f0805150855o59a14e34h82b20f847c53f392@mail.gmail.com>
References: <2473b43f0805150706g5be9918cu3c77d9135cded912@mail.gmail.com>
	 <20080515084610.4e5161bc@tupile.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:33391 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757092AbYEOPzT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 May 2008 11:55:19 -0400
Received: by wf-out-1314.google.com with SMTP id 27so442921wfd.4
        for <linux-nfs@vger.kernel.org>; Thu, 15 May 2008 08:55:16 -0700 (PDT)
In-Reply-To: <20080515084610.4e5161bc-PC62bkCOHzGdMjc06nkz3ljfA9RmPOcC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 15, 2008 at 9:46 AM, Jeff Layton <jlayton@redhat.com> wrote:
>  It really depends on the program, but I'd guess that it saw something
>  in the fstat64() call that it didn't like. You might want to use strace
>  with '-v -s 256' or something and look for differences in the info
>  returned by the fstat64 call.

With the working kernel:

access("/mnt/isilon/fonts/arial.ttf", R_OK) = 0
open("/mnt/isilon/fonts/arial.ttf", O_RDONLY) = 3
fcntl64(3, F_SETFD, FD_CLOEXEC)         = 0
fstat64(3, {st_dev=makedev(0, 25), st_ino=4634215,
st_mode=S_IFREG|0666, st_nlink=1, st_uid=1001, st_gid=100,
st_blksize=32768, st_blocks=194, st_size=48784,
st_atime=2008/05/14-11:46:53, st_mtime=2008/05/14-11:46:53,
st_ctime=2008/05/14-21:12:18}) = 0
mmap2(NULL, 48784, PROT_READ, MAP_PRIVATE, 3, 0) = 0xb7a07000
close(3)

With the *non* working kernel:

access("/mnt/isilon/fonts/arial.ttf", R_OK) = 0
open("/mnt/isilon/fonts/arial.ttf", O_RDONLY) = 3
fcntl64(3, F_SETFD, FD_CLOEXEC)         = 0
fstat64(3, {st_dev=makedev(0, 23), st_ino=4299601510,
st_mode=S_IFREG|0666, st_nlink=1, st_uid=1001, st_gid=100,
st_blksize=32768, st_blocks=194, st_size=48784,
st_atime=2008/05/14-11:46:53, st_mtime=2008/05/14-11:46:53,
st_ctime=2008/05/14-21:12:18}) = 0
close(3)                                = 0

Still looks almost identical, except the missing mmap2 in the
non-working kernel.  Also, the st_ino is different... should they be
the same?

-- 
Adam Olsen
SendOutCards.com
http://www.vimtips.org
http://last.fm/user/synic
