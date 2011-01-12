Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59069 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750722Ab1ALS20 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jan 2011 13:28:26 -0500
Subject: Re: Regression, bisected: NFS O_EXCL breakage in 2.6.37 client.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Nick Bowler <nbowler@elliptictech.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
In-Reply-To: <20110112161054.GA3431@elliptictech.com>
References: <20110112161054.GA3431@elliptictech.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 12 Jan 2011 13:28:09 -0500
Message-ID: <1294856889.2971.43.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-12 at 11:10 -0500, Nick Bowler wrote: 
> With 2.6.37 (client), opens on NFS with O_CREAT | O_EXCL are
> occasionally succeeding when the file already exists, apparently
> depending on the state of the filesystem cache.  The issue was observed
> because mplayer would randomly overwrite its config file...
> 
> Using the test program (./nfsbreak) included in this mail, I can
> reproduce it as follows (/home/nbowler is the NFS mount point).  No
> interesting kernel messages appear on either the client or server
> machines during the test:
> 
>   % mkdir /home/nbowler/nfsexcl
>   % ./nfsbreak
>   nfsbreak: File opened <<< This is OK
>   % ./nfsbreak
>   nfsbreak: File exists
>   % ./nfsbreak
>   nfsbreak: File exists
>   % su -c 'echo 2 > /proc/sys/vm/drop_caches'
>   % ./nfsbreak
>   nfsbreak: File opened <<< Uhoh!
>   % ./nfsbreak
>   nfsbreak: File exists
> 
> Here's the nfsbreak C source:
> 
>   #include <stdio.h>
>   #include <stdlib.h>
>   #include <fcntl.h>
> 
>   int main(void)
>   {
>     int fd;
> 
>     /* /home/nbowler is the NFS mount point */
>     fd = open("/home/nbowler/nfsexcl/nfsexcl", O_WRONLY|O_CREAT|O_EXCL);
>     if (fd == -1) {
>       perror("nfsbreak");
>       return EXIT_FAILURE;
>     }
> 
>     puts("nfsbreak: File opened");
>     return 0;
>   }
> 
> This is a regression from 2.6.36; bisection implicates the following,
> which unfortunately does not revert cleanly.

Confirmed. The breakage does not affect NFSv4, but is limited to NFSv3.
The following patch should therefore suffice to fix it.

Cheers
  Trond

8<--------------------------------------------------------------------- 
