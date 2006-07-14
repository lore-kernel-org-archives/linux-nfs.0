From: Stefan Palme <kleiner@hora-obscura.de>
Subject: Re: disabling caching
Date: Fri, 14 Jul 2006 14:17:22 +0200
Message-ID: <1152879442.28635.40.camel@devel.office.ancoso-development.de>
References: <1152864752.28625.30.camel@devel.office.ancoso-development.de>
	<20060714092612.GA11555@janus>
	<1152870249.28636.34.camel@devel.office.ancoso-development.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G1Mbw-0003ff-PR
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 05:17:36 -0700
Received: from moutng.kundenserver.de ([212.227.126.183])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G1Mbr-0006YG-Jd
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 05:17:34 -0700
Received: from localhost (localhost [127.0.0.1])
	by smtp.hora-obscura.de (Postfix) with ESMTP id 3A9F5878038
	for <nfs@lists.sourceforge.net>; Fri, 14 Jul 2006 14:17:28 +0200 (CEST)
Received: from devel.office.ancoso-development.de
	(p54B98F43.dip0.t-ipconnect.de [84.185.143.67])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by smtp.hora-obscura.de (Postfix) with ESMTP id 8B462878022
	for <nfs@lists.sourceforge.net>; Fri, 14 Jul 2006 14:17:23 +0200 (CEST)
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
In-Reply-To: <1152870249.28636.34.camel@devel.office.ancoso-development.de>
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


Hmpf. Using variant (2) did not fix the problem. Is it enough to

  remount -o remount /my/imported/dir,

or do I have to completely unmount and remount the directory? I ask
before doing this, because doing this would require to completely
shutdown our server process first, because this process has open 
files in the mounted dir...

I have taken a look at patch (3), but I guess, this would not make
much difference to solution (2), because this patch does the same
as the noac-option, but more "locally" (in time and place) - am I right?

Are there any other hints?

Best regards
-stefan-


> Thanks. Variant (1) is not possible for me, because I can't modify
> the application in question. Variant (2) may be exactly what I have 
> searched for (but did not read "man nfs" down to the end :-)
> 
> regards
> -stefan-
> 
> > On Fri, Jul 14, 2006 at 10:12:32AM +0200, Stefan Palme wrote:
> > > 
> > > After a few seconds, the open() call on the second box succeeds.
> > > So I guess that caching is the reason for the second open()-call
> > > to fail.
> > 
> > You might want to try (1) and/or ((2) or (3)) on the NFS client:
> > 
> > (1)	On the NFS client, put this before the open():
> > 
> > 		close(open("whatever", O_WRONLY|O_CREAT, 0666));
> > 		unlink("whatever");
> > 
> > (2)	Try the "noac" nfs mount option, it'll cost performance though.
> > 
> > (3)	Another solution might be to use the patch at www.frankvm.com/nfs-noac
> > 	to selectively disable attribute caching (see the README). It's a trick
> > 	I use for some distributed work.
> > 
> > 
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
