From: =?ISO-8859-1?Q?Sven_K=F6hler?= <skoehler@upb.de>
Subject: Re: why do i get "Stale NFS file handle" for hours?
Date: Sun, 05 Sep 2004 04:23:24 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <413A789C.9000501@upb.de>
References: <chdp06$e56$1@sea.gmane.org>	 <1094348385.13791.119.camel@lade.trondhjem.org>  <413A7119.2090709@upb.de> <1094349744.13791.128.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S265973AbUIECXR@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1094349744.13791.128.camel@lade.trondhjem.org>
List-ID: <nfs.lists.sourceforge.net>

>>I agree, but you simply admit that the NFS client doesn't seem to know, 
>>when the server was restart. The simpliest thing i can imagine, is that 
>>the NFS server generates a random integer-value at start, and transmits 
>>it along with ESTALE. If the integer-value is different from the 
>>integer-value the server send while mounting the FS, than the kernel has 
>>to remount it transparently. This is a simple thing so that a client can 
>>safely determine, if the server has been restarted, or not, and it only 
>>adds 4 byte to some nfs-packets.
> 
> No.... The simplest thing is for the server to actually abide by the
> RFCs and not generate filehandles that change on reboot.

OK, that sounds complicated, but if it would work, than it would be very 
nice indeed.

> NFSv4 is the ONLY version of the protocol that actually supports the
> concept of filehandles that have a finite lifetime.

But NFSv4 is still exprerimental :-( and i think the client don't have 
NFSv4 support too.

>>In my case, if the nfs directory is mounted to /mnt/nfs, i can't even do 
>>a simple "cd /mnt/nfs" without getting the "stale nfs handle" - even if 
>>i use a different shell. I always thought, that the "cd /mnt/nfs" should 
>>work, since the shell will aquire a new handle, but it doesn't work :-(
> 
> It won't if the root filehandle is broken too. That is the standard way
> of telling the NFS client that the administrator has revoked our access
> to the filesystem.
> 
> The solution is simple here: fix the broken server...

Sorry? Why is my server broken? I'm using kernel 2.6.8.1 with nfs-utils 
1.0.6 on my server, and i don't see, what should be broken.

Thx
   Sven
