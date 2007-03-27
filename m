From: Phy Prabab <phyprabab@yahoo.com>
Subject: Re: Issues with 2.6.21-rc4/5 and slowlaris 8
Date: Tue, 27 Mar 2007 12:58:18 -0700 (PDT)
Message-ID: <560308.2157.qm@web90509.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1730530547=="
To: Phy Prabab <phyprabab@yahoo.com>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWHoF-0004En-Id
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 12:58:24 -0700
Received: from web90509.mail.mud.yahoo.com ([216.252.100.176])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HWHoG-0000ZR-JQ
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 12:58:26 -0700
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

--===============1730530547==
Content-Type: multipart/alternative; boundary="0-2145401129-1175025498=:2157"

--0-2145401129-1175025498=:2157
Content-Type: text/plain; charset=ascii

Another follow up, the permission issue is only experienced on Solaris 8, 10 on sparc.  On Solaris on Intel (x86_64) the permission issue does not exit.

TIA!
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
--0-2145401129-1175025498=:2157
Content-Type: text/html; charset=ascii

<html><head><style type="text/css"><!-- DIV {margin:0px;} --></style></head><body><div style="font-family:times new roman, new york, times, serif;font-size:12pt"><div style="font-family: times new roman,new york,times,serif; font-size: 12pt;">Another follow up, the permission issue is only experienced on Solaris 8, 10 on sparc.&nbsp; On Solaris on Intel (x86_64) the permission issue does not exit.<br><br>TIA!<br>Phy<br><br><div style="font-family: times new roman,new york,times,serif; font-size: 12pt;">----- Original Message ----<br>From: Phy Prabab &lt;phyprabab@yahoo.com&gt;<br>To: nfs@lists.sourceforge.net<br>Sent: Tuesday, March 27, 2007 12:32:16 PM<br>Subject: Issues with 2.6.21-rc4/5 and slowlaris 8<br><br><div style="font-family: times new roman,new york,times,serif; font-size: 12pt;"><div>Hello,<br><br>I am having some issues with slowlaris 8 sparc and linux
2.6.21-rc4/5 (actually, 2.6.20.x as well) with directory
permissions.&nbsp;&nbsp;The client is the slowlaris box mounting a file system
(XFS, LVM, DM, 3Ware 9650) from the linux box.&nbsp;&nbsp;I extract some files
from a tar ball and then try to delete them, I get permission denied,
however, the files are owned by my uid and the file permissions are
775.&nbsp;&nbsp;Any help figuring this out would be most welcome.&nbsp;&nbsp;I can provide
plenty of debugging if needed.<br><br>TIA!<br>Phy<br></div></div><br>

<hr size="1">
Don't get soaked.  Take a<a rel="nofollow" target="_blank" href="http://tools.search.yahoo.com/shortcuts/?fr=oni_on_mail&amp;#news"> quick peek at the forecast </a><br> with the<a rel="nofollow" target="_blank" href="http://tools.search.yahoo.com/shortcuts/?fr=oni_on_mail&amp;#news">Yahoo! Search weather shortcut.</a></div><br></div></div><br>

<hr size=1>Need Mail bonding?<br>Go to the <a href="http://answers.yahoo.com/dir/index;_ylc=X3oDMTFvbGNhMGE3BF9TAzM5NjU0NTEwOARfcwMzOTY1NDUxMDMEc2VjA21haWxfdGFnbGluZQRzbGsDbWFpbF90YWcx?link=ask&sid=396546091">Yahoo! Mail Q&A</a> for <a href="http://answers.yahoo.com/dir/index;_ylc=X3oDMTFvbGNhMGE3BF9TAzM5NjU0NTEwOARfcwMzOTY1NDUxMDMEc2VjA21haWxfdGFnbGluZQRzbGsDbWFpbF90YWcx?link=ask&sid=396546091">great tips from Yahoo! Answers</a> users.</body></html>
--0-2145401129-1175025498=:2157--


--===============1730530547==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1730530547==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1730530547==--
