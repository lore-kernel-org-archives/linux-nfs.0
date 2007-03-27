From: Phy Prabab <phyprabab@yahoo.com>
Subject: Re: Issues with 2.6.21-rc4/5 and slowlaris 8
Date: Tue, 27 Mar 2007 13:05:24 -0700 (PDT)
Message-ID: <350605.5583.qm@web90512.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0441277832=="
To: Phy Prabab <phyprabab@yahoo.com>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWHv8-0004zj-CW
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 13:05:31 -0700
Received: from web90512.mail.mud.yahoo.com ([216.252.100.179])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HWHv8-0001xr-A6
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 13:05:32 -0700
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

--===============0441277832==
Content-Type: multipart/alternative; boundary="0-1953134253-1175025924=:5583"

--0-1953134253-1175025924=:5583
Content-Type: text/plain; charset=ascii

Hello again,

So it looks like I have to make a small correction, I do indeed see this problem on Solaris 10 on intel.  Interestingly, the first time I untarred the files, everything went smoothly - I was even able to remove the entire package without issue.  However, upon the second untarring, I started to get errors about permissions and directories not being there.  I am inclined to think this is a caching issue.

Any help?
TIA,
Phy

----- Original Message ----
From: Phy Prabab <phyprabab@yahoo.com>
To: nfs@lists.sourceforge.net
Sent: Tuesday, March 27, 2007 12:32:16 PM
Subject: Issues with 2.6.21-rc4/5 and slowlaris 8

Hello,

I am having some issues with slowlaris 8 sparc and linux
2.6.21-rc4/5 (actually, 2.6.20.x as well) with directory
permissions.  The client is the slowlaris box mounting a file system
(XFS, LVM, DM, 3Ware 9650) from the linux box.  I extract some files
from a tar ball and then try to delete them, I get permission denied,
however, the files are owned by my uid and the file permissions are
775.  Any help figuring this out would be most welcome.  I can provide
plenty of debugging if needed.

TIA!
Phy






Don't get soaked.  Take a quick peek at the forecast 
 with theYahoo! Search weather shortcut.





 
____________________________________________________________________________________
Get your own web address.  
Have a HUGE year through Yahoo! Small Business.
http://smallbusiness.yahoo.com/domains/?p=BESTDEAL
--0-1953134253-1175025924=:5583
Content-Type: text/html; charset=ascii

<html><head><style type="text/css"><!-- DIV {margin:0px;} --></style></head><body><div style="font-family:times new roman, new york, times, serif;font-size:12pt"><div style="font-family: times new roman,new york,times,serif; font-size: 12pt;">Hello again,<br><br>So it looks like I have to make a small correction, I do indeed see this problem on Solaris 10 on intel.&nbsp; Interestingly, the first time I untarred the files, everything went smoothly - I was even able to remove the entire package without issue.&nbsp; However, upon the second untarring, I started to get errors about permissions and directories not being there.&nbsp; I am inclined to think this is a caching issue.<br><br>Any help?<br>TIA,<br>Phy<br><br><div style="font-family: times new roman,new york,times,serif; font-size: 12pt;">----- Original Message ----<br>From: Phy Prabab &lt;phyprabab@yahoo.com&gt;<br>To: nfs@lists.sou
 rceforge.net<br>Sent: Tuesday, March 27, 2007 12:32:16 PM<br>Subject: Issues with
 2.6.21-rc4/5 and slowlaris 8<br><br><div style="font-family: times new roman,new york,times,serif; font-size: 12pt;"><div>Hello,<br><br>I am having some issues with slowlaris 8 sparc and linux
2.6.21-rc4/5 (actually, 2.6.20.x as well) with directory
permissions.&nbsp;&nbsp;The client is the slowlaris box mounting a file system
(XFS, LVM, DM, 3Ware 9650) from the linux box.&nbsp;&nbsp;I extract some files
from a tar ball and then try to delete them, I get permission denied,
however, the files are owned by my uid and the file permissions are
775.&nbsp;&nbsp;Any help figuring this out would be most welcome.&nbsp;&nbsp;I can provide
plenty of debugging if needed.<br><br>TIA!<br>Phy<br></div></div><br>

<hr size="1">
Don't get soaked.  Take a<a rel="nofollow" target="_blank" href="http://tools.search.yahoo.com/shortcuts/?fr=oni_on_mail&amp;#news"> quick peek at the forecast </a><br> with the<a rel="nofollow" target="_blank" href="http://tools.search.yahoo.com/shortcuts/?fr=oni_on_mail&amp;#news">Yahoo! Search weather shortcut.</a></div><br></div></div><br>

<hr size=1>No need to miss a message. <a href="http://us.rd.yahoo.com/evt=43910/*http://mobile.yahoo.com/mail
">Get email on-the-go </a><br>with Yahoo! Mail for Mobile. <a href="http://us.rd.yahoo.com/evt=43910/*http://mobile.yahoo.com/mail
">Get started.</a></body></html>
--0-1953134253-1175025924=:5583--


--===============0441277832==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0441277832==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0441277832==--
