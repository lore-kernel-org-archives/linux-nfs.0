From: Usha Ketineni <uketinen@us.ibm.com>
Subject: Re: nfs-utils-1.0.9 compilation failed!
Date: Tue, 11 Jul 2006 13:40:12 -0700
Message-ID: <OF403E603F.D7203F48-ON882571A8.007019CB-882571A8.00718C37@us.ibm.com>
References: <20060711000648.GE11009@debianrules.debiancolombia.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0088139093=="
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G0P1p-00050w-PE
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 13:40:21 -0700
Received: from e33.co.us.ibm.com ([32.97.110.151])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G0P1o-0002Y0-SJ
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 13:40:22 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com
	[9.17.195.106])
	by e33.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k6BKeEmG018506
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <nfs@lists.sourceforge.net>; Tue, 11 Jul 2006 16:40:14 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id
	k6BKeEbL139434
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Tue, 11 Jul 2006 14:40:14 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k6BKeECt012509
	for <nfs@lists.sourceforge.net>; Tue, 11 Jul 2006 14:40:14 -0600
Received: from d03nm116.boulder.ibm.com (d03nm116.boulder.ibm.com
	[9.17.195.142])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k6BKeE88012506
	for <nfs@lists.sourceforge.net>; Tue, 11 Jul 2006 14:40:14 -0600
In-Reply-To: <20060711000648.GE11009@debianrules.debiancolombia.org>
To: =?ISO-8859-1?Q?An=EDbal_Monsalve_Salazar?= <anibal@debian.org>
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
--===============0088139093==
Content-Type: multipart/alternative;
	boundary="=_alternative 00718C34882571A8_="

This is a multipart message in MIME format.
--=_alternative 00718C34882571A8_=
Content-Type: text/plain; charset="US-ASCII"

> >>write_oid() should be defined in utils/gssd/write_bytes.h as an 
> >>inline function.
> >
> >hmm...I don't see it defined in write_bytes.h in the nfs-utils-1.0.9 
> >source and hence the compilation error.
> >Just added it as inline function myself from the previous release and 
it 
> >compiled just fine. 
> >I guess the nfs-utils-1.0.9 package is broken then.
> 
> It has been compiled successfully twice on 12 different arches. See:
> 
> http://buildd.debian.org/build.php?pkg=nfs-utils
> 

I think nfs-util-1.0.9 compilation succeeds properly only in the case 
either HAVE_KRB5 or HAVE_LUCID_CONTEXT_SUPPORT is not defined.


Thanks
Usha
--=_alternative 00718C34882571A8_=
Content-Type: text/html; charset="US-ASCII"


<br><tt><font size=2><br>
&gt; &gt;&gt;write_oid() should be defined in utils/gssd/write_bytes.h
as an <br>
&gt; &gt;&gt;inline function.<br>
&gt; &gt;<br>
&gt; &gt;hmm...I don't see it defined in write_bytes.h in the nfs-utils-1.0.9
<br>
&gt; &gt;source and hence the compilation error.<br>
&gt; &gt;Just added it as inline function myself from the previous release
and it <br>
&gt; &gt;compiled just fine. <br>
&gt; &gt;I guess the nfs-utils-1.0.9 package is broken then.<br>
&gt; <br>
&gt; It has been compiled successfully twice on 12 different arches. See:<br>
&gt; <br>
&gt; http://buildd.debian.org/build.php?pkg=nfs-utils<br>
&gt; <br>
</font></tt>
<br><tt><font size=2>I think nfs-util-1.0.9 compilation succeeds properly
only in the case either HAVE_KRB5 or HAVE_LUCID_CONTEXT_SUPPORT is not
defined.</font></tt>
<br>
<br>
<br><tt><font size=2>Thanks</font></tt>
<br><tt><font size=2>Usha</font></tt>
--=_alternative 00718C34882571A8_=--


--===============0088139093==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642

--===============0088139093==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0088139093==--
