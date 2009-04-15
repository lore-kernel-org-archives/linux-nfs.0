From: Simon Kirby <sim@hostway.ca>
Subject: Write on close behaviour versus slow media and slow network
Date: Tue, 14 Apr 2009 17:48:09 -0700
Message-ID: <20090415004809.GC17195@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from newpeace.netnation.com ([204.174.223.7]:39351 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751912AbZDOAsO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Apr 2009 20:48:14 -0400
Received: from sim by peace.netnation.com with local (Exim 4.63)
	(envelope-from <sim@netnation.com>)
	id 1LttIP-0007tD-Cv
	for linux-nfs@vger.kernel.org; Tue, 14 Apr 2009 17:48:09 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello!

I have a usual process of downloading pictures from a flash card (@ 15
MB/s or so) and writing them over 100 Mbps Ethernet (@ 12 MB/s or so). 
One would expect and hope that both the reading and writing could happen
simultaneously to optimize throughput, but the current behaviour on both
NFSv3 and NFSv4 is as follows:

multiple files loop (copying with "cp"):
	open source, dest
	data copy loop:
		read(source)
		write(dest)
	close(source)
	close(dest)

The inner loop happens at about the rate of the flash card reader all the
way up to my picture size (12-25 MB).  Then, on close(), rpciod / the NFS
client flushes all data over the network, at the rate which the network
can sustain.

Overall throughput is therefore about 1/(1/12+1/15) == 6.67 MB/s, which
is not very exciting.

I find that replacing "cp" with "dd ... bs=131072 oflag=dsync" lets me
copy at near network speed, at the expense of slowing down copying to a
local hard drive should I chose to do that instead, and seems to be more
of a workaround than a solution (and it's very sensitive to block size
and still slower than network speed).

Is there any way to convince NFS (or buffer flushing) to start sooner in
this case -- preferrably when there are at least wsize bytes available to
write?  Is there any downside to doing this?

Other than some special-case handling with deleting a temporary file
before closing it (does that even work?), I don't see how the current
behaviour helps performance in _any_ case, even when copying from fast
media.

I looked around the NFS man pages, /proc and /sys and didn't see anything
that might be helpful, but I am interested to find out how things came to
arrive at this implementation.

Cheers!

Simon-
