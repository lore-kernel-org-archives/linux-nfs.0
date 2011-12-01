Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:45190 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753377Ab1LACYU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Nov 2011 21:24:20 -0500
Message-ID: <1322706258.2646.6.camel@lade.trondhjem.org>
Subject: Re: Rename dir on server can cause client to get ESTALE - this time
 with PATCH
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: NeilBrown <neilb@suse.de>, NFS <linux-nfs@vger.kernel.org>
Date: Wed, 30 Nov 2011 21:24:18 -0500
In-Reply-To: <20111201021251.GY2203@ZenIV.linux.org.uk>
References: <20111114131929.7b341444@notabene.brown>
	 <20111201124922.22e7d72f@notabene.brown>
	 <20111201021251.GY2203@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2011-12-01 at 02:12 +0000, Al Viro wrote: 
> On Thu, Dec 01, 2011 at 12:49:22PM +1100, NeilBrown wrote:
> 
> > If the path was "/some/long/path/.", then the final component ("path" in
> > this case) has already been revalidated and there is no particular
> > need to do it again.
> > 
> > If we change nd->last_type to refer to "the last component looked at"
> > rather than just "the last component", then these cases can be
> > detected by "nd->last_type != LAST_NORM".
> 
> This is just plain wrong.  Let's *not* bring more dependencies on
> nameidata into ->d_revalidate().  The goal is to get rid of it there...
> 
> FWIW, if you want a really nasty bug in that area, consider this:
> 
> mkdir /tmp/a
> mkdir /tmp/b
> echo "local file" >/tmp/x
> mount -t nfs4 $SOMETHING /tmp/a
> mount -t nfs4 $SOMETHING /tmp/b
> echo "NFS file" >/tmp/a/x
> mount --bind /tmp/x /tmp/a/x
> 
> now try opening /tmp/b/x.  And watch the NFS traffic; there won't be OPEN
> request for x on server.  Why?  Because NFS sees that x is a mountpoint in
> *some* instance of that filesystem.  And decides that opening it would be
> wrong.  And so it would, if we were asked to open /tmp/a/x.  Alas, in this
> case, while dentry is the same, it does *not* have anything mounted on it.
> What we get is ->d_revalidate() returning without issuing OPEN and ->open()
> being called - again, without issuing OPEN, since it assumes that ->lookup()
> or ->d_revalidate() had done it for us.
> 
> Plain IO on resulting descriptor will work and work correcly (you'll get
> "NFS file\n" read from it), but try to do F_SETLK on it and it'll fail
> since that requires the server to have seen an OPEN.

We can possibly fix this for the NFSv4.1 case since that adds support
for open-by-filehandle. However, I agree that NFSv4.0 is unfixable: all
OPENs are required to do the equivalent of a lookup, which isn't
possible in the bind mount case.

> As far as I can tell, the idea of open done in ->d_revalidate() is
> unsalvagable.  It's simply the wrong place for that.  Note that NFS
> is the only filesystem trying to do atomic open stuff in its ->d_revalidate()
> and it's not succeeding.

Not doing an open there is prohibitively expensive, though: you are
likely to see your cached inode flushed down the toilet if you just drop
the dentry...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

