From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: VFS: Busy inodes after unmount. Self-destruct in 5 seconds.
 Have a nice day...
Date: Thu, 28 Dec 2006 10:43:29 +0100 (MET)
Message-ID: <Pine.LNX.4.61.0612281041340.15825@yvahk01.tjqt.qr>
References: <200612281027.09783.jesper.juhl@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932809AbWL1JpF@vger.kernel.org>
To: Jesper Juhl <jesper.juhl@gmail.com>
In-Reply-To: <200612281027.09783.jesper.juhl@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


On Dec 28 2006 10:27, Jesper Juhl wrote:
>
>I get this message in my webservers (with NFS mounted homedirs) logs once 
>in a while : 
>
>  kernel: VFS: Busy inodes after unmount. Self-destruct in 5 seconds.  Have a nice day...

This happens when the underlying "block device" disappears, the most 
prominent case being ejecting the CD while the fs is still mounted. I 
have not seen it with nfs yet, since networked fs don't have any 
real backing device and instead provide either [waiting for 
reconnection] or -EIO, i.e. proper error handling.

>

	-`J'
-- 
