From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: VFS: Busy inodes after unmount. Self-destruct in 5 seconds.  Have a nice day...
Date: Thu, 28 Dec 2006 10:27:09 +0100
Message-ID: <200612281027.09783.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net, jesper.juhl@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964996AbWL1J1U@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


I get this message in my webservers (with NFS mounted homedirs) logs once 
in a while : 

  kernel: VFS: Busy inodes after unmount. Self-destruct in 5 seconds.  Have a nice day...

It doesn't seem to have any bad effect on anything, but it would be nice 
to know if there is any cause for concern.

The NFS server is running 2.6.18.1 and the webservers are running 2.6.17.8


-- 
Jesper Juhl <jesper.juhl@gmail.com>
