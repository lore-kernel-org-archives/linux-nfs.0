From: "Hyatt, Daniel J" <daniel.j.hyatt@boeing.com>
Subject: LINUX NFS server Solaris NFS client issue
Date: Tue, 7 Sep 2004 11:43:34 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <0CF6F73B3B779D43B160B85FD0CC2D37026551D7@xch-sw-07.sw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C4kwZ-0004zZ-4C
	for nfs@lists.sourceforge.net; Tue, 07 Sep 2004 11:43:51 -0700
Received: from stl-smtpout-01.boeing.com ([130.76.96.56])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C4kwW-00023i-GC
	for nfs@lists.sourceforge.net; Tue, 07 Sep 2004 11:43:50 -0700
Received: from stl-av-01.boeing.com ([192.76.190.6])
	by stl-smtpout-01.boeing.com (8.9.2.MG.10092003/8.8.5-M2) with ESMTP id NAA19847
	for <nfs@lists.sourceforge.net>; Tue, 7 Sep 2004 13:43:40 -0500 (CDT)
Received: from XCH-SWBH-02.sw.nos.boeing.com (localhost [127.0.0.1])
	by stl-av-01.boeing.com (8.11.3/8.11.3/MBS-LDAP-01) with ESMTP id i87IhdD29115
	for <nfs@lists.sourceforge.net>; Tue, 7 Sep 2004 13:43:40 -0500 (CDT)
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

I am hoping for some recommendations for success. I was just told that
Linux NFS server is experimental. But I am backed into a corner and need
to get this working. And Redhat docs and redhat sys admin manual don't
mention it being experimental.


I have a Linux NFS server running Redhat 8 "lap"
I have a Solaris ultra 10 running Solaris8. "hal"

I checked the systems files and both Linux and Solaris offer both TCP
and UDP for NFS.

The file systems shows up=20
[root@lap init.d]# exportfs -v
/projects/os    hal(rw,wdelay,insecure,no_root_squash)
/projects/os    losangeles(rw,wdelay,insecure,no_root_squash)
/projects/os    larry(rw,async,wdelay,insecure,no_root_squash)
/appl           hal(rw,async,wdelay,insecure,no_root_squash)
/appl           losangeles(rw,async,wdelay,insecure,no_root_squash)
/appl           larry(rw,async,wdelay,insecure,no_root_squash)

The Linux NFS server is successfully exporting the fs to another Linux
box "larry"
But when I import it into Solaris 8 (two different boxes) I get=20
hal# mountall
/dev/rdsk/c0t0d0s7 already mounted
=20
mount: lap:/appl or /appll, no such file or directory
mount: lap:/projects/os or /proj/os, no such file or directory
hal#=20

Vfstab is:
lap:/projects/os -    /proj/os                ufs     -       yes     rw

lap:/appl      -      /appll                  ufs     -       yes     rw



At one point, I was able to import it into Solaris, but when I went to
the directory no files were visible.
Thanks in advance,
Dan



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
