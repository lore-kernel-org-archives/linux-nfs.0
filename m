Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:6158 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754095AbZCQG2j convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Mar 2009 02:28:39 -0400
Received: by rv-out-0506.google.com with SMTP id g37so1985075rvb.1
        for <linux-nfs@vger.kernel.org>; Mon, 16 Mar 2009 23:28:37 -0700 (PDT)
In-Reply-To: <49BF2D0B.6060108@sgi.com>
References: <72dbd3150903131336m78526d4ao1308052d6233b70@mail.gmail.com>
	 <1236978608.7265.41.camel@heimdal.trondhjem.org>
	 <72dbd3150903131432u43d9ba43nf0456b99aed0f8fd@mail.gmail.com>
	 <1236980438.7265.47.camel@heimdal.trondhjem.org>
	 <72dbd3150903131459u273d8e8nc9e966eae01848f7@mail.gmail.com>
	 <1236983389.7265.51.camel@heimdal.trondhjem.org>
	 <72dbd3150903131605m6aec6e41j8d608512b2693ba9@mail.gmail.com>
	 <49BF2D0B.6060108@sgi.com>
Date: Mon, 16 Mar 2009 23:28:37 -0700
Message-ID: <72dbd3150903162328x5ad7d874u125e7437faa40718@mail.gmail.com>
Subject: Re: Horrible NFS Client Performance During Heavy Server IO
From: David Rees <drees76@gmail.com>
To: Greg Banks <gnb@sgi.com>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Mar 16, 2009 at 9:54 PM, Greg Banks <gnb@sgi.com> wrote:
> David, could you try your test case with this command running on the server?
>
> tethereal -i eth0 -f 'port 2049' -z rpc,rtt,100003,3 -w /dev/null
>
> and ^C it when you've done.  You should see a table by RPC call with
> minimum maximum and average "roundtrip times" (actually as they're
> measured on the server, they should be server response times).  This
> should tell you which calls are slow and whether it's all those calls or
> only a few outliers.

OK, filtering out the empty lines, I ran the test (note that I
modified it slightly, details later) with and without the server side
large write running:

Without:

Procedure        Calls   Min RTT   Max RTT   Avg RTT
GETATTR              3   0.00006   0.00133   0.00048
SETATTR              1   0.03878   0.03878   0.03878
ACCESS               9   0.00006   0.00232   0.00049
COMMIT               1   1.13381   1.13381   1.13381

With:
Procedure        Calls   Min RTT   Max RTT   Avg RTT
GETATTR              1   0.00016   0.00016   0.00016
SETATTR              1  30.14662  30.14662  30.14662
ACCESS               8   0.00005   0.00544   0.00154
COMMIT               1   0.34472   0.34472   0.34472

> Another experiment worth trying is a local filesystem load fairness test
> on the server (no NFS client involved).  This will tell you whether the
> nfsd's IO priority is an issue, or if you're just seeing an IO
> scheduling issue.
>
> 1.  echo 3 > /proc/sys/vm/drop_caches
> 2.  time find /your/home/some/dir -ls > /dev/null (choose a directory
> tree with a few hundred files)
> 3.  echo 3 > /proc/sys/vm/drop_caches
> 4.  start your large writes
> 5.  time find /your/home/some/dir -ls > /dev/null

This test actually returned similar response times with or without the
big server write running.  Which led me to thinking that this isn't
even a NFS problem - it actually appears to be a VM or
filesystem(ext3) problem.

Here's the test case again:

1. On the server, write out a large file:
dd if=/dev/zero of=bigfile bs=1M count=5000

2. On the client, write out a small file:
dd if=/dev/zero of=smallfile bs=4k count=1

Now, I just ran #2 both on a NFS client and on the local server -
response time was the same, about 45 seconds.

So it appears that my combination of server (older dual Xeon 3Ghz, 8GB
RAM, SATA RAID1) lets too much dirty data accumulate creating a huge
backlog of data to be written to the journal and leaving small,
latency sensitive writes go very slowly.  I seem to remember reading
about this problem before - oh yeah:

http://lwn.net/Articles/216853/
on top of this newer bug:
http://bugzilla.kernel.org/show_bug.cgi?id=12309
http://lkml.org/lkml/2009/1/16/487

I'm off to go hack dirty_ratio and dirty_background_ratio for now
until this bug gets fixed and ext4 appears to fully stabilize. :-)

Thanks for your help, guys.

-Dave
