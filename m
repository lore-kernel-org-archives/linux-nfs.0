From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 00/30] What's in the NFS queue for 2.6.27
Date: Wed, 8 Oct 2008 15:39:51 -0400
Message-ID: <20081008193951.GB12386@fieldses.org>
References: <20081007221952.20945.69529.stgit@localhost.localdomain> <20081008193114.GA12386@fieldses.org> <1223494670.16460.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34832 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753248AbYJHTjw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Oct 2008 15:39:52 -0400
In-Reply-To: <1223494670.16460.2.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 08, 2008 at 03:37:50PM -0400, Trond Myklebust wrote:
> On Wed, 2008-10-08 at 15:31 -0400, J. Bruce Fields wrote:
> > On Tue, Oct 07, 2008 at 06:19:52PM -0400, Trond Myklebust wrote:
> > > Most of the following patches are bugfixes:
> > >   There are a couple of spin locking fixes to follow up the BKL removal.
> > >   There are some attribute update fixups, mainly to make the spin
> > >   locking more efficient
> > >   A fix for the problem of autobind on cloned RPC clients
> > > 
> > > The one feature that has been added is the lookup revalidation mount
> > > option to allow clients to specify that they might not want to cache
> > > negative dentries, and that they might want strict dentry revalidation.
> > 
> > The version of the fs_locations fixes are slightly older than my most
> > recent.  Looking back through the archive, I think it may have been my
> > mistake.  Sorry!
> > 
> > There's a missing patch from Chuck that makes the ip address parsing a
> > bit more paranoid.  I'll resend that, followed by the newer versions of
> > the other patches.
> > 
> > Aside from the missing patch from Chuck, the only difference between the
> > versions you have and my latest are summarized below.  it's just:
> > 
> > 	- a cosmetic change to set_port to address your complaints about
> > 	  blocks used just to define local variables, and
> > 	- changes to stop bothering to check for scope id's in v6
> > 	  addresses.
> > 
> > So--could you just take the following patches, and throw out the 4
> > corresponding patches from me in your current tree?
> 
> I'll split your patch into 2 and apply on top the existing tree.

That'll work too, thanks; let me know if you'd like me to do that for
you.

(And note also that patch #1, from Chuck, also needs to be applied.)

--b.
