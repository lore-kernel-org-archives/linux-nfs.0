From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [NFS] [PATCH][RFC] use completions instead of sleep_on for rpciod
Date: Tue, 10 Feb 2004 12:52:18 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40283952.6093F19D@melbourne.sgi.com>
References: <20040207144405.GA19416@lst.de> <20040209102801.GC21364@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, netdev@oss.sgi.com,
        nfs@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Kirch <okir@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-ID: <nfs.lists.sourceforge.net>

Olaf Kirch wrote:
> 
> [...] The code in fs/nfs/unlink.c is probably also racy
> without BKL.

I had cause to poke around there recently, and it's *definitely* racy
without BKL.  That file would benefit from several modernisations:

1.  move the list of nfs_unlinkdata from a global to a field in nfs_server

2.  add a lock in nfs_server for it instead of implicit BKL in
    nfs_complete_unlink, nfs_async_unlink, nfs_put_unlinkdata

3.  use proper list.h lists

> So if you remove the sunrpc BKL be prepared for lots and lots
> of bug reports :)

Yes but it's worth doing, especially serverside.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.
