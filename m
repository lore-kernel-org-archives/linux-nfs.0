Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2988 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751078Ab1AEBmt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Jan 2011 20:42:49 -0500
Subject: Re: flock gives EIO on NFSv4, works on NFSv3
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Simon Kirby <sim@hostway.ca>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20110104234938.GM27727@hostway.ca>
References: <20110104234938.GM27727@hostway.ca>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 04 Jan 2011 20:42:45 -0500
Message-ID: <1294191765.5896.35.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-01-04 at 15:49 -0800, Simon Kirby wrote: 
> Hello,
> 
> In testing NFSv4, I found that this lock test script fails with EIO:
> 
> #!/usr/bin/perl
> 
> $|=1;
> use Fcntl qw(:DEFAULT :flock);
> open(IN, "< locktest.pl") or die "open: $!";
> print "Locking...\n";
> flock(IN,LOCK_EX) or die "flock $filename: $!";
> print "Locked.\n";
> sleep(4);
> print "Unlocking...\n";
> close(IN);
> exit(0);
> 
> This just locks itself (assuming it's called locktest.pl).  This works
> fine over NFSv3, but with NFSv4, I'm seeing:
> 
> flock(3, LOCK_EX)                       = -1 EIO (Input/output error)
> 
> tcpdump and NFS debugging shows status "10038", which as far as I can
> tell is "NFS4ERR_OPENMODE".

That is known and expected behaviour. We have to map flock() onto byte
range locks (i.e. POSIX locks), and since LOCK_EX has to map to a write
lock in order to give exclusive semantics, the server will not allow it
when you only have the file open for reading.

Cheers
   Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

