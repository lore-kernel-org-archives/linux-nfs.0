Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58942 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751773AbdCOMap (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 15 Mar 2017 08:30:45 -0400
Date: Wed, 15 Mar 2017 08:30:44 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC nfs-utils PATCH] nfsdcltrack: cluster mode
Message-ID: <20170315123044.q4lzoxug4wkuhspi@tonberry.usersys.redhat.com>
References: <20170310214612.12583-1-smayhew@redhat.com>
 <20170313212029.GB15183@fieldses.org>
 <20170314141157.tjyhyostquyazpyl@tonberry.usersys.redhat.com>
 <20170314210344.GA5690@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170314210344.GA5690@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 14 Mar 2017, J. Bruce Fields wrote:

> On Tue, Mar 14, 2017 at 10:11:57AM -0400, Scott Mayhew wrote:
> > On Mon, 13 Mar 2017, J. Bruce Fields wrote:
> > > On Fri, Mar 10, 2017 at 04:46:12PM -0500, Scott Mayhew wrote:
> > > > 3. During nfsdcltrack's startup, we stat the etab file.  If the inode
> > > >    number is different than what we have in the db, then we know that
> > > >    the exportfs program has modified the file.  We read in the exported
> > > >    path names and compare them to what we have stored in the exports
> > > >    table.  If any new exports has been added, we merge the client
> > > >    records from db's on those exports into the clients table of the
> > > >    local db.  Then we update the exports table in the local db.
> > > 
> > > How does the merging work?  What happens when some of the clients from
> > > an export's .nfsdcltrack/ database are the same as known clients?
> > 
> > The known clients are left as-is.  That's what the 'OR IGNORE' in the
> > INSERT statement in the merge function is for (the id is the primary
> > key of the clients table -- the 'OR IGNORE' tells sqlite what to do in
> > the event that it were to violate that constraint).
> 
> I wonder about the other fields--the merged entry should probably have
> the latest of the times on the two entries,

That can be done.

> and it should probably be a
> sign of a problem if has_session doesn't agree, I think?

How would that happen?  AFAICT the client string includes the minor
version number and has_session is set whenever the minor version is
nonzero.  So I guess it might happen if you have a non-Linux client
that doesn't include the minor version number in the client string,
which does v4.0 and v4.x mounts of filesystems exported by separate
cluster nodes, and the one of the exports is moved so that both of them
are now on the same node.

-Scott
> 
> --b.
