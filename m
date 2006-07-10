From: Usha Ketineni <uketinen@us.ibm.com>
Subject: nfs-utils-1.0.9 compilation failed!
Date: Mon, 10 Jul 2006 15:10:17 -0700
Message-ID: <OF7F9FF7E6.DBB070D5-ON882571A7.00785158-882571A7.0079CB32@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1934236823=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G03xS-0007KF-Dh
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 15:10:26 -0700
Received: from e31.co.us.ibm.com ([32.97.110.149])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G03xR-0008Ie-FV
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 15:10:26 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com
	[9.17.195.11])
	by e31.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k6AMAJ9b000480
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <nfs@lists.sourceforge.net>; Mon, 10 Jul 2006 18:10:19 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id
	k6AMAJfG302732
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Mon, 10 Jul 2006 16:10:19 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k6AMAIS1019854
	for <nfs@lists.sourceforge.net>; Mon, 10 Jul 2006 16:10:18 -0600
Received: from d03nm116.boulder.ibm.com (d03nm116.boulder.ibm.com
	[9.17.195.142])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k6AMAIDg019848
	for <nfs@lists.sourceforge.net>; Mon, 10 Jul 2006 16:10:18 -0600
To: nfs@lists.sourceforge.net
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

This is a multipart message in MIME format.
--===============1934236823==
Content-Type: multipart/alternative;
	boundary="=_alternative 0079CB2E882571A7_="

This is a multipart message in MIME format.
--=_alternative 0079CB2E882571A7_=
Content-Type: text/plain; charset="US-ASCII"

Hi,

Compilation of nfs-utils-1.0.9 failed with the below error on my machine.
I don't see the function "write_oid()" being defined in the source code.
Anyone hit this error or am I missing something? 

gssd-context_mit.o(.text+0x268): In function `serialize_krb5_ctx':
/home/ketineni/nfs-utils-1.0.9/utils/gssd/context_mit.c:346: undefined 
reference to `write_oid'
collect2: ld returned 1 exit status
make[2]: *** [gssd] Error 1
make[2]: Leaving directory `/home/ketineni/nfs-utils-1.0.9/utils/gssd'
make[1]: *** [all-recursive] Error 1
make[1]: Leaving directory `/home/ketineni/nfs-utils-1.0.9/utils'
make: *** [all-recursive] Error 1


Thanks
Usha
--=_alternative 0079CB2E882571A7_=
Content-Type: text/html; charset="US-ASCII"


<br><font size=2 face="Courier New">Hi,</font>
<br>
<br><font size=2 face="Courier New">Compilation of nfs-utils-1.0.9 failed
with the below error on my machine.</font>
<br><font size=2 face="Courier New">I don't see the function &quot;write_oid()&quot;
being defined in the source code.</font>
<br><font size=2 face="Courier New">Anyone hit this error or am I missing
something? </font>
<br>
<br><font size=2 face="Courier New">gssd-context_mit.o(.text+0x268): In
function `serialize_krb5_ctx':</font>
<br><font size=2 face="Courier New">/home/ketineni/nfs-utils-1.0.9/utils/gssd/context_mit.c:346:
undefined reference to `write_oid'</font>
<br><font size=2 face="Courier New">collect2: ld returned 1 exit status</font>
<br><font size=2 face="Courier New">make[2]: *** [gssd] Error 1</font>
<br><font size=2 face="Courier New">make[2]: Leaving directory `/home/ketineni/nfs-utils-1.0.9/utils/gssd'</font>
<br><font size=2 face="Courier New">make[1]: *** [all-recursive] Error
1</font>
<br><font size=2 face="Courier New">make[1]: Leaving directory `/home/ketineni/nfs-utils-1.0.9/utils'</font>
<br><font size=2 face="Courier New">make: *** [all-recursive] Error 1</font>
<br>
<br>
<br><font size=2 face="sans-serif">Thanks</font>
<br><font size=2 face="sans-serif">Usha</font>
--=_alternative 0079CB2E882571A7_=--


--===============1934236823==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642

--===============1934236823==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1934236823==--
