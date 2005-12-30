From: Kalin KOZHUHAROV <kalin@thinrope.net>
Subject: rpc.statd: open (/var/lib/nfs/state): Permission denied
Date: Fri, 30 Dec 2005 20:06:20 +0900
Message-ID: <43B514AC.7080400@thinrope.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EsI6S-0005U4-Tl
	for nfs@lists.sourceforge.net; Fri, 30 Dec 2005 03:07:20 -0800
Received: from s175249.ppp.asahi-net.or.jp ([220.157.175.249] helo=mail.tar.bz)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EsI6P-0005cb-BA
	for nfs@lists.sourceforge.net; Fri, 30 Dec 2005 03:07:20 -0800
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

Hi, there!

I guess it is not the bes time to ask, but some of us have busy hollidays...

So I am upgrading a small network to rely more on NFSv3 (All are Gentoo boxen) and I ran into a problem.

On one of the server machines, rpc.statd cannot start:

celina nfs # rpc.statd -Fd
12/30/2005 19:01:49 rpc.statd[17982]: Version 1.0.7 Starting
12/30/2005 19:01:49 rpc.statd[17982]: Flags: No-Daemon Log-STDERR
12/30/2005 19:01:49 rpc.statd[17982]: open (/var/lib/nfs/state): Permission denied

celina nfs # strace -s64 -f -e setuid32,open,socket,bind,dup,close rpc.statd -Fd

[snip]

12/30/2005 19:44:10 rpc.statd[18113]: Version 1.0.7 Starting
12/30/2005 19:44:10 rpc.statd[18113]: Flags: No-Daemon Log-STDERR
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) = 3
bind(3, {sa_family=AF_INET, sin_port=htons(905), sin_addr=inet_addr("0.0.0.0")}, 16) = 0
open("/var/run/rpc.statd.pid", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 4
dup(4)                                  = 5
close(4)                                = 0
setuid32(65534)                         = 0
socket(PF_NETLINK, SOCK_RAW, 0)         = 4
bind(4, {sa_family=AF_NETLINK, pid=0, groups=00000000}, 12) = 0
close(4)                                = 0
socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) = 4
bind(4, {sa_family=AF_INET, sin_port=htons(906), sin_addr=inet_addr("0.0.0.0")}, 16) = -1 EACCES
(Permission denied)
close(4)                                = 0
open("/var/lib/nfs/state", O_RDWR|O_CREAT, 0600) = -1 EACCES (Permission denied)
12/30/2005 19:44:10 rpc.statd[18113]: open (/var/lib/nfs/state): Permission denied

celina nfs # ls -ld /var/lib/nfs/{,state}
drwxr-xr-x  7 root   root 304 Dec 30 18:42 /var/lib/nfs/
-rw-------  1 nobody root   6 Dec 30 18:50 /var/lib/nfs/state

celina nfs # getfacl /var/lib/nfs/{,state}
getfacl: Removing leading '/' from absolute path names
# file: var/lib/nfs
# owner: root
# group: root
user::rwx
group::r-x
other::r-x

# file: var/lib/nfs/state
# owner: nobody
# group: root
user::rw-
group::---
other::---

celina nfs # grep nobody /etc/{passwd,group}
/etc/passwd:nobody:x:65534:65534:nobody:/:/bin/false
/etc/group:nobody:x:65534:

celina nfs # lsmod |grep nfs
nfs                   114028  0
nfsd                  111240  0
exportfs                5984  1 nfsd
nfs_acl                 3680  2 nfs,nfsd
lockd                  66728  2 nfs,nfsd
sunrpc                147388  4 nfs,nfsd,nfs_acl,lockd

celina nfs # uname -a
Linux celina 2.6.14.4-K01_PIII_server #1 Thu Dec 22 14:48:26 JST 2005 i686 Celeron (Coppermine)
GenuineIntel GNU/Linux

celina nfs # gzcat /proc/config.gz |grep NFS |grep =
CONFIG_NFS_FS=m
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFSD=m
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFS_ACL_SUPPORT=m
CONFIG_NFS_COMMON=y

I have almost exactly the same setup on a few other machines and it works.

What am I missing here? This just drives me crazy...

Kalin.

-- 
|[ ~~~~~~~~~~~~~~~~~~~~~~ ]|
+-> http://ThinRope.net/ <-+
|[ ______________________ ]|


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
