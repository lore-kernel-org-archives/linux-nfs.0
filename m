From: "Nida M" <nidajm@gmail.com>
Subject: Re: On NFS mounted file system access time not updated
Date: Thu, 29 Jun 2006 18:53:10 +0530
Message-ID: <b01966ec0606290623u186c16abw62bd5b81df2570a0@mail.gmail.com>
References: <b01966ec0606170504p1575f325y560aa3b764dc47a2@mail.gmail.com>
	<1150660000.6771.189.camel@lade.trondhjem.org>
	<b01966ec0606190050r48757400x98945f58f1032283@mail.gmail.com>
	<1150807633.14850.1.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neil@brown.name, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FvwUC-0002HG-Iu
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 06:23:12 -0700
Received: from wr-out-0506.google.com ([64.233.184.233])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FvwUB-0005Lk-Lv
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 06:23:12 -0700
Received: by wr-out-0506.google.com with SMTP id i3so171015wra
	for <nfs@lists.sourceforge.net>; Thu, 29 Jun 2006 06:23:10 -0700 (PDT)
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
In-Reply-To: <1150807633.14850.1.camel@lade.trondhjem.org>
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

> You would have to either use O_DIRECT reads (i.e. uncached reads) or you
> would have to call utimes() after every read. Either way that will
> seriously slow down your application.
>

The read page cache timeout "attrtimeo" value is 60. Where it will refresh
the local cache after every 60 second.

How to reduce the timeout value in the kernel source?

I need to reduce the timeout upto the point where it will update the atime
frequently and it will not degrade the performance also.


~Nida

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
