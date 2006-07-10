From: Usha Ketineni <uketinen@us.ibm.com>
Subject: Re: nfs-utils-1.0.9 compilation failed!
Date: Mon, 10 Jul 2006 15:27:38 -0700
Message-ID: <OF1D753314.D06EB0BF-ON882571A7.007A2454-882571A7.007B6268@us.ibm.com>
References: <OF7F9FF7E6.DBB070D5-ON882571A7.00785158-882571A7.0079CB32@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0454256504=="
Cc: nfs-bounces@lists.sourceforge.net, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <OF7F9FF7E6.DBB070D5-ON882571A7.00785158-882571A7.0079CB32@us.ibm.com>
To: Usha Ketineni <uketinen@us.ibm.com>
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
--===============0454256504==
Content-Type: multipart/alternative;
	boundary="=_alternative 007B6266882571A7_="

This is a multipart message in MIME format.
--=_alternative 007B6266882571A7_=
Content-Type: text/plain; charset="US-ASCII"

nfs-bounces@lists.sourceforge.net wrote on 07/10/2006 03:10:17 PM:

> 
> Hi, 
> 
> Compilation of nfs-utils-1.0.9 failed with the below error on my 
machine. 
> I don't see the function "write_oid()" being defined in the source code. 

> Anyone hit this error or am I missing something? 
> 

write_oid() has been defined in nfs-utils-1.0.8 version and used in couple
of function calls in utils/gssd/context_mit.c. I believe some changes 
might have 
happened in the release 1.0.9. 



--=_alternative 007B6266882571A7_=
Content-Type: text/html; charset="US-ASCII"


<br>
<br><tt><font size=2>nfs-bounces@lists.sourceforge.net wrote on 07/10/2006
03:10:17 PM:<br>
<br>
&gt; <br>
&gt; Hi, <br>
&gt; <br>
&gt; Compilation of nfs-utils-1.0.9 failed with the below error on my machine.
<br>
&gt; I don't see the function &quot;write_oid()&quot; being defined in
the source code. <br>
&gt; Anyone hit this error or am I missing something? <br>
&gt; </font></tt>
<br>
<br><tt><font size=2>write_oid() has been defined in nfs-utils-1.0.8 version
and used in couple</font></tt>
<br><tt><font size=2>of function calls in utils/gssd/context_mit.c. I believe
some changes might have </font></tt>
<br><tt><font size=2>happened in the release 1.0.9. </font></tt>
<br>
<br><tt><font size=2><br>
</font></tt>
--=_alternative 007B6266882571A7_=--


--===============0454256504==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642

--===============0454256504==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0454256504==--
