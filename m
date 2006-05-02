From: Ian Kent <raven@themaw.net>
Subject: Re: [NFS] Re: [PATCH][RFC] NFS: Improving the access cache
Date: Tue, 2 May 2006 23:26:37 +0800 (WST)
Message-ID: <Pine.LNX.4.64.0605022324330.10562@raven.themaw.net>
References: <444EC96B.80400@RedHat.com> <17486.64825.942642.594218@cse.unsw.edu.au>
 <444F88EF.5090105@RedHat.com> <17487.62730.16297.979429@cse.unsw.edu.au>
 <44572B33.4070100@RedHat.com> <445763CF.5040506@redhat.com>
 <44576EE4.4010704@RedHat.com> <44577204.5070000@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <44577204.5070000@redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, 2 May 2006, Peter Staubach wrote:

> Steve Dickson wrote:
> 
> > Peter Staubach wrote:
> > 
> > > > Basically we would maintain one global hlist (i.e. link list) that
> > > > would contain all of the cached entries; then each nfs_inode would
> > > > have its own LRU hlist that would contain entries that are associated
> > > > with that nfs_inode. So each entry would be on two lists, the
> > > > global hlist and hlist in the nfs_inode.
> > > > 
> > > 
> > > How are these lists used?
> > 
> > The inode hlist will be used to search and purge...
> > 
> 
> Eeee!  A linear search?  That gets expensive as the list grows.  A hashed
> list would keep the search times down.

I thought hlist was meant to be used for hash tables with chaining?

Ian

