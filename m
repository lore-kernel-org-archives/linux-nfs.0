From: "Adam Olsen" <arolsen@gmail.com>
Subject: Re: NFS+GD issues on kernel 2.6.24, but not 2.6.22
Date: Thu, 15 May 2008 15:19:54 -0600
Message-ID: <2473b43f0805151419l3b773803y28ad8a86887cc0a5@mail.gmail.com>
References: <2473b43f0805150706g5be9918cu3c77d9135cded912@mail.gmail.com>
	 <20080515084610.4e5161bc@tupile.poochiereds.net>
	 <2473b43f0805150855o59a14e34h82b20f847c53f392@mail.gmail.com>
	 <1210876652.17301.3.camel@localhost>
	 <2473b43f0805151315m3547bc17o57ca14c46a636671@mail.gmail.com>
	 <20080515164913.7e161c30@tupile.poochiereds.net>
	 <20080515165639.40e92911@tupile.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:41608 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753735AbYEOVTy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 May 2008 17:19:54 -0400
Received: by wf-out-1314.google.com with SMTP id 27so549526wfd.4
        for <linux-nfs@vger.kernel.org>; Thu, 15 May 2008 14:19:54 -0700 (PDT)
In-Reply-To: <20080515165639.40e92911-PC62bkCOHzGdMjc06nkz3ljfA9RmPOcC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 15, 2008 at 2:56 PM, Jeff Layton <jlayton@redhat.com> wrote:
>  Actually...my suspicion is that Trond is right and this app (or maybe a
>  library) doesn't like 64 bit inode numbers. It was probably not built
>  with LFS defines. glibc will turn that into a fstat64() system call,
>  and when it gets an inode number that won't fit in the field, it will
>  generate a -EOVERFLOW in userspace. You won't see it in an strace. An
>  ltrace *might* show it, or you could hook up gdb to your program and
>  try to look at it that way.

Ok, the library is freetype.  I'll look for related bugs on their
site.  Why does it work in kernel 2.6.22, though?

-- 
Adam Olsen
SendOutCards.com
http://www.vimtips.org
http://last.fm/user/synic
