Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:46218 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751906Ab1AFBgK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jan 2011 20:36:10 -0500
Date: Wed, 5 Jan 2011 17:36:07 -0800
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: flock gives EIO on NFSv4, works on NFSv3
Message-ID: <20110106013607.GA22915@hostway.ca>
References: <20110104234938.GM27727@hostway.ca> <1294191765.5896.35.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1294191765.5896.35.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jan 04, 2011 at 08:42:45PM -0500, Trond Myklebust wrote:

> On Tue, 2011-01-04 at 15:49 -0800, Simon Kirby wrote: 
> > Hello,
> > 
> > In testing NFSv4, I found that this lock test script fails with EIO:
> > 
> > #!/usr/bin/perl
> > 
> > $|=1;
> > use Fcntl qw(:DEFAULT :flock);
> > open(IN, "< locktest.pl") or die "open: $!";
> > print "Locking...\n";
> > flock(IN,LOCK_EX) or die "flock $filename: $!";
> > print "Locked.\n";
> > sleep(4);
> > print "Unlocking...\n";
> > close(IN);
> > exit(0);
> > 
> > This just locks itself (assuming it's called locktest.pl).  This works
> > fine over NFSv3, but with NFSv4, I'm seeing:
> > 
> > flock(3, LOCK_EX)                       = -1 EIO (Input/output error)
> > 
> > tcpdump and NFS debugging shows status "10038", which as far as I can
> > tell is "NFS4ERR_OPENMODE".
> 
> That is known and expected behaviour. We have to map flock() onto byte
> range locks (i.e. POSIX locks), and since LOCK_EX has to map to a write
> lock in order to give exclusive semantics, the server will not allow it
> when you only have the file open for reading.

So, I tested fcntl(F_SETLKW) with F_RDLCK and F_WRLCK as you describe,
and the semantics do work there as expected, returning EBADF if the
descriptor is open O_RDONLY over NFSv3, NFSv4, and locally.

It seems that with NFSv3, the client does the check only in the fcntl()
F_WRLCK case, and that or the flock() case, passes the lock request the
same way via NLMv4, where the server does not care how the file handle
was opened.  With NFSv4, the server is always rejecting write/exclusive
lock requests on file handles opened O_RDONLY.

It's unfortunate that the flock() interface makes no check itself, though
this appears intentional, as it is advisory-only.  Meanwhile, we have a
number of user-uploaded applications which rely on the local and NFSv3
flock() behaviour on O_RDONLY descriptors, which means that we can't just
switch to NFSv4 without breaking those applications.

Simon-


#!/usr/bin/perl

$|=1;
use Fcntl;
open(IN, "+< locktestfcntl.pl") or die "open: $!";
print "Locking...\n";
$x = pack('ssllllllll',F_WRLCK,SEEK_SET,0,0,0,0,0,0,0,0);
fcntl(IN,F_SETLKW,$x) or die "fcntl: $!";
print "Locked.\n";
sleep(4);
print "Unlocking...\n";
close(IN);
exit(0);
