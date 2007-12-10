From: "Fredrik Lindgren" <fli-FpffG6+3qsA@public.gmane.org>
Subject: Client performance questions
Date: Mon, 10 Dec 2007 22:52:51 +0100
Message-ID: <0a15723c4b267d4eb8b5ad05800315c0@swip.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailfe10.tele2.se ([212.247.155.33]:42442 "EHLO swip.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751357AbXLJWxd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 17:53:33 -0500
Received: from [130.244.254.1] (account fli-FpffG6+3qsA@public.gmane.org)
  by mailbe05.swip.net (CommuniGate Pro IMAP 5.1.13)
  with XMIT id 81269641 for linux-nfs@vger.kernel.org; Mon, 10 Dec 2007 22:53:28 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello

We have a mail-application running on a set of Linux machines using NFS
for the storage. Recently iowait on the machines has started to become
a problem, and it seems that they can't quite keep up. Iowait figures of
50% or above are not uncommon during peak hours.

What I'd like to know if there is something we could do to makes things
run smoother or if we've hit some performance cap and adding more machines
is the best answer.

>From what we can tell the NFS server doesn't seem to be the bottleneck.
The performance metrics say it's fine and we've run tests from other clients
during both on and off hours seeing almost the same results regardless.
The server(s) is a BlueArc cluster.

The clients are quad 2,2Ghz Opteron machines running Linux kernel 2.6.18.3,
except one which is on 2.6.23.9 since today.

Mount options on the clients are as follows:
bg,intr,timeo=600,retrans=2,vers=3,proto=tcp,rsize=32768,wsize=32768

MTU is 9000 bytes and they're all in the same Gigabit Ethernet switch along
with the NFS server.

Each client seems to be doing somewhere around 3500 NFS ops/s during peak hours.
Average read/write size seems to be around 16kb, although these operations make
up just ~30% of the activity.

This is from the 2.6.23.9 client:
Client nfs v3:
null         getattr      setattr      lookup       access       readlink
0         0% 11020402 20% 2823881   5% 7708643  14% 13259044 24% 20        0%
read         write        create       mkdir        symlink      mknod
8693411  16% 6750099  12% 3107      0% 120       0% 0         0% 0         0%
remove       rmdir        rename       link         readdir      readdirplus
1729      0% 0         0% 1558      0% 0         0% 7         0% 2738003   5%
fsstat       fsinfo       pathconf     commit
74550     0% 40        0% 0         0% 0         0%

This is from a 2.6.18.3 one:
Client nfs v3:
null         getattr      setattr      lookup       access       readlink
0         0% 2147483647 23% 495517229  5% 1234824013 13% 2147483647 23% 22972     0%
read         write        create       mkdir        symlink      mknod
1505525496 16% 1095925729 12% 492815    0% 14863     0% 0         0% 0         0%
remove       rmdir        rename       link         readdir      readdirplus
206499    0% 67        0% 273202    0% 0         0% 324       0% 447735359  4%
fsstat       fsinfo       pathconf     commit
31254030  0% 18        0% 0         0% 0         0%

10:37:03 PM  CPU   %user   %nice %system %iowait    %irq   %soft   %idle    intr/s
10:37:08 PM  all   15.72    0.00    9.68   57.49    0.15    2.15   14.82   7671.80
10:37:08 PM    0   16.40    0.00    8.20   61.60    0.00    1.80   12.00   1736.40
10:37:08 PM    1   13.80    0.00    9.60   51.40    0.20    2.00   23.00   1503.00
10:37:08 PM    2   17.40    0.00   10.20   63.40    0.20    2.60    6.20   2424.00
10:37:08 PM    3   15.20    0.00   10.60   53.80    0.20    2.40   18.20   2008.00

Is this the level of performance that could be expected from these machines?
Any suggestions on what to change to squeeze some more performance from them?

Regards,
  Fredrik Lindgren





