From: Kresimir Kukulj <madmax@iskon.hr>
Subject: NFS problems (kernel locks up)
Date: Wed, 19 Mar 2003 19:22:41 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030319182241.GA9216@max.zg.iskon.hr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iskon.hr ([213.191.128.4])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18viEX-0008FT-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Mar 2003 10:24:15 -0800
Received: from max.zg.iskon.hr (madmax@localhost [127.0.0.1])
	by max.zg.iskon.hr (8.12.6/8.12.6/Debian-6Woody) with ESMTP id h2JIMlmd009640
	for <nfs@lists.sourceforge.net>; Wed, 19 Mar 2003 19:22:50 +0100
Received: (from madmax@localhost)
	by max.zg.iskon.hr (8.12.6/8.12.6/Debian-6Woody) id h2JIMfMK009637
	for nfs@lists.sourceforge.net; Wed, 19 Mar 2003 19:22:41 +0100
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi

We are trying to assess if linux could perform as a NFS server to linux
client(s). In our test we moved part of mailboxes of a freemail service
(after some initial testing) to a NFS storage (linux NFS server). It worked
ok, and used very little resources. But, during the nightly backup, NFS
server crashed. Symptoms were that:
  1. client detected that NFS server is not responding
  2. NFS server responded to ping, but you could not log in to it. Every
     attempt to log-in stopped at TCP connection being established, but
     daemon did not respond (I presume, that at that particular moment
     TCP/IP stack was still working).
  3. After cca 10 minutes, it locks up (not ping-able).
  4. I have serial console attached to the server, and kernel did not
     respond to SYS-REQ.
  5. After turning off the power and then back on, server booted, and
     resumed its function.

This happened three times, every time during the backup (Networker),
sometimes only 5 minutes after backup started, sometimes after 1.5 hours.
This was all using 2.4.20 kernel (no extra patches), using NFSv3, udp, async.
NFS client was using: rw,hard,intr,udp,rsize=8192,wsize=8192,nodev,nosuid
NFS server used: rw,no_root_squash (default is async).

Then, I have put 2.4.21-pre5 because it contained some NFS fixes. After
that, server survived three days (2 incrementals and one full backup
completed successfully). Then it crashed during the day for no apparent
reason (we have the server monitored with 'cricket', and there were no
unusual activities...).

I have changed to NFSv2,sync,udp and it crashed during the backup that night,
and then again during the day. This resulted with filesystem corruption
(replaying the ext3 journal caused fsck to be invoked - couple of hours was
wasted on checking).

Now I have reverted back to NFSv3,udp, but kept 'sync'. I will see tonight
will it survive or not. 

Filesystem is 99Gb ext3 partition, with 1024 block size, internal journal.
That fs is 50% full, and contains around 290000 files (13.7% fragmentation).
Files are between few kilobytes up to 10 Mb.

Normal filesystem usage is ~200kb read, 300Kb write per second with < 5%
disk utilization. When backup runs, reading gets ~ 5Mb/sec with disk
utilization of ~ 100%.

Client and server are connected to the same switch, with no dropped packets.

We are satisfied with performance (while the server works).

Can anybody give a suggestion ? I have tried everything I can think of.
We would like to use linux as a NFS server, but if this does not work, we
will be forced to consider alternatives like Solaris x86.
Can anyone here suggest a good alternative NFS server OS (for x86) with a
good support for SCSI HW RAID controllers ? ICP Vortex unfortunately is
not supported under Solaris x86, but what other controllers (let's say for
Solaris x86) do you reccommend ?

Also, I am concerned about filesystem. Will ext3 be able to handle, let's
say, 10 million files ? If not, will Solaris x86 UFS be any better.
[ For us, reiser proved to be sometimes difficult, and we had couple of fs
related crashes, so we are trying to find alternatives. Filesystem check
on that amount of files is measured in days. ]

Some info about hardware:
Dell PowerApp 200 with 2 x Pentium III (Coppermine), each 1GHz.
1Gb memory, with CONFIG_HIGHMEM4G=y.
eepro100 ethernet
ServerWorks chipset but nothing except CDROM is connected to it.
ICP Vortex Hardware RAID model GDT8523RZ
Driver for this (SCSI) controller is from 2.4.20 kernel (its pretty new).
5 FUJITSU MAJ3364MC 34Gb drives in RAID5 (4+hotfix).
Filesystem is ext3 with journal=ordered.

Kernel is vanilla 2.4.20, and 2.4.21-pre5.
I can provide 'dmesg' and '.config' for that kernel.

Distribution is Debian stable 3.0.
These packages are installed:
ii  nfs-common              1.0-2                   NFS support files common to client and server
ii  nfs-kernel-server       1.0-2                   Kernel NFS server support

NFS server and client use fixed ports as described at NFS-Howto:
Kernel command line: root=/dev/sda2 lockd.udpport=32768 \
                     lockd.tcpport=32768 console=tty0 console=ttyS0,9600
statd, mountd are fixed as well, and iptables are configured to pass
fragmented packets. By default, NFS server runs with 8 kernel threads
(knfsd). According to /proc/net/rpc/nfsd there is no need for more kernel
threads.

Services that run on NFS client are POP3 and SMTP daemons and a web based
frontend that uses them. Both daemons are configured to use their version of
dot locking (as recommended).

Thanks.

-- 
Kresimir Kukulj
Iskon Internet d.d.
ISS
Savska 41/X.
10000 Zagreb


-------------------------------------------------------
This SF.net email is sponsored by: Does your code think in ink? 
You could win a Tablet PC. Get a free Tablet PC hat just for playing. 
What are you waiting for?
http://ads.sourceforge.net/cgi-bin/redirect.pl?micr5043en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
