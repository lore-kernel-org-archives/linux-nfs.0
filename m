From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] statfs fails with EOVERFLOW
Date: Tue, 23 Mar 2004 13:36:07 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040323133607.A473@infradead.org>
References: <20040323130513.GB30984@suse.de> <20040323132127.A322@infradead.org> <20040323133019.GD30984@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5m4g-0005V1-7H
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 05:36:10 -0800
Received: from phoenix.infradead.org ([213.86.99.234])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B5m4f-0008Ch-FE
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 05:36:09 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040323133019.GD30984@suse.de>; from okir@suse.de on Tue, Mar 23, 2004 at 02:30:19PM +0100
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tue, Mar 23, 2004 at 02:30:19PM +0100, Olaf Kirch wrote:
> > that's why we have statfs64 in 2.6, a program with the right LFS magic
> > and a recentish glibc should use if for you.
> 
> The glibc maintainers at suse tell me it's broken at the moment.
> 
> Second, not all apps can easily be converted to LFS support. One of the
> apps that barfed was OpenOffice... be my guest and make it LFS clean :)

OpenOffice is hopeless, it's one of this "if it's finally unmaintainable,
opensource it" things :)

> And finally, I think it's really an NFS bug. A local statfs on the file
> system on the server works fine; it's just that the NFS client barfs
> because it uses wtmult as the block size (and if it's a v2 mount, things
> are even worse because it picks a totally arbitrary wtmult value of 512).

Hmm.  Why do you limit the sb_blocksize changes to 32bit architectures then?
I see it doesn't trip easily for 64bit arches, but having different values
for exactly the same filesystem and mount options sounds like a rather bad
idea to me.



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
