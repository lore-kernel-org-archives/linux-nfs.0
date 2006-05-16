From: Rudi Starcevic <tech@wildcash.com>
Subject: time_out_leases + 2.6 problem?
Date: Tue, 16 May 2006 10:02:57 +1000
Message-ID: <446916B1.8040202@wildcash.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ffn1q-0000VR-4E
	for nfs@lists.sourceforge.net; Mon, 15 May 2006 17:03:10 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ffn1q-00038N-3b
	for nfs@lists.sourceforge.net; Mon, 15 May 2006 17:03:10 -0700
Received: from mail1.mailhostingservice.com ([216.154.198.171])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1Ffn1p-00049f-PI
	for nfs@lists.sourceforge.net; Mon, 15 May 2006 17:03:10 -0700
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

Hi,

I have an NFS cluster of 16 Servers and 7 Clients.

The 7 NFS clients are also running Apache web servers
for a video-on-demand web site.

All servers are GNU/Debian Linux with 2.6.8 kernel.

The problem is basicly something like one on the 16 NFS
servers 'drops-out'. This causes issues on the 7 clients.

These client issues are mostly super high load averages, 400+,
being caused by Apache not being able to complete file requests
from the NFS mounted movies/images I think.

The end result is 1 NFS server causes 7 NFS client to increase
load-avg so high www request serviceing stops. Thus all 23 boxes basicly
stop using bandwidth.

When I log into this 1 NFS server thats is causing the problem

I'm unable to umount the disk partitions, and unable to kill
all nfs.rpc processes.

Somestime the machines will even hang during reboot.

This is some of the on-screen error I've been able to get the remote
data center tech to get for me:

CPU: 0
EIP: 0060: [<c0166a68>] not tainted
EFlags: 00010206 (2.6.8-imp10)
EIP is at a time_out_leases
Process rpc.nfsd

Do you think this 'time_out_leases' is a 2.6.8 NFS kernel issues?

Would upgrading to a new kernel help this?

I've also been informed by the data center techs that the
box times out during a script with a CALL TRACE error, then about a page
of hex code error. The box stays up for ping and ssh, you can ssh in and
reboot it, but then it hangs when its trying to unmount the filesystem
during the shutdown process.

The following is more data I've collected from the problem
server at the time one of these NFS server 'lock-ups' occurred:

nfs# lsof /dev/sda9
COMMAND   PID USER   FD   TYPE DEVICE      SIZE       NODE NAME
rpc.nfsd 1964 root    0r   REG    8,9     10056  695287888
/onlinemovies1/comedy/196_greatescapes/04/02.jpg

nfs# lsof /dev/sdb1
COMMAND   PID USER   FD   TYPE DEVICE      SIZE       NODE NAME
rpc.nfsd 1964 root    7r   REG   8,17      9510 1240091088
/onlinemovies2/comedy/196_greatescapes/04/08.jpg
rpc.nfsd 1964 root    9r   REG   8,17 110665728  645657338

nfs# ps aux | grep 1964
root      1964  1.6  0.0  3120 1536 ?        Ds   May10  19:21
/usr/sbin/rpc.nfsd

nfs# killall -9 rpc.nfsd

nfs# ps aux | grep 1964
root      1964  1.6  0.0  3120 1536 ?        Ds   May10  19:21
/usr/sbin/rpc.nfsd

media7:~/scripts/nfs# lsof -p 1964
COMMAND   PID USER   FD   TYPE     DEVICE      SIZE       NODE NAME
rpc.nfsd 1964 root  cwd    DIR        8,3      4096          2 /
rpc.nfsd 1964 root  rtd    DIR        8,3      4096          2 /
rpc.nfsd 1964 root  txt    REG        8,6     66456     337606
/usr/sbin/rpc.nfsd
rpc.nfsd 1964 root  mem    REG        8,3     90248     321937
/lib/ld-2.3.2.so
rpc.nfsd 1964 root  mem    REG        8,3     18876     563366
/lib/tls/libcrypt-2.3.2.so
rpc.nfsd 1964 root  mem    REG        8,3     73304     563370
/lib/tls/libnsl-2.3.2.so
rpc.nfsd 1964 root  mem    REG        8,3   1254468     563365
/lib/tls/libc-2.3.2.so
rpc.nfsd 1964 root  mem    REG        8,3     17860     322016
/lib/libnss_db-2.2.so
rpc.nfsd 1964 root  mem    REG        8,3     34748     563373
/lib/tls/libnss_files-2.3.2.so
rpc.nfsd 1964 root  mem    REG        8,6    692456     321288
/usr/lib/libdb3.so.3.0.2
rpc.nfsd 1964 root  mem    REG        8,3     28616     563371
/lib/tls/libnss_compat-2.3.2.so
rpc.nfsd 1964 root  mem    REG        8,3     33440     563375
/lib/tls/libnss_nis-2.3.2.so
rpc.nfsd 1964 root  mem    REG        8,3     13976     563372
/lib/tls/libnss_dns-2.3.2.so
rpc.nfsd 1964 root  mem    REG        8,3     64924     563379
/lib/tls/libresolv-2.3.2.so
rpc.nfsd 1964 root    0r   REG        8,9     10056  695287888
/onlinemovies1/comedy/196_greatescapes/04/02.jpg
rpc.nfsd 1964 root    2r   REG        8,9     10757  695287892
/onlinemovies1/comedy/196_greatescapes/04/06.jpg
rpc.nfsd 1964 root    3u  unix 0xf6f10900                 3885 socket
rpc.nfsd 1964 root    4u  IPv4       3888                  UDP *:2049
rpc.nfsd 1964 root    5u  IPv4       3891                  TCP *:2049


-- 
Thank you.
Regards,
Rudi


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
