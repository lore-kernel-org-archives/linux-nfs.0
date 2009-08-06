From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.6.28.9: EXT3/NFS inodes corruption
Date: Thu, 6 Aug 2009 13:05:43 -0400
Message-ID: <20090806170543.GA32511@fieldses.org>
References: <20090716172749.GC3740@atrey.karlin.mff.cuni.cz> <20090725151751.GA6419@gradator.net> <20090727154253.GB8332@duck.suse.cz> <20090728112715.GA8442@gradator.net> <20090728135226.GA21682@duck.suse.cz> <20090728164142.GA13662@gradator.net> <20090803222901.GB23162@duck.suse.cz> <20090804111505.GA6433@gradator.net> <20090804225619.GB11097@duck.suse.cz> <20090806131555.GA23359@gradator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org,
	linux-ext4@vger.kernel.org, linux-nfs@vger.kernel.org,
	Al Viro <viro@zeniv.linux.org.uk>
To: Sylvain Rochet <gradator-XWGZPxRNpGHk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57868 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756222AbZHFRFq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Aug 2009 13:05:46 -0400
In-Reply-To: <20090806131555.GA23359-XWGZPxRNpGHk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 06, 2009 at 03:15:56PM +0200, Sylvain Rochet wrote:
> Hi,
> 
> 
> On Wed, Aug 05, 2009 at 12:56:19AM +0200, Jan Kara wrote:
> > 
> > Thanks for testing. So you seem to be really stressting the path where
> > creation of new files / directories fails (probably due to group quota).
> 
> Yes, there are 29 groups over quota on a total of 4499. Those are mainly 
> spammed websites and therefore quite stressed due to the amount of tries 
> to add new "data".
> 
> 
> > I have one idea what could cause your filesystem corruption, although 
> > it's a wild guess... Please try attached oneliner.
> 
> Running since yesterday.
> 
> 
> > Also your corruption reminded me that Al Viro has been fixing problems
> > where we could cache one inode twice when a filesystem was mounted over NFS
> > and that could also lead to a filesystem corruption. So I'm adding him to
> > CC just in case he has some idea. BTW Al, what do you think about the
> > problem I describe in the attached patch? I'm not sure if it can cause some
> > real problems but in theory it could...
> 
> Should we upgrade NFS clients as well ?  (now running 2.6.28.9)

The client version shouldn't matter.

--b.
