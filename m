Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55404 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756937Ab0ITSFo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Sep 2010 14:05:44 -0400
Date: Mon, 20 Sep 2010 14:04:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Neil Brown <neilb@suse.de>, Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/9] sunrpc: Start making sunrpc work in containers
Message-ID: <20100920180418.GN4580@fieldses.org>
References: <4C90BADB.10700@parallels.com>
 <20100920161326.GL4580@fieldses.org>
 <4C978CE6.5080508@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C978CE6.5080508@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 20, 2010 at 08:33:42PM +0400, Pavel Emelyanov wrote:
> >> Looking forward to your feedback.
> > 
> > What are you thinking of as a use-case for this?
> 
> To make it possible run both NFS server and client in containers.

Could you describe that in user-visible terms?  (Currently if I create a
new network namespace, what happens, and what will happen differently
afterwards?)

> I know, that the NFS client is already a filesystem, but such
> things as its internal servers and clients abstraction require
> isolation from each other in containers terms.
> 
> > I think it would be useful to able to run what appear to be multiple NFS
> > servers on a single host; 
> 
> Yup, this is one of the goals.

OK, good.

> > and for that, we would want to vary more than
> > just the ip_map_cache.  The export-related caches (nfsd.fh and
> > nfsd.export), at least.
> 
> Sure! The thing is that the full containerization of that stuff is
> too many patches and I'm not sure that you and other maintainers wish
> to review the 100-patch set in one go ;)

Well, if it's really all ready....

Better, though, would be an outline of the work to be done and what you
expect to be working at the end.

> I want to find out what git tree to hack on and prepare small patch
> sets making things step-by-step. This one is just the first in a row.

For the server side you can use

	git://linux-nfs.org/~bfields/linux.git nfsd-next

though generally the latest upstream will likely work as well.

On a quick skim, those patches look fine (and brokenly up nicely for
review, thanks).  My main concern is just being sure I understand where
this all ends up.

--b.
