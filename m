From: David Baer <david@student.ethz.ch>
Subject: problem with mount of nfs
Date: Wed, 12 Nov 2003 10:57:15 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200311121057.15913.david@student.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AJrkn-0000Dm-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Nov 2003 01:57:37 -0800
Received: from tri-e2k.ethz.ch ([129.132.112.23] helo=tri-e2k.d.ethz.ch)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AJrkU-00020f-UU
	for nfs@lists.sourceforge.net; Wed, 12 Nov 2003 01:57:19 -0800
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

hi, 

i have the following problem:

i try to share the filesystems of two machines, so it does not really matter 
which one is server/client. My guess is, that there is something wrong with 
the network and/or portmapper on "suriananda".
I'm sorry, there is a lot of output attached, I still hope someone has the 
time to look at it and give me a hint where and how to go from here.
Thanks, 
david

btw. how can i find out nfs-utils version?

machine "compuJAH": suse 8.1, kernelversion 2.4, 192.168.1.3
/etc/exports:  
/home/david   192.168.1.4(rw)
compuJAH:/etc # more /proc/filesystems
nodev   rootfs
nodev   bdev
nodev   proc
nodev   sockfs
nodev   futexfs
nodev   tmpfs
nodev   shm
nodev   pipefs
        ext2
nodev   ramfs
        minix
        iso9660
nodev   nfs
nodev   devpts
nodev   usbdevfs
nodev   usbfs
compuJAH:/etc # ps aux |grep portmap
bin        954  0.0  0.1  1296  404 ?        S    09:01   0:00 /sbin/portmap
root      2283  0.0  0.2  1752  672 pts/2    S    10:36   0:00 grep portmap
ping 192.168.1.4 is absolutly norma


machine "suriananda": debian, kernelversion 2.4, 192.168.1.4
/etc/exports:
/home/david 192.168.1.0/255.255.255.0(rw)
suriananda:/etc# more /proc/filesystems
nodev   rootfs
nodev   proc
nodev   sockfs
nodev   tmpfs
nodev   shm
nodev   pipefs
        cramfs
nodev   ramfs
nodev   devfs
nodev   devpts
        ext3
        vfat
nodev   usbdevfs
nodev   usbfs
nodev   afs
NFS IS MISSING, how can I add it?
suriananda:/etc# ps aux | grep portmap
daemon     324  0.0  0.1  1384  536 ?        S    08:43   0:00 [portmap]
root      1543  0.0  0.0  1336  432 pts/2    R    10:44   0:00 grep portmap
LOOKS STRANGE, what is wrong? (why are the brackets there?)
suriananda:/etc# ping 192.168.1.3
PING 192.168.1.3 (192.168.1.3): 56 data bytes
64 bytes from 192.168.1.3: icmp_seq=0 ttl=64 time=0.8 ms
64 bytes from 192.168.1.3: icmp_seq=0 ttl=64 time=1.0 ms (DUP!)
64 bytes from 192.168.1.3: icmp_seq=0 ttl=63 time=1.5 ms (DUP!)
64 bytes from 192.168.1.3: icmp_seq=0 ttl=63 time=1.8 ms (DUP!)
64 bytes from 192.168.1.3: icmp_seq=1 ttl=64 time=0.5 ms
64 bytes from 192.168.1.3: icmp_seq=1 ttl=64 time=1.0 ms (DUP!)
64 bytes from 192.168.1.3: icmp_seq=1 ttl=63 time=1.0 ms (DUP!)
64 bytes from 192.168.1.3: icmp_seq=1 ttl=63 time=1.5 ms (DUP!)
WHY DO I GET THE DUPs? I don't get them on any other ping within the network.


i've tried both ways: 
server: suriananda, client compuJAH:
suriananda:/etc# rpcinfo -p 192.168.1.4
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100021    1   udp  32776  nlockmgr
    100021    3   udp  32776  nlockmgr
    100021    4   udp  32776  nlockmgr
    100021    1   tcp  32912  nlockmgr
    100021    3   tcp  32912  nlockmgr
    100021    4   tcp  32912  nlockmgr
    100005    1   udp  32778  mountd
    100005    1   tcp  32913  mountd
    100005    2   udp  32778  mountd
    100005    2   tcp  32913  mountd
    100005    3   udp  32778  mountd
    100005    3   tcp  32913  mountd
suriananda:/etc# rpcinfo -p 192.168.1.4
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100021    1   udp  32776  nlockmgr
    100021    3   udp  32776  nlockmgr
    100021    4   udp  32776  nlockmgr
    100021    1   tcp  32912  nlockmgr
    100021    3   tcp  32912  nlockmgr
    100021    4   tcp  32912  nlockmgr
    100005    1   udp  32778  mountd
    100005    1   tcp  32913  mountd
    100005    2   udp  32778  mountd
    100005    2   tcp  32913  mountd
    100005    3   udp  32778  mountd
    100005    3   tcp  32913  mountd

mounting the server leeds to this (timeout)-message:
compuJAH:/etc # mount -t nfs 192.168.1.4:/home/david/ /mnt/suriananda/
mount: RPC: Wartezeit abgelaufen

the other way: server compuJAH / client suriananda:
compuJAH:/etc # rpcinfo -p 192.168.1.3
   Program Vers Proto   Port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp   1024  status
    100024    1   tcp   1024  status
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100021    1   udp   1026  nlockmgr
    100021    3   udp   1026  nlockmgr
    100021    4   udp   1026  nlockmgr
    100021    1   tcp   1025  nlockmgr
    100021    3   tcp   1025  nlockmgr
    100021    4   tcp   1025  nlockmgr
    100005    1   udp   1027  mountd
    100005    1   tcp   1026  mountd
    100005    2   udp   1027  mountd
    100005    2   tcp   1026  mountd
    100005    3   udp   1027  mountd
    100005    3   tcp   1026  mountd
suriananda:/home/david# rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100021    1   udp  32776  nlockmgr
    100021    3   udp  32776  nlockmgr
    100021    4   udp  32776  nlockmgr
    100021    1   tcp  32912  nlockmgr
    100021    3   tcp  32912  nlockmgr
    100021    4   tcp  32912  nlockmgr
    100005    1   udp  32778  mountd
    100005    1   tcp  32913  mountd
    100005    2   udp  32778  mountd
    100005    2   tcp  32913  mountd
    100005    3   udp  32778  mountd
    100005    3   tcp  32913  mountd
suriananda:/etc# rpcinfo -p 192.168.1.3
rpcinfo: can't contact portmapper: RPC: Remote system error - Connection timed 
out
suriananda:/etc# mount -t nfs 192.168.1.3:/home/david /mnt/compuJAH
-> NOTHING HAPPENS...










-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
