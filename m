Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39723 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751142Ab3IZRrn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 13:47:43 -0400
Date: Thu, 26 Sep 2013 13:47:42 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jongman Heo <jongman.heo@samsung.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: Re: Regression caused by commit 4bdc33ed ("NFSDv4.2: Add NFS
 v4.2 support to the NFS server")
Message-ID: <20130926174742.GA5066@fieldses.org>
References: <42.19.15034.896B3425@epcpsbgx2.samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <42.19.15034.896B3425@epcpsbgx2.samsung.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 26, 2013 at 04:22:48AM +0000, Jongman Heo wrote:
> 
> Hi,
> 
> >
> >------- Original Message -------
> >Sender : J. Bruce Fields<bfields@fieldses.org>
> >Date : 2013-09-25 23:05 (GMT+09:00)
> >Title : Re: Regression caused by commit 4bdc33ed ("NFSDv4.2: Add NFS v4.2 support to the NFS server")
> >
> >On Wed, Sep 25, 2013 at 05:19:50AM +0000, Jongman Heo wrote:
> >> My embedded development box fails to NFS-boot with NFS server which uses recent kernel.
> >> 
> >> Using git bisect, I found it is caused by commit 4bdc33ed ("NFSDv4.2: Add NFS v4.2 support to the NFS server").
> >> 
> >> 
> >> 1. dmesg (NFS boot failure case)
> >> 
> >> ...
> >> [    2.040893] ADDRCONF(NETDEV_UP): eth0: link is not ready
> >> [    2.046207] e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow Control: RX
> >> [    2.053570] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
> >> [    3.055023] IP-Config: Guessing netmask 255.255.0.0
> >> [    3.059979] IP-Config: Gateway not on directly connected network.
> >> [    3.066330] Looking up port of RPC 100003/2 on 165.213.88.249
> >> [    3.074001] Looking up port of RPC 100005/1 on 165.213.88.249
> >> [    3.122878] VFS: Unable to mount root fs via NFS, trying floppy.
> >> [    3.129134] VFS: Cannot open root device "nfs" or unknown-block(2,0)
> >> [    3.135478] Please append a correct "root=" boot option; here are the available partitions:
> >> [    3.143831] 1f00            3072 mtdblock0 (driver?)
> >> [    3.148798] 1f01              64 mtdblock1 (driver?)
> >> [    3.153758] 1f02              64 mtdblock2 (driver?)
> >> [    3.158719] 1f03              64 mtdblock3 (driver?)
> >> [    3.163682] 1f04              64 mtdblock4 (driver?)
> >> [    3.168644] 1f05              64 mtdblock5 (driver?)
> >> [    3.173607] 1f06              64 mtdblock6 (driver?)
> >> [    3.178568] 0800       488386584 sda driver: sd
> >> [    3.183099]   0801          506016 sda1
> >> [    3.186927]   0802         4008217 sda2
> >> [    3.190755]   0803       483869767 sda3
> >> [    3.194584] b300         1880064 mmcblk0 driver: mmcblk
> >> [    3.199802]   b301            4096 mmcblk0p1
> >> [    3.204063]   b302          102400 mmcblk0p2
> >> [    3.208330]   b303            4096 mmcblk0p3
> >> [    3.212594]   b304               1 mmcblk0p4
> >> [    3.216855]   b305            2048 mmcblk0p5
> >> [    3.221116]   b306            2048 mmcblk0p6
> >> [    3.225382]   b307            2048 mmcblk0p7
> >> [    3.229644]   b308            4096 mmcblk0p8
> >> [    3.233906]   b309           12288 mmcblk0p9
> >> [    3.238176]   b30a           16384 mmcblk0p10
> >> [    3.242524]   b30b          142336 mmcblk0p11
> >> [    3.246869]   b30c         1572864 mmcblk0p12
> >> [    3.251219] b320           12288 mmcblk0gp1 (driver?)
> >> [    3.256272] b310           12288 mmcblk0gp0 (driver?)
> >> [    3.261320] Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(2,0)
> >> [    3.269566] Pid: 1, comm: swapper Not tainted 2.6.35 #1
> >> [    3.274776] Call Trace:
> >> [    3.277232]  [<80d0db5b>] ? printk+0x1e/0x20
> >> [    3.281492]  [<80d0dad1>] panic+0x65/0xd1
> >> [    3.285495]  [<80eb9ce3>] mount_block_root+0x125/0x1be
> >> [    3.290631]  [<809d1f6d>] ? sys_mknod+0x2d/0x30
> >> [    3.295156]  [<80eb9f6d>] mount_root+0xd0/0xf2
> >> [    3.299591]  [<80eba0d9>] prepare_namespace+0x14a/0x184
> >> [    3.304803]  [<809c44f6>] ? sys_access+0x26/0x30
> >> [    3.309411]  [<80eb9a4e>] kernel_init+0x25e/0x26e
> >> [    3.314105]  [<80eb97f0>] ? kernel_init+0x0/0x26e
> >> [    3.318800]  [<80903242>] kernel_thread_helper+0x6/0x10
> >> 
> >> 
> >> 2. Client (my embedded box) configuration
> >>   It's kernel 2.6.35 based, and has following NFS kernel configs.
> >> 
> >> # grep NFS .config
> >> CONFIG_NFS_FS=y
> >> CONFIG_NFS_V3=y
> >> CONFIG_NFS_V3_ACL=y
> >> CONFIG_NFS_V4=y
> >> # CONFIG_NFS_V4_1 is not set
> >> CONFIG_ROOT_NFS=y
> >> # CONFIG_NFSD is not set
> >> CONFIG_NFS_ACL_SUPPORT=y
> >> CONFIG_NFS_COMMON=y
> >> 
> >> 
> >> 3. Server (NFSD) configuration
> >>    Fedora 19 + latest linus git kernel 3.12.0-rc2+ (commit 22356f44, mm: Place preemption point in do_mlockall() loop)
> >> 
> >> 
> >> 4. workaround
> >> 
> >> Reverting the commit 4bdc33ed resolves my issue, NFS boot is working then.
> >> I've done git bisect, but lost the resulting bisect log due to sudden power loss :(.
> >
> >So when you say you revert that commit, you mean you revert it on your
> >*server*, right?  You're not changing the client at all throughout these
> >tests?
> 
> Right. I reverted the commit on my server, while client is same throughout the tests.
> 
> >
> >A network trace might be interesting: so, on the server, run
> >
> >tcpdump -s0 -wtmp.pcap -ieth0
> >
> >(replace eth0 by the right network interface), then try booting the
> >client and after the client fails, kill tcpdump and send us a copy of
> >tmp.pcap.
> >
> >(And also you might want to fire up "wireshark tmp.pcap" and take a look
> >yourself--you'll probably see something like a version mismatch error in
> >the network traffic.)
> >
> >--b.
> 
> I've attached two tcpdump files. 
> In the dump, 165.213.88.238 is IP address for NFS client (embedded box with 2.6.35 kernel), and 192.168.64.128 is for NFS server (running latest git kernel with and without the commit revert)
> 
>  * tmp_good_filtered.pcap
>    - latest linus git tree + commit 4bdc33ed reverted
>    - NFS boot is working
> 
>  * tmp_bad_filtered.pcap
>    - latest linus git tree
>    - NFS boot doesn't work
>  
> In error case, I can see following message from wireshark packet window ;
> 
>     Accept State: remote can't support version # (2)
>     Program Version (Minimum): 3
>     Program Version (Maximum): 4

This is pretty weird--it's not at all obvious how that patch would
affect this.

You're absolutely positive that the *only* thing you're changing on the
server between the "good" and "bad" cases is that one kernel patch?
You're not changing anything in userspace?

What does "cat /proc/fs/nfsd/versions" report in the good and bad cases?

(BTW, out of curiosity: what kind of client is this that only supports
NFSv2 and NFSv3?  Even for an embedded system that's a bit surprising.)

--b.
