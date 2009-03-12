Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:41787 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750752AbZCLBnW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2009 21:43:22 -0400
Subject: Re: Intermittent NFS problems with NetApp server
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Alfred von Campe <alfred@von-campe.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <96B48952-DA6E-457C-AFAF-B8A96A29CDF1@von-campe.com>
References: <96B48952-DA6E-457C-AFAF-B8A96A29CDF1@von-campe.com>
Content-Type: text/plain
Date: Wed, 11 Mar 2009 21:43:16 -0400
Message-Id: <1236822196.21941.23.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2009-03-11 at 20:57 -0400, Alfred von Campe wrote:
> I've been experiencing some intermittent problems accessing at NetApp
> server via NFS and automount.  I'm running CentOS 5.2 (fully updated)
> on all my servers and workstations.  Usually, everything is working
> just fine, when suddenly we get the following error:
> 
>     /bin/sh: /home/epd/srcref/swtools/Crontabs/ 
> run_release_requests.sh: Permission denied
> 
> This is actually an email from cron because we try to run that shell
> script every minute (yes, the crontab entry is * * * * * /home/epd/
> srcref/swtools/Crontabs/run_release_requests.sh), and /home/epd is an
> automounted directory.  Here is its map entry:
> 
>     epd -rw,nointr,rsize=32768,wsize=32768 XXXXXX:/epd
> 
> When this is happening, other users can successfully access that
> directory on the server.  The directory is actually mounted
> correctly, and unmounting doesn't fix the issue.  Furthermore, the
> same user that is being denied access, can successfully access that
> directory on a different server.  The problem usually lasts about 20
> minutes and then resolves itself.  We have been pulling our hair out
> trying to debug this problem, because it's intermittent and the debug
> window is fairly short.
> 
> Recently we have been getting help from one of the NetApp admins, and
> he ran a command on the NetApp that produced the following warning:
> 
>     The TCP receive window advertised by NFS client XXXXXXX is 5888.
>     This is less than the recommended value of 32768 bytes.
>     You should increase the TCP receive buffer size for NFS on the  
> client.
> 
> Some googling around got me to check these values for TCP:
> 
>     # sysctl net.ipv4.tcp_mem
>     net.ipv4.tcp_mem = 98304        131072  196608
>     # sysctl net.ipv4.tcp_rmem
>     net.ipv4.tcp_rmem = 4096        87380   4194304
>     # sysctl net.ipv4.tcp_wmem
>     net.ipv4.tcp_wmem = 4096        16384   4194304
> 
> So these seem fine to me (i.e., the max is greater than 32768).  Is
> there an NFS (as opposed to TCP) setting I should be tweaking?  Any
> ideas why the NetApp is issuing those warnings?  Any other
> suggestions on how to debug this problem?

In TCP, the send and receive window sizes are values that are negotiated
dynamically by the sender and receiver. These values depends on all
sorts of dynamic parameters that measure the current state of the
network.
IOW: I can't see how TCP window size could be the problem here: the
server should be able to cope just fine with a small window size (as all
TCP streams are required to do).

How about amending your crontab to do something along the lines of

if [ ! -r /home/epd/srcref/swtools/Crontabs/run_release_requests.sh ]
then
   echo 1 >/proc/sys/sunrpc/nfs_debug
   tshark -s 90000 -w /var/tmp/dump.out host XXXXXXXX and port 2049 &
   sleep 5
   sh /home/epd/srcref/swtools/Crontabs/run_release_requests.sh
   kill %1
   echo 0 >/proc/sys/sunrpc/nfs_debug
fi

to try to get a tcpdump and an NFS syslog dump of what's going on?

Trond

