From: Filipe Brandenburger <branden@terra.com.br>
Subject: Re: Reading 64k blocks at a time
Date: Thu, 29 Jun 2006 10:48:36 -0300
Message-ID: <20060629104451.1D6A.BRANDEN@terra.com.br>
References: <20060628143949.1D55.BRANDEN@terra.com.br>
	<1151522618.29569.38.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: f.soto@terra.com.br
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fvwsp-0004P4-Qd
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 06:48:39 -0700
Received: from buniche.hst.terra.com.br ([200.176.10.197])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fvwsn-0008P8-P2
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 06:48:40 -0700
Received: from ladigue.hst.terra.com.br (ladigue.hst.terra.com.br
	[200.176.10.10])
	by buniche.hst.terra.com.br (Postfix) with ESMTP id 1C0EF3DD8EC9
	for <nfs@lists.sourceforge.net>; Thu, 29 Jun 2006 10:48:36 -0300 (BRT)
To: nfs@lists.sourceforge.net
In-Reply-To: <1151522618.29569.38.camel@lade.trondhjem.org>
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


Hello,

* Wed, 28 Jun 2006 15:23:37 -0400, Trond Myklebust <trond.myklebust@fys.uio.no>:
> > The problem is that when I try to fetch the first 1kb of several big
> > files, it gets really slow... I wonder, is there some way to change this
> > behaviour or tune it on the O.S. so that I don't have to read that much
> > to get that little information?
> 
> 'man posix_fadvise()'
> 
> Cheers,
>   Trond

Thanks a lot for your answer, this really seems to be what I'm looking
for.

However, I tried a lot of settings (setting POSIX_FADV_RANDOM on all
file, setting POSIX_FADV_NOREUSE, setting POSIX_FADV_DONTNEED, setting
it starting on a 8k boundary, etc.), but nothing seemed to change the
behaviour...

I tried to google for more information on how to use this posix_fadvise,
I found some things about increasing the performance of Postgresql on
local filesystems (ext3, etc.), but not much further...

Could you please help me a little more and give me some more small hint on it?

Thank you very much,
Filipe Brandenburger


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
