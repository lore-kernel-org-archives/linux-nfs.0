From: Phy Prabab <phyprabab@yahoo.com>
Subject: Issues with 2.6.21-rc4/5 and slowlaris 8
Date: Tue, 27 Mar 2007 12:32:16 -0700 (PDT)
Message-ID: <124175.27074.qm@web90504.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1713025871=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWHP3-0001Jp-5S
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 12:32:21 -0700
Received: from web90504.mail.mud.yahoo.com ([216.252.100.171])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HWHP4-0001EW-0H
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 12:32:23 -0700
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

--===============1713025871==
Content-Type: multipart/alternative; boundary="0-839072182-1175023936=:27074"

--0-839072182-1175023936=:27074
Content-Type: text/plain; charset=ascii

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




 
____________________________________________________________________________________
Now that's room service!  Choose from over 150,000 hotels
in 45,000 destinations on Yahoo! Travel to find your fit.
http://farechase.yahoo.com/promo-generic-14795097
--0-839072182-1175023936=:27074
Content-Type: text/html; charset=ascii

<html><head><style type="text/css"><!-- DIV {margin:0px;} --></style></head><body><div style="font-family:times new roman, new york, times, serif;font-size:12pt"><div>Hello,<br><br>I am having some issues with slowlaris 8 sparc and linux
2.6.21-rc4/5 (actually, 2.6.20.x as well) with directory
permissions.&nbsp;&nbsp;The client is the slowlaris box mounting a file system
(XFS, LVM, DM, 3Ware 9650) from the linux box.&nbsp;&nbsp;I extract some files
from a tar ball and then try to delete them, I get permission denied,
however, the files are owned by my uid and the file permissions are
775.&nbsp;&nbsp;Any help figuring this out would be most welcome.&nbsp;&nbsp;I can provide
plenty of debugging if needed.<br><br>TIA!<br>Phy<br></div></div><br>

<hr size=1>
Don't get soaked.  Take a<a href="
http://tools.search.yahoo.com/shortcuts/?fr=oni_on_mail&#news"> quick peek at the forecast </a><br> with the<a href="
http://tools.search.yahoo.com/shortcuts/?fr=oni_on_mail&#news">Yahoo! Search weather shortcut.</a></body></html>
--0-839072182-1175023936=:27074--


--===============1713025871==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1713025871==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1713025871==--
