From: Filipe Brandenburger <branden@terra.com.br>
Subject: Re: Reading 64k blocks at a time
Date: Thu, 29 Jun 2006 14:51:27 -0300
Message-ID: <20060629144917.1D73.BRANDEN@terra.com.br>
References: <20060629104451.1D6A.BRANDEN@terra.com.br>
	<1151590716.17300.17.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: f.soto@terra.com.br
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fw0fw-0002Y6-Gn
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 10:51:36 -0700
Received: from burta.hst.terra.com.br ([200.176.10.199])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fw0fu-0004tM-FZ
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 10:51:36 -0700
Received: from caliope.hst.terra.com.br (caliope.hst.terra.com.br
	[200.176.10.8])
	by burta.hst.terra.com.br (Postfix) with ESMTP id 98C374B78203
	for <nfs@lists.sourceforge.net>; Thu, 29 Jun 2006 14:51:28 -0300 (BRT)
To: nfs@lists.sourceforge.net
In-Reply-To: <1151590716.17300.17.camel@lade.trondhjem.org>
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


Hi, there.

* Thu, 29 Jun 2006 10:18:36 -0400, Trond Myklebust <trond.myklebust@fys.uio.no>:
> fd = open('foo', O_RDONLY);
> posix_fadvise(fd, 0, 8192, POSIX_FADV_RANDOM); // turn off readahead
> read(fd, buffer, 8192);
> close(fd);
> ....

Thanks, it really worked. However, I saw that it did two 4k reads
instead of one 8k read. I tweeked it a little more and came up with
this:

     posix_fadvise(fd, 0, 8192, POSIX_FADV_NOREUSE);
     posix_fadvise(fd, 8193, 0, POSIX_FADV_RANDOM);

which had the desired effect of doing only one 8k read with no prefetch
or read-ahead.

Thank you very much for your time.

Regards,
Filipe Brandenburger


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
