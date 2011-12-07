Return-Path: linux-nfs-owner@vger.kernel.org
Received: from lo.gmane.org ([80.91.229.12]:43709 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756649Ab1LGWpK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Dec 2011 17:45:10 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1RYQEe-0001ZM-4s
	for linux-nfs@vger.kernel.org; Wed, 07 Dec 2011 23:45:08 +0100
Received: from user-387o921.cable.mindspring.com ([208.124.36.65])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 07 Dec 2011 23:45:08 +0100
Received: from chris.j.arges by user-387o921.cable.mindspring.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 07 Dec 2011 23:45:08 +0100
To: linux-nfs@vger.kernel.org
From: Chris J Arges <chris.j.arges@canonical.com>
Subject: Re: [PATCH] nfsd4: permit read opens of executable-only files
Date: Wed, 7 Dec 2011 22:42:32 +0000 (UTC)
Message-ID: <loom.20111207T233110-295@post.gmane.org>
References: <20110825161957.GC1114@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields <bfields@...> writes:

> 
> From: J. Bruce Fields <bfields@...>
> 
> A client that wants to execute a file must be able to read it.  Read
> opens over nfs are therefore implicitly allowed for executable files
> even when those files are not readable.
> 
> NFSv2/v3 get this right by using a passed-in NFSD_MAY_OWNER_OVERRIDE on
> read requests, but NFSv4 has gotten this wrong ever since
> dc730e173785e29b297aa605786c94adaffe2544 "nfsd4: fix owner-override on
> open", when we realized that the file owner shouldn't override
> permissions on non-reclaim NFSv4 opens.
> 
> So we can't use NFSD_MAY_OWNER_OVERRIDE to tell nfsd_permission to allow
> reads of executable files.
> 
> So, do the same thing we do whenever we encounter another weird NFS
> permission nit: define yet another NFSD_MAY_* flag.
> 
> The industry's future standardization on 128-bit processors will be
> motivated primarily by the need for integers with enough bits for all
> the NFSD_MAY_* flags.
> 
> Reported-by: Leonardo Borda <leonardoborda@...>
> Cc: stable@...
> Signed-off-by: J. Bruce Fields <bfields@...>
> ---
<snip>


Bruce,

I've tested this patch against linux-3.0 and it doesn't allow me to execute 
binaries with permissions of 111.
Here is the BugLink for the Ubuntu bug: 
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/833300
My method of reproducing the bug is documented here: 
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/833300/comments/22
This is copied and pasted below:
I can reproduce this failure on natty/oneiric just fine.

I then applied the upstream patch (a043226bc140a2c1dde162246d68a67e5043e6b2), 
that was identified in the public bug and upstream bug.

After doing this I installed the tools on my laptop:
  apt-get install nfs-common nfs-kernel-server

Then I setup of /etc/exports as described in the bug to a directory on my laptop 
(ext4).
  /path/to/dir *(rw,sync,fsid=0,no_subtree_check)

I then had to insert the module and restart the server:
  sudo modprobe nfs
  sudo service nfs-kernel-server restart

I mounted the directory:
  sudo mount -t nfs4 -o proto=tcp,port=2049 localhost:/ /mnt

I created a similar c program and compiled. I put this into the shared folder.
I could run it with normal permissions.
I then did 'chmod 111 ./a.out' and then I could not run the program (Permission 
denied) if I was doing it via the /mnt directory.

arges@arges-virtual-machine:/mnt$ ls -la
total 24
drwxr-xr-x 2 4294967294 4294967294 4096 2011-11-17 10:12 .
drwxr-xr-x 22 root root 4096 2011-11-17 09:57 ..
---x--x--x 1 4294967294 4294967294 8425 2011-11-17 10:12 a.out
-rw-r--r-- 1 4294967294 4294967294 73 2011-11-17 10:12 hello.c
arges@arges-virtual-machine:/mnt$ ./a.out
-bash: ./a.out: Permission denied
arges@arges-virtual-machine:/mnt$ mount -v
/dev/vda1 on / type ext4 (rw,errors=remount-ro,commit=0)
<snip>
nfsd on /proc/fs/nfsd type nfsd (rw)
localhost:/ on /mnt type nfs (rw,vers=4,addr=127.0.0.1,clientaddr=127.0.0.1)

I could run it if I wasn't running it over the nfsv4 share (sanity check):

arges@arges-virtual-machine:/mnt$ cd ~/Test/
arges@arges-virtual-machine:~/Test$ ls -la
total 24
drwxr-xr-x 2 arges arges 4096 2011-11-17 10:12 .
drwxr-xr-x 22 arges arges 4096 2011-11-17 10:10 ..
---x--x--x 1 arges arges 8425 2011-11-17 10:12 a.out
-rw-r--r-- 1 arges arges 73 2011-11-17 10:12 hello.c
arges@arges-virtual-machine:~/Test$ ./a.out
hello binary



Thanks,
--chris j arges



