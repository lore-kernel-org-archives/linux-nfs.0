From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: fix possible read-ahead cache and export
	table	corruption
Date: Fri, 13 Jul 2007 13:46:25 -0400
Message-ID: <20070713174625.GF12582@fieldses.org>
References: <20070713024420.GA31364@fieldses.org>
	<20070713041019.GB20430@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9PDn-00013h-F1
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 10:46:27 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9PDp-0004xW-RZ
	for nfs@lists.sourceforge.net; Fri, 13 Jul 2007 10:46:31 -0700
In-Reply-To: <20070713041019.GB20430@sgi.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, Jul 13, 2007 at 02:10:19PM +1000, Greg Banks wrote:
> My bad.  The code I added really only works properly if the number
> of nfsd threads at startup is a multiple of 8, so that cache_size
> is a multiple of 16 and the shift doesn't lose any nonzero bits.
> As we use 128 threads in our product, I'd never noticed the bug :-(

It seems likely the distros all default to powers or 2, so that may make
it a little less likely to explain other bug reports I've seen.  Oh
well.  I'm not sure why I had this one test machine set to start 50
threads.

> There's a couple of other problems with that code, for which I'll send
> patches shortly.  But I think the raparams cache needs a more thorough
> renovation than that.  I have a mostly-working patch which rips it out
> entirely and replaces it with a cache of open struct files, an idea
> of Neil's.  This approach fixes a whole bunch of separate problems
> at once, and will be really useful...

OK!  What are the other problems you were thinking of?

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
