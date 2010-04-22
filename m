Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:58406 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753304Ab0DVBRc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Apr 2010 21:17:32 -0400
Date: Thu, 22 Apr 2010 03:17:27 +0200
From: Stefan =?iso-8859-1?Q?Kr=FCger?= <stadtkind2@gmx.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: strange performance issues with OS X 10.6 client
Message-ID: <20100422011727.GA1147@gmx.de>
References: <20100415214900.GA4143@web.de>
 <20100419122120.GA3716@gmx.de>
 <4BCC8C06.1080106@oracle.com>
 <20100420212116.GA161@gmx.de>
 <4BCE1F6A.6000902@oracle.com>
 <20100420224408.GB161@gmx.de>
 <E44BE585-6051-470A-900A-7B4520782A0D@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E44BE585-6051-470A-900A-7B4520782A0D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 21 Apr 2010, Chuck Lever wrote:

> So, VMware is probably not waiting for disk writes to complete, since NFS
> servers in VMware guests run faster than native.  Note to self: never put
> mission critical data on NFS servers running as VMware guests.

yeah I only did this for testing...

> Still, the Linux NFS server has some kind of problem here when comparing
> apples to apples.  Does increasing the number of nfsd threads on the server
> help?

Increasing the number of nfsd threads did not help (I raised them from 8 to
32 but Fedora is still crawling when extracting the tgz file, nfsstat numbers
below are with 8 nfsd threads on both Fedora and FreeBSD)

So speaking of nfsstat, I've got some new statistics, this time I extracted
the whole tgz and not just a single directory (+ files) inside it (statistics
zeroed before ofc, both tests run on bare metal and on same hardware,
network, etc.)

Fedora 12:

Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
45960      0          0          0          0       

Server nfs v3:
null         getattr      setattr      lookup       access       readlink     
1         0% 641       1% 6885     14% 10373    22% 18336    39% 0         0% 
read         write        create       mkdir        symlink      mknod        
1917      4% 2552      5% 1999      4% 228       0% 0         0% 0         0% 
remove       rmdir        rename       link         readdir      readdirplus  
633       1% 0         0% 3         0% 0         0% 0         0% 3         0% 
fsstat       fsinfo       pathconf     commit       
21        0% 1         0% 1         0% 2366      5% 

FreeBSD 8:

Server Info:
  Getattr   Setattr    Lookup  Readlink      Read     Write    Create Remove
      628      6421      5287         3       703      2490      1991 629
   Rename      Link   Symlink     Mkdir     Rmdir   Readdir  RdirPlus Access
        3         0         0       229         2         0         2 6526
    Mknod    Fsstat    Fsinfo  PathConf    Commit
        0         5         1         1      2402
Server Ret-Failed
             5267
Server Faults
            0
Server Cache Stats:
   Inprog      Idem  Non-idem    Misses
        0         0         0         0
Server Write Gathering:
 WriteOps  WriteRPC   Opsaved
     2490      2490         0

First thing that catches my eyes is Access, it's 3x higher on Fedora, next
would be Lookup and Read, both 2x higher

MacOS 10.6 nfsstat client statistics after extracting on Fedora 12:

Client Info:
RPC Counts:
  Getattr   Setattr    Lookup  Readlink      Read     Write    Create Remove
      640      6885     10380         0      1919      2553      1999 634
   Rename      Link   Symlink     Mkdir     Rmdir   Readdir  RdirPlus Access
        3         0         0       228         1         0         3 18353
    Mknod    Fsstat    Fsinfo  PathConf    Commit
        0        21         1         1      2367
RPC Info:
 TimedOut   Invalid X Replies   Retries  Requests
        0         0         0         0     45989
Cache Info:
Attr Hits    Misses Lkup Hits    Misses BioR Hits    Misses BioW Hits Misses
    84529      5034      9021      9408      5235      1701       766 2553
BioRLHits    Misses BioD Hits    Misses DirE Hits    Misses
        0         0         1         3         4         0


... after extracting on FreeBSD 8:

Client Info:
RPC Counts:
  Getattr   Setattr    Lookup  Readlink      Read     Write    Create Remove
      628      6421      5290         3       704      2490      1991 630
   Rename      Link   Symlink     Mkdir     Rmdir   Readdir  RdirPlus Access
        3         0         0       229         3         0         2 6538
    Mknod    Fsstat    Fsinfo  PathConf    Commit
        0         5         1         1      2402
RPC Info:
 TimedOut   Invalid X Replies   Retries  Requests
        0         0         0         0     27342
Cache Info:
Attr Hits    Misses Lkup Hits    Misses BioR Hits    Misses BioW Hits Misses
    36508      1529      1817      4317       958       704       767 2490
BioRLHits    Misses BioD Hits    Misses DirE Hits    Misses
        1         3         1         7         3         0

Well this mostly matches what we've seen in the nfs server statistics,
even though a lot more caching was done when using the Fedora nfs server

nfsstat manpage on OSX explains them as:
Attr Hits/Misses - Performance of the NFS file attribute cache.
Lkup Hits/Misses - Performance of the directory name lookup cache.
BioR Hits/Misses - Performance of block cache for reads.
BioW Hits/Misses - Performance of block cache for writes.
BioRL Hits/Misses - Performance of symbolic link cache.
BioD Hits/Misses - Performance of directory cache.
DirE Hits/Misses - Performance of directory offset cache.

I've also captured the traffic from both sessions with tcpdump, it's quite
huge though, 42MB for Fedora and 10MB for FreeBSD... let me know if you want
to take a look

TIA

PS: Please let me say again that extraction time using FreeBSD nfs is 10
*seconds* while on Fedora it's over 5 *minutes*...
