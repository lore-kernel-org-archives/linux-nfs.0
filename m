Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40184 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751062AbdCNVDq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 17:03:46 -0400
Date: Tue, 14 Mar 2017 17:03:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC nfs-utils PATCH] nfsdcltrack: cluster mode
Message-ID: <20170314210344.GA5690@fieldses.org>
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
> > On Fri, Mar 10, 2017 at 04:46:12PM -0500, Scott Mayhew wrote:
> > > 3. During nfsdcltrack's startup, we stat the etab file.  If the inode
> > >    number is different than what we have in the db, then we know that
> > >    the exportfs program has modified the file.  We read in the exported
> > >    path names and compare them to what we have stored in the exports
> > >    table.  If any new exports has been added, we merge the client
> > >    records from db's on those exports into the clients table of the
> > >    local db.  Then we update the exports table in the local db.
> > 
> > How does the merging work?  What happens when some of the clients from
> > an export's .nfsdcltrack/ database are the same as known clients?
> 
> The known clients are left as-is.  That's what the 'OR IGNORE' in the
> INSERT statement in the merge function is for (the id is the primary
> key of the clients table -- the 'OR IGNORE' tells sqlite what to do in
> the event that it were to violate that constraint).

I wonder about the other fields--the merged entry should probably have
the latest of the times on the two entries, and it should probably be a
sign of a problem if has_session doesn't agree, I think?

--b.
