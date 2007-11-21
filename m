From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] Cache flushing
Date: Wed, 21 Nov 2007 16:15:37 -0500
Message-ID: <1195679737.8374.34.camel@heimdal.trondhjem.org>
References: <1195258291.6039.189.camel@hurina>
	<1195328785.6999.5.camel@localhost.localdomain>
	<600549E3-82CF-44EB-8394-E57A3BB41118@iki.fi>
	<1195332062.6999.20.camel@localhost.localdomain>
	<1195337516.6039.239.camel@hurina> <1195524890.6039.315.camel@hurina>
	<1195602454.7234.100.camel@heimdal.trondhjem.org>
	<1195650851.6039.425.camel@hurina>
	<1195653389.8374.4.camel@heimdal.trondhjem.org>
	<D30D2934-0124-4AD4-B184-DCC3EF62440E@iki.fi>
	<1195677569.8374.18.camel@heimdal.trondhjem.org>
	<1195678584.6039.436.camel@hurina>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Timo Sirainen <tss@iki.fi>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iuwv8-0003SS-4E
	for nfs@lists.sourceforge.net; Wed, 21 Nov 2007 13:15:42 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IuwvC-0005g8-Em
	for nfs@lists.sourceforge.net; Wed, 21 Nov 2007 13:15:47 -0800
In-Reply-To: <1195678584.6039.436.camel@hurina>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


On Wed, 2007-11-21 at 22:56 +0200, Timo Sirainen wrote:
> On Wed, 2007-11-21 at 15:39 -0500, Trond Myklebust wrote:
> > I thought you said this was for flushing the attribute cache?
> 
> That was it originally, but this one's more important. :) Also I
> originally thought that directory's attribute cache flushing also
> flushed its file handle cache. I'm not actually sure what file handle
> cache should even really be called. It looks like Linux handles it with
> page cache the same way as for files?
> 
> So I guess I'm asking for chown(-1,-1) call to invalidate the file's
> attribute and page cache. Although it's interesting why chown(0,-1)
> flushes a directory's file handle cache (==page cache?), but the same
> call for a file doesn't flush its page cache. Maybe I'm still
> misunderstanding something how all of this works.

No. I'm not at all comfortable with the idea of overloading chown() to
invalidate data caches.

It is one thing to have it revalidate the attribute cache (you might be
able to argue that this is consistent with the mission of chown(),
although I'm not yet convinced of that) but the only effect that chown()
has on data caching is that we force a sync to disk in order to avoid
trouble with cached writes that are no longer accepted by the server. It
has never forced a cache invalidation.

IMO, the right interface for manipulating the page cache is rather
posix_fadvise(). I can certainly see an argument for adding a
"POSIX_FADV_UNCACHE" option in order to force a cache invalidation for
those applications that need stronger cache consistency.

Note, however, that even if such a thing is accepted into the mainstream
kernel, you still have to convince all the distros to backport this
interface to their older kernels. If not, you will still have a problem
with legacy clients...

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

