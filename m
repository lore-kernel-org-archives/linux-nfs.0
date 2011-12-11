Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm26.access.bullet.mail.sp2.yahoo.com ([98.139.44.153]:34019
	"HELO nm26.access.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752223Ab1LKUHV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Dec 2011 15:07:21 -0500
Message-ID: <1323633645.16114.YahooMailClassic@web181402.mail.ne1.yahoo.com>
Date: Sun, 11 Dec 2011 12:00:45 -0800 (PST)
From: John Simon <tzzhc4@yahoo.com>
Subject: Intermittent performance issues with Solaris 10 NFS V3 client to RHEL 5.5 NFS server
To: linux-nfs@vger.kernel.org
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I recently attached a Solaris 10 8/07 client (6900 with ce gigbit interface) to our NFS server which runs RHEL 5.5 (kernel 2.6.18-194.el5). Performance typically is good running around 25-50MB/s but sometimes seemingly without reason the performance drops to abysmal levels and will stay like that until NFS is unmounted and remounted. I have tested this after hours when there is no load on either server, no traffic on the network and using a 1GB test file. Our other 300 Linux clients have no performance issues, I have ruled out network issues by isolating the server to a switch dedicated to it and an additional port on the NFS server and the tests I performed were with the file cache in memory.

$ time cp /var/tmp/1g.TEST.new /mnt/
real    25m1.456s
user    0m0.276s
sys     0m6.699s

After an unmount, wait 5 minutes and remount:

$ time cp /var/tmp/1g.TEST.new /mnt/
real    0m26.767s
user    0m0.277s
sys     0m6.589s

Mount options I am using on Solaris:

  Flags:         vers=3,proto=tcp,sec=none,hard,intr,link,symlink,acl,rsize=32768,wsize=32768,retrans=5,timeo=600
Attr cache:    acregmin=120,acregmax=120,acdirmin=120,acdirmax=120
