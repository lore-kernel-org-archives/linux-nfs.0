From: wang dengyi <dy_wang@yahoo.com>
Subject: umount error: device is busy
Date: Mon, 15 May 2006 11:57:22 -0700 (PDT)
Message-ID: <20060515185722.58152.qmail@web51913.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FfiG1-0006n2-Hm
	for nfs@lists.sourceforge.net; Mon, 15 May 2006 11:57:29 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FfiG1-0001uD-JE
	for nfs@lists.sourceforge.net; Mon, 15 May 2006 11:57:29 -0700
Received: from web51913.mail.yahoo.com ([206.190.48.76])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FfiG0-0000rk-Ai
	for nfs@lists.sourceforge.net; Mon, 15 May 2006 11:57:29 -0700
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

Hello,

When I ran ltp test case:tlocklfs, I met a old problem
with the kernel:2.6.9. I can not umount a file system
after nfs and lock using it. Here is the steps.
 1) mount /dev/sda3 /xyz
 2) export /xyz
 3) restart nfs
 4) mount 127.0.0.1:/xyz /mnt/nfs_xyz
 5) run the special lock test program: "tlocklfs -t 7
/mnt/nfs_xyz
 6) umount /mnt/nfs_xyz
 7) stop nfs
 8) umount /xyz
Then I got the error: "umount /xyz: device is busy".
And the error displays twice.=20

If I run the different lock test case for the step 5,
the umount works fine. It only failed on the test case
7 from tlocklfs.=20

There are 2 processes in this special test case.
First, the parent process "setlk" for a file from nfs
file system. Then the child process "setlkw". At the
end, the parent and the child process unlock the file.


With some debug line in the code, I found the file
system's "mnt_count" is 3 instead of 2 before
umounting it. I traced back the problem and I'm lost
in linux/net/sunrpc/sched.c. Could anyone give me some
hint? Thank you very much.

Best regard

Dengyi Wang
 =20

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam
protection around=20
http://mail.yahoo.com=20

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job ea=
sier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronim=
o
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D120709&bid=3D263057&dat=3D=
121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
