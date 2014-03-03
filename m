Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23848 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754018AbaCCPnU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Mar 2014 10:43:20 -0500
Date: Mon, 3 Mar 2014 10:43:15 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Dennis Jacobfeuerborn <dennisml@conversis.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Temporary hangs when using locking with apache+nfsv4
Message-ID: <20140303104315.1f949cb4@tlielax.poochiereds.net>
In-Reply-To: <53141788.9030209@conversis.de>
References: <53141788.9030209@conversis.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 03 Mar 2014 06:47:52 +0100
Dennis Jacobfeuerborn <dennisml@conversis.de> wrote:

> Hi,
> I'm experimenting with using NFSv4 as storage for web servers and while 
> regular file access seems to work fine as soon as I bring flock() into 
> play things become more problematic.
> I've create a tiny test php script that basically opens a file, locks it 
> using flock(), writes that fact into a log file (on a local filesystem), 
> performs a usleep(1000), writes into the log that it is about to unlock 
> the file and finally unlocks it.
> I invoke that script using ab with a concurrency of 20 for a few 
> thousand requests.
> 

Is all the activity from a single client, or are multiple clients
contending for the lock?

> The result is that while 99% of the request respond quickly a few 
> request seem to hang for up to 30 seconds. According to the log file 
> they must eventually succeed since I see all expected entries and the 
> locking seems to work as well since all entries are in the expected order.
> 
> Is it expected that these long delays happen? When I comment the locking 
> function out these hangs disappear.
> Are there some knobs to tune NFS and make it behave better in these 
> situations?
> 

NFSv4 locking is inherently unfair. If you're doing a blocking lock,
then the client is expected to poll for it. So, long delays are
possible if you just happen to be unlucky and keep missing the lock.

There's no knob to tune, but there probably is room for improvement in
this code. In principle we could try to be more aggressive about
getting the lock by trying to wake up one or more blocked tasks whenever
a lock is released. You might still end up with delays, but it could
help improve responsiveness.

-- 
Jeff Layton <jlayton@redhat.com>
