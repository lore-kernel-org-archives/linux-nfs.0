From: kbakalar@comcast.net
Subject: NFS config error?
Date: Sun, 06 Oct 2002 11:59:51 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <001a01c26d51$67bd8f50$6500a8c0@wv.mentorg.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp.comcast.net ([24.153.64.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17yDrL-0000c7-00
	for <nfs@lists.sourceforge.net>; Sun, 06 Oct 2002 09:02:23 -0700
Received: from mdrkbakalar (pcp822938pcs.nrockv01.md.comcast.net [68.49.43.78])
 by mtaout04.icomcast.net
 (iPlanet Messaging Server 5.1 HotFix 1.4 (built Aug  5 2002))
 with SMTP id <0H3K00EHBHVTVD@mtaout04.icomcast.net> for
 nfs@lists.sourceforge.net; Sun, 06 Oct 2002 12:02:17 -0400 (EDT)
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

I have two Redhat sytems on my home network. I want to be able to reference
each from the other (both serve as clients, both as servers). But I cannot
get nfs working either way. I am sure I am making some obvious error in
configuration, but no amount of research has uncovered it. Perhaps a reader
can set me on the true path. Here are transcripts from each of the two
machines, showing OS, configuration, /etc/exports, /etc/hosts.* and other
relevant detail (the two machines are "omnibook" and "mexico")

[note: I have since corrected the clocks on both machines, but that didn't
seem to help]

FIRST MACHINE (omnibook, Redhat 7.3 with updates):

[root@Omnibook init.d]# uname -a
Linux Omnibook 2.4.2-2 #1 Sun Apr 8 19:37:14 EDT 2001 i586 unknown
[root@Omnibook init.d]# ping mexico
PING mexico (192.168.0.111) from 192.168.0.113 : 56(84) bytes of data.
Warning: time of day goes back, taking countermeasures.
64 bytes from mexico (192.168.0.111): icmp_seq=0 ttl=64 time=1.742 msec
64 bytes from mexico (192.168.0.111): icmp_seq=1 ttl=64 time=709 usec
64 bytes from mexico (192.168.0.111): icmp_seq=2 ttl=64 time=716 usec
64 bytes from mexico (192.168.0.111): icmp_seq=3 ttl=64 time=718 usec
64 bytes from mexico (192.168.0.111): icmp_seq=4 ttl=64 time=720 usec
64 bytes from mexico (192.168.0.111): icmp_seq=5 ttl=64 time=706 usec

--- mexico ping statistics ---
6 packets transmitted, 6 packets received, 0% packet loss
round-trip min/avg/max/mdev = 0.706/0.885/1.742/0.383 ms
[root@Omnibook init.d]# rpcinfo -p mexico
rpcinfo: can't contact portmapper: RPC: Remote system error - Connection
refused
[root@Omnibook init.d]# cat /etc/{exports,hosts.allow,hosts.deny}
/ 192.168.0.0/255.255.0.0(rw,no_root_squash,no_subtree_check)
#
# hosts.allow   This file describes the names of the hosts which are
#               allowed to use the local INET services, as decided
#               by the '/usr/sbin/tcpd' server.
#
# ALL: 192.168.0.0/255.255.0.0
#
# hosts.deny    This file describes the names of the hosts which are
#               *not* allowed to use the local INET services, as decided
#               by the '/usr/sbin/tcpd' server.
#
# The portmap line is redundant, but it is left to remind you that
# the new secure portmap uses hosts.deny and hosts.allow.  In particular
# you should know that NFS uses portmap!

[root@Omnibook init.d]#
[root@Omnibook init.d]# rpm -q nfs-utils
nfs-utils-0.3.1-5
[root@Omnibook init.d]# rpcinfo -p localhost
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp   1024  status
    100024    1   tcp   1024  status
    100011    1   udp    731  rquotad
    100011    2   udp    731  rquotad
    100005    1   udp   1025  mountd
    100005    1   tcp   1087  mountd
    100005    2   udp   1025  mountd
    100005    2   tcp   1087  mountd
    100005    3   udp   1025  mountd
    100005    3   tcp   1087  mountd
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp   1026  nlockmgr
    100021    3   udp   1026  nlockmgr
    100021    4   udp   1026  nlockmgr
[root@Omnibook init.d]# mount mexico:/ /mnt/mexico
mount: RPC: Unable to receive; errno = Connection refused

SECOND MACHINE (mexico,RedHat 8.0 stock)

[root@mexico root]# uname -a
Linux mexico 2.4.18-14 #1 Wed Sep 4 12:13:11 EDT 2002 i686 athlon i386
GNU/Linux
[root@mexico root]# ping omnibook
PING omnibook (192.168.0.113) from 192.168.0.111 : 56(84) bytes of data.
64 bytes from omnibook (192.168.0.113): icmp_seq=1 ttl=255 time=0.862 ms
64 bytes from omnibook (192.168.0.113): icmp_seq=2 ttl=255 time=0.667 ms
64 bytes from omnibook (192.168.0.113): icmp_seq=3 ttl=255 time=0.666 ms
64 bytes from omnibook (192.168.0.113): icmp_seq=4 ttl=255 time=0.665 ms
64 bytes from omnibook (192.168.0.113): icmp_seq=5 ttl=255 time=0.665 ms
64 bytes from omnibook (192.168.0.113): icmp_seq=6 ttl=255 time=0.655 ms

--- omnibook ping statistics ---
6 packets transmitted, 6 received, 0% loss, time 5002ms
rtt min/avg/max/mdev = 0.655/0.696/0.862/0.080 ms
[root@mexico root]# rpcinfo -p 127.0.0.1
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    391002    2   tcp  32769  sgi_fam
    100011    1   udp    988  rquotad
    100011    2   udp    988  rquotad
    100011    1   tcp    991  rquotad
    100011    2   tcp    991  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  32770  nlockmgr
    100021    3   udp  32770  nlockmgr
    100021    4   udp  32770  nlockmgr
    100005    1   udp  32771  mountd
    100005    1   tcp  32770  mountd
    100005    2   udp  32771  mountd
    100005    2   tcp  32770  mountd
    100005    3   udp  32771  mountd
    100005    3   tcp  32770  mountd
[root@mexico root]# rpcinfo -p omnibook
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp   1024  status
    100024    1   tcp   1024  status
    100011    1   udp    731  rquotad
    100011    2   udp    731  rquotad
    100005    1   udp   1025  mountd
    100005    1   tcp   1087  mountd
    100005    2   udp   1025  mountd
    100005    2   tcp   1087  mountd
    100005    3   udp   1025  mountd
    100005    3   tcp   1087  mountd
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp   1026  nlockmgr
    100021    3   udp   1026  nlockmgr
    100021    4   udp   1026  nlockmgr
[root@mexico root]# cat /etc/{exports,hosts.allow,hosts.deny}
/ 192.168.0.0/255.255.0.0(rw,sync,no_subtree_check,no_root_squash)
#
# hosts.allow   This file describes the names of the hosts which are
#               allowed to use the local INET services, as decided
#               by the '/usr/sbin/tcpd' server.
#
portmap:192.168.0.0/255.255.0.0
lockd:192.168.0.0/255.255.0.0
rquotad:192.168.0.0/255.255.0.0
mountd:192.168.0.0/255.255.0.0
statd:192.168.0.0/255.255.0.0
#
# hosts.deny    This file describes the names of the hosts which are
#               *not* allowed to use the local INET services, as decided
#               by the '/usr/sbin/tcpd' server.
#
# The portmap line is redundant, but it is left to remind you that
# the new secure portmap uses hosts.deny and hosts.allow.  In particular
# you should know that NFS uses portmap!
# portmap:ALL
# lockd:ALL
# mountd:ALL
# rquotad:ALL
# statd:ALL

[root@mexico root]# rpm -q nfs-utils
nfs-utils-1.0.1-2
[root@mexico root]# mount omnibook:/ /mnt/omnibook
mount: RPC: Timed out
[root@mexico root]#




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
