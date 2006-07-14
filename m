From: Stefan Palme <kleiner@hora-obscura.de>
Subject: Re: disabling caching
Date: Fri, 14 Jul 2006 14:19:22 +0200
Message-ID: <1152879562.28633.42.camel@devel.office.ancoso-development.de>
References: <1152864752.28625.30.camel@devel.office.ancoso-development.de>
	<20060714092612.GA11555@janus>
	<1152870249.28636.34.camel@devel.office.ancoso-development.de>
	<1152879442.28635.40.camel@devel.office.ancoso-development.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G1Mdj-0003qI-PD
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 05:19:27 -0700
Received: from moutng.kundenserver.de ([212.227.126.188])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G1Mdj-00072q-KZ
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 05:19:28 -0700
Received: from localhost (localhost [127.0.0.1])
	by smtp.hora-obscura.de (Postfix) with ESMTP id 37BE0878038
	for <nfs@lists.sourceforge.net>; Fri, 14 Jul 2006 14:19:26 +0200 (CEST)
Received: from devel.office.ancoso-development.de
	(p54B98F43.dip0.t-ipconnect.de [84.185.143.67])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by smtp.hora-obscura.de (Postfix) with ESMTP id 75BC4878022
	for <nfs@lists.sourceforge.net>; Fri, 14 Jul 2006 14:19:23 +0200 (CEST)
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
In-Reply-To: <1152879442.28635.40.camel@devel.office.ancoso-development.de>
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

> Hmpf. Using variant (2) did not fix the problem. Is it enough to
> 
>   remount -o remount /my/imported/dir,
> 
> or do I have to completely unmount and remount the directory? 

... after adding the noac-option to /etc/fstab




-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
