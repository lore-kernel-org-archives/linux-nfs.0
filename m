From: Ulrich Gemkow <gemkow@ikr.uni-stuttgart.de>
Subject: exportfs -u hangs on SMP
Date: Sun, 20 Jul 2003 10:36:49 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030720103649.A20763@ikr.uni-stuttgart.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gate.ikr.uni-stuttgart.de ([129.69.170.1])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19e9gg-0003t6-00
	for <nfs@lists.sourceforge.net>; Sun, 20 Jul 2003 01:36:58 -0700
Received: from netsrv1.ikr.uni-stuttgart.de (netsrv1-c [10.11.12.12])
	by gate.ikr.uni-stuttgart.de (Postfix) with ESMTP id D64BF2ADEC
	for <nfs@lists.sourceforge.net>; Sun, 20 Jul 2003 10:36:49 +0200 (CEST)
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

we have (for security reasons) implemented a "session layer" above the usual
NFS, where paths are exported on a NFS-Server for a host when an user logs in
and are un-exported on logout.

>From this results a rather high rate of calls to "exportfs" and "exportfs -u"
for individual hosts/paths on the server during normal work (not only on
server-startup/shutdown as usual).

Now sometimes we have hangs of "exportfs -u". The process hangs and is not
killable. The server works normal except that it is no longer responding to 
NFS requests. Only a reboot of the server helps.

The "hang rate" is about once per day with 20 users and 5 directories exported
on login for each user. The server has medium to high NFS-load.

The hangs only happen when the server is running a SMP-enabled kernel. When
using a non-SMP-kernel on the same hardware, the hangs are not happening.

Environment is Linux 2.4.21 (vanilla), nfs-utils 1.0.1 (vanilla, xlog-patch
applied), glibc 2.3 (RedHat 9 based) on a 2-processor PIII hardware.

Please tell me if I can be of any help diagnosing and solving the problem.

Thank you and greetings

Ulrich

-- 
|-----------------------------------------------------------------------
| Ulrich Gemkow
| University of Stuttgart, Germany
| Institute of Communication Networks and Computer Engineering (IKR)
|-----------------------------------------------------------------------


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
