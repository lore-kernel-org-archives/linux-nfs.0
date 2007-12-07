From: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Subject: Re: [NFS] NFSv2/3 broken exporting/mounting (permission denied) in
	2.6.24-rc4
Date: Fri, 7 Dec 2007 15:05:12 -0500
Message-ID: <200712072005.lB7K5Cre013747__12305.7092576802$1197058026$gmane$org@agora.fsl.cs.sunysb.edu>
References: <20071207025504.GA3070@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:38933 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757708AbXLGUFk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Dec 2007 15:05:40 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1J0jS5-0007aQ-SL
	for linux-nfs@vger.kernel.org; Sat, 08 Dec 2007 07:05:37 +1100
In-reply-to: Your message of "Thu, 06 Dec 2007 21:55:04 EST."
	<20071207025504.GA3070@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In message <20071207025504.GA3070@fieldses.org>, "J. Bruce Fields" writes:
> On Thu, Dec 06, 2007 at 09:20:41PM -0500, Erez Zadok wrote:
> > I get a "permission denied" when trying to mount a localhost nfsv2/3
> > exported volume, on v2.6.24-rc4-124-gf194d13.  It works w/ nfsv4 mounting.
> > It worked fine in 2.6.24-rc3.  Here's a sequence of ops I tried:
> > 
> > # mount -t ext2 /dev/hdb1 /n/lower/b0
> > # exportfs -o no_root_squash,rw localhost:/n/lower/b0
> > # mount -t nfs -o nfsvers=3 localhost:/n/lower/b0 /mnt
> 
> What do you see if you watch the network traffic in ethereal?
> 
> --b.

Bruce, I'm using nfs-utils-1.0.10-14.fc6 on an FC6 system with all latest
FC6 patches.  Using git-bisect I was able to find the patch which broke it:

commit 2b1e300a9dfc3196ccddf6f1d74b91b7af55e416
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Sun Dec 2 00:33:17 2007 +1100

    [NETNS]: Fix /proc/net breakage
    
    Well I clearly goofed when I added the initial network namespace support
    for /proc/net.  Currently things work but there are odd details visible to
    user space, even when we have a single network namespace.
    
    Since we do not cache proc_dir_entry dentries at the moment we can just
    modify ->lookup to return a different directory inode depending on the
    network namespace of the process looking at /proc/net, replacing the
    current technique of using a magic and fragile follow_link method.
    
    To accomplish that this patch:
    - introduces a shadow_proc method to allow different dentries to
      be returned from proc_lookup.
    - Removes the old /proc/net follow_link magic
    - Fixes a weakness in our not caching of proc generic dentries.
    
    As shadow_proc uses a task struct to decided which dentry to return we can
    go back later and fix the proc generic caching without modifying any code
    that uses the shadow_proc method.
    
    Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
    Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
    Cc: Pavel Machek <pavel@ucw.cz>
    Cc: Pavel Emelyanov <xemul@openvz.org>
    Cc: "David S. Miller" <davem@davemloft.net>
    Cc: Ingo Molnar <mingo@elte.hu>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>

With the above patch, rpc.mountd is unable to open /proc/fs/nfsd/filehandle.
Strace shows:

open("/proc/fs/nfsd/filehandle", O_RDWR|O_LARGEFILE) = -1 ENOENT (No such file or directory)

Without the above patch, /proc/fs/nfsd is populated with a number of files,
including "filehandle".

Erez.

-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

