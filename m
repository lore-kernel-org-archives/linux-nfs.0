From: <robvog@hetnet.nl>
Subject: networkboot nfs as root
Date: Tue, 14 May 2002 15:33:01 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3017d01c1fb4b$dea57970$f26897c2@hetnet.nl>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [194.151.104.242] (helo=hetnet.nl)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177cQx-0001pA-00
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 06:33:43 -0700
To: <nfs@lists.sourceforge.net>
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

hello everyone,


I am using pxelinux to boot kernel from network, which goes ok.
When root must be mounted from NFS, I get the following code:

Looking up port 100003/2 on 192.168.1.1
RPC: sendmsg returned error 22
portmap: RPC call returned error 22
ROOT-NFS: unable to get nfsd port number from server, using default
 looking up port of RPC 100005/1 on 192.168.1.1
RPC: sendmsg returned error 22
portmap: RPC call returned error 22
ROOT-NFS:unable to get nfsd port number from server, using default
RPC: sendmsg returned error 22
mount: RPC call returned error 22
ROOT-NFS: server returned error -22 while mounting =
192.168.1.1:/netboot/base
VFS: cannot open root device via nfs, trying floppy

server is indeed 192.168.1.1 and root of client system is in =
/netboot/base
inetd, dhcpd, rcp.mountd, rcp.nfsd are running
/etc/exports: /netboot/base   =
192.168.1.0/255.255.255.0(rw,no_root_squash)
/etc/hosts.allow: ALL:ALL (for now)

dhcpd seems to work fine: clients gets ip-address.
tftp from inetd should be working fine since the kernel is received by =
client and executed.
- though I get in log: in.tftpd:tftp: client does not accept options. I =
dont know if NFS needs tftp in some way, if so tftp could be the cause.
Network (imbedded) card is recognised and passes self test.
socket of nfs tcp is listening.

In netstat -p |grep rpc I get:
 dgram 56732 rpc.nfsd
 dgram 55905 rpc.mountd
While client looks for socket 100003/2 or 100005/1, mine rpc.mountd is =
on socket 55905. Maybe it is a reason for an error 22.


If someone could tell me more I would appreciate very much.

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
