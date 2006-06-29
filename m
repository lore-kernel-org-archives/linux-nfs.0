From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Reading 64k blocks at a time
Date: Thu, 29 Jun 2006 10:18:36 -0400
Message-ID: <1151590716.17300.17.camel@lade.trondhjem.org>
References: <20060628143949.1D55.BRANDEN@terra.com.br>
	<1151522618.29569.38.camel@lade.trondhjem.org>
	<20060629104451.1D6A.BRANDEN@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, f.soto@terra.com.br
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FvxM9-00071j-73
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 07:18:57 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FvxM5-0006Cm-RW
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 07:18:54 -0700
To: Filipe Brandenburger <branden@terra.com.br>
In-Reply-To: <20060629104451.1D6A.BRANDEN@terra.com.br>
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

On Thu, 2006-06-29 at 10:48 -0300, Filipe Brandenburger wrote:
> However, I tried a lot of settings (setting POSIX_FADV_RANDOM on all
> file, setting POSIX_FADV_NOREUSE, setting POSIX_FADV_DONTNEED, setting
> it starting on a 8k boundary, etc.), but nothing seemed to change the
> behaviour...
> 
> I tried to google for more information on how to use this posix_fadvise,
> I found some things about increasing the performance of Postgresql on
> local filesystems (ext3, etc.), but not much further...
> 
> Could you please help me a little more and give me some more small hint on it?

You have to call posix_fadvise() after you've opened the file (its
behaviour is local to the file descriptor that you use). Turning off
readahead can be done using the POSIX_FADV_RANDOM hint.

Something like

fd = open('foo', O_RDONLY);
posix_fadvise(fd, 0, 8192, POSIX_FADV_RANDOM); // turn off readahead
read(fd, buffer, 8192);
close(fd);
....

Cheers,
  Trond


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
