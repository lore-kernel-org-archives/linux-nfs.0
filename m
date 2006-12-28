From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [NFS] VFS: Busy inodes after unmount. Self-destruct in 5 seconds.
 Have a nice day...
Date: Thu, 28 Dec 2006 08:02:09 -0500
Message-ID: <4593C051.2020400@redhat.com>
References: <200612281027.09783.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753526AbWL1NC0@vger.kernel.org>
To: Jesper Juhl <jesper.juhl@gmail.com>
In-Reply-To: <200612281027.09783.jesper.juhl@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Jesper Juhl wrote:
> I get this message in my webservers (with NFS mounted homedirs) logs once 
> in a while : 
> 
>   kernel: VFS: Busy inodes after unmount. Self-destruct in 5 seconds.  Have a nice day...
> 
> It doesn't seem to have any bad effect on anything, but it would be nice 
> to know if there is any cause for concern.
> 

It is cause for concern. This means that the filesystem was unmounted (and the 
superblock was freed), but the inode structs are still hanging around. The 
"self-destruct" is telling you that eventually, this machine will crash due to 
this. If you see this message you should probably plan a reboot sometime.

What will happen is that eventually the kernel may try to reference these 
inodes, but they now have pointers into a freed superblock. If that superblock 
memory was reused for another purpose, you'll likely crash.

IMO, we should probably consider this to be a BUG(), but that only really is 
helpful if you can capture a coredump and can try to track down why these inodes 
couldn't be flushed correctly. In the very least, it's probably time to change 
this message to be less cryptic.

I've seen some sporadic reports of this problem on earlier kernels in situations 
where a NFS server is unable to be contacted for a while, but have not gotten 
enough info to get a handle on it.

-- Jeff
