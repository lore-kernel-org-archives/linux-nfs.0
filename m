From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [NFS] NFS performance debugging
Date: Mon, 30 Jun 2008 14:35:01 +0530
Message-ID: <OFE0CA60F9.923E6E7D-ON65257478.00303B97-65257478.0031E627@in.ibm.com>
References: <76bd70e30806270644j3e67c83and7b1f7fd6cc2f5f5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>,
	chucklever@gmail.com
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:48740 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754882AbYF3JIM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jun 2008 05:08:12 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KDFMo-00076X-2Y
	for linux-nfs@vger.kernel.org; Mon, 30 Jun 2008 19:08:10 +1000
In-Reply-To: <76bd70e30806270644j3e67c83and7b1f7fd6cc2f5f5-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

chucklever@gmail.com wrote on 06/27/2008 07:14:38 PM:

> At a guess, it's because the client is now caching your file data?

Today it is working fine, so maybe something was wrong earlier. However,
nfs-iostat shows very low BW:

   op/s         rpc bklog
  42.60            0.00
read:             ops/s            Kb/s           Kb/op         retrans
avg RTT (ms)     avg exe (ms)
                 42.542         2734.324         64.273        0 (0.0%)
18.480   18.518
write:            ops/s            Kb/s           Kb/op         retrans
avg RTT (ms)     avg exe (ms)
                  0.000           0.000           0.000        0 (0.0%)
0.000    0.000

A cat of the file (after fresh mount of /local and /nfs) on the NFS
mountpoint to
/dev/null gives around 29.4 MB/s (vs 39.1 MB/s on /local).

> Can you post a copy of your mount command line, and your
> /proc/self/mountstats file after a test run (but before you unmount)?

mount:
      mount -o
rw,bg,hard,nointr,proto=tcp,vers=3,rsize=65536,wsize=65536,timeo=600,noatime
 localhost:/local /nfs

mountstats file:

device rootfs mounted on / with fstype rootfs
device /dev/root mounted on / with fstype ext3
device /dev mounted on /dev with fstype tmpfs
device /proc mounted on /proc with fstype proc
device /sys mounted on /sys with fstype sysfs
device none mounted on /selinux with fstype selinuxfs
device /proc/bus/usb mounted on /proc/bus/usb with fstype usbfs
device devpts mounted on /dev/pts with fstype devpts
device tmpfs mounted on /dev/shm with fstype tmpfs
device none mounted on /proc/sys/fs/binfmt_misc with fstype binfmt_misc
device sunrpc mounted on /var/lib/nfs/rpc_pipefs with fstype rpc_pipefs
device /etc/auto.misc mounted on /misc with fstype autofs
device -hosts mounted on /net with fstype autofs
device nfsd mounted on /proc/fs/nfsd with fstype nfsd
device /dev/sda6 mounted on /local with fstype ext3
device localhost:/local mounted on /nfs with fstype nfs statvers=1.0
        opts:
rw,vers=3,rsize=65536,wsize=65536,acregmin=3,acregmax=60,acdirmin=30,acdirmax=60,hard,proto=tcp,timeo=600,retrans=2,sec=sys
        age:    79
        caps:   caps=0x9,wtmult=4096,dtsize=4096,bsize=0,namelen=255
        sec:    flavor=1,pseudoflavor=1
        events: 0 0 0 0 1 3 4 0 0 609 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0
        bytes:  595722240 0 0 0 596639744 0 145664 0
        RPC iostats version: 1.0  p/v: 100003/3 (nfs)
        xprt:   tcp 855 0 2 0 60 9117 9117 0 72672 0
        per-op statistics
                NULL: 0 0 0 0 0 0 0 0
             GETATTR: 2 2 0 264 224 0 0 0
             SETATTR: 0 0 0 0 0 0 0 0
              LOOKUP: 3 3 0 448 684 0 1 1
              ACCESS: 4 4 0 568 480 0 0 0
            READLINK: 0 0 0 0 0 0 0 0
                READ: 9104 9104 0 1383808 597805056 15 168246 168587
               WRITE: 0 0 0 0 0 0 0 0
              CREATE: 0 0 0 0 0 0 0 0
               MKDIR: 0 0 0 0 0 0 0 0
             SYMLINK: 0 0 0 0 0 0 0 0
               MKNOD: 0 0 0 0 0 0 0 0
              REMOVE: 0 0 0 0 0 0 0 0
               RMDIR: 0 0 0 0 0 0 0 0
              RENAME: 0 0 0 0 0 0 0 0
                LINK: 0 0 0 0 0 0 0 0
             READDIR: 0 0 0 0 0 0 0 0
         READDIRPLUS: 0 0 0 0 0 0 0 0
              FSSTAT: 0 0 0 0 0 0 0 0
              FSINFO: 1 1 0 132 80 0 0 0
            PATHCONF: 0 0 0 0 0 0 0 0
              COMMIT: 0 0 0 0 0 0 0 0

And:

[root@localhost nfs]# nfsstat -rc
Client rpc stats:
calls      retrans    authrefrsh
713710     19         0

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

