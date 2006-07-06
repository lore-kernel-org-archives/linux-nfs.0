From: Chris Abbey <cablnx@us.ibm.com>
Subject: Re: [PATCH] CONFIG_NFSD_TCP actually impacts clients
Date: Thu, 6 Jul 2006 16:56:15 -0500
Message-ID: <200607061656.15913.cablnx@us.ibm.com>
References: <200606291522.46235.cablnx@us.ibm.com>
	<76bd70e30606300538h6351dbffrdefe694dc99d12c7@mail.gmail.com>
	<17574.3711.649582.365653@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FybqS-000495-D2
	for nfs@lists.sourceforge.net; Thu, 06 Jul 2006 14:57:12 -0700
Received: from e1.ny.us.ibm.com ([32.97.182.141])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FybqS-0004KV-Bx
	for nfs@lists.sourceforge.net; Thu, 06 Jul 2006 14:57:12 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k66LuHUX004126
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <nfs@lists.sourceforge.net>; Thu, 6 Jul 2006 17:56:17 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id
	k66LuHbc291994
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <nfs@lists.sourceforge.net>; Thu, 6 Jul 2006 17:56:17 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k66LuHnn009938
	for <nfs@lists.sourceforge.net>; Thu, 6 Jul 2006 17:56:17 -0400
Received: from bezerkwookie.rchland.ibm.com (bezerkwookie.rchland.ibm.com
	[9.10.86.237])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k66LuHEM009918
	for <nfs@lists.sourceforge.net>; Thu, 6 Jul 2006 17:56:17 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <17574.3711.649582.365653@cse.unsw.edu.au>
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

On Thursday 29 June 2006 06:11 pm, Trond Myklebust wrote:
> Good point, but it seems to me that it would make sense to have
> CONFIG_NFS_FS automatically select it.

On Saturday 01 July 2006 12:56 am, Neil Brown wrote:
> Another option would be to throw the option away altogether and
> default to always listen on TCP.

These two  thoughts both seem to follow along the same line of thinking I 
originally started with: don't make tcp conditional. I'd be more than happy 
to see TCP no longer be optional, that's actually what I had implemented at 
first, but I figured it was still an option because someone somewhere in some 
oddball configuration still needed to disable it. Given that the kernel IP 
stack doesn't let you build IP without TCP, it doesn't seem like it's 
possible to break anyone by removing this as an option... it's just the 
slight overhead of having it enabled. (assuming they don't use it.)

Neil, is this something your upcoming protocol selection patch would include, 
or should I put forward a seperate (trivial) removal patch?

-- 
The value of Open Standards is only evident to Open Minds.

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
