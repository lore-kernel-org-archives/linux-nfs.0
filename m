From: Alex Cresswell <acresswell@x-iss.com>
Subject: diskless linux client device permissions problem
Date: Fri, 26 Aug 2005 16:43:48 -0500
Message-ID: <430F8D14.9050904@x-iss.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="------------050401060208000401070006"
Cc: Deepak Khosla <dkhosla@x-iss.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E8lzL-000171-DU
	for nfs@lists.sourceforge.net; Fri, 26 Aug 2005 14:43:51 -0700
Received: from lsh123.siteprotect.com ([66.113.130.238])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1E8lzK-0007v9-R0
	for nfs@lists.sourceforge.net; Fri, 26 Aug 2005 14:43:51 -0700
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

This is a multi-part message in MIME format.
--------------050401060208000401070006
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

I'm trying to boot a linux node diskless, but I'm running into problems 
with the permissions in the /dev directory.  The way I'm setting up the 
diskless image I run rpm with the --root option to install the files 
into the image directory on an NFS mount, but when I install the dev rpm 
the permissions on the devices ends up as 000, as the example below.  
The strange thing is if I manually create a device with mknod then set 
the permissions with chmod, it works fine. 

> b---------    1 root     root     106,  76 Jun 24  2004 
> /ifs/cit/machine/RHWS3U3/image/dev/cciss/c2d4p12


At first I thought the permissions may be set through a post script in 
the dev-x.y.z.rpm file, but I looked through the scripts in the rpm with 
the rpm -qp --scripts command, and they are not set by the post script. 


Next I looked at an strace of the rpm command to see exactly what it was 
doing.  Below is a portion of the output from strace.  RPM seems to 
repeat the same process for all the devices, but this is just an example 
of what it does for one device.

> lstat64("/dev/cciss/c2d4p12;430f682c", 0x82e8dbc) = -1 ENOENT (No such 
> file or directory)
> mknod("/dev/cciss/c2d4p12;430f682c", S_IFBLK, makedev(106, 76)) = 0
> ioctl(1, TCGETS, {B38400 opost isig icanon echo ...}) = 0
> rename("/dev/cciss/c2d4p12;430f682c", "/dev/cciss/c2d4p12") = 0
> getuid32()                              = 0
> chown32(0x807fe40, 0, 0x6)              = 0
> chmod("/dev/cciss/c2d4p12", 0660)       = 0
> utime("/dev/cciss/c2d4p12", [2004/06/24-13:04:38, 
> 2004/06/24-13:04:38]) = 0

Next I looked at a tcpdump -vvv -u host node3 to see what it was sending 
to the NFS server while the rpm command is running.  Once again the same 
few command are repeated in the same sequence.  This is what it looks like:

> 15:52:27.160008 cmgmt1.4079924938 > node3.nfs: 156 lookup fh 
> Unknown/0100000100080002FBC00200C8140B00D3C9AD460000000E68646432333B3433 
> "hdd23;430f80f6" (DF) (ttl 64, id 34918, len 184)
> 15:52:27.160266 node3.nfs > cmgmt1.4079924938: reply ok 116 lookup 
> ERROR: No such file or directory post dattr: DIR 40755 ids 0/0 sz 
> 0x00001d000 nlink 22 rdev 0/0 fsid 0x000000000 nodeid 0x000000000 
> a/m/ctime 1088100277.000000 1125089325.000000 1125089325.000000  (DF) 
> (ttl 64, id 9633, len 144)
> 15:52:27.160371 cmgmt1.4096702154 > node3.nfs: 196 mknod fh 
> Unknown/0100000100080002FBC00200C8140B00D3C9AD460000000E68646432333B3433 
> "hdd23;430f80f6" BLK 22/87 mode 60000 (DF) (ttl 64, id 34919, len 224)
> 15:52:27.161489 node3.nfs > cmgmt1.4096702154: reply ok 240 mknod fh 
> Unknown/0100000200080002FBC00200C2160B0022B6AF46C8140B000000000100000003 
> BLK 60000 ids 0/0 sz 0x000000000 nlink 1 rdev 22/87 fsid 0x1600000057 
> nodeid 0x5700000000 a/m/ctime 1125089325.000000 1125089325.000000 
> 1125089325.000000 dir attr: PRE: POST: DIR 40755 ids 0/0 sz 
> 0x00001d000 nlink 22 rdev 0/0 fsid 0x000000000 nodeid 0x000000000 
> a/m/ctime 1088100277.000000 1125089325.000000 1125089325.000000  (DF) 
> (ttl 64, id 9634, len 268)
> 15:52:27.161633 cmgmt1.4113479370 > node3.nfs: 148 lookup fh 
> Unknown/0100000100080002FBC00200C8140B00D3C9AD46000000056864643233000000 
> "hdd23" (DF) (ttl 64, id 34920, len 176)
> 15:52:27.161897 node3.nfs > cmgmt1.4113479370: reply ok 232 lookup fh 
> Unknown/0100000200080002FBC00200C3160B00826BAF46C8140B000000000100000003 
> BLK 60000 ids 0/0 sz 0x000000000 nlink 1 rdev 22/87 fsid 0x1600000057 
> nodeid 0x5700000000 a/m/ctime 1125088075.000000 1125088075.000000 
> 1125088075.000000  post dattr: DIR 40755 ids 0/0 sz 0x00001d000 nlink 
> 22 rdev 0/0 fsid 0x000000000 nodeid 0x000000000 a/m/ctime 
> 1088100277.000000 1125089325.000000 1125089325.000000  (DF) (ttl 64, 
> id 9635, len 260)
> 15:52:27.162032 cmgmt1.4130256586 > node3.nfs: 192 rename fh 
> Unknown/0100000100080002FBC00200C8140B00D3C9AD460000000E68646432333B3433 
> "hdd23;430f80f6" -> fh 
> Unknown/0100000100080002FBC00200C8140B00D3C9AD46000000056864643233000000 
> "hdd23" (DF) (ttl 64, id 34921, len 220)
> 15:52:27.163120 node3.nfs > cmgmt1.4130256586: reply ok 260 rename 
> from: PRE: sz 0x00001d000 mtime 1125089325.000000 ctime 
> 1125089325.000000 POST: DIR 40755 ids 0/0 sz 0x00001d000 nlink 22 rdev 
> 0/0 fsid 0x000000000 nodeid 0x000000000 a/m/ctime 1088100277.000000 
> 1125089325.000000 1125089325.000000  to: PRE: sz 0x00001d000 mtime 
> 1125089325.000000 ctime 1125089325.000000 POST: DIR 40755 ids 0/0 sz 
> 0x00001d000 nlink 22 rdev 0/0 fsid 0x000000000 nodeid 0x000000000 
> a/m/ctime 1088100277.000000 1125089325.000000 1125089325.000000  (DF) 
> (ttl 64, id 9636, len 288)


On the NFS client I'm running 2.4.21-4.ELsmp, and the NFS server is 
running 2.4.21-20.ELsmp.  The export file has the flags rw and 
no_root_squash, but I've also tried the sync flag to no effect.  On the 
client I've tried the actimeo=0 flag, which also had no effect on the 
issue. 

Does anyone have an idea what is going wrong here?  At this point it 
will probably take me quite a while to get to the bottom of this, so I'm 
hoping someone can tell me where I might look next.  Do I need to set 
some client side flags, it seems like it's doing some caching improperly 
and the permissions never get written to the server? 

thanks for any help,
-Alex

-- 
Alex Cresswell - Systems Analyst
RHCE, CCNA, CLE
eXcellence in IS Solutions, Inc. (X-ISS)
========================================
Email:      acresswell@x-iss.com
VM/Pager:   713.339.7225
Office:     713.862.9200
Fax:        713.586.3224
========================================


--------------050401060208000401070006
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html;charset=ISO-8859-1">
  <title></title>
</head>
<body text="#000066" bgcolor="#ffffff">
I'm trying to boot a linux node diskless, but I'm running into problems
with the permissions in the /dev directory.&nbsp; The way I'm setting up the
diskless image I run rpm with the --root option to install the files
into the image directory on an NFS mount, but when I install the dev
rpm the permissions on the devices ends up as 000, as the example
below.&nbsp; The strange thing is if I manually create a device with mknod
then set the permissions with chmod, it works fine.&nbsp; <br>
<blockquote type="cite">b---------&nbsp;&nbsp;&nbsp; 1 root&nbsp;&nbsp;&nbsp;&nbsp; root&nbsp;&nbsp;&nbsp;&nbsp; 106,&nbsp; 76 Jun
24&nbsp; 2004 /ifs/cit/machine/RHWS3U3/image/dev/cciss/c2d4p12<br>
</blockquote>
<br>
At first I thought the permissions may be set through a post script in
the dev-x.y.z.rpm file, but I looked through the scripts in the rpm
with the rpm -qp --scripts command, and they are not set by the post
script.&nbsp; <br>
<br>
<br>
Next I looked at an strace of the rpm command to see exactly what it
was doing.&nbsp; Below is a portion of the output from strace.&nbsp; RPM seems to
repeat the same process for all the devices, but this is just an
example of what it does for one device.<br>
<blockquote type="cite">lstat64("/dev/cciss/c2d4p12;430f682c",
0x82e8dbc) = -1 ENOENT (No such file or directory)<br>
mknod("/dev/cciss/c2d4p12;430f682c", S_IFBLK, makedev(106, 76)) = 0<br>
ioctl(1, TCGETS, {B38400 opost isig icanon echo ...}) = 0<br>
rename("/dev/cciss/c2d4p12;430f682c", "/dev/cciss/c2d4p12") = 0<br>
getuid32()&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; = 0<br>
chown32(0x807fe40, 0, 0x6)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; = 0<br>
chmod("/dev/cciss/c2d4p12", 0660)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; = 0<br>
utime("/dev/cciss/c2d4p12", [2004/06/24-13:04:38, 2004/06/24-13:04:38])
= 0<br>
</blockquote>
Next I looked at a tcpdump -vvv -u host node3 to see what it was
sending to the NFS server while the rpm command is running.&nbsp; Once again
the same few command are repeated in the same sequence.&nbsp; This is what
it looks like:<br>
<blockquote type="cite">15:52:27.160008 cmgmt1.4079924938 &gt;
node3.nfs: 156 lookup fh
Unknown/0100000100080002FBC00200C8140B00D3C9AD460000000E68646432333B3433
"hdd23;430f80f6" (DF) (ttl 64, id 34918, len 184)<br>
15:52:27.160266 node3.nfs &gt; cmgmt1.4079924938: reply ok 116 lookup
ERROR: No such file or directory post dattr: DIR 40755 ids 0/0 sz
0x00001d000 nlink 22 rdev 0/0 fsid 0x000000000 nodeid 0x000000000
a/m/ctime 1088100277.000000 1125089325.000000 1125089325.000000&nbsp; (DF)
(ttl 64, id 9633, len 144)<br>
15:52:27.160371 cmgmt1.4096702154 &gt; node3.nfs: 196 mknod fh
Unknown/0100000100080002FBC00200C8140B00D3C9AD460000000E68646432333B3433
"hdd23;430f80f6" BLK 22/87 mode 60000 (DF) (ttl 64, id 34919, len 224)<br>
15:52:27.161489 node3.nfs &gt; cmgmt1.4096702154: reply ok 240 mknod fh
Unknown/0100000200080002FBC00200C2160B0022B6AF46C8140B000000000100000003
BLK 60000 ids 0/0 sz 0x000000000 nlink 1 rdev 22/87 fsid 0x1600000057
nodeid 0x5700000000 a/m/ctime 1125089325.000000 1125089325.000000
1125089325.000000 dir attr: PRE: POST: DIR 40755 ids 0/0 sz 0x00001d000
nlink 22 rdev 0/0 fsid 0x000000000 nodeid 0x000000000 a/m/ctime
1088100277.000000 1125089325.000000 1125089325.000000&nbsp; (DF) (ttl 64, id
9634, len 268)<br>
15:52:27.161633 cmgmt1.4113479370 &gt; node3.nfs: 148 lookup fh
Unknown/0100000100080002FBC00200C8140B00D3C9AD46000000056864643233000000
"hdd23" (DF) (ttl 64, id 34920, len 176)<br>
15:52:27.161897 node3.nfs &gt; cmgmt1.4113479370: reply ok 232 lookup
fh
Unknown/0100000200080002FBC00200C3160B00826BAF46C8140B000000000100000003
BLK 60000 ids 0/0 sz 0x000000000 nlink 1 rdev 22/87 fsid 0x1600000057
nodeid 0x5700000000 a/m/ctime 1125088075.000000 1125088075.000000
1125088075.000000&nbsp; post dattr: DIR 40755 ids 0/0 sz 0x00001d000 nlink
22 rdev 0/0 fsid 0x000000000 nodeid 0x000000000 a/m/ctime
1088100277.000000 1125089325.000000 1125089325.000000&nbsp; (DF) (ttl 64, id
9635, len 260)<br>
15:52:27.162032 cmgmt1.4130256586 &gt; node3.nfs: 192 rename fh
Unknown/0100000100080002FBC00200C8140B00D3C9AD460000000E68646432333B3433
"hdd23;430f80f6" -&gt; fh
Unknown/0100000100080002FBC00200C8140B00D3C9AD46000000056864643233000000
"hdd23" (DF) (ttl 64, id 34921, len 220)<br>
15:52:27.163120 node3.nfs &gt; cmgmt1.4130256586: reply ok 260 rename
from: PRE: sz 0x00001d000 mtime 1125089325.000000 ctime
1125089325.000000 POST: DIR 40755 ids 0/0 sz 0x00001d000 nlink 22 rdev
0/0 fsid 0x000000000 nodeid 0x000000000 a/m/ctime 1088100277.000000
1125089325.000000 1125089325.000000&nbsp; to: PRE: sz 0x00001d000 mtime
1125089325.000000 ctime 1125089325.000000 POST: DIR 40755 ids 0/0 sz
0x00001d000 nlink 22 rdev 0/0 fsid 0x000000000 nodeid 0x000000000
a/m/ctime 1088100277.000000 1125089325.000000 1125089325.000000&nbsp; (DF)
(ttl 64, id 9636, len 288)<br>
</blockquote>
<br>
On the NFS client I'm running 2.4.21-4.ELsmp, and the NFS server is
running 2.4.21-20.ELsmp.&nbsp; The export file has the flags rw and
no_root_squash, but I've also tried the sync flag to no effect.&nbsp; On the
client I've tried the actimeo=0 flag, which also had no effect on the
issue.&nbsp; <br>
<br>
Does anyone have an idea what is going wrong here?&nbsp; At this point it
will probably take me quite a while to get to the bottom of this, so
I'm hoping someone can tell me where I might look next.&nbsp; Do I need to
set some client side flags, it seems like it's doing some caching
improperly and the permissions never get written to the server?&nbsp; <br>
<br>
thanks for any help,<br>
-Alex<br>
<br>
<pre class="moz-signature" cols="72">-- 
Alex Cresswell - Systems Analyst
RHCE, CCNA, CLE
eXcellence in IS Solutions, Inc. (X-ISS)
========================================
Email:      <a class="moz-txt-link-abbreviated" href="mailto:acresswell@x-iss.com">acresswell@x-iss.com</a>
VM/Pager:   713.339.7225
Office:     713.862.9200
Fax:        713.586.3224
========================================</pre>
</body>
</html>

--------------050401060208000401070006--



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
