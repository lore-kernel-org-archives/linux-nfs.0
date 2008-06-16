From: "howard chen" <howachen@gmail.com>
Subject: [NFS] Sudden high load average and abnormal behavior
Date: Mon, 16 Jun 2008 13:25:22 +0800
Message-ID: <b66ddc900806152225o3a7f2bccrf4e83e70c992847a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:49061 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751180AbYFPFZd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jun 2008 01:25:33 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1K87De-000139-AZ
	for linux-nfs@vger.kernel.org; Mon, 16 Jun 2008 15:25:30 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I have a dedicated NFS server running Raid5 disks and recently
observed a sudden increase in load average and some abnormal behavior
(e.g. command "df -h" halt without returning).

I have checked the Dell OpenManage and showing hardware is okay, the
load average used to be around 3 to 4 before.


Some info might be useful:


>> top

top - 13:17:53 up 382 days, 23:44,  6 users,  load average: 20.53, 20.21, 18.93
Tasks: 286 total,   1 running, 285 sleeping,   0 stopped,   0 zombie
Cpu(s):  0.1% us,  1.1% sy,  0.0% ni, 68.4% id, 29.9% wa,  0.0% hi,  0.5% si
Mem:   4045256k total,  4028028k used,    17228k free,   437428k buffers
Swap:  9775512k total,      160k used,  9775352k free,  2814332k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
 2049 root      15   0     0    0    0 S    1  0.0 861:21.26 kjournald
26094 root      15   0     0    0    0 S    0  0.0  85:02.82 nfsd
26106 root      15   0     0    0    0 S    0  0.0  83:49.86 nfsd
26110 root      15   0     0    0    0 S    0  0.0  84:33.23 nfsd
26124 root      15   0     0    0    0 S    0  0.0  84:37.47 nfsd
 2839 root      16   0  6280 1172  780 R    0  0.0   0:00.02 top
..

>> iostat

avg-cpu:  %user   %nice    %sys %iowait   %idle
           0.06    0.00    1.34   21.60   77.00

Device:            tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
sda             114.89         4.33        18.05  143391021  597126208
sda1              1.07         0.69         8.26   22771290  273100496
sda2              0.00         0.00         0.00          2          0
sda5              0.00         0.00         0.00       1010        408
sda6            110.49         3.63         9.79  119979495  323992464
dm-0              0.58         2.91         3.22   96295602  106444120
dm-1              0.55         0.60         4.31   19996266  142435600
dm-2              0.02         0.08         0.18    2673626    5953184
dm-3            109.53         1.52         2.09   50389354   69192400


>> df -h

Filesystem            Size  Used Avail Use% Mounted on
/dev/sda1             9.7G  1.6G  7.6G  18% /
none                  2.0G     0  2.0G   0% /dev/shm
/dev/mapper/lvm01-lvm01_usr
                       20G  1.5G   18G   8% /usr
/dev/mapper/lvm01-lvm01_var
                      9.9G  327M  9.1G   4% /var
/dev/mapper/lvm01-lvm01_home
                      9.9G   56M  9.3G   1% /home
/dev/mapper/lvm01-lvm01_data0
                      492G  285G  182G  62% /data0

# !!! == The command stopped at here without returning === !!!



Any idea?

Howard

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

