Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ironport02-1.csupomona.edu ([134.71.187.45]:36126 "EHLO
	ironport02-1.csupomona.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933990Ab3FSDWL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jun 2013 23:22:11 -0400
Received: from localhost (localhost [127.0.0.1])
	by adler.unx.csupomona.edu (Postfix) with ESMTP id 7B7DC94049
	for <linux-nfs@vger.kernel.org>; Tue, 18 Jun 2013 20:12:49 -0700 (PDT)
Received: from adler.unx.csupomona.edu ([127.0.0.1])
	by localhost (adler.unx.csupomona.edu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id LFlQi1AvDpv6 for <linux-nfs@vger.kernel.org>;
	Tue, 18 Jun 2013 20:12:49 -0700 (PDT)
Received: from localhost.localdomain (woof.iitsystems.csupomona.edu [134.71.248.29])
	(using SSLv3 with cipher AES128-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: bldewolf)
	by adler.unx.csupomona.edu (Postfix) with ESMTPSA id 5CEA594034
	for <linux-nfs@vger.kernel.org>; Tue, 18 Jun 2013 20:12:49 -0700 (PDT)
Date: Tue, 18 Jun 2013 20:12:48 -0700
From: Brian De Wolf <bldewolf@csupomona.edu>
To: Linux NFS list <linux-nfs@vger.kernel.org>
Subject: Issues using new idmapper in large sites
Message-ID: <20130618201248.6cc88501@csupomona.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I've been having some problems after upgrading to 3.4.44 that seem to
stem from the new idmapper.  We've got a site with ~36k users and our
interactive login servers pretty quickly started identifying users as
nfsnobody (-2).  Looking at /proc/key-users, we had exhausted the
available space for "keys".  After tuning these variables up to large
values, though, it still fails to cache more than ~500 users.

I made a directory with a file owned by every user and started testing
with /proc/sys/kernel/key values.  To test, my script
prints /proc/key-users, times an "ls -ln", and checks the output for
wrong uids.

Before tweaking values:

3.4.44-gentoo
    0:   620 619/514 615/1000 19995/20000
real    0m52.758s
user    0m0.370s
sys     0m7.020s
Missing users: 35784
    0:   620 619/514 615/1000 19995/20000

After tweaking values (and with a hot cache):

3.4.44-gentoo
    0:   620 619/514 615/1000000 19995/536870912
real    0m17.198s
user    0m0.410s
sys     0m5.020s
Missing users: 35784
    0: 72188 72187/514 72183/1000000 1964565/536870912

It's fast but...it also missed most of my users (it only has 503
cached, there are 36287 total).  The refcount and number of keys
skyrocket even further on repeated runs but the number of missing
users remains the same.

After testing with 3.9.6, I'm really wondering about the number of keys
instantiated being so low.  It seems to hit the same ~500 limit but does
something so that it can keep working:

3.9.6-gentoo
    0:    13 12/12 8/1000000 239/536870912
real    12m3.462s
user    0m0.440s
sys     0m10.720s
Missing users: 0
    0:   519 518/518 513/1000000 17276/536870912

The key numbers settle at ~500 and refuse to settle any higher, even on
repeated runs (although if I watch /proc/key-users while it runs, it
sometimes jumps to ~700 and goes back to ~500.  Aggressive GC?).  It
would be nice to be able to give it a bit more room to cache.

Is there anything else I should test?  Is there a tunable I missed?  It
looks like idmapping in 3.4.44 is problematic with several hundred
users and slow in 3.9.6.  Solaris performs the same test in 1 minute (1
second with a hot cache, though the cache quickly dissipates).

Thanks,
Brian
