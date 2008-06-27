From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [NFS] NFS performance debugging
Date: Fri, 27 Jun 2008 13:00:09 +0530
Message-ID: <OFDFC449CB.7BDDC7DB-ON65257475.0028A009-65257475.002936C0@in.ibm.com>
References: <48624F34.1070108@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:34590 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752320AbYF0Hby (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Jun 2008 03:31:54 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KC8Qx-0000yO-UQ
	for linux-nfs@vger.kernel.org; Fri, 27 Jun 2008 17:31:52 +1000
In-Reply-To: <48624F34.1070108-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

linux-nfs-owner@vger.kernel.org wrote on 06/25/2008 07:29:16 PM:

> But please do not let this caveat stop you from trying this script and
> mountstats script. We definitely need feedback on how well they do or
> don't work (and as always... patches are welcomed! ;-) ) Once things
harden
> up (via any feedback), I'll added the install code to make these scripts
be
> installed (probably in /usr/sbin) which means they will be ready for
> prime time...

Hi Steve,

When I ran this util, it worked the first time:

[root@localhost ~]# /tmp/nfs-iostat

localhost:/local mounted on /nfs:

   op/s         rpc bklog
   1.27            0.01
read:             ops/s            Kb/s           Kb/op         retrans
avg RTT (ms)    avg exe (ms)
                  0.619          39.772          64.273        0 (0.0%)
16.889          16.927
write:            ops/s            Kb/s           Kb/op         retrans
avg RTT (ms)    avg exe (ms)
                  0.626          39.112          62.523        0 (0.0%)
26.357         4039.241

8.124.111.71:/mnt mounted on /mnt:

   op/s         rpc bklog
   3.00            0.00
read:             ops/s            Kb/s           Kb/op         retrans
avg RTT (ms)    avg exe (ms)
                  0.000           0.000           0.000        0 (0.0%)
0.000           0.000
write:            ops/s            Kb/s           Kb/op         retrans
avg RTT (ms)    avg exe (ms)
                  0.000           0.000           0.000        0 (0.0%)
0.000           0.000

(KK: for some reason, the real NFS mount gives all zero. Also, for
loopback, the read/write
BW is very poor: less than 40 Kb/s).

But from the next time I ran, and all subsequent runs (and even after a
reboot),
I get:

[root@localhost init.d]# /tmp/nfs-iostat
localhost:/local mounted on /nfs:

   op/s         rpc bklog
   0.04            0.00
read:             ops/s            Kb/s           Kb/op         retrans
avg RTT (ms)    avg exe (ms)
                  0.000           0.000           0.000        0 (0.0%)
0.000           0.000
write:            ops/s            Kb/s           Kb/op         retrans
avg RTT (ms)    avg exe (ms)
                  0.000           0.000           0.000        0 (0.0%)
0.000           0.000

8.124.111.71:/mnt mounted on /mnt:

   op/s         rpc bklog
   6.00            0.00
read:             ops/s            Kb/s           Kb/op         retrans
avg RTT (ms)    avg exe (ms)
                  0.000           0.000           0.000        0 (0.0%)
0.000           0.000
write:            ops/s            Kb/s           Kb/op         retrans
avg RTT (ms)    avg exe (ms)
                  0.000           0.000           0.000        0 (0.0%)
0.000           0.000

(KK: every filesystem gives zero for all parameters).

What could be wrong?

Thanks,

- KK


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

