Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48351 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752788AbbIKNff (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Sep 2015 09:35:35 -0400
Date: Fri, 11 Sep 2015 09:35:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: add a new nowcc export option to disable WCC attrs
 in v3 replies
Message-ID: <20150911133534.GB11677@fieldses.org>
References: <1441301594-17293-1-git-send-email-jeff.layton@primarydata.com>
 <20150903184327.GC10088@fieldses.org>
 <20150903145225.3a3a3776@tlielax.poochiereds.net>
 <20150903191914.GF10088@fieldses.org>
 <20150903155417.468aaca0@tlielax.poochiereds.net>
 <20150903202016.GH10088@fieldses.org>
 <20150903163537.3f6d9292@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150903163537.3f6d9292@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 03, 2015 at 04:35:37PM -0400, Jeff Layton wrote:
> On Thu, 3 Sep 2015 16:20:16 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Thu, Sep 03, 2015 at 03:54:17PM -0400, Jeff Layton wrote:
> > > 2) getattrs: We're working around the problem with this new export
> > > option, but if you don't use that then you can potentially deadlock
> > > with NFS. It wants to take the i_mutex in its ->getattr operation but
> > > knfsd calls vfs_getattr with that held to do post-op attrs. My initial
> > > workaround was to drop the i_mutex before calling fh_getattr instead of
> > > after, but then I hit the performance problem I described.
> > > 
> > > 3) locking: proxying v3 locking is a painful mess. If the reexporter
> > > reboots, it'll lose its lease on the main server, which will kick out
> > > all of its state. At that point you can end up with another client
> > > racing and getting your lock before the reexporter can come back up and
> > > reclaim it.
> > > 
> > > Our main use-case for this is pretty limited and doesn't involve file
> > > locking (so far!).
> > 
> > So this is the interest part, I guess.--b.
> > 
> 
> Yeah. The locking one is a real bugger. We have a potential design for
> a solution, but I'm not sure it'll be something we can open source.

Actually it wasn't the locking I was curious about so much as the use
case and whether it's something anyone else would care about.

--b.
