From: Neil Brown <neilb@suse.de>
Subject: Re: Broken nfsd in recent kernels
Date: Tue, 13 Feb 2007 14:48:51 +1100
Message-ID: <17873.13603.316692.955211@notabene.brown>
References: <1171326368.8065.36.camel@hoeplx2923>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, nfs@lists.sourceforge.net
To: Norman Weathers <norman.r.weathers@conocophillips.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGofj-0004NX-L2
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 19:49:39 -0800
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HGofl-00088R-BE
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 19:49:41 -0800
In-Reply-To: message from Norman Weathers on Monday February 12
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

On Monday February 12, norman.r.weathers@conocophillips.com wrote:
> Hello,
> 
> I have noticed, at least in our Fedora 6 test case, that recent kernels
> (2.6.18 and 2.6.19) that there appears to be a "read hell" issue.  Has
> anyone else seen this?
> 
> For instance, using iozone, during a write case (32 kb blocks) to a Sun
> x4100 running Fedora Core 6 and the Fedora core kernels, I get decent
> throughput.  But, as soon as the test goes from write to rewrite, I see
> a large amount of read activity (via iostat) on the NFS server.  It
> looks like 4kb read blocks.

Yes.......

When the NFS server writes a large block (e.g. 32K) to a file, it has
the data in a number of buffers as they came in off the network.  Due
to the alignment of data in an NFS request, they almost certainly will
not be page-aligned.

This 'iovec' is then written to the file.

Normally when writing to a file from user-space (normal write or
writev system call), the pages holding the data to be written could be
paged out, so it has to be brought in to memory before the copy start.

A change was made to generic_file_buffered_write (in mm/filemap.c)
probably around 2.6.18 so that when writing from an iovec, each entry
is send to the file separately, because faulting in all the entries
at once is a bit awkward.

So the net result is that when NFSd writes to a file, the filesystem
sees a bunch of non-page-aligned writes rather than nicely aligned
writes (even when the NFS request holds a nicely aligned write).  This
causes it to pre-read all the pages.  Ugh.

Nick:  You've have some pending patching in this area.  Might they
address this problem?

NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
