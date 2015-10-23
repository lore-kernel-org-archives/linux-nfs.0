Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:34368 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbbJWTRQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Oct 2015 15:17:16 -0400
Received: by qgem9 with SMTP id m9so74461120qge.1
        for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2015 12:17:15 -0700 (PDT)
Date: Fri, 23 Oct 2015 15:17:12 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Anders Blomdell <anders.blomdell@control.lth.se>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: NULL pointer dereference in nfs_delegation_find_inode
Message-ID: <20151023151712.6cec9529@synchrony.poochiereds.net>
In-Reply-To: <562A280A.7070205@control.lth.se>
References: <5629E933.8030807@control.lth.se>
	<20151023072827.2861dd75@tlielax.poochiereds.net>
	<562A280A.7070205@control.lth.se>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 23 Oct 2015 14:28:58 +0200
Anders Blomdell <anders.blomdell@control.lth.se> wrote:

> On 2015-10-23 13:28, Jeff Layton wrote:
> > On Fri, 23 Oct 2015 10:00:51 +0200
> > Anders Blomdell <anders.blomdell@control.lth.se> wrote:
> > 
> >> We occasionally (about once every 2-4 weeks on 1 of a 100 machenes) get 
> >>
> >>   BUG: unable to handle kernel NULL pointer dereference at 0000000000000548
> >>   IP: [<ffffffffa0651744>] nfs_delegation_find_inode+0x64/0x150 [nfsv4]
> >>
> >> the attached bug is from 4.1.8-100.fc21, but I have seen it on 4.1.5-100.fc21 as
> >> well. Right now I have a realtime modified (xenomai.org) 3.8.13 system that exhibits
> >> the problem more frequently, and that leads me to belive that the problem is
> >> a data race problem, and by instrumenting fs/nfs/delegation.c (3.8.13) to:
> >>
> >>
> >>   static struct inode *
> >>   nfs_delegation_find_inode_server(struct nfs_server *server,
> >> 				 const struct nfs_fh *fhandle)
> >>   {
> >> 	  struct nfs_delegation *delegation;
> >> 	  struct inode *res = NULL;
> >>
> >>  	  printk(KERN_ERR "server = %p\n", server);
> >> 	  list_for_each_entry_rcu(delegation, &server->delegations, super_list) {
> >> 		  printk(KERN_ERR "delegation = %p\n", delegation);
> >> 		  printk(KERN_ERR "delegation->lock = %p\n", delegation->lock);
> >> 		  spin_lock(&delegation->lock);
> >> 		  printk(KERN_ERR "delegation->inode = %p\n", delegation->inode);
> >> 		  if (delegation->inode != NULL) {
> >> 			  printk(KERN_ERR "NFS_I(delegation->inode) = %p", NFS_I(delegation->inode));
> >> 			  printk(KERN_ERR "NFS_I(delegation->inode)->fh = %p", NFS_I(delegation->inode)->fh);
> >> 		  }
> >> 		  if (delegation->inode != NULL &&
> >> 		      nfs_compare_fh(fhandle, &NFS_I(delegation->inode)->fh) == 0) {
> >> 			  res = igrab(delegation->inode);
> >> 		  }
> >> 		  spin_unlock(&delegation->lock);
> >> 		  if (res != NULL)
> >> 			  break;
> >> 	  }
> >> 	  return res;
> >>   }
> >>
> >> the system dies with (delegation.c compiled with -O0):
> >>
> >>   server = ffff8803dee58458
> >>   delegation =           (null)
> >>   BUG: unable to handle kernel NULL pointer dereference at 0000000000000050
> >>   IP: [<ffffffffa08924ae>] nfs_delegation_find_inode_server+0x80/0x1e0 [nfsv4]
> >>
> >> Anybody thet can give me a hint how to write a program that gives rise to multiple 
> >> delegations to further investigate this issue?
> >>
> >> Regards
> >>
> >> Anders Blomdell
> >>
> > 
> > Huh. That delegation pointer really never be NULL. 
>                                       ^should
> > I'm unclear on how
> > that could even happen in the context of a list_for_each_entry_rcu
> > loop. Oh, but super_list is the first struct member in nfs_delegation
> > so it probably means that server->delegations was NULL.
> > 
> > Maybe this is a use-after free of some sort or there's a memory
> > scribble involved?
> That is my guess, and the realtime patch used probably makes the window of opportunity
> much larger (since the bug happens every few hours instead of every few years on average).
> 
> 
> > You might want to consider turning up some memory
> > debugging options while reproducing this.
> Any hints on what options? Could/should they beturned on for the NFS module only
> 

If your kernel uses SLUB then you can poke around with the options
under /sys/kernel/slab. Figure out which cache that object belongs too
(it appears to be kmalloc'ed) and enable stuff like "poison" and
red_zone.

If you can get a vmcore then you could also open it up with the
debugger and see what at "server" object looks like. Has it been freed?
Does it belong to the right slabcache? etc...

> Any hints of what file operations to use to force delegations to happen?
> 

You can't really force it as it's 100% up to the server. They are
handed out at OPEN time. So any open-heavy workload should help
reproduce it.

-- 
Jeff Layton <jlayton@poochiereds.net>
