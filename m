From: Stefan Palme <kleiner@hora-obscura.de>
Subject: Re: disabling caching
Date: Fri, 14 Jul 2006 11:44:09 +0200
Message-ID: <1152870249.28636.34.camel@devel.office.ancoso-development.de>
References: <1152864752.28625.30.camel@devel.office.ancoso-development.de>
	<20060714092612.GA11555@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G1KDb-00082I-Dw
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 02:44:19 -0700
Received: from moutng.kundenserver.de ([212.227.126.187])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G1KDa-0006PT-AR
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 02:44:19 -0700
Received: from localhost (localhost [127.0.0.1])
	by smtp.hora-obscura.de (Postfix) with ESMTP id 667BD878038
	for <nfs@lists.sourceforge.net>; Fri, 14 Jul 2006 11:44:13 +0200 (CEST)
Received: from devel.office.ancoso-development.de
	(p54B98F43.dip0.t-ipconnect.de [84.185.143.67])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by smtp.hora-obscura.de (Postfix) with ESMTP id 96C76878022
	for <nfs@lists.sourceforge.net>; Fri, 14 Jul 2006 11:44:10 +0200 (CEST)
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
In-Reply-To: <20060714092612.GA11555@janus>
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


Thanks. Variant (1) is not possible for me, because I can't modify
the application in question. Variant (2) may be exactly what I have 
searched for (but did not read "man nfs" down to the end :-)

regards
-stefan-

> On Fri, Jul 14, 2006 at 10:12:32AM +0200, Stefan Palme wrote:
> > 
> > After a few seconds, the open() call on the second box succeeds.
> > So I guess that caching is the reason for the second open()-call
> > to fail.
> 
> You might want to try (1) and/or ((2) or (3)) on the NFS client:
> 
> (1)	On the NFS client, put this before the open():
> 
> 		close(open("whatever", O_WRONLY|O_CREAT, 0666));
> 		unlink("whatever");
> 
> (2)	Try the "noac" nfs mount option, it'll cost performance though.
> 
> (3)	Another solution might be to use the patch at www.frankvm.com/nfs-noac
> 	to selectively disable attribute caching (see the README). It's a trick
> 	I use for some distributed work.
> 
> 
-- 
-------------------------------------------------------------------
Dipl. Inf. (FH) Stefan Palme
 
email: kleiner@hora-obscura.de
www:   http://hbci4java.kapott.org
icq:   36376278
phon:  +49 341 3910484
fax:   +49 1212 517956219
mobil: +49 178 3227887
 
key fingerprint: 1BA7 D217 36A1 534C A5AD  F18A E2D1 488A E904 F9EC
-------------------------------------------------------------------



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
