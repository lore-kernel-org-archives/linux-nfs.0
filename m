From: Don Allingham <don.allingham@dothill.com>
Subject: NFS randomly denying permission to files
Date: Thu, 01 Feb 2007 15:42:36 -0700
Message-ID: <1170369756.1221.8.camel@allingham.power.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HCkdm-0005MO-EX
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 14:42:50 -0800
Received: from artecon.dothill.com ([155.254.128.254] helo=dothill.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HCkdk-0008Ct-12
	for nfs@lists.sourceforge.net; Thu, 01 Feb 2007 14:42:52 -0800
Received: from earthex1.dothill.com (earthex1 [206.6.180.60])
	by dothill.com (8.12.9+Sun/8.12.5) with ESMTP id l11MRBCe001149
	for <nfs@lists.sourceforge.net>; Thu, 1 Feb 2007 14:27:12 -0800 (PST)
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

I have recently upgraded my NFS (and NIS) server to a newer system.
Unfortunately, this has caused some very strange errors. Certain
directories (such as .mozilla/firefox) will give Permission denied
errors about 50% of the time.

$ ls
8g3rtccm.default  pluginreg.dat  profiles.ini
$ ls
8g3rtccm.default  pluginreg.dat  profiles.ini
$ ls
ls: .: Permission denied
$ ls
ls: .: Permission denied

The client is using the same mount command as before, only with a
different server name. Both the old and new servers are running Ubuntu
6.10 (one is a older P4, the new one is a dual processor Opteron)

The fstab for the client has the line:

vlsi-fs0:/export /home nfs rw,rsize=8192,wsize=8192,intr,hard 0 0

The host export file is pretty simple:

/export *(rw,no_root_squash,sync)

UIDs and GIDs for all files are the same (even though the NIS server
changed as well).

Any ideas on how to debug this problem?

Thanks
Don
 


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
