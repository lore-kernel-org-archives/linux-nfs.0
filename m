Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from b.mail.sonic.net ([64.142.19.5]:55282 "EHLO b.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756622Ab1HTAPn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Aug 2011 20:15:43 -0400
Received: from meno.noc.sonic.net (meno.noc.sonic.net [64.142.18.2])
	by b.mail.sonic.net (8.13.8.Beta0-Sonic/8.13.7) with ESMTP id p7JN1qLH003737
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 19 Aug 2011 16:01:52 -0700
Received: from meno.noc.sonic.net (localhost [127.0.0.1])
	by meno.noc.sonic.net (8.14.3/8.14.3) with ESMTP id p7JN1q4e047974
	for <linux-nfs@vger.kernel.org>; Fri, 19 Aug 2011 16:01:52 -0700 (PDT)
	(envelope-from kgc@corp.sonic.net)
Received: (from kgc@localhost)
	by meno.noc.sonic.net (8.14.3/8.14.3/Submit) id p7JN1qN6047973
	for linux-nfs@vger.kernel.org; Fri, 19 Aug 2011 16:01:52 -0700 (PDT)
	(envelope-from kgc@corp.sonic.net)
Date: Fri, 19 Aug 2011 16:01:52 -0700
From: Kelsey Cummings <kgc@corp.sonic.net>
To: linux-nfs@vger.kernel.org
Subject: Odd locking behavior
Message-ID: <20110819230151.GD44681@corp.sonic.net>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'm looking for some suggestions as to where to look next with an odd
nfs file locking problem with linux clients (RHEL6) and a netapp server.
FSC is enabled on these.

The rather simple example code and output says it all.  It works as
expected when a single process is run, when a second proccess is started
it works for a while and then something breaks and we start seeing it
take multiples of 30 seconds for the lock request to succeed.  The more
proccess that are run, the more likely it is to occur as well as if a
proccess is started on a second client.

When the issue is exhibiting itself, the netaps' lock status display the
granted and waiting locks as expected(?).

..
 6681 0x00085ec8:0x71082409 0:0 1 GWAITING (0x64ea6728)
 6645 0x00085ec8:0x71082409 0:0 1 GRANTED (0x523bb598)


# perl t.pl 
locking lock-test.1 0.000672
locking lock-test.1 0.000229
locking lock-test.1 0.000244
locking lock-test.1 1.000247   #second process started, expected 1s
locking lock-test.1 0.999786
locking lock-test.1 1.000069
locking lock-test.1 31.000492  #third process is started, at worst we expect 2s for the lock
locking lock-test.1 60.000472
locking lock-test.1 90.001829
locking lock-test.1 89.999942
locking lock-test.1 90.001407
locking lock-test.1 90.00091
locking lock-test.1 90.000044
locking lock-test.1 60.000306

#!/usr/bin/perl

use Fcntl qw(:flock);
use Time::HiRes qw(tv_interval gettimeofday);

$| = 1;

my $file = "lock-test";

open (T,">$file") || die "Couldn't open file.\n";
print T $file;
close(T);

#now run lock tests
while ( 1 )
{
        open (F, $file);
        my $start = [gettimeofday];
        print "locking $file ";
        flock(F,LOCK_EX);
        print $elapsed = tv_interval ( $start, [gettimeofday]) . "\n";
        usleep(10);
        close(F);
}


-- 
Kelsey Cummings - kgc@corp.sonic.net      sonic.net, inc.
System Architect                          2260 Apollo Way
707.522.1000                              Santa Rosa, CA 95407
