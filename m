From: <robvog@hetnet.nl>
Subject: nfs root at networkboot
Date: Tue, 14 May 2002 15:47:04 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3043a01c1fb4d$d4978d40$f26897c2@hetnet.nl>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
To: <NFS@lists.sourceforge.net>
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

hello everyone,=20


I am using pxelinux to boot kernel from network, which goes ok.=20
When root must be mounted from NFS, I get the following code:=20

Looking up port 100003/2 on 192.168.1.1=20
RPC: sendmsg returned error 22=20
portmap: RPC call returned error 22=20
ROOT-NFS: unable to get nfsd port number from server, using default=20
looking up port of RPC 100005/1 on 192.168.1.1=20
RPC: sendmsg returned error 22=20
portmap: RPC call returned error 22=20
ROOT-NFS:unable to get nfsd port number from server, using default=20
RPC: sendmsg returned error 22=20
mount: RPC call returned error 22=20
ROOT-NFS: server returned error -22 while mounting =3D=20
192.168.1.1:/netboot/base=20
VFS: cannot open root device via nfs, trying floppy=20

server is indeed 192.168.1.1 and root of client system is in =3D=20
/netboot/base=20
inetd, dhcpd, rcp.mountd, rcp.nfsd are running=20
/etc/exports: /netboot/base   =3D=20
192.168.1.0/255.255.255.0(rw,no_root_squash)=20
/etc/hosts.allow: ALL:ALL (for now)=20

dhcpd seems to work fine: clients gets ip-address.=20
tftp from inetd should be working fine since the kernel is received by =
=3D=20
client and executed.=20
- though I get in log: in.tftpd:tftp: client does not accept options. I =
=3D=20
dont know if NFS needs tftp in some way, if so tftp could be the cause.=20
Network (imbedded) card is recognised and passes self test.=20
socket of nfs tcp is listening.=20

In netstat -p |grep rpc I get:=20
dgram 56732 rpc.nfsd=20
dgram 55905 rpc.mountd=20
While client looks for socket 100003/2 or 100005/1, mine rpc.mountd is =
=3D=20
on socket 55905. Maybe it is a reason for an error 22.=20


If someone could tell me more I would appreciate very much.=20

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
