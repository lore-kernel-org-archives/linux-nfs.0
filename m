Return-Path: linux-nfs-owner@vger.kernel.org
Received: from pmpc1228.nerc-pml.ac.uk ([192.171.161.128]:45929 "EHLO
	pmpc1228.npm.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755551Ab2DES1m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Apr 2012 14:27:42 -0400
Received: from pmpc1228.npm.ac.uk (localhost.localdomain [127.0.0.1])
	by pmpc1228.npm.ac.uk (8.14.4/8.14.4) with ESMTP id q35HQNq1013884
	for <linux-nfs@vger.kernel.org>; Thu, 5 Apr 2012 18:26:24 +0100
Message-ID: <4F7DD5BF.7070003@pml.ac.uk>
Date: Thu, 05 Apr 2012 18:26:23 +0100
From: Mike Grant <mggr@pml.ac.uk>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFS4 client loop (10025 / BAD_STATEID)
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

We've recently had some issues with NFS clients hammering servers to a
crawl due to a loop condition with NFS4 BAD_STATEID.  After trawling the
archives, I found something similar:
 http://www.spinics.net/lists/linux-nfs/msg25012.html
  ("RE: NFS4ERR_STALE_CLIENTID loop" Oct 2011)

I believe the outcome was that this was probably a Solaris server bug,
but the archive search makes it tricky to be sure.

Our issue is similar albeit with BAD_STATEID.  A couple of tcpdumps can
be found at http://rsg.pml.ac.uk/staff/mggr/linux-nfs/  The clients are
a bit outdated (Fedora 14, running 2.6.35.14-106.fc14.x86_64).

This is also against a Solaris server and, while not reproducable on
demand, happens about once every 2 days.  There are three machines in
this loop as I write ;)  Anyway, I'm assuming that's Oracle's (and our)
problem..

However, we have seen the same situation against a Linux server (RHEL 6,
2.6.32-71.el6.x86_64) about two weeks ago.  It occurred when the server
was rebooted and 2 workstations (out of 40) that were active at the time
of the reboot went into the same sort of loop when the server
reappeared.  Unfortunately the workstations were quickly rebooted
without gathering info and it's not yet reoccurred.

We're likely to do another reboot sometime after Easter, so I have my
fingers crossed we'll get a repeat of the issue.  If so, what info and
conditions would you ideally want us to try and get, bearing in mind
this is a core operational fileserver?  (i.e. we'd rather not run
development kernels on it)

Cheers,

Mike Grant.
