From: David Warren <warren@atmos.washington.edu>
Subject: NFS caching bug is back
Date: Thu, 19 Apr 2007 08:43:35 -0700
Message-ID: <46278E27.8050705@atmos.washington.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1595328680=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HeYnT-0007oo-0d
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 08:43:47 -0700
Received: from dew2.atmos.washington.edu ([128.95.89.42])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HeYnV-0007Wq-CG
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 08:43:49 -0700
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

This is a multi-part message in MIME format.
--===============1595328680==
Content-Type: multipart/alternative;
	boundary="------------050601060307050400030805"

This is a multi-part message in MIME format.
--------------050601060307050400030805
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

A bug that we turned in a while ago is back in the 2.6.20 kernels, only 
worse. I have found it in 2.6.20.6 and 2.6.20.7. It happens with both 
NFS4 and NFS3 mounts. Clients don't see inode changes (delete and 
recreate file):
Setup:
3 systems all running:
Linux enkf1 2.6.20.7 #1 SMP Wed Apr 18 16:23:15 PDT 2007 x86_64 GNU/Linux
File system is xfs. mounted as:
/dev/sda3       /home/enkf      xfs     defaults        0       2
exported as:
(fsid=0,nohide,rw,no_subtree_check,sync,no_root_squash)
NFS mounted as
enkf1:/ /home/enkf   nfs4   rw,proto=tcp,rsize=32768,wsize=32768,hard  0 0
also as
enkf1:/ /home/enkf   nfs   rw,proto=tcp,rsize=8192,wsize=8192,hard  0 0
and
enkf1:/ /home/enkf   nfs   rw,proto=tcp,hard  0 0

Here are the mounts according to the mount command:
enkf1 -
/dev/sda3 on /home/enkf type xfs (rw)

enkf2 -
enkf1:/ on /home/enkf type nfs4 
(rw,proto=tcp,rsize=32768,wsize=32768,hard,addr=128.95.175.220)

enkf3 -
enkf1:/ on /home/enkf type nfs4 
(rw,proto=tcp,rsize=32768,wsize=32768,hard,addr=128.95.175.220)

Here is the sequence in time order. This is even easier to demonstrate 
than the last time:
enkf1:~# echo 2 > /home/enkf/ddd

enkf2:~# cat /home/enkf/ddd
2

enkf3:~# cat /home/enkf/ddd
2

enkf1:~# rm /home/enkf/ddd
enkf1:~# echo 3 > /home/enkf/ddd

enkf2:~# cat /home/enkf/ddd
2

enkf3:~# cat /home/enkf/ddd
2

enkf1:~# ls -i /home/enkf/ddd
10872 /home/enkf/ddd

enkf2:~# ls -i /home/enkf/ddd
10855 /home/enkf/ddd

enkf3:~# ls -i /home/enkf/ddd
10855 /home/enkf/ddd
enkf3:~# touch /home/enkf/ddd
enkf3:~# ls -i /home/enkf/ddd
10872 /home/enkf/ddd

enkf2:~# ls -i /home/enkf/ddd
10855 /home/enkf/ddd



-- 
David Warren 		INTERNET: warren@atmos.washington.edu
(206) 543-0945		Fax: (206) 543-0308
University of Washington
Dept of Atmospheric Sciences, Box 351640
Seattle, WA 98195-1640
-------------------------------------------------------------------------------
DECUS E-PUBS Library Committee representative
SeaLUG DECUS Chair


--------------050601060307050400030805
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
</head>
<body bgcolor="#ffffff" text="#000000">
A bug that we turned in a while ago is back in the 2.6.20 kernels, only
worse. I have found it in 2.6.20.6 and 2.6.20.7. It happens with both
NFS4 and NFS3 mounts. Clients don't see inode changes (delete and
recreate file):<br>
Setup:<br>
3 systems all running: <br>
Linux enkf1 2.6.20.7 #1 SMP Wed Apr 18 16:23:15 PDT 2007 x86_64
GNU/Linux<br>
File system is xfs. mounted as:<br>
/dev/sda3&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; /home/enkf&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; xfs&nbsp;&nbsp;&nbsp;&nbsp; defaults&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 0&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2<br>
exported as:<br>
(fsid=0,nohide,rw,no_subtree_check,sync,no_root_squash)<br>
NFS mounted as<br>
enkf1:/ /home/enkf&nbsp;&nbsp; nfs4&nbsp;&nbsp; rw,proto=tcp,rsize=32768,wsize=32768,hard&nbsp;
0 0<br>
also as<br>
enkf1:/ /home/enkf&nbsp;&nbsp; nfs&nbsp;&nbsp; rw,proto=tcp,rsize=8192,wsize=8192,hard&nbsp; 0 0<br>
and<br>
enkf1:/ /home/enkf&nbsp;&nbsp; nfs&nbsp;&nbsp; rw,proto=tcp,hard&nbsp; 0 0<br>
<br>
Here are the mounts according to the mount command:<br>
enkf1 -<br>
/dev/sda3 on /home/enkf type xfs (rw)<br>
<br>
enkf2 -<br>
enkf1:/ on /home/enkf type nfs4
(rw,proto=tcp,rsize=32768,wsize=32768,hard,addr=128.95.175.220)<br>
<br>
enkf3 -<br>
enkf1:/ on /home/enkf type nfs4
(rw,proto=tcp,rsize=32768,wsize=32768,hard,addr=128.95.175.220)<br>
<br>
Here is the sequence in time order. This is even easier to demonstrate
than the last time:<br>
<font color="#ff0000">enkf1:~# echo 2 &gt; /home/enkf/ddd</font><br>
<br>
<font color="#3333ff">enkf2:~# cat /home/enkf/ddd<br>
2</font><br>
<br>
<font color="#009900">enkf3:~# cat /home/enkf/ddd<br>
2</font><br>
<br>
<font color="#ff0000">enkf1:~# rm /home/enkf/ddd<br>
enkf1:~# echo 3 &gt; /home/enkf/ddd</font><br>
<br>
<font color="#3333ff">enkf2:~# cat /home/enkf/ddd<br>
2</font><br>
<br>
<font color="#009900">enkf3:~# cat /home/enkf/ddd<br>
2</font><br>
<br>
<font color="#ff0000">enkf1:~# ls -i /home/enkf/ddd<br>
10872 /home/enkf/ddd</font><br>
<br>
<font color="#3333ff">enkf2:~# ls -i /home/enkf/ddd<br>
10855 /home/enkf/ddd<br>
</font><br>
<font color="#009900">enkf3:~# ls -i /home/enkf/ddd<br>
10855 /home/enkf/ddd<br>
enkf3:~# touch /home/enkf/ddd<br>
enkf3:~# ls -i /home/enkf/ddd<br>
10872 /home/enkf/ddd</font><br>
<br>
<font color="#3333ff">enkf2:~# ls -i /home/enkf/ddd<br>
10855 /home/enkf/ddd</font><br>
<br>
<br>
<br>
<pre class="moz-signature" cols="72">-- 
David Warren 		INTERNET: <a class="moz-txt-link-abbreviated" href="mailto:warren@atmos.washington.edu">warren@atmos.washington.edu</a>
(206) 543-0945		Fax: (206) 543-0308
University of Washington
Dept of Atmospheric Sciences, Box 351640
Seattle, WA 98195-1640
-------------------------------------------------------------------------------
DECUS E-PUBS Library Committee representative
SeaLUG DECUS Chair
</pre>
</body>
</html>

--------------050601060307050400030805--


--===============1595328680==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============1595328680==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1595328680==--
