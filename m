Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:61104 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751677Ab2IYCDv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Sep 2012 22:03:51 -0400
Message-ID: <506110BB.2070408@cn.fujitsu.com>
Date: Tue, 25 Sep 2012 10:02:35 +0800
From: chenditang <chendt.fnst@cn.fujitsu.com>
MIME-Version: 1.0
To: util-linux@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [QUESTION]about libmount library performance problems
References: <505FBE77.8030802@cn.fujitsu.com> <5061076C.2080707@cn.fujitsu.com>
In-Reply-To: <5061076C.2080707@cn.fujitsu.com>
Content-Type: text/plain; charset=GB2312
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi util-linux@vger.kernel.org

I have 1 question which need confirm.

  in the RHEL7.0alpha version
	nfs-utils-1.2.5-3.el7.x86_64  --> use mount_libmount.c
	util-linux-2.20.1-2.el7.x86_64
  when umount a NFS directory, the mnt_table_parse_mtab() function will merge user options(/run/mount/utab) 
into mountinfo(/proc/self/mountinfo)from kernel. if the mount number is large, leading to umount a directory
time-consuming. the complexity of the algorithm is O(n(n+1)/2).

    but in the old version(RHEL6.3GA/nfs-utils-1.2.3-26.el6.x86_64(use mount.c)), only according to the parameters of umount command, 
find the corresponding record in the /etc/mtab file

  Question)*:* merg the tow file are necessary for umount a dir?

TEST LOG:
#cat mount_test.sh
#!/bin/bash
mount=/tmp/mount
if [ ! -d $mount ]; then
    mkdir -p $mount
fi
for dir in {1..8000}; do
    if [ ! -d $mount/$dir ]; then
        mkdir -p $mount/$dir
    fi
    echo mount $dir
    mount -t nfs 127.0.0.1:/ $mount/$dir
done 

# time umount /tmp/mount/1    --------->RHEL7.0alpha
real    0m2.395s
user    0m1.640s        
sys     0m0.466s

# time umount /tmp/mount/1    --------->RHEL6.3GA
real	0m0.159s
user	0m0.042s        
sys	0m0.114s


thanks.

