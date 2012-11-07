Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53396 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754519Ab2KGTNh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Nov 2012 14:13:37 -0500
Date: Wed, 7 Nov 2012 14:13:36 -0500
To: Andrey Borzenkov <arvidjaar@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Effective process GID is ignored when client creates file on NFS
Message-ID: <20121107191336.GE7421@fieldses.org>
References: <CAA91j0VBWhT58iyNDTMXVnMU8skJTEwHyezD_HyhmaqW5+pt3w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAA91j0VBWhT58iyNDTMXVnMU8skJTEwHyezD_HyhmaqW5+pt3w@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 29, 2012 at 06:09:29PM +0400, Andrey Borzenkov wrote:
> I have met application that is badly broken when installed on NFS. The
> reason is - it expects files to belong to specific group. It switches
> to this group on startup (explicit setgid) and creates files. But
> files come out as belonging to GID 0.
> 
> I finally reduced it to this trivial script:
> 
> === cut here ===
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <fcntl.h>
> #include <unistd.h>
> 
> main()
> {
>         int fd;
> 
>         setgid(107);
>         fd = open("bar", O_CREAT, 0666);
>         close(fd);
> }
> === cut here ===
> 
> On local storage file comes with GID 107; on NFS file comes with GID 0.
> 
> Linux is SLES10 SP3 with relatively old kernel: 2.6.16.60-0.89.1-smp,
> server(s) are NetApp with different Data ONTAP versions (7.x and 8.1.1
> as the last).
> 
> Client passes correct credentials (UID:0, GID:107), but does not

Those are the credentials in the rpc header on the CREATE call?

> explicitly request file ownership in CREATE call (uid set_it - 0, gid
> set_it - 0).

The client shouldn't have to set the owner or group itself.

So this is server behavior.

Have you checked that the directory you're creating in doesn't have the
sgid bit?  Or perhaps there's some other server configuration that
causes this.

--b.

> 
> I am not sure whether this is a bug and if yes, on which side. I
> appreciate any hint. Thank you!
> 
> -andrey
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
