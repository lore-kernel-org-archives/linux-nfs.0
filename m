From: "Da Grinch" <grinch_01@hotmail.com>
Subject: KNFS 2.6.1 with nfs-utils-1.0.6 Problems :(
Date: Wed, 28 Jan 2004 10:10:06 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <BAY1-F130x4BqJWqwIR0004bfd5@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AlmeC-0007XI-1W
	for nfs@lists.sourceforge.net; Wed, 28 Jan 2004 02:10:12 -0800
Received: from bay1-f130.bay1.hotmail.com ([65.54.245.130] helo=hotmail.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AlmeB-0008JS-LQ
	for nfs@lists.sourceforge.net; Wed, 28 Jan 2004 02:10:11 -0800
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

Hi everyone,

I'm having trouble trying to get a new kernel build 2.6.1 to mount its root 
filesystem over NFS, I've enabled all the NFS kernel options via 'make 
xconfig' and tried various 'V3/TCP, V3/UDP, V2/TCP, V2/UDP' trys with no 
luck :(...the UDP tests, just give me ICMP: destination unreachable errors, 
after the portmapper just told me to use that port??? Go figure.

I can ping my client '192.168.34.11' from the server.  Also, server's 
iptables are not running to block any of this traffic.  Using 
nfs-utils-1.0.6 for nfsd/mountd/statd/etc.  Client is an Alpha (.34.11) and 
Server is i686 (Slackware) (.34.40), both running 2.6.1 Kernel.

I have also gotten this to occur, when trying to mount the exported 
filesystem on the same machine (i686) *(I know I don't have the latest 
mount, but I'm just using knfs, so this shouldn't matter right?):
>mount -t nfs 192.168.34.40:/tftpboot/Alpha1 /mnt
mount: RPC: Unable to receive; errno = Connection refused
**Also, get the same log in the /var/log/syslog file
** Jan 28 04:54:41 Grinch1 rpc.kmountd: my_svc_run() - select: Bad file 
descriptor
** Jan 28 04:54:41 Grinch1 rpc.kmountd: Ack! Gack! svc_run returned!
>mount --version
mount: mount-2.11b

>cat /etc/exports
/tftpboot/Alpha  
192.168.34.*(rw,no_root_squash,async,no_subtree_check,no_auth_n
lm,insecure)
/tftpboot/Alpha1 
192.168.34.*(rw,no_root_squash,async,no_subtree_check,no_auth_n
lm,insecure)

Below is a sample run and logs using various V3/V2 with TCP/UDP settings for 
the KNFS client, after each run a './rc.nfsd restart' was required since the 
mountd task exits :(

Thanks in advance, I hope its something simple =)

===
=== Bootline that client booted with (I change the tcp,v3 settings for 
various runs) ===
===
console=ttyS0 root=/dev/nfs rw 
nfsroot=192.168.34.40:/tftpboot/Alpha1,tcp,rsize=8192,wsize=8192,v3 
ip=192.168.34.11:192.168.34.40:192.168.34.40:255.255.255.0:Alpha1:eth1:off

=== Some Server stuff (nfs-utils-1.0.6) ===
root@Grinch1:~# rpcinfo -p localhost
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    391002    1   tcp    673  sgi_fam
    391002    2   tcp    673  sgi_fam
    100011    1   udp    927  rquotad
    100011    2   udp    927  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100021    1   udp   1056  nlockmgr
    100021    3   udp   1056  nlockmgr
    100021    4   udp   1056  nlockmgr
    100021    1   tcp   1455  nlockmgr
    100021    3   tcp   1455  nlockmgr
    100021    4   tcp   1455  nlockmgr
    100005    1   udp    940  mountd
    100005    1   tcp    943  mountd
    100005    2   udp    940  mountd
    100005    2   tcp    943  mountd
    100005    3   udp    940  mountd
    100005    3   tcp    943  mountd
    100024    1   udp   1057  status
    100024    1   tcp   1456  status

=== Logs on KNFS client for V3/TCP ===
IP-Config: Complete:
      device=eth1, addr=192.168.34.11, mask=255.255.255.0, gw=192.168.34.40,
     host=Alpha1, domain=, nis-domain=(none),
     bootserver=192.168.34.40, rootserver=192.168.34.40, rootpath=
Looking up port of RPC 100003/3 on 192.168.34.40
Looking up port of RPC 100005/3 on 192.168.34.40
Root-NFS: Server returned error -13 while mounting /tftpboot/Alpha1

=== Logs on/from server for V3/TCP ===
Jan 27 11:39:13 Grinch1 rpc.mountd: my_svc_run() - select: Bad file 
descriptor
Jan 27 11:39:13 Grinch1 rpc.mountd: Ack! Gack! svc_run returned!

=== Logs on KNFS client for V2/TCP ===
Looking up port of RPC 100003/2 on 192.168.34.40
Looking up port of RPC 100005/1 on 192.168.34.40
RPC: error 5 connecting to server 192.168.34.40
Root-NFS: Server returned error -5 while mounting /tftpboot/Alpha1
=== Logs on server for V2/TCP ===
Jan 27 11:39:13 Grinch1 rpc.mountd: my_svc_run() - select: Bad file 
descriptor
Jan 27 11:39:13 Grinch1 rpc.mountd: Ack! Gack! svc_run returned!

=== Logs on KNFS client for V3/UDP ===
Looking up port of RPC 100003/3 on 192.168.34.40
Looking up port of RPC 100005/3 on 192.168.34.40
mount: server 192.168.34.40 not responding, timed out
Root-NFS: Server returned error -5 while mounting /tftpboot/Alpha1
=== Logs on server for V3/UDP ===
Jan 27 11:39:13 Grinch1 rpc.mountd: my_svc_run() - select: Bad file 
descriptor
Jan 27 11:39:13 Grinch1 rpc.mountd: Ack! Gack! svc_run returned!
ICMP Port 940 unreachable :(

=== Logs on KNFS client for V2/UDP ===
Looking up port of RPC 100003/2 on 192.168.34.40
Looking up port of RPC 100005/1 on 192.168.34.40
mount: server 192.168.34.40 not responding, timed out
Root-NFS: Server returned error -5 while mounting /tftpboot/Alpha1
=== Logs on server for V2/UDP ===
Jan 27 11:39:13 Grinch1 rpc.mountd: my_svc_run() - select: Bad file 
descriptor
Jan 27 11:39:13 Grinch1 rpc.mountd: Ack! Gack! svc_run returned!
ICMP Port 940 unreachable :(

_________________________________________________________________
Learn how to choose, serve, and enjoy wine at Wine @ MSN. 
http://wine.msn.com/



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
