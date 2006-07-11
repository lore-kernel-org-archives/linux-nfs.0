From: Usha Ketineni <uketinen@us.ibm.com>
Subject: nfs-utils compilation failing?
Date: Tue, 11 Jul 2006 13:54:07 -0700
Message-ID: <OF11F5EA29.FE9B4626-ON882571A8.0071F565-882571A8.0072D28A@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1163790479=="
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G0PFJ-0006Bt-AR
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 13:54:17 -0700
Received: from e36.co.us.ibm.com ([32.97.110.154])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G0PFH-000783-Di
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 13:54:17 -0700
To: nfs@lists.sf.net
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
--===============1163790479==
Content-Type: multipart/alternative;
	boundary="=_alternative 0072D288882571A8_="

This is a multipart message in MIME format.
--=_alternative 0072D288882571A8_=
Content-Type: text/plain; charset="US-ASCII"

Hi,

I am seeing a problem when tried to install the nfs-utils-1.0.9.

gssd-context_mit.o(.text+0x268): In function `serialize_krb5_ctx': 
/home/ketineni/nfs-utils-1.0.9/utils/gssd/context_mit.c:346: undefined 
reference to `write_oid' 
collect2: ld returned 1 exit status 
make[2]: *** [gssd] Error 1 
make[2]: Leaving directory `/home/ketineni/nfs-utils-1.0.9/utils/gssd' 
make[1]: *** [all-recursive] Error 1 
make[1]: Leaving directory `/home/ketineni/nfs-utils-1.0.9/utils' 
make: *** [all-recursive] Error 1 


As serialize_krb5_ctx() is surrounded by ifdef HAVE_KRB5 & ifdef 
HAVE_LUCID_CONTEXT_SUPPORT, in the case where those
two variables are defined serialize_krb5_ctx() need write_oid which is 
supposed to be defined somewhere. And in nfs-utils-1.0.8 it's 
been defined.

I was able to compile the nfs-utils-1.0.9 package just by adding the 
write_oid() function call in utils/gssd/write_bytes.h.  I am not sure what
these variables are used for in the configure script. 


Thanks
Usha
--=_alternative 0072D288882571A8_=
Content-Type: text/html; charset="US-ASCII"


<br><font size=2 face="sans-serif">Hi,</font>
<br>
<br><font size=2 face="sans-serif">I am seeing a problem when tried to
install the nfs-utils-1.0.9.</font>
<br>
<br><font size=2 face="Courier New">gssd-context_mit.o(.text+0x268): In
function `serialize_krb5_ctx':</font><font size=3> </font><font size=2 face="Courier New"><br>
/home/ketineni/nfs-utils-1.0.9/utils/gssd/context_mit.c:346: undefined
reference to `write_oid'</font><font size=3> </font><font size=2 face="Courier New"><br>
collect2: ld returned 1 exit status</font><font size=3> </font><font size=2 face="Courier New"><br>
make[2]: *** [gssd] Error 1</font><font size=3> </font><font size=2 face="Courier New"><br>
make[2]: Leaving directory `/home/ketineni/nfs-utils-1.0.9/utils/gssd'</font><font size=3>
</font><font size=2 face="Courier New"><br>
make[1]: *** [all-recursive] Error 1</font><font size=3> </font><font size=2 face="Courier New"><br>
make[1]: Leaving directory `/home/ketineni/nfs-utils-1.0.9/utils'</font><font size=3>
</font><font size=2 face="Courier New"><br>
make: *** [all-recursive] Error 1</font><font size=3> </font>
<br>
<br>
<br><font size=2 face="sans-serif">As serialize_krb5_ctx() is surrounded
by ifdef HAVE_KRB5 &amp; ifdef HAVE_LUCID_CONTEXT_SUPPORT, in the case
where those</font>
<br><font size=2 face="sans-serif">two variables are defined serialize_krb5_ctx()
need write_oid which is supposed to be defined somewhere. And in nfs-utils-1.0.8
it's </font>
<br><font size=2 face="sans-serif">been defined.</font>
<br>
<br><font size=2 face="sans-serif">I was able to compile the nfs-utils-1.0.9
package just by adding the write_oid() function call in utils/gssd/write_bytes.h.
&nbsp;I am not sure what</font>
<br><font size=2 face="sans-serif">these variables are used for in the
configure script. </font>
<br>
<br>
<br><font size=2 face="sans-serif">Thanks</font>
<br><font size=2 face="sans-serif">Usha</font>
--=_alternative 0072D288882571A8_=--


--===============1163790479==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642

--===============1163790479==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1163790479==--
