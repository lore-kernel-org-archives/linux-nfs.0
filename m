From: mike <mike503@gmail.com>
Subject: Trying to determine why my NFS connection goes away
Date: Thu, 14 Jun 2007 16:25:31 -0700
Message-ID: <bd9320b30706141625l6ceb9c73j22a46cf115ca78cd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hyygz-0006GA-MT
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 16:25:29 -0700
Received: from nz-out-0506.google.com ([64.233.162.234])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hyyh2-0003cm-KP
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 16:25:33 -0700
Received: by nz-out-0506.google.com with SMTP id 18so2016779nzp
	for <nfs@lists.sourceforge.net>; Thu, 14 Jun 2007 16:25:31 -0700 (PDT)
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

THE ISSUE (easily repeatable by doing a bunch of file I/O on the client - using
nhfsstone, eventually my "normal" web load hits it too)

I will dump as much information as possible... I really want to make
sure that I have the most optimal setup.

This is the output from dmesg that concerns me:

 nfs: server raid01 not responding, still trying
 nfs: server raid01 not responding, still trying
 nfs: server raid01 not responding, still trying
 nfs: server raid01 OK
 nfs: server raid01 OK
 nfs: server raid01 OK
 nfs: server raid01 not responding, still trying
 nfs: server raid01 not responding, still trying
 nfs: server raid01 not responding, still trying
 nfs: server raid01 OK
 nfs: server raid01 OK

However from everything I am looking at, all the right programs are running.

[root@web03 ~]# rpcinfo -u raid01 mount
program 100005 version 1 ready and waiting
program 100005 version 2 ready and waiting
program 100005 version 3 ready and waiting

[root@web03 ~]# rpcinfo -u raid01 portmap
program 100000 version 2 ready and waiting

[root@web03 ~]# rpcinfo -u raid01 status
program 100024 version 1 ready and waiting

[root@web03 ~]# rpcinfo -p raid01
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100021    1   udp  32771  nlockmgr
    100021    3   udp  32771  nlockmgr
    100021    4   udp  32771  nlockmgr
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100021    1   tcp  44102  nlockmgr
    100021    3   tcp  44102  nlockmgr
    100021    4   tcp  44102  nlockmgr
    100005    1   udp  32767  mountd
    100005    1   tcp  32767  mountd
    100005    2   udp  32767  mountd
    100005    2   tcp  32767  mountd
    100005    3   udp  32767  mountd
    100005    3   tcp  32767  mountd
    100024    1   udp  32765  status
    100024    1   tcp  32765  status

I have even increased the number of nfsd's on the server.

THE SPECS:

Client mounts server:
raid01:/home on /local/home type nfs
(rw,noatime,nfsvers=3,rsize=16384,wsize=16384,hard,intr,timeo=10,addr=192.168.1.151)

Server

/etc/default/nfs-kernel-server:

# Number of servers to start up
RPCNFSDCOUNT=24

# Runtime priority of server (see nice(1))
RPCNFSDPRIORITY=-15

# Options for rpc.mountd.
# If you have a port-based firewall, you might want to set up
# a fixed port here using the --port option. For more information,
# see rpc.mountd(8) or http://wiki.debian.org/?SecuringNFS
RPCMOUNTDOPTS="-p 32767"

/etc/default/nfs-common:
# Options for rpc.statd.
#   Should rpc.statd listen on a specific port? This is especially useful
#   when you have a port-based firewall. To use a fixed port, set this
#   this variable to a statd argument like: "--port 4000 --outgoing-port 4001".
#   For more information, see rpc.statd(8) or
http://wiki.debian.org/?SecuringNFS
STATDOPTS="--port 32765 --outgoing-port 32766"

# Some kernels need a separate lockd daemon; most don't. Set this if you
# want to force an explicit choice for some reason.
NEED_LOCKD=

# Do you want to start the idmapd daemon? It is only needed for NFSv4.
NEED_IDMAPD="no"

# Do you want to start the gssd daemon? It is required for Kerberos mounts.
NEED_GSSD="no"

Network info:
Server: MTU 1500 (current NIC won't support jumbo)
Client: MTU 6000
The entire LAN is gigabit

OS info:
Ubuntu Edgy Eft (all up to date) amd64
Linux kernel 2.6.21.5

Usage info:
Server serves 3 medium busy webservers, and a couple other less busy servers.

Hardware:
Client is Dual-core Opteron 2.2ghz, 2G RAM, runs only
PHP+FastCGI/webserver. Broadcom Corporation NetXtreme BCM5704 Gigabit
Ethernet.

Server is Dual-core Xeon 3050 (2.2ghz), 2G RAM, Areca RAID5 w/ 4x750G
SATA2, dedicated basically for NFS. Intel Corporation 82573E Gigabit
Ethernet Controller.

Is there any more information I could possibly supply? I am willing to
try anything here. I have upgraded my kernels to the latest stable
just in case there was a minor bug I might have been hitting... no
such luck.

Thanks in advance!
- mike

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
