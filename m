Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51455 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751424Ab1LHVVw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Dec 2011 16:21:52 -0500
Date: Thu, 8 Dec 2011 16:21:51 -0500
To: Chris J Arges <chris.j.arges@canonical.com>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trond@netapp.com>
Subject: Re: [PATCH] nfsd4: permit read opens of executable-only files
Message-ID: <20111208212151.GF32505@fieldses.org>
References: <20110825161957.GC1114@fieldses.org>
 <loom.20111207T233110-295@post.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <loom.20111207T233110-295@post.gmane.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 07, 2011 at 10:42:32PM +0000, Chris J Arges wrote:
> J. Bruce Fields <bfields@...> writes:
> 
> > 
> > From: J. Bruce Fields <bfields@...>
> > 
> > A client that wants to execute a file must be able to read it.  Read
> > opens over nfs are therefore implicitly allowed for executable files
> > even when those files are not readable.
> > 
> > NFSv2/v3 get this right by using a passed-in NFSD_MAY_OWNER_OVERRIDE on
> > read requests, but NFSv4 has gotten this wrong ever since
> > dc730e173785e29b297aa605786c94adaffe2544 "nfsd4: fix owner-override on
> > open", when we realized that the file owner shouldn't override
> > permissions on non-reclaim NFSv4 opens.
> > 
> > So we can't use NFSD_MAY_OWNER_OVERRIDE to tell nfsd_permission to allow
> > reads of executable files.
> > 
> > So, do the same thing we do whenever we encounter another weird NFS
> > permission nit: define yet another NFSD_MAY_* flag.
> > 
> > The industry's future standardization on 128-bit processors will be
> > motivated primarily by the need for integers with enough bits for all
> > the NFSD_MAY_* flags.
> > 
> > Reported-by: Leonardo Borda <leonardoborda@...>
> > Cc: stable@...
> > Signed-off-by: J. Bruce Fields <bfields@...>
> > ---
> <snip>
> 
> 
> Bruce,
> 
> I've tested this patch against linux-3.0 and it doesn't allow me to execute 
> binaries with permissions of 111.

Hm, I see the same permissions error.  However, looking at the
client-server traffic with wireshark, I see no permissions failures from
the server: the read-open of cat succeeds.  (Could you check if the same
is true in your case?)

So my first inclination is to blame the client.... Does this work with
an older client?

--b.

> Here is the BugLink for the Ubuntu bug: 
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/833300
> My method of reproducing the bug is documented here: 
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/833300/comments/22
> This is copied and pasted below:
> I can reproduce this failure on natty/oneiric just fine.
> 
> I then applied the upstream patch (a043226bc140a2c1dde162246d68a67e5043e6b2), 
> that was identified in the public bug and upstream bug.
> 
> After doing this I installed the tools on my laptop:
>   apt-get install nfs-common nfs-kernel-server
> 
> Then I setup of /etc/exports as described in the bug to a directory on my laptop 
> (ext4).
>   /path/to/dir *(rw,sync,fsid=0,no_subtree_check)
> 
> I then had to insert the module and restart the server:
>   sudo modprobe nfs
>   sudo service nfs-kernel-server restart
> 
> I mounted the directory:
>   sudo mount -t nfs4 -o proto=tcp,port=2049 localhost:/ /mnt
> 
> I created a similar c program and compiled. I put this into the shared folder.
> I could run it with normal permissions.
> I then did 'chmod 111 ./a.out' and then I could not run the program (Permission 
> denied) if I was doing it via the /mnt directory.
> 
> arges@arges-virtual-machine:/mnt$ ls -la
> total 24
> drwxr-xr-x 2 4294967294 4294967294 4096 2011-11-17 10:12 .
> drwxr-xr-x 22 root root 4096 2011-11-17 09:57 ..
> ---x--x--x 1 4294967294 4294967294 8425 2011-11-17 10:12 a.out
> -rw-r--r-- 1 4294967294 4294967294 73 2011-11-17 10:12 hello.c
> arges@arges-virtual-machine:/mnt$ ./a.out
> -bash: ./a.out: Permission denied
> arges@arges-virtual-machine:/mnt$ mount -v
> /dev/vda1 on / type ext4 (rw,errors=remount-ro,commit=0)
> <snip>
> nfsd on /proc/fs/nfsd type nfsd (rw)
> localhost:/ on /mnt type nfs (rw,vers=4,addr=127.0.0.1,clientaddr=127.0.0.1)
> 
> I could run it if I wasn't running it over the nfsv4 share (sanity check):
> 
> arges@arges-virtual-machine:/mnt$ cd ~/Test/
> arges@arges-virtual-machine:~/Test$ ls -la
> total 24
> drwxr-xr-x 2 arges arges 4096 2011-11-17 10:12 .
> drwxr-xr-x 22 arges arges 4096 2011-11-17 10:10 ..
> ---x--x--x 1 arges arges 8425 2011-11-17 10:12 a.out
> -rw-r--r-- 1 arges arges 73 2011-11-17 10:12 hello.c
> arges@arges-virtual-machine:~/Test$ ./a.out
> hello binary
> 
> 
> 
> Thanks,
> --chris j arges
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
