From: mike <mike503@gmail.com>
Subject: [NFS] Help! NFS broken
Date: Sun, 7 Dec 2008 06:48:52 -0800
Message-ID: <bd9320b30812070648x652c8430uf567b9c80cda07a6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:54884 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750802AbYLGOtW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Dec 2008 09:49:22 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1L9Kwi-0006pp-Gf
	for linux-nfs@vger.kernel.org; Mon, 08 Dec 2008 01:49:20 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I upgraded my Ubuntu Hardy server to Intrepid the night before last.
When I woke up yesterday morning, my main server I use as my ssh
gateway into the others was totally messed up.

My server is FreeBSD. I haven't had to touch it since I set it up.

My clients are 6 Ubuntu servers. All are identical in packages,
configs (I diff'ed /etc), kernel versions, network setup, etc.

Only *one* of the machines is suffering (and of course, one of the
most important ones) - and it isn't even one of the busiest.

I've tried downgrading the kernel on the box suffering the issue from
2.6.27-10 to 2.6.27-7, my next attempt will be picking a kernel .deb
that was from the previous Ubuntu release...

What is odd is that it works great after reboot and lasts for a couple
hours, then stops working. I can umount -l /home and then try to
remount it (see below) but it never gets anywhere and eventually dies
with a generic message. I tried to strace -f it, and it gave me
nothing to work with. The FreeBSD server doesn't give me anything in
logs to go off of either. I can ping and ssh between the two no
problem at this point still. It's just NFS that is odd. Also I did
notice trying to restart services manually and try to debug them that
portmap seemed to throw a kernel error in my logs once in a while. But
I don't get a connection to portmap when I run the mount command, and
I would assume if portmap is required for mounting NFS shares that it
would need to contact it. That could totally be irrelevant though.

Any help or insight or request for additional information is
appreciated. On-list or off-list is fine. I will pay someone via
Paypal who can help me resolve this quickly...

[root@lvs01 ~]# mount -vvvv /home
mount: fstab path: "/etc/fstab"
mount: mtab path:  "/etc/mtab"
mount: lock path:  "/etc/mtab~"
mount: temp path:  "/etc/mtab.tmp"
mount: spec:  "raid01:/home"
mount: node:  "/home"
mount: types: "nfs"
mount: opts:  "rsize=8192,rsize=8192,tcp,rw,acregmin=30"
mount: external mount: argv[0] = "/sbin/mount.nfs"
mount: external mount: argv[1] = "raid01:/home"
mount: external mount: argv[2] = "/home"
mount: external mount: argv[3] = "-v"
mount: external mount: argv[4] = "-o"
mount: external mount: argv[5] = "rw,rsize=8192,rsize=8192,tcp,acregmin=30"
mount.nfs: timeout set for Sun Dec  7 06:36:39 2008
mount.nfs: text-based options:
'rsize=8192,rsize=8192,tcp,acregmin=30,addr=10.13.220.94'
(just stalls here, normally a connection is near instant. eventually
it will die with a generic error message. i can control-C to quit it
too, so it's not frozen completely)



thanks...

------------------------------------------------------------------------------
SF.Net email is Sponsored by MIX09, March 18-20, 2009 in Las Vegas, Nevada.
The future of the web can't happen without you.  Join us at MIX09 to help
pave the way to the Next Web now. Learn more and register at
http://ad.doubleclick.net/clk;208669438;13503038;i?http://2009.visitmix.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

