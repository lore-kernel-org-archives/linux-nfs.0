Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46324 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753762AbdKFUEu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 6 Nov 2017 15:04:50 -0500
Date: Mon, 6 Nov 2017 15:04:49 -0500
To: John Ratliff <john@bluemarble.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS v3 file lock testing
Message-ID: <20171106200449.GC13456@fieldses.org>
References: <a34f4eb6-564d-e752-0909-5cb5f9efc796@bluemarble.net>
 <3a62e72f-d654-59bf-7aea-16928535bdcb@bluemarble.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <3a62e72f-d654-59bf-7aea-16928535bdcb@bluemarble.net>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Nov 04, 2017 at 09:50:58PM -0400, John Ratliff wrote:
> On 11/4/2017 8:22 PM, John Ratliff wrote:
> >We recently migrated our email storage to a server sharing the
> >files with NFSv4 rather than NFS v3. We ran into a strange
> >problem, so we wanted to find out if it was related to the NFS
> >version or not.
> >
> >When I tried to mount the NFS share as an NFSv3 share, I was
> >unable to do any file locking. I was unable to diagnose the
> >problem, so I moved the disk back to the old NFS v3 server until I
> >could do further testing.
> >
> >Is there a reason I might not be able to do a file lock on an NFS
> >client with a server that does NFSv4 and NFSv3?
> >
> >The server and client are on the same subnet. There is no firewall
> >between the two systems. hosts.allow was set to ALL: ALL on both
> >client and server just to make sure that wasn't the problem.
> >
> >Reverting to the old NFSv3 server worked fine. Building another
> >NFSv3 server didn't exhibit the problem either. So I'm not sure
> >how to find out what the problem is.
> >
> >I used this program to test whether a file could be locked.
> >
> >---------------------
> >#! /usr/bin/perl
> >
> >use strict;
> >use warnings;
> >
> >use Fcntl ':flock';
> >
> >my $file = '/mnt/nfs3/test-file.lock';
> >open (my $fh, '>>', $file) or die;
> >flock($fh, LOCK_EX) or die 'could not lock file';
> >close($fh);
> >--------------------
> >
> >Normally, it returns immediately. But on the new NFSv4 server, it
> >times out and dies with 'could not lock file'. I don't know if
> >that's the proper way to do file locking on NFSv3, but I know my
> >mail server daemons can't do locking when that program fails, so
> >it looks like a reasonable test.
> >
> >Any advice for how I can diagnose this problem?
> >
> >NFSv3 client machine:
> >   Ubuntu 14.04
> >   Kernel 3.13.0 64-bit
> >   nfs-common version 1.2.8
> >
> >/etc/fstab:
> >   192.168.1.103:/mnt/nfs3 /mnt/nfs3 nfs tcp,soft,intr,nfsvers=3 0 0
> >
> >NFSv3 server machine (the broken one):
> >   Debian 9
> >   Kernel 4.9.0
> >   nfs-common version 1.3.4
> >
> >/etc/exports:
> >   /srv/nfs4 192.168.1.0/24(rw,sync,fsid=root,crossmnt,no_subtree_check)
> >   /srv/nfs4/nfs3 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
> >
> >NFSv3 server machine (the old functional one):
> >   Debian 8
> >   Kernel 3.16.0
> >   nfs-common 1.2.8
> >
> >/etc/exports:
> >   /mnt/nfs3 192.168.1.0/24(rw,sync,no_subtree_check,no_root_sqaush)
> >
> 
> 
> After checking the rpcinfo -p outputs on both servers, I noticed the
> status process wasn't running on the debian 9 server. It was not
> enabled. After starting that process, the lock returns successfully.

That would do it.  Thanks for the followup.--b.
