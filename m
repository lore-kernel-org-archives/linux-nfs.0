From: Gregory Guthrie <guthrie@mum.edu>
Subject: NFS install problem: getfh failed; not implemented
Date: Sat, 09 Aug 2003 10:54:25 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.2.1.1.2.20030809103714.00a8c840@mail.mum.edu>
References: <Pine.LNX.4.33.0308091522540.1062-100000@localhost.localdom
 ain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from thames.mum.edu ([208.145.205.253] helo=cserv.mum.edu)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19lW2m-0002ib-00
	for <nfs@lists.sourceforge.net>; Sat, 09 Aug 2003 08:54:13 -0700
Received: from pcgrg.mum.edu (pcgrg.cs [10.10.10.50])
	by cserv.mum.edu (8.11.6+Sun/8.11.6) with ESMTP id h79Fs8s18728
	for <nfs@lists.sourceforge.net>; Sat, 9 Aug 2003 10:54:09 -0500 (CDT)
To: <nfs@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.33.0308091522540.1062-100000@localhost.localdom
 ain>
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

I'm having NFS problems:

Trying to cross mount two files, works one way, not the other.

    omega:/s/net  --> theta:/net/omega   = fine
    theta:/s/net  --> omega:/net/theta   = broken...

The basic problem is that trying to start nfs daemon on the server (Omega)
fails, gives the message:
    getfh failed: Function not implemented

Then, nfsd isn't running, and exportfs fails. Oddly, starting nfsd seems to
look ok, but then it is not running (more below).

Setup: (both machines)
   Debian 3.0, kernel 2.2
   nfs-common 1.1
   nfs-kernel-server

I've seen several discussions of this (google), but no resolution.

I am sure that when I first set this up (same as below), it worked both
ways; then stopped. I have read that NFS caches and state can get garbled,
and need to be reset; but don't konw what that means. (/var/lib/nfs...
files).

I'm pretty sure (:-) that everything is setup right. One sugestion that I
got was to rebuild my own kernel on both machines, using NFS V3; but ... I
would hope that the standard Debian distor would work.

Another solution I have seen suggested was to change to hfs-user-server; but
  since this (nfs-kernel-server) works on one of the two (clone..) machines,
seems like it should work on the other!

Any hints welcome.
Greg
-------------------------------------------------------------
On Server: (Omega)
   omega:/etc/init.d# ./nfs-common start
   Starting NFS common utilities: statd lockd.
   omega:/etc/init.d# ./nfs-kernel-server start
   Exporting directories for NFS kernel daemon...theta.cs.mum.edu:/s/net:
         Function not implemented    ( <---- this is the getfh error )
   done.
   Starting NFS kernel daemon: nfsd mountd.

On client: (Theta)
   theta:/etc/init.d# ./mountnfs.sh
   Starting portmapper... Mounting remote filesystems...
   mount: omega:/s/net failed, reason given by server: Permission denied

On Server: /var/log/messages:
   Aug  6 23:40:50 omega rpc.mountd:
       authenticated mount request from theta.cs.mum.edu:609 for /s/net
(/s/net)
   Aug  6 23:40:50 omega rpc.mountd: getfh failed: Function not implemented

On Client:
   theta:/etc/init.d# mount omega:/s/net /net/omega
   mount: omega:/s/net failed, reason given by server: Permission denied
   theta:/etc/init.d#

   theta:/etc/init.d# showmount -a
   All mount points on theta:
   omega.cs.mum.edu:/s/net
-----------------
On Server:
   omega:/etc/init.d# showmount -a
   All mount points on omega:

   omega:/etc/init.d# cat /proc/filesystems
           ext2
           msdos
           vfat
   nodev   proc
   nodev   nfs
           iso9660
   nodev   devpts



------------------------------------------------------
On Omega: (Server)
/etc/exports:
omega:/etc/init.d# cat /etc/exports
   # /etc/exports: the access control list for filesystems which may be
exported
   #               to NFS clients.  See exports(5).
   /s/net  theta(rw)
/etc/hosts.allow:
   # /etc/hosts.allow: list of hosts that are allowed to access the system.
   ALL:  10.10.10
/etc/fstab:
   # /etc/fstab: static file system information.
   theta:/s/net    /net/theta      nfs
rsize=8192,wsize=8192,timeo=14,intr

omega:/home/net# rpcinfo -p
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100021    1   udp   1024  nlockmgr
     100021    3   udp   1024  nlockmgr
     100024    1   udp   1027  status
     100024    1   tcp   1024  status
     100005    1   udp   1028  mountd
     100005    1   tcp   1025  mountd
     100005    2   udp   1028  mountd
     100005    2   tcp   1025  mountd
    (Note: rpc not running!)

------------------------------------------------------
On Theta: (Client)
/etc/exports:
   # /etc/exports: the access control list for filesystems which may be
exported
   #               to NFS clients.  See exports(5).
   /s/net omega(rw)

/etc/hosts/allow:
   # /etc/hosts.allow: list of hosts that are allowed to access the system.
   ALL: 10.10.10.
/etc/fstab:
   # /etc/fstab: static file system information.
   omega:/s/net    /net/omega      nfs
rsize=8192,wsize=8192,timeo=14,intr

  theta:/root# rpcinfo -p
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100021    1   udp   1024  nlockmgr
     100021    3   udp   1024  nlockmgr
     100024    1   udp   1025  status
     100024    1   tcp   1024  status
     100003    2   udp   2049  nfs
     100005    1   udp   1136  mountd
     100005    1   tcp   4203  mountd
     100005    2   udp   1136  mountd
     100005    2   tcp   4203  mountd

------------------------------------------------------






--------------------------------------------------------
Gregory Guthrie
guthrie@mum.edu
-------------------------------------------------------- 



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
