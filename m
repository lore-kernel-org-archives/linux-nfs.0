From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Broken nfsd in recent kernels
Date: Tue, 13 Feb 2007 14:58:06 +1100
Message-ID: <45D1374E.1090800@yahoo.com.au>
References: <1171326368.8065.36.camel@hoeplx2923>
	<17873.13603.316692.955211@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Norman Weathers <norman.r.weathers@conocophillips.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGooH-0005GJ-Pr
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 19:58:32 -0800
Received: from smtp106.mail.mud.yahoo.com ([209.191.85.216])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HGooH-0000gz-7D
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 19:58:30 -0800
In-Reply-To: <17873.13603.316692.955211@notabene.brown>
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

Neil Brown wrote:
> On Monday February 12, norman.r.weathers@conocophillips.com wrote:
> 
>>Hello,
>>
>>I have noticed, at least in our Fedora 6 test case, that recent kernels
>>(2.6.18 and 2.6.19) that there appears to be a "read hell" issue.  Has
>>anyone else seen this?
>>
>>For instance, using iozone, during a write case (32 kb blocks) to a Sun
>>x4100 running Fedora Core 6 and the Fedora core kernels, I get decent
>>throughput.  But, as soon as the test goes from write to rewrite, I see
>>a large amount of read activity (via iostat) on the NFS server.  It
>>looks like 4kb read blocks.
> 
> 
> Yes.......
> 
> When the NFS server writes a large block (e.g. 32K) to a file, it has
> the data in a number of buffers as they came in off the network.  Due
> to the alignment of data in an NFS request, they almost certainly will
> not be page-aligned.
> 
> This 'iovec' is then written to the file.
> 
> Normally when writing to a file from user-space (normal write or
> writev system call), the pages holding the data to be written could be
> paged out, so it has to be brought in to memory before the copy start.
> 
> A change was made to generic_file_buffered_write (in mm/filemap.c)
> probably around 2.6.18 so that when writing from an iovec, each entry
> is send to the file separately, because faulting in all the entries
> at once is a bit awkward.
> 
> So the net result is that when NFSd writes to a file, the filesystem
> sees a bunch of non-page-aligned writes rather than nicely aligned
> writes (even when the NFS request holds a nicely aligned write).  This
> causes it to pre-read all the pages.  Ugh.
> 
> Nick:  You've have some pending patching in this area.  Might they
> address this problem?

Hi Neil,

Yes, they do address the multiple-segment iovec problem, but it remains
to be seen when the patches will get in...

It is very awkward to fix the problem in the prepare_write/commit_write
path due to the nature of the API. Basically I'm reverting to performing
an extra data copy there, which reduces bandwidth quite a lot (although
it does reintroduce the multi-segment iovec copying, so it might be a
win in this case).

Then I'm looking at introducing a new aops API that filesystems can
implement to solve the problem in a well performing manner.

The problem is, this can't really happen until the important filesystems
implement the API.

It would be interesting to know whether Norman's test case actually is
using writev...

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
