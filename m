From: Andrew Ferrier <andrew.junk@new-destiny.co.uk>
Subject: NFS problems w/ OpenBSD 3.1 (Server) / Debian 3.0 (Client)
Date: Fri, 28 Jun 2002 10:26:37 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0206281021580.4094-100000@laura.aferrier>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host217-36-45-175.in-addr.btopenworld.com ([217.36.45.175] helo=laura.aferrier)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Ns1Y-0006Ak-00
	for <nfs@lists.sourceforge.net>; Fri, 28 Jun 2002 02:26:41 -0700
Received: from aferrier (helo=localhost)
	by laura.aferrier with local-esmtp (Exim 3.35 #1 (Debian))
	id 17Ns1V-00015a-00
	for <nfs@lists.sourceforge.net>; Fri, 28 Jun 2002 10:26:37 +0100
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

I'm having some trouble getting an NFS setup to work. After
investigation of several similar problem reports, mostly on
the archives for the lists, I'm still not closer to figuring
out my problem --- I was hoping some could help.

I'm running an OpenBSD 3.1 NFS server which exports it's home
directories. They are mounted as the home directories on a
Debian 3.0 (testing) client. I was having a problem with GConf
on the client, and tracked it down to the following:

# gconf-sanity-check-1

Please contact your system administrator to resolve the
following problem:
Could not lock the file
"/home/aferrier/.gconf-test-locking-file"; this indicates that
there may be a problem with your operating system
configuration. If you have an NFS-mounted home directory,
either the client or the server may be set up incorrectly. See
the rpc.statd and rpc.lockd documentation. A common cause of
this error is that the "nfslock" service has been disabled.The
error was "Input/output error" (errno = 5).

The problem is that I'm fairly sure that rpc.statd and lockd
are running on both the client and the server.

client's (Debian) rpcinfo -p:

   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100021    1   udp  32768  nlockmgr
    100021    3   udp  32768  nlockmgr
    100021    4   udp  32768  nlockmgr
    100024    1   udp  32772  status
    100024    1   tcp  32791  status

server's (OpenBSD) rpcinfo -p:

   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100005    1   udp    903  mountd
    100005    3   udp    903  mountd
    100005    1   tcp    716  mountd
    100005    3   tcp    716  mountd
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100021    1   udp    748  nlockmgr
    100021    3   udp    748  nlockmgr
    100021    1   tcp    844  nlockmgr
    100021    3   tcp    844  nlockmgr
    100001    1   udp    813  rstatd
    100001    2   udp    813  rstatd
    100001    3   udp    813  rstatd
    100002    1   udp    982  rusersd
    100002    2   udp    982  rusersd
    100002    3   udp    982  rusersd

rstatd does not show up on the client in the rpcinfo list,
however, ps -ef does show:

root       100     1  0 20:41 ?        00:00:00 [lockd]
...
root       168     1  0 20:41 ?        00:00:00 /sbin/rpc.statd

I don't know if not showing up in the rpcinfo -p list on the
client is a bad thing or not. Should it? If so, any thoughts as
to why it might not be?

The Debian system is running a custom 2.4 kernel, the lines
relevant to NFS in the config file are:

#
# Network File Systems
#
# CONFIG_CODA_FS is not set
# CONFIG_INTERMEZZO_FS is not set
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
# CONFIG_ROOT_NFS is not set
# CONFIG_NFSD is not set
# CONFIG_NFSD_V3 is not set
CONFIG_SUNRPC=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_SMB_FS=y

The OpenBSD system is pretty much 'off the shelf'.

There are no particularly helpful messages in the logs on
either machines, except that the /var/log/messages file on the
client contains:

Jun 28 10:22:03 laura kernel: call_verify: server accept status: 2
Jun 28 10:22:03 laura last message repeated 2 times
Jun 28 10:22:03 laura kernel: RPC: garbage, exit EIO

every now and again.

Any help with this problem would be appreciated, or some hints
on what to investigate. I've seen many references to similar
problems, but I've ruled each of those out in one way or
another.

Regards,
Andrew.

-- 
Andrew Ferrier

email: andrew.junk@new-destiny.co.uk
web:   http://www.new-destiny.co.uk/andrew/




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Caffeinated soap. No kidding.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
