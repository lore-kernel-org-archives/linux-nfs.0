From: Stephen Liu <satimis@yahoo.com>
Subject: Fail to start rpc nfsd
Date: Sat, 11 Nov 2006 22:50:03 +0800 (CST)
Message-ID: <20061111145003.65766.qmail@web35210.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GiuBP-0004FW-DC
	for nfs@lists.sourceforge.net; Sat, 11 Nov 2006 06:50:12 -0800
Received: from web35210.mail.mud.yahoo.com ([66.163.179.89])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1GiuBN-0001eu-Mt
	for nfs@lists.sourceforge.net; Sat, 11 Nov 2006 06:50:12 -0800
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi folks,

Ubuntu-6.06.1-LAMP-server-amd64

I'm following;
https://help.ubuntu.com/ubuntu/serverguide/C/index.html
Network File System (NFS)
https://help.ubuntu.com/ubuntu/serverguide/C/network-file-system.html

to build a LAMP server which is for test only, not for production.
Failed to start "nfs-kernel-server"


$ sudo /etc/init.d/nfs-kernel-server start
Password:
 * Exporting directories for NFS kernel daemon...
[ ok ]
 * Starting rpc nfsd...                              [fail]


$ cat /var/log/messages
........
.........
Nov 11 22:36:15 ubuntu kernel: [  563.144537] NFSD: Using
/var/lib/nfs/v4recovery as the NFSv4 state recovery dire$Nov 11
22:36:15
ubuntu kernel: [  563.144547] NFSD: recovery directory
/var/lib/nfs/v4recovery doesn't exist
Nov 11 22:36:15 ubuntu kernel: [  563.144550] NFSD: starting 90-second
grace period
Nov 11 22:36:50 ubuntu kernel: [  598.130968] portmap: server localhost
not responding, timed out
Nov 11 22:36:50 ubuntu kernel: [  598.130989] RPC: failed to contact
portmap (errno -5).
Nov 11 22:37:25 ubuntu kernel: [  633.112341] portmap: server localhost
not responding, timed out
Nov 11 22:37:25 ubuntu kernel: [  633.112361] RPC: failed to contact
portmap (errno -5).
Nov 11 22:38:00 ubuntu kernel: [  668.098108] portmap: server localhost
not responding, timed out
Nov 11 22:38:00 ubuntu kernel: [  668.098128] RPC: failed to contact
portmap (errno -5).
* end *


Please advise how to fix the problem.  TIA

B.R.
Stephen


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
