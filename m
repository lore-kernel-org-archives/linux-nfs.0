Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41367 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754307Ab2LRUh2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Dec 2012 15:37:28 -0500
Date: Tue, 18 Dec 2012 15:37:26 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Keith Edmunds <kae@midnighthax.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS access slow
Message-ID: <20121218203726.GA15006@fieldses.org>
References: <20121218155248.49dfa1fd@kae.tiger-computing.wbp>
 <20121218185006.GA14716@fieldses.org>
 <20121218194251.5bf674ff@ws.the.cage>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121218194251.5bf674ff@ws.the.cage>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 18, 2012 at 07:42:51PM +0000, Keith Edmunds wrote:
> > What are your disks?
> 
> They are Enterprise Nearline 6Gb/s SAS drives in an Infortrend disk array.
> 
> >  How exactly are you getting those numbers?
> > (Literally, step-by-step, what commands are you running?)
> 
> Using postmark:
> 
> pm> set location /mnt/tmp
> pm> set size 10000 10000000
> pm> run
> 
> The only difference is the 'set location' line, which points to either the
> NFS mountpoint or the local mountpoint.

Note that NFS requires operations such as file creation and removal to
be synchronous (for reboot/crash-recovery reasons).  So e.g. if postmark
is single threaded (I think it is), then the client has to wait for the
server to respond to a file create before proceeding, and the server has
to wait for the create to hit disk before responding.

Depending on exactly how postmark calculates those bandwidth numbers
that could have a big effect.

If your array has a battery-backed cache that should help.

> A test using dd ("dd if=/dev/zero of=/mnt/tmp bs=1M count=8192") gave a
> difference of about five times faster for direct access versus access via
> NFS.

To make that an apples-to-apples comparison you should include the
time to sync after the dd in both cases.  (Though if your server doesn't
have much memory that might not make a big difference.)

> > What kernel version?
> 
> 3.2
> 
> > Note loopback-mounts (client and server on same machine) aren't really
> > fully supported.
> 
> OK, I wasn't aware of that. We were only testing that way to try to
> eliminate switches, cables, etc. I've just run a test from another server,
> both connected via 10G links, and I'm getting a read speed of just under
> 20BM/s and a write speed of 52MB/s.

Have you tested the network speed?  (E.g. with iperf.)

--b.
