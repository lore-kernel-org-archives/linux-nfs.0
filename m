From: "Nida M" <nidajm@gmail.com>
Subject: On NFS mounted file system access time not updated
Date: Sat, 17 Jun 2006 17:34:35 +0530
Message-ID: <b01966ec0606170504p1575f325y560aa3b764dc47a2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0908324773=="
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FrZXZ-0005Dq-1C
	for nfs@lists.sourceforge.net; Sat, 17 Jun 2006 05:04:37 -0700
Received: from nz-out-0102.google.com ([64.233.162.207])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FrZXZ-0003Qs-0V
	for nfs@lists.sourceforge.net; Sat, 17 Jun 2006 05:04:37 -0700
Received: by nz-out-0102.google.com with SMTP id x7so882623nzc
	for <nfs@lists.sourceforge.net>; Sat, 17 Jun 2006 05:04:35 -0700 (PDT)
To: neil@brown.name
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

--===============0908324773==
Content-Type: multipart/alternative;
	boundary="----=_Part_104411_30622257.1150545875435"

------=_Part_104411_30622257.1150545875435
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi

I am phasing a problem on MIPS platform for kernel 2.6.16 that,
on NFS mounted file system the atime is not getting updated.

To test this i have written a test program ,in which I am doing a read(),
and then I do a stat() to check the changed attribute of the file being
read.
But I found the access time [atime]  is not getting updated..

For 2.6 kernel has any patch is released to fix this problem ..?
I need to fix this problem .. Can Anybody help me in this..??





~ Nida

------=_Part_104411_30622257.1150545875435
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

<div>Hi</div>
<div>&nbsp;</div>
<div>I am phasing a problem on MIPS platform for kernel 2.6.16 that, </div>
<div>on NFS mounted file system the atime is not getting updated.</div>
<div>&nbsp;</div>
<div>To test this i have written a test program ,in which I am doing a read(), </div>
<div>and then I do a stat() to check the changed attribute of the file being read.</div>
<div>But I found the access time [atime]&nbsp; is not getting updated..</div>
<div>&nbsp;</div>
<div>For 2.6 kernel has any patch is released to fix this problem ..?</div>
<div>I need to fix this problem&nbsp;.. Can&nbsp;Anybody help me in this..??</div>
<div>&nbsp;</div>
<div>&nbsp;</div>
<div>&nbsp;</div>
<div>&nbsp;</div>
<div>&nbsp;</div>
<div>~ Nida</div>
<div>&nbsp;</div>
<div>&nbsp;</div>
<div>&nbsp;</div>

------=_Part_104411_30622257.1150545875435--


--===============0908324773==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============0908324773==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0908324773==--
