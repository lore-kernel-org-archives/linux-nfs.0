From: "Alexander Povolotsky" <pevnev@juno.com>
Subject: I have two Linux ( 2.6.8 ?)   NFS client/server problems
Date: Mon, 11 Oct 2004 21:19:18 GMT
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041011.141946.8277.9770@webmail11.lax.untd.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CH7bS-0005y0-DT
	for nfs@lists.sourceforge.net; Mon, 11 Oct 2004 14:21:10 -0700
Received: from outbound-mail.lax.untd.com ([64.136.28.164])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1CH7b3-0007KZ-1f
	for nfs@lists.sourceforge.net; Mon, 11 Oct 2004 14:21:10 -0700
Received: from outbound29-sr.lax.untd.com (webmail11.lax.untd.com [10.130.30.151])
	by smtpout04.lax.untd.com with SMTP id AABAYX8JXATGYW32
	for <nfs@lists.sourceforge.net> (sender <pevnev@juno.com>);
	Mon, 11 Oct 2004 14:20:21 -0700 (PDT)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Hi,

I have two Linux NFS problems disclosed here.

Problem # 1  "pivot_root" failure issue  
 (is probably less  important vs Problem # 2 - see below, but the info for the # 1 is also needed for # 2) : 

 Please note that PQ2FADS-VR is an embedded diskless board,
booted with (old) ramdisk (from W. Denk) with BusyBox v0.60.1and
then manually mounting (specifying NFS version 2 as it was suggested by you in 1)  ) onto NFS file 
system (from where lmbench is executed), 
provided on the Linux "file server" PC running Linux Red Hat 9 Shrike. 
During the "manual"mount with specifying NFS version 2,  several warnings are thrown ...
 but after a while the mount gets complete ...

A)
************************
tftpboot 200000 uimage
...
bootm 200000 FF800000
...
RAMDISK: Compressed image found at block 0
VFS: Mounted root (ext2 filesystem).
Freeing unused kernel memory: 272k init
serial console detected.  Disabling virtual terminals.
### Application running ...
BusyBox v0.60.1 (2002.10.24-02:29+0000) Built-in shell (msh)
Enter 'help' for a list of built-in commands.
#mkdir /fadsroot
# ls -l /
drwxr-xr-x    2 0        0            2048 Jan  1 01:29 bin
drwxr-xr-x    2 0        0            3072 Jan  1 00:00 dev
drwxr-xr-x    5 0        0            1024 Jan  1 00:00 etc
drwxrwxrwx   38 0        0            4096 Oct  7  2004 fadsroot
drwxr-xr-x    2 0        0            1024 Jan  1 00:00 ftp
drwxr-xr-x    2 0        0            1024 Jan  1 00:00 home
drwxr-xr-x    3 0        0            1024 Jan  1 01:29 lib
dr-xr-xr-x   25 0        0               0 Jan  1 00:00 proc
drwxr-xr-x    2 0        0            1024 Jan  1 00:00 sbin
drwxr-xr-x    2 0        0            1024 Jan  1 00:00 tmp
drwxr-xr-x    4 0        0            1024 Jan  1 00:00 usr
drwxr-xr-x    4 0        0            1024 Jan  1 00:00 var
# portmap
portmap: not found
# ifconfig
eth0      Link encap:Ethernet  HWaddr 08:00:17:40:00:03
          inet addr:192.168.0.5  Bcast:192.168.0.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:19 errors:0 dropped:0 overruns:0 frame:0
          TX packets:15 errors:0 dropped:0 overruns:0 carrier:15
          collisions:0 txqueuelen:1000
          RX bytes:2056 (2.0 kb)  TX bytes:1488 (1.4 kb)
          Base address:0x8500

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
# mount
rootfs on / type rootfs (rw)
/dev/ram0 on / type ext2 (rw)
/proc on /proc type proc (rw,nodiratime)
#mount -o mountvers=2 192.168.0.3:/fadsroot /fadsroot
 fs warning: mount version older than kernel
 portmap: server localhost not responding, timed out
 RPC: failed to contact portmap (errno -5).
 portmap: server localhost not responding, timed out
 RPC: failed to contact portmap (errno -5).
 lockd_up: makesock failed, error=-5
 portmap: server localhost not responding, timed out
 RPC: failed to contact portmap (errno -5).
# 
# mount
rootfs on / type rootfs (rw)
/dev/ram0 on / type ext2 (rw)
/proc on /proc type proc (rw,nodiratime)
192.168.0.3:/fadsroot on /fadsroot type nfs (rw,v2,rsize=8192,wsize=8192,hard,ud
p,lock,addr=192.168.0.3)
# ps
  PID  Uid     Stat Command
    1 root     S    init
    2 root     R    [ksoftirqd/0]
    3 root     S    [events/0]
    4 root     S    [khelper]
    5 root     S    [kblockd/0]
    6 root     S    [pdflush]
    7 root     S    [pdflush]
    8 root     S    [kswapd0]
    9 root     S    [aio/0]
   15 root     S    /usr/sbin/xinetd -stayalive -reuse -pidfile /tmp/xinetd.pid
  138 root     S    [rpciod]
  253 root     S    -sh
  254 root     S    /bin/sh /bin/application
  256 root     S    sleep 300
  258 root     R    ps

# ifconfig
eth0      Link encap:Ethernet  HWaddr 08:00:17:40:00:03
          inet addr:192.168.0.5  Bcast:192.168.0.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:122 errors:0 dropped:0 overruns:0 frame:0
          TX packets:114 errors:0 dropped:0 overruns:0 carrier:114
          collisions:0 txqueuelen:1000
          RX bytes:20747 (20.2 kb)  TX bytes:14320 (13.9 kb)
          Base address:0x8500

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

# cd /fadsroot
#sbin/pivot_root /fadsroot /tmp
pivot_root: pivot_root: Device or resource busy

Note that using additionally -o noolock option while doung mount allows to get rid of warnings during mounting but does fix 
the pivot_root failure.
 
  ************************************************************* 
I am not an expert on Red Hat 9 Linux either(though I "manage" that machine ;-)),
but on that machine portmap is running there and /fadsroot is exported for NFS mounting also:

B)
**************************************************
[root@localhost root]# uname -a
Linux localhost.localdomain 2.4.20-28.9 #1 Thu Dec 18 13:45:22 EST 2003 i686 i686 i386 GNU/Linux

[root@localhost root]# rpm -qa | grep portmap
portmap-4.0-54

[root@localhost root]# rpm -qa | grep nfs
nfs-utils-1.0.1-3.9
redhat-config-nfs-1.0.4-5

[root@localhost root]# rpcinfo -p localhost
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp   1024  status
    100024    1   tcp   1024  status
    391002    2   tcp   1025  sgi_fam
    100011    1   udp    999  rquotad
    100011    2   udp    999  rquotad
    100011    1   tcp   1002  rquotad
    100011    2   tcp   1002  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp   1026  nlockmgr
    100021    3   udp   1026  nlockmgr
    100021    4   udp   1026  nlockmgr
    100005    1   udp   1027  mountd
    100005    1   tcp   1026  mountd
    100005    2   udp   1027  mountd
    100005    2   tcp   1026  mountd
    100005    3   udp   1027  mountd
    100005    3   tcp   1026  mountd

[root@localhost root]# cat /etc/exports
/fadsroot *(rw,no_root_squash,async)

[root@localhost root]# showmount -e
Export list for localhost.localdomain:
/fadsroot *

*********************************************** 

 Note from above in A)  that I am also not able to "pivot_root" on my board onto that mounted file system
thereafter (though on the board the portmap is not running  ...I think ..  and loopback is configured)  
- getting error: "pivot_root: Device or resource busy".
I have limited tools on that board at that time to figure out what keeps old root busy 
(outdated libc.so library, provided with ramdisk, which I can not replace on the fly,
prevents adding/running rpcinfo and lsof).  

Problem #2 
I am also not able to boot "straight" (i.e., without ramdisk) -  with NFS mounting the root file system
onto the same (as described above) Linux "file server" PC running Linux Red Hat 9 Shrike
(with the same settings as it is described above)  -
this does not work - I am getting kernel panic "Attempted to kill init!"- see below C) 
 (That is why I am booting with ramdisk instead).
This kernel panic is puzzling (given that with ramdisk I could boot now ).

So perhaps the problem is again in the NFS version incompatibility ???
But this time it is not BusyBox from ramdisk ... but perhaps an attempt to run BusyBox from /fadsroot
(it is there too, but more "current version" ) during the boot is failing in this case ?
... and the kernel on my board during booting does not "know", that it needs to use NFS version 2 
during mounting ?

Should the kernel be configured to 
allow to NFS mount root file system onto the NFS server with version 2 ? 

      I do not see the kernel option to configure NFS version 2 ...
      Here is what I have:
 
      CONFIG_NFS_FS=y
      # CONFIG_NFS_V3 is not set
      # CONFIG_NFS_V4 is not set
      # CONFIG_NFS_DIRECTIO is not set
      # CONFIG_NFSD is not set
      CONFIG_ROOT_NFS=y
      CONFIG_LOCKD=y

C)
*************************************************************** 
 => printenv
bootdelay=5
bootcmd=bootm 200000
ethaddr=08:00:17:00:00:03
serverip=192.168.0.3
ipaddr=192.168.0.5
baudrate=9600
bootargs=root=/dev/nfs rw nfsroot=192.168.0.4:/fadsroot
stdin=serial
stdout=serial
stderr=serial

Environment size: 210/262140 bytes
=> tftpboot 200000 uimage
Using FCC2 ETHERNET device
TFTP from server 192.168.0.3; our IP address is 192.168.0.5
Filename 'uimage'.
Load address: 0x200000
Loading: #################################################################
         #################################################################
         #######################################
done
Bytes transferred = 864364 (d306c hex)
=> bootm 200000
## Booting image at 00200000 ...
   Image Name:   Linux-2.6.8-rc4
   Image Type:   PowerPC Linux Kernel Image (gzip compressed)
   Data Size:    864300 Bytes = 844 kB
   Load Address: 00000000
   Entry Point:  00000000
   Verifying Checksum ... OK
   Uncompressing Kernel Image ... OK
Linux version 2.6.8-rc4 (apovolot@USPITLAD104868) (gcc version 3.3.2) #5 Mon Aug
 16 08:49:38 EDT 2004
PQ2 ADS Port
Built 1 zonelists
Kernel command line: root=/dev/nfs rw nfsroot=192.168.0.4:/fadsroot nobats ip=19
2.168.0.5
PID hash table entries: 256 (order 8: 2048 bytes)
Warning: real time clock seems stuck!
Dentry cache hash table entries: 8192 (order: 3, 32768 bytes)
Inode-cache hash table entries: 4096 (order: 2, 16384 bytes)
Memory: 30432k available (1348k kernel code, 324k data, 272k init, 0k highmem)
Calibrating delay loop... 131.07 BogoMIPS
Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
NET: Registered protocol family 16
PCI: Probing PCI hardware
Generic RTC Driver v1.07
Serial: CPM driver $Revision: 0.01 $
ttyCPM0 at MMIO 0xf0011a00 (irq = 40) is a CPM UART
RAMDISK driver initialized: 16 RAM disks of 32768K size 1024 blocksize
loop: loaded (max 8 devices)
eth0: FCC ENET Version 0.3, 08:00:17:40:00:03
NET: Registered protocol family 2
IP: routing cache hash table of 512 buckets, 4Kbytes
TCP: Hash tables configured (established 2048 bind 4096)
NET: Registered protocol family 1
NET: Registered protocol family 17
IP-Config: Guessing netmask 255.255.255.0
IP-Config: Complete:
      device=eth0, addr=192.168.0.5, mask=255.255.255.0, gw=255.255.255.255,
     host=192.168.0.5, domain=, nis-domain=(none),
     bootserver=255.255.255.255, rootserver=192.168.0.4, rootpath=
Looking up port of RPC 100003/2 on 192.168.0.4
Looking up port of RPC 100005/1 on 192.168.0.4
VFS: Mounted root (nfs filesystem).
Freeing unused kernel memory: 272k init
Kernel panic: Attempted to kill init!
 <0>Rebooting in 180 seconds..
 
Any comment/opinion/solution/   ? 

Thanks,
Best Regards,
Your input/comments/advise is APPRECIATED in advance !,
Alex
 



________________________________________________________________
Speed up your surfing with Juno SpeedBand.
Now includes pop-up blocker!
Only $14.95/ month - visit http://www.juno.com/surf to sign up today!


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
