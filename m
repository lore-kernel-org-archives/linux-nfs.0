From: "Hyatt, Daniel J" <daniel.j.hyatt@boeing.com>
Subject: NFS server on startup on Redhat
Date: Thu, 9 Sep 2004 12:36:33 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <0CF6F73B3B779D43B160B85FD0CC2D37035C546D@xch-sw-07.sw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5Uj0-0001wA-6d
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 12:36:54 -0700
Received: from blv-smtpout-01.boeing.com ([130.76.32.69])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C5Uiw-0004fl-H7
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 12:36:53 -0700
Received: from slb-av-01.boeing.com ([129.172.13.4])
	by blv-smtpout-01.boeing.com (8.9.2.MG.10092003/8.8.5-M2) with ESMTP id MAA26261
	for <nfs@lists.sourceforge.net>; Thu, 9 Sep 2004 12:36:36 -0700 (PDT)
Received: from XCH-SWBH-02.sw.nos.boeing.com (localhost [127.0.0.1])
	by slb-av-01.boeing.com (8.11.3/8.11.3/MBS-LDAP-01) with ESMTP id i89JaZ402120
	for <nfs@lists.sourceforge.net>; Thu, 9 Sep 2004 12:36:35 -0700 (PDT)
To: <nfs@lists.sourceforge.net>
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

I installed Redhat 8 and am using the native NFS server.
I have it working with one small detail, and it seems to be a Linux
issue but cannot tell for sure if it is a race condition.

When I setup a startup script to run=20
/etc/init.d/nfs restart=20
In the rc2.d, rc3.d, or rc6.d=20
It wont run.

If I run it manually
/etc/rc2.d/nfs=20

It works perfectly.

But on startup it wont start the NFS server.

Thanks in advance....
Dan


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
