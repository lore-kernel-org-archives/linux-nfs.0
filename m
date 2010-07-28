Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57156 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752785Ab0G1Wke (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jul 2010 18:40:34 -0400
Received: by wyf19 with SMTP id 19so4626582wyf.19
        for <linux-nfs@vger.kernel.org>; Wed, 28 Jul 2010 15:40:33 -0700 (PDT)
Date: Wed, 28 Jul 2010 17:40:32 -0500
Message-ID: <AANLkTimvGjqhFEYkP-X7eLz+tE0aoETM2nAHgBbGUrj8@mail.gmail.com>
Subject: Strange error of current write on NFS
From: Peng Yu <pengyu.ut@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I have the following perl script that write to a nfs system. The
output doesn't have all the number from 1 to 10. But if I try the
program on a local disk, I see all the number from 1 to 10.

I'm not sure if this is an NFS problem (It may be a perl problem).
Could any guru here let me know if this is possible due to an NFS
problem?

$ cat main.pl
#!/usr/bin/env perl

use strict;
use warnings;

use Parallel::ForkManager;

open OUT, ">main.txt";

my $pm = new Parallel::ForkManager(5);

foreach my $n (1..10) {
  my $pid = $pm->start and next;
  print $n, "\n";
  sleep rand(1);
  print OUT $n;
  $pm->finish;
}

$pm->wait_all_children;

$ ./main.pl
1
3
4
5
2
7
6
8
10
9
$ cat main.txt
12690

-- 
Regards,
Peng
