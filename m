Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dragon.async.com.br ([208.70.149.241]:39213 "EHLO
	dragon.async.com.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbcCVA6X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Mar 2016 20:58:23 -0400
Received: from anthem.async.com.br (189-19-234-109.dsl.telesp.net.br [189.19.234.109])
	by dragon.async.com.br (Postfix) with ESMTPS id F1F0B4540F5
	for <linux-nfs@vger.kernel.org>; Mon, 21 Mar 2016 19:58:20 -0500 (CDT)
Received: from anthem.async.com.br (kiko@localhost [127.0.0.1])
	by anthem.async.com.br (8.14.4/8.14.4/Debian-2ubuntu2.1) with ESMTP id u2M0wEJ7004463
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 21 Mar 2016 21:58:14 -0300
Received: (from kiko@localhost)
	by anthem.async.com.br (8.14.4/8.14.4/Submit) id u2M0wDip004462
	for linux-nfs@vger.kernel.org; Mon, 21 Mar 2016 21:58:13 -0300
Date: Mon, 21 Mar 2016 21:58:13 -0300
From: Christian Robottom Reis <kiko@acm.org>
To: NFS List <linux-nfs@vger.kernel.org>
Subject: Re: Finding and breaking client locks
Message-ID: <20160322005813.GA3378@anthem.async.com.br>
References: <20160321143914.GA6397@anthem.async.com.br>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="/9DWx/yDrRhgMJTb"
In-Reply-To: <20160321143914.GA6397@anthem.async.com.br>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--/9DWx/yDrRhgMJTb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Mar 21, 2016 at 11:39:14AM -0300, Christian Robottom Reis wrote:
> indeed does not return any information pertaining NFS client locks, and
> I'm not clear whether /proc/locks (on the server side obviously) does or
> not.

Somewhat OT, but I find it a PITA that /proc/locks gives inode numbers
that then need to be looked up individually. I have often been surprised
no tool exists to parse that and give you back a report of filenames, so
I just put together a small tool that just offloads the work to debugfs.

I've attached it in case others might find it useful.

(Interestingly, in a network of Ubuntu desktops, the long-term remote lock
holders are basically Spotify, Firefox and Zeitgeist, of which the
latter two are essentially sqlite.)
-- 
Christian Robottom Reis | [+55 16] 3376 0125   | http://async.com.br/~kiko
                        | [+55 16] 991 126 430 | http://launchpad.net/~kiko

--/9DWx/yDrRhgMJTb
Content-Type: text/x-python; charset=us-ascii
Content-Disposition: attachment; filename="parselocks.py"

#!/usr/bin/env python3
import os
import sys
import subprocess
import io

locksdb = open("/proc/locks")
device_inodes = {}
for lockline in locksdb:
    lock_inode_raw = lockline.split()[5]
    lock_inode = lock_inode_raw.split(":")
    if len(lock_inode) < 3:
        #print("Ignoring %s" % lock_inode)
        continue
    device = tuple(map(int,lock_inode[0:2]))
    try:
        target_device = os.readlink("/sys/dev/block/%s:%s" % device)
        target_device = target_device.split("/")[-1]
    except OSError:
        #print("Device %s:%s not found" % device)
        continue
    inode = lock_inode[2]
    if not device_inodes.get(target_device):
            device_inodes[target_device] = []
    device_inodes[target_device].append(inode)

for device in device_inodes:
    print("-> Inodes on %s" % device)
    inode_input = []
    for inode in device_inodes[device]:
        inode_input.append("ncheck %s" % inode)
    debugfs = subprocess.Popen(['debugfs', '/dev/%s' % device],
                     stdin=subprocess.PIPE,
                     stdout=subprocess.PIPE,
                     stderr=subprocess.PIPE)
    debugfs_input = "\n".join(inode_input)
    out, err = debugfs.communicate(input=debugfs_input.encode())
    debugfs_output = out.decode()
    for line in debugfs_output.split("\n"):
        if line.startswith("debugfs:"):
            continue
        if line.startswith("Inode"):
            continue
        print(line)



--/9DWx/yDrRhgMJTb--
