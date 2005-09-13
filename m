From: Scott Leerssen <scott@leerssen.com>
Subject: permission denied with nfs built into kernel 2.6.13
Date: Tue, 13 Sep 2005 10:23:49 -0400
Message-ID: <fd1eac12512fdd18f46a0635cff07b22@leerssen.com>
Mime-Version: 1.0 (Apple Message framework v622)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EFBha-0005YC-VZ
	for nfs@lists.sourceforge.net; Tue, 13 Sep 2005 07:24:02 -0700
Received: from smtpauth03.mail.atl.earthlink.net ([209.86.89.63])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EFBhX-0001EK-E9
	for nfs@lists.sourceforge.net; Tue, 13 Sep 2005 07:24:02 -0700
Received: from [216.91.87.190] (helo=[192.168.1.70])
	by smtpauth03.mail.atl.earthlink.net with asmtp (Exim 4.34)
	id 1EFBhO-0005JW-Mh
	for nfs@lists.sourceforge.net; Tue, 13 Sep 2005 10:23:50 -0400
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Thanks in advance for plowing through this message...

I have NFS built into a 2.6.13 kernel running on Fedora Core 3, and am 
unable to mount a filesystem on the server running the kernel.  Output 
in /var/log/messages seems to indicate a successful mount request:

Sep 13 10:10:41 boot10-5-3-54 rpc.mountd: authenticated mount request 
from 10.5.1.1:870 for /I (/I)

However the client gives me this:

mount: 10.5.3.54:/I failed, reason given by server: Permission denied

Even though from the client:

[root@devmws5 fc3mws]# showmount -e 10.5.3.54
Export list for 10.5.3.54:
/I   *

I've noticed that Fedora blindly assumes that all of the nfs related 
kernel code will load as modules, as there are a number of module 
install options that won't occur (like '/bin/mount -t rpc_pipefs sunrpc 
/var/lib/nfs/rpc_pipefs').  I probably just missed some obscure 
configuration option.

Here's a list of what I have....

nfs-utils-1.0.6-52

kernel config for NFS in case it helps:

linux 2.6.13 built with NFS in the kernel as follows:
#
# Network File Systems
#
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
CONFIG_NFS_V4=y
CONFIG_NFS_DIRECTIO=y
CONFIG_NFSD=m
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V3_ACL is not set
CONFIG_NFSD_V4=y
CONFIG_NFSD_TCP=y
CONFIG_ROOT_NFS=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_EXPORTFS=m
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y

/etc/exports:

/R *(rw,async,hide,insecure,no_root_squash,secure_locks)
/I *(rw,async,hide,insecure,no_root_squash,secure_locks)

And, finally, output from the client:

[root@devmws5 fc3mws]# rpcinfo -p 10.5.3.54
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100024    1   udp  32768  status
     100024    1   tcp  32769  status
     100021    1   udp  32769  nlockmgr
     100021    3   udp  32769  nlockmgr
     100021    4   udp  32769  nlockmgr
     100021    1   tcp  32774  nlockmgr
     100021    3   tcp  32774  nlockmgr
     100021    4   tcp  32774  nlockmgr
     100011    1   udp    871  rquotad
     100011    2   udp    871  rquotad
     100011    1   tcp    874  rquotad
     100011    2   tcp    874  rquotad
     100003    2   udp   2049  nfs
     100003    3   udp   2049  nfs
     100003    4   udp   2049  nfs
     100003    2   tcp   2049  nfs
     100003    3   tcp   2049  nfs
     100003    4   tcp   2049  nfs
     100005    1   udp    886  mountd
     100005    1   tcp    889  mountd
     100005    2   udp    886  mountd
     100005    2   tcp    889  mountd
     100005    3   udp    886  mountd
     100005    3   tcp    889  mountd

and from the server:

[root@boot10-5-3-54 ~]# rpcinfo -p localhost
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100024    1   udp  32768  status
     100024    1   tcp  32769  status
     100021    1   udp  32769  nlockmgr
     100021    3   udp  32769  nlockmgr
     100021    4   udp  32769  nlockmgr
     100021    1   tcp  32774  nlockmgr
     100021    3   tcp  32774  nlockmgr
     100021    4   tcp  32774  nlockmgr
     100011    1   udp    871  rquotad
     100011    2   udp    871  rquotad
     100011    1   tcp    874  rquotad
     100011    2   tcp    874  rquotad
     100003    2   udp   2049  nfs
     100003    3   udp   2049  nfs
     100003    4   udp   2049  nfs
     100003    2   tcp   2049  nfs
     100003    3   tcp   2049  nfs
     100003    4   tcp   2049  nfs
     100005    1   udp    886  mountd
     100005    1   tcp    889  mountd
     100005    2   udp    886  mountd
     100005    2   tcp    889  mountd
     100005    3   udp    886  mountd
     100005    3   tcp    889  mountd



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
