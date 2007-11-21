From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Cache flushing
Date: Wed, 21 Nov 2007 15:39:29 -0500
Message-ID: <1195677569.8374.18.camel@heimdal.trondhjem.org>
References: <1195258291.6039.189.camel@hurina>
	<1195328785.6999.5.camel@localhost.localdomain>
	<600549E3-82CF-44EB-8394-E57A3BB41118@iki.fi>
	<1195332062.6999.20.camel@localhost.localdomain>
	<1195337516.6039.239.camel@hurina> <1195524890.6039.315.camel@hurina>
	<1195602454.7234.100.camel@heimdal.trondhjem.org>
	<1195650851.6039.425.camel@hurina>
	<1195653389.8374.4.camel@heimdal.trondhjem.org>
	<D30D2934-0124-4AD4-B184-DCC3EF62440E@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Timo Sirainen <tss@iki.fi>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IuwLC-00089d-VK
	for nfs@lists.sourceforge.net; Wed, 21 Nov 2007 12:38:35 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IuwLI-0002tC-DQ
	for nfs@lists.sourceforge.net; Wed, 21 Nov 2007 12:38:41 -0800
In-Reply-To: <D30D2934-0124-4AD4-B184-DCC3EF62440E@iki.fi>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


On Wed, 2007-11-21 at 22:36 +0200, Timo Sirainen wrote:
> On 21.11.2007, at 15.56, Trond Myklebust wrote:
> 
> > On Wed, 2007-11-21 at 15:14 +0200, Timo Sirainen wrote:
> >
> >> Now that I think of it, I guess the reason is that my 2.6.22 setup  
> >> has
> >> Linux+ext3 as NFS server and 2.6.17-rc2 setup has NetApp as  
> >> server. So
> >> even though open()+close() flushes the directory's attribute  
> >> cache, it
> >> doesn't flush the file name -> NFS handle cache unless mtime changes?
> >
> > Right. You're hitting the principal limitation of ext3 as an NFS  
> > backend
> > filesystem.
> > As I said in an earlier mail, the resolution on the time is 1  
> > second, so
> > client 2 can basically not see any changes that happen within < 1  
> > second
> > on client 1. The reason is that the mtime stays the same.
> 
> With files it's possible to work around this limitation with fcntl  
> locking, but directories can't be locked. So back to my original  
> question: Would it be possible to have chmod(dir, (uid_t)-1,  
> (gid_t)-1) flush its cache? I don't see what harm there could be in  
> this, since normally no-one would do it anyway and the change is simple.

I thought you said this was for flushing the attribute cache?

Flushing the attribute cache won't help in this case, since the crux of
the problem is that the attributes haven't actually changed at all.

Cheers
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

