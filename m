From: "James Pearson" <james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Subject: Re: NFS+GD issues on kernel 2.6.24, but not 2.6.22
Date: Thu, 15 May 2008 22:29:01 +0100
Message-ID: <a92ebfd90805151429g1fd81ef8qc0e8056b359f4bb2@mail.gmail.com>
References: <2473b43f0805150706g5be9918cu3c77d9135cded912@mail.gmail.com>
	 <20080515084610.4e5161bc@tupile.poochiereds.net>
	 <2473b43f0805150855o59a14e34h82b20f847c53f392@mail.gmail.com>
	 <1210876652.17301.3.camel@localhost>
	 <2473b43f0805151315m3547bc17o57ca14c46a636671@mail.gmail.com>
	 <20080515164913.7e161c30@tupile.poochiereds.net>
	 <20080515165639.40e92911@tupile.poochiereds.net>
Reply-To: james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Adam Olsen" <arolsen@gmail.com>, linux-nfs@vger.kernel.org
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.224]:58679 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160AbYEOV3F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 May 2008 17:29:05 -0400
Received: by wx-out-0506.google.com with SMTP id h29so447956wxd.4
        for <linux-nfs@vger.kernel.org>; Thu, 15 May 2008 14:29:01 -0700 (PDT)
In-Reply-To: <20080515165639.40e92911-PC62bkCOHzGdMjc06nkz3ljfA9RmPOcC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 15/05/2008, Jeff Layton <jlayton@redhat.com> wrote:
>
> Actually...my suspicion is that Trond is right and this app (or maybe a
> library) doesn't like 64 bit inode numbers. It was probably not built
> with LFS defines. glibc will turn that into a fstat64() system call,
> and when it gets an inode number that won't fit in the field, it will
> generate a -EOVERFLOW in userspace. You won't see it in an strace. An
> ltrace *might* show it, or you could hook up gdb to your program and
> try to look at it that way.

We had a similar issue with Isilon NFS mounts - but only had an issue
with non-LFS apps (32 bit) running on 64 bit clients - hence my
previous question ...

The 'fix' we use on the Isilon servers is to enable 32 bit 'fileids'
on the server nodes - the fix is to add the line:

vfs.nfsrv.do_32bit_fileid=1

to /etc/mcp/override/sysctl.conf (or create the file if it doesn't
exist) on any node (it gets copied to all nodes and updated
automagically) - however, _do not_ do this if you have any mounted
clients as are likely to get stale mounts ...

However, we get this issue with earlier 2.6 clients - so I'm not sure
it is exactly the same problem ...

James Pearson
