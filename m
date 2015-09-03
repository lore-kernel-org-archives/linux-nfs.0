Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:35582 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908AbbICUfm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Sep 2015 16:35:42 -0400
Received: by ykek143 with SMTP id k143so1401092yke.2
        for <linux-nfs@vger.kernel.org>; Thu, 03 Sep 2015 13:35:41 -0700 (PDT)
Date: Thu, 3 Sep 2015 16:35:37 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: add a new nowcc export option to disable WCC
 attrs in v3 replies
Message-ID: <20150903163537.3f6d9292@tlielax.poochiereds.net>
In-Reply-To: <20150903202016.GH10088@fieldses.org>
References: <1441301594-17293-1-git-send-email-jeff.layton@primarydata.com>
	<20150903184327.GC10088@fieldses.org>
	<20150903145225.3a3a3776@tlielax.poochiereds.net>
	<20150903191914.GF10088@fieldses.org>
	<20150903155417.468aaca0@tlielax.poochiereds.net>
	<20150903202016.GH10088@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 3 Sep 2015 16:20:16 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Sep 03, 2015 at 03:54:17PM -0400, Jeff Layton wrote:
> > On Thu, 3 Sep 2015 15:19:14 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Thu, Sep 03, 2015 at 02:52:25PM -0400, Jeff Layton wrote:
> > > > On Thu, 3 Sep 2015 14:43:27 -0400
> > > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > > 
> > > > > On Thu, Sep 03, 2015 at 01:33:14PM -0400, Jeff Layton wrote:
> > > > > > There are cases with NFSv3 where the client doesn't actually care about
> > > > > > WCC attributes in replies. If the server is mainly acting as a DS for
> > > > > > flexfiles, then the client just throws out those attributes anyway.
> > > > > > Also, in the case where the client is primarily doing direct I/O, post
> > > > > > op attributes aren't terribly useful
> > > > > >
> > > > > > Another reason to allow turning these off is that NFS will flush all
> > > > > > buffered writes prior to issuing a GETATTR, and it also takes the
> > > > > > i_mutex in its ->getattr operation.
> > > > > >
> > > > > > If we're doing a vfs_getattr after most RPCs, then we can end up
> > > > > > deadlocking or (at best) prematurely flushing buffered writes, which
> > > > > > kills performance.
> > > > > 
> > > > > So you're talking about the NFS re-export case?  Do we know of any other
> > > > > case when a ->getattr is so expensive?
> > > > > 
> > > > 
> > > > That's the main one that I have experience with, but getattr can be
> > > > pretty expensive in clustered filesystems. For instance, on ceph:
> > > > 
> > > >         err = ceph_do_getattr(inode, CEPH_STAT_CAP_INODE_ALL, false);
> > > >         if (!err) {
> > > >                 generic_fillattr(inode, stat);
> > > >                 stat->ino = ceph_translate_ino(inode->i_sb, inode->i_ino);
> > > > 
> > > > 
> > > > ...and it looks like ceph_do_getattr can issue a request on the network
> > > > (though I'm not familiar with that code and I imagine that it's
> > > > sometimes optimized out).
> > > 
> > > OK.  Could we get something like that in the changelog?  The change
> > > really needs to stand on the non-NFS case alone as long as NFS
> > > reexport's not upstream.  For that reason (and because without the
> > > context that second paragraph's kind of confusing), it'd be helpful to
> > > preface the NFS discussion by smoething like "In the (out-of-tree) NFS
> > > re-export case".
> > > 
> > 
> > Yeah, no problem. I'll respin the changelog on both patches and resend
> > within the next day or two.
> > 
> > > What's keeping that out of upstream, anyway?  Apparently there's some
> > > use case, and if it's inspiring a lot of changes in generic code, then
> > > it'd simplify life to have it upstream.
> > > 
> > > 
> > 
> > There are several problems. Here are few but there are others:
> > 
> > 1) it is at least somewhat of a potential security concern. By mounting
> > on a box that has access and then reexporting it, you can circumvent
> > the export restrictions on the original server. Granted you can do that
> > today with samba or something, but still -- it's a little sketchy.
> 
> Or with ganesha, or you could run a web server, or just mail the file
> contents to someone....  This just isn't the way to enforce anything.
> 
> I've hard Trond argue something like this before, but I think his point
> was a little different: not that we have to deny reexports for security
> reasons, but just that such a policy-circumventing use case isn't worth
> supporting.  So he wasn't interested in reexports as long as that was
> the only use case he'd heard about.
> 

Agreed. We can't really enforce anything with this, but it's not a use
case we really want to be an enabler of.

> > 2) getattrs: We're working around the problem with this new export
> > option, but if you don't use that then you can potentially deadlock
> > with NFS. It wants to take the i_mutex in its ->getattr operation but
> > knfsd calls vfs_getattr with that held to do post-op attrs. My initial
> > workaround was to drop the i_mutex before calling fh_getattr instead of
> > after, but then I hit the performance problem I described.
> > 
> > 3) locking: proxying v3 locking is a painful mess. If the reexporter
> > reboots, it'll lose its lease on the main server, which will kick out
> > all of its state. At that point you can end up with another client
> > racing and getting your lock before the reexporter can come back up and
> > reclaim it.
> > 
> > Our main use-case for this is pretty limited and doesn't involve file
> > locking (so far!).
> 
> So this is the interest part, I guess.--b.
> 

Yeah. The locking one is a real bugger. We have a potential design for
a solution, but I'm not sure it'll be something we can open source.

-- 
Jeff Layton <jlayton@poochiereds.net>
