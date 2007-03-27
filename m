From: Phy Prabab <phyprabab@yahoo.com>
Subject: Re: Issues with 2.6.21-rc4/5 and slowlaris 8
Date: Tue, 27 Mar 2007 12:47:28 -0700 (PDT)
Message-ID: <626588.55969.qm@web90501.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2109373445=="
To: Phy Prabab <phyprabab@yahoo.com>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWHdl-0002zK-Dt
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 12:47:34 -0700
Received: from web90501.mail.mud.yahoo.com ([216.252.100.168])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HWHdm-0005kT-Cc
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 12:47:35 -0700
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

--===============2109373445==
Content-Type: multipart/alternative; boundary="0-930421789-1175024848=:55969"

--0-930421789-1175024848=:55969
Content-Type: text/plain; charset=ascii

Hello again,

Following up on my message, I also tried this with a slowlaris 10 box and ran into the same permission issues.  However, I do not see this on any linux client.  I also do not see this behavior with AIX 5.303/04.

Any help is greatly appreciated in tracking down this issue.
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
We won't tell. Get more on shows you hate to love 
(and love to hate): Yahoo! TV's Guilty Pleasures list.
http://tv.yahoo.com/collections/265 
--0-930421789-1175024848=:55969
Content-Type: text/html; charset=ascii

<html><head><style type="text/css"><!-- DIV {margin:0px;} --></style></head><body><div style="font-family:times new roman, new york, times, serif;font-size:12pt"><div style="font-family: times new roman,new york,times,serif; font-size: 12pt;">Hello again,<br><br>Following up on my message, I also tried this with a slowlaris 10 box and ran into the same permission issues.&nbsp; However, I do not see this on any linux client.&nbsp; I also do not see this behavior with AIX 5.303/04.<br><br>Any help is greatly appreciated in tracking down this issue.<br>TIA!<br>Phy<br><br><div style="font-family: times new roman,new york,times,serif; font-size: 12pt;">----- Original Message ----<br>From: Phy Prabab &lt;phyprabab@yahoo.com&gt;<br>To: nfs@lists.sourceforge.net<br>Sent: Tuesday, March 27, 2007 12:32:16 PM<br>Subject: Issues with 2.6.21-rc4/5 and slowlaris 8<br><br><div style="font-family: times
  new roman,new york,times,serif; font-size: 12pt;"><div>Hello,<br><br>I am having some
 issues with slowlaris 8 sparc and linux
2.6.21-rc4/5 (actually, 2.6.20.x as well) with directory
permissions.&nbsp;&nbsp;The client is the slowlaris box mounting a file system
(XFS, LVM, DM, 3Ware 9650) from the linux box.&nbsp;&nbsp;I extract some files
from a tar ball and then try to delete them, I get permission denied,
however, the files are owned by my uid and the file permissions are
775.&nbsp;&nbsp;Any help figuring this out would be most welcome.&nbsp;&nbsp;I can provide
plenty of debugging if needed.<br><br>TIA!<br>Phy<br></div></div><br>

<hr size="1">
Don't get soaked.  Take a<a rel="nofollow" target="_blank" href="http://tools.search.yahoo.com/shortcuts/?fr=oni_on_mail&amp;#news"> quick peek at the forecast </a><br> with the<a rel="nofollow" target="_blank" href="http://tools.search.yahoo.com/shortcuts/?fr=oni_on_mail&amp;#news">Yahoo! Search weather shortcut.</a></div><br></div></div><br>

<hr size=1>Don't pick lemons.<br>
See all the <a href="http://autos.yahoo.com/new_cars.html;_ylc=X3oDMTE0OGRsc3F2BF9TAzk3MTA3MDc2BHNlYwNtYWlsdGFncwRzbGsDbmV3Y2Fycw--">new 2007 cars</a> at <a href="http://autos.yahoo.com/new_cars.html;_ylc=X3oDMTE0OGRsc3F2BF9TAzk3MTA3MDc2BHNlYwNtYWlsdGFncwRzbGsDbmV3Y2Fycw--">Yahoo! Autos.</a></body></html>
--0-930421789-1175024848=:55969--


--===============2109373445==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============2109373445==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============2109373445==--
