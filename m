From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Cache flushing
Date: Tue, 20 Nov 2007 18:47:34 -0500
Message-ID: <1195602454.7234.100.camel@heimdal.trondhjem.org>
References: <1195258291.6039.189.camel@hurina>
	<1195328785.6999.5.camel@localhost.localdomain>
	<600549E3-82CF-44EB-8394-E57A3BB41118@iki.fi>
	<1195332062.6999.20.camel@localhost.localdomain>
	<1195337516.6039.239.camel@hurina> <1195524890.6039.315.camel@hurina>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Timo Sirainen <tss@iki.fi>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iucny-0005BI-P1
	for nfs@lists.sourceforge.net; Tue, 20 Nov 2007 15:46:59 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Iuco2-0007ie-88
	for nfs@lists.sourceforge.net; Tue, 20 Nov 2007 15:47:04 -0800
In-Reply-To: <1195524890.6039.315.camel@hurina>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


On Tue, 2007-11-20 at 04:14 +0200, Timo Sirainen wrote:
> On Sun, 2007-11-18 at 00:11 +0200, Timo Sirainen wrote:
> > > Why can't you simply close(), and then re-open() the file? That is _the_
> > > standard way to force an attribute cache revalidation on all NFS
> > > versions. The close-to-open caching model, which is implemented on most
> > > NFS clients guarantees this.
> ..
> > close()+open() would have been difficult to handle because open() can
> > fail, but looks like opening another file descriptor and closing it
> > works just as well. Also looks like it works for flushing directories'
> > attribute cache (which doesn't seem to work with FreeBSD though).
> 
> Actually it works for flushing a directory's attribute cache in
> v2.6.17-rc2, but not in v2.6.22. chown() works in v2.6.22 also. Is there
> a reason for this change? I guess it anyway means that I'm back to using
> chown() for flushing a directory's attribute cache.

close-to-open caching works fine for me in v2.6.22. It does indeed send
a GETATTR and revalidate the inode.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

