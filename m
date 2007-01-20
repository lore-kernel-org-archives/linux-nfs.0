From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 13/14] NLM: Shrink the maximum request size of
	NLM4 requests
Date: Sat, 20 Jan 2007 09:26:56 +0000
Message-ID: <20070120092656.GA28676@infradead.org>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
	<20070118233056.23310.1289.stgit@localhost.localdomain>
	<20070119001355.GD13473@infradead.org>
	<45B145C1.5080007@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H8CVb-0001Xq-47
	for nfs@lists.sourceforge.net; Sat, 20 Jan 2007 01:27:35 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H8CVb-0001jA-KS
	for nfs@lists.sourceforge.net; Sat, 20 Jan 2007 01:27:37 -0800
To: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <45B145C1.5080007@oracle.com>
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

On Fri, Jan 19, 2007 at 05:27:13PM -0500, Chuck Lever wrote:
> Christoph Hellwig wrote:
> >On Thu, Jan 18, 2007 at 06:30:56PM -0500, Chuck Lever wrote:
> >>NLM version 4 requests estimate the call and reply header sizes rather
> >>conservatively, using the very maximum size allowed in the protocol even
> >>though Linux always uses only a small fraction of the allowable space.
> >>
> >>Reduce the size of caller and lock arguments to conserve RPC buffer space
> >>while XDR encoding NLM4 arguments..
> >
> >>+#ifndef MIN
> >>+# define MIN(a, b)	(((a) < (b)) ? (a) : (b))
> >>+#endif
> >
> >please use the kernel min or min_t macros instead.
> 
> min/min_t don't work for integer constants, which is what I'm using 
> MIN() for.  What should I use instead?

I suspect the right thing is to fix min/max/min_t/max_t for it using gcc
hackery like __builtin_constant_p.  Then again I don't understand enough
of that nor do I expect you to know this deep magic.  So Let's keep one
MIN/MAX in some central sunrpc header for now and add a block comment
describing why you need it.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
