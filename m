From: Usha Ketineni <uketinen@us.ibm.com>
Subject: Re: nfs-utils-1.0.9 compilation failed!
Date: Mon, 10 Jul 2006 16:57:30 -0700
Message-ID: <OF985C22F0.D508648E-ON882571A7.00808418-882571A7.00839C72@us.ibm.com>
References: <4d569c330607101604u62a240edo6116c589ac4dc780@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1044166635=="
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G05dD-00080X-Sy
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 16:57:42 -0700
Received: from e33.co.us.ibm.com ([32.97.110.151])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G05dD-00067G-0n
	for nfs@lists.sourceforge.net; Mon, 10 Jul 2006 16:57:40 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com
	[9.17.195.11])
	by e33.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k6ANvX21004983
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <nfs@lists.sourceforge.net>; Mon, 10 Jul 2006 19:57:33 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id
	k6ANvWLm310602
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Mon, 10 Jul 2006 17:57:32 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k6ANvWiI019249
	for <nfs@lists.sourceforge.net>; Mon, 10 Jul 2006 17:57:32 -0600
Received: from d03nm116.boulder.ibm.com (d03nm116.boulder.ibm.com
	[9.17.195.142])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k6ANvWU1019246
	for <nfs@lists.sourceforge.net>; Mon, 10 Jul 2006 17:57:32 -0600
In-Reply-To: <4d569c330607101604u62a240edo6116c589ac4dc780@mail.gmail.com>
To: "Kevin Coffman" <kwc@citi.umich.edu>
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
--===============1044166635==
Content-Type: multipart/alternative;
	boundary="=_alternative 00839C6F882571A7_="

This is a multipart message in MIME format.
--=_alternative 00839C6F882571A7_=
Content-Type: text/plain; charset="US-ASCII"

nfs-bounces@lists.sourceforge.net wrote on 07/10/2006 04:04:46 PM:

> write_oid() should be defined in utils/gssd/write_bytes.h as an 
> inline function.
> 

hmm...I don't see it defined in write_bytes.h in the nfs-utils-1.0.9 
source and hence the compilation error.
Just added it as inline function myself from the previous release and it 
compiled just fine. 
I guess the nfs-utils-1.0.9 package is broken then.

Thanks
Usha
--=_alternative 00839C6F882571A7_=
Content-Type: text/html; charset="US-ASCII"


<br>
<br><tt><font size=2>nfs-bounces@lists.sourceforge.net wrote on 07/10/2006
04:04:46 PM:<br>
<br>
&gt; write_oid() should be defined in utils/gssd/write_bytes.h as an <br>
&gt; inline function.<br>
&gt; </font></tt>
<br>
<br><tt><font size=2>hmm...I don't see it defined in write_bytes.h in the
nfs-utils-1.0.9 source and hence the compilation error.</font></tt>
<br><tt><font size=2>Just added it as inline function myself from the previous
release and it compiled just fine. </font></tt>
<br><tt><font size=2>I guess the nfs-utils-1.0.9 package is broken then.</font></tt>
<br>
<br><tt><font size=2>Thanks</font></tt>
<br><tt><font size=2>Usha</font></tt>
--=_alternative 00839C6F882571A7_=--


--===============1044166635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642

--===============1044166635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1044166635==--
