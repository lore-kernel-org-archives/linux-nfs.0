Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39574 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752305AbdCNOUP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 10:20:15 -0400
Date: Tue, 14 Mar 2017 10:20:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC nfs-utils PATCH] nfsdcltrack: cluster mode
Message-ID: <20170314142013.GB31956@fieldses.org>
References: <20170310214612.12583-1-smayhew@redhat.com>
 <20170313212029.GB15183@fieldses.org>
 <20170314141157.tjyhyostquyazpyl@tonberry.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170314141157.tjyhyostquyazpyl@tonberry.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 14, 2017 at 10:11:57AM -0400, Scott Mayhew wrote:
> On Mon, 13 Mar 2017, J. Bruce Fields wrote:
> 
> > On Fri, Mar 10, 2017 at 04:46:12PM -0500, Scott Mayhew wrote:
> > > This patch adds a new config option called "cluster-mode" for sharing
> > > client records from the cltrack database between nodes of an HA cluster
> > > such as pacemaker.
> > > 
> > > When enabled:
> > > 
> > > 1. We have a sqlite db in a hidden directory (".nfsdcltrack") on each
> > >    export.
> > 
> > I'm worried about storing any nfsdcltrack in an exported filesystem.
> > 
> > Access restrictions that might make sense for the rest of the export may
> > be too permissive for this stuff.  We don't want a client to be able to
> > modify the database,
> 
> In my test setup I have the database file writable only by root, so the
> server would have to have root squashing disabled.

Well, we do support disabling of root squashing.  For some exports,
auth=sys,no_root_squash may be the most useful configuration.  I'm
uncomfortable prohibiting that.

> > How does the merging work?  What happens when some of the clients from
> > an export's .nfsdcltrack/ database are the same as known clients?
> 
> The known clients are left as-is.  That's what the 'OR IGNORE' in the
> INSERT statement in the merge function is for (the id is the primary
> key of the clients table -- the 'OR IGNORE' tells sqlite what to do in
> the event that it were to violate that constraint).

Obviously I'm putting off reading the code, apologies....

> > > 4. When client records are added (cltrack_create()), updated
> > >    (cltrack_check()), or removed (cltrack_remove() and
> > >    cltrace_gracedone()) from the local db, they're added/updated/removed
> > >    from db on each of the exports as well.
> > 
> > Could you explain why you think this will give us the correct behavior
> > across migrations and reboots?
> 
> The idea was that if the export's db was kept up to date then it would
> reflect what clients were keeping their lease active with the node
> that was previously exporting the filesystem, and therefore should be
> allowed to reclaim their locks from the node that was taking over the
> export after it was moved or if the old node rebooted.

OK, thanks for the explanations!

I'd like to mull this over a bit.

--b.
