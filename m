From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Client cache updates missing? (2.6.31.5)
Date: Mon, 30 Nov 2009 13:26:43 -0500
Message-ID: <20091130182643.GB6348@fieldses.org>
References: <4B122FB2.7040505@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:38407 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752601AbZK3SZn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Nov 2009 13:25:43 -0500
In-Reply-To: <4B122FB2.7040505-Q2TZfHgGEy4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 29, 2009 at 09:24:18AM +0100, Jesper Krogh wrote:
> Hi.
> 
> I'm seeing some random odd behaviour on my NFS clients. It is
> not directly reproducible, but I have had users telling me about, but
> until you hit stuff like this yourself .. you almost dont believe it.
> 
> jk@bach:~$ ssh nfsserver ls -ltrah | grep blast-2.out
> -rw-rw-r--   1 jk jk 552K 2009-11-29 09:10 blast-2.out
> jk@bach:~$ ls -tlrha  | grep blast-2.out
> jk@bach:~$ date
> Sun Nov 29 09:17:14 CET 2009
> jk@bach:~$ stat blast-2.out
>   File: `blast-2.out'
>   Size: 564283    	Blocks: 1112       IO Block: 1048576 regular file
> Device: 18h/24d	Inode: 139405089   Links: 1
> Access: (0664/-rw-rw-r--)  Uid: ( 1000/      jk)   Gid: ( 1000/      jk)
> Access: 2009-11-29 09:07:34.000000000 +0100
> Modify: 2009-11-29 09:10:27.000000000 +0100
> Change: 2009-11-29 09:10:27.0000
> 
> So.. the file has been present for 7 minutes on the NFS-server (and any
> client doing a fresh mount) but the client I'm sitting on is not having
> the file in the directory listing, but if I explicitly ask for it.. its
> there.
> 
> Wether or not it has anything to do. The file has been written to the
> NFS-server from another NFS-client. The server is running 2.6.31.5 and
> the client that above was run on is 2.6.24-24 (Ubuntu Jaunty), the
> client that wrote the file was running 2.6.29.1.

I this v3 or v4?  What's the exported filesystem?  (ext3?)

It's probably a timestamp resolution problem; if the directory was
modified twice in the same second, the later change won't change the
timestamp, and so the client may assume its cache is still good.

Recent clients try a little harder to work around this.  On the server
side it should help to switch to a filesystem with better than 1-second
timestamp resolution.

--b.
