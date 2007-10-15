From: Andrea Righi <righiandr@users.sourceforge.net>
Subject: Re: nfsd closes port 2049
Date: Mon, 15 Oct 2007 20:23:46 +0200 (MEST)
Message-ID: <4713B033.6040207@users.sourceforge.net>
References: <47139C02.9020009@cineca.it>
	<EXNANE01sVxONvzyJxA000006ff@exnane01.hq.netapp.com>
Reply-To: righiandr@users.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, neilb@cse.unsw.edu.au,
	LKML <linux-kernel@vger.kernel.org>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IhUfC-0006Li-0B
	for nfs@lists.sourceforge.net; Mon, 15 Oct 2007 11:27:38 -0700
Received: from as3.cineca.com ([130.186.84.211])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IhUfF-0007vw-Nj
	for nfs@lists.sourceforge.net; Mon, 15 Oct 2007 11:27:43 -0700
In-Reply-To: <EXNANE01sVxONvzyJxA000006ff@exnane01.hq.netapp.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Talpey, Thomas wrote:
>> Oct 13 05:20:56 node0101 kernel: nfsd_acceptable failed at ffff8100c7873700
> 
> Sounds like the filesystem became unexported, or unexportable
> due to turning off an "x" bit somewhere along the directory tree.
> Were all these clients accessing a single mountpoint? Check
> /etc/exports, and that directory.

Thomas,

thanks for the quick reply. Here is the /etc/exports (all clients are
accessing the same mountpoint):

node0101:~ # cat /etc/exports
# See the exports(5) manpage for a description of the syntax of this file.
# This file contains a list of all directories that are to be exported to
# other computers via NFS (Network File System).
# This file used by rpc.nfsd and rpc.mountd. See their manpages for details
# on how make changes in this file effective.

/eni01      *.eni01.cineca.it(rw,no_root_squash,async,fsid=745)

And:

node0101:~ # exportfs -v
/eni01          *.eni01.cineca.it(rw,async,wdelay,no_root_squash,fsid=745)

The expoted directory is still available during the faulty condition.

It's a gpfs mountpoint exported to the clients by NFS (don't think gpfs
is an issue, I've used the same configuration in a lot of similar cases
without any problem).

node0101:~ # mount
/dev/mapper/root_vg-root_lv on / type ext3 (rw,acl,user_xattr)
proc on /proc type proc (rw)
sysfs on /sys type sysfs (rw)
debugfs on /sys/kernel/debug type debugfs (rw)
udev on /dev type tmpfs (rw)
devpts on /dev/pts type devpts (rw,mode=0620,gid=5)
/dev/sda1 on /boot type ext2 (rw,acl,user_xattr)
/dev/mapper/root_vg-home_lv on /home type ext3 (rw,acl,user_xattr)
/dev/mapper/root_vg-tmp_lv on /tmp type ext3 (rw,acl,user_xattr)
/dev/mapper/root_vg-usr_lv on /usr type ext3 (rw,acl,user_xattr)
/dev/mapper/root_vg-var_lv on /var type ext3 (rw,acl,user_xattr)
/dev/gpfs_eni01 on /eni01 type gpfs (rw,mtime,quota=userquota;groupquota;filesetquota,dev=gpfs_eni01,autostart)
nfsd on /proc/fs/nfsd type nfsd (rw)
node0101:~ # df -hT /eni01
Filesystem    Type    Size  Used Avail Use% Mounted on
/dev/gpfs_eni01
              gpfs     18T  292G   18T   2% /eni01
node0101:~ # stat /eni01/
  File: `/eni01/'
  Size: 32768           Blocks: 64         IO Block: 32768  directory
Device: 11h/17d Inode: 3           Links: 17
Access: (0755/drwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2007-10-15 20:08:21.000000000 +0200
Modify: 2007-10-15 15:43:08.846245519 +0200
Change: 2007-10-15 15:43:08.846245519 +0200

BTW I see some dropped packets in the network interfaces used to export
the filesystem (bond0):

node0101:~ # ifconfig bond0
bond0     Link encap:Ethernet  HWaddr 00:15:17:23:F1:29
          inet addr:10.130.0.11  Bcast:10.130.255.255  Mask:255.255.0.0
          inet6 addr: fe80::215:17ff:fe23:f129/64 Scope:Link
          UP BROADCAST RUNNING MASTER MULTICAST  MTU:9000  Metric:1
          RX packets:594282923 errors:0 dropped:2253 overruns:0 frame:0
          TX packets:549363611 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:149828096309 (142887.2 Mb)  TX bytes:199133526153 (189908.5 Mb)

node0101:~ # ifconfig eth3
eth3      Link encap:Ethernet  HWaddr 00:15:17:23:F1:29
          inet6 addr: fe80::215:17ff:fe23:f129/64 Scope:Link
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:9000  Metric:1
          RX packets:320861616 errors:0 dropped:1384 overruns:0 frame:0
          TX packets:265916198 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:103186260542 (98406.0 Mb)  TX bytes:98671309326 (94100.2 Mb)
          Base address:0x7420 Memory:e7960000-e7980000

node0101:~ # ifconfig eth5
eth5      Link encap:Ethernet  HWaddr 00:15:17:23:F1:29
          inet6 addr: fe80::215:17ff:fe23:f129/64 Scope:Link
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:9000  Metric:1
          RX packets:273428614 errors:0 dropped:869 overruns:0 frame:0
          TX packets:283454604 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:46645599519 (44484.7 Mb)  TX bytes:100463595893 (95809.5 Mb)
          Base address:0x5420 Memory:e7e60000-e7e80000

Could it lead to potential NFS problems (even if it sounds quite strange)?

-Andrea

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
