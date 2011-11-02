Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30077 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751655Ab1KBLH7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Nov 2011 07:07:59 -0400
Date: Wed, 2 Nov 2011 07:07:42 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: open-associated setattr shouldn't invalidate own
 cache
Message-ID: <20111102070742.5354d83c@tlielax.poochiereds.net>
In-Reply-To: <20111102012315.GA5532@fieldses.org>
References: <02f301cc45a8$1ad15db6$78be630a@hq.netapp.com>
	<20111101202715.GB1891@fieldses.org>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430BDE7BC5@SACMVEXC2-PRD.hq.netapp.com>
	<20111101204325.522c35b3@corrin.poochiereds.net>
	<20111102012315.GA5532@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 1 Nov 2011 21:23:15 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Nov 01, 2011 at 08:43:25PM -0400, Jeff Layton wrote:
> > On Tue, 1 Nov 2011 16:07:27 -0700
> > "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> > 
> > > > -----Original Message-----
> > > > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > > > Sent: Tuesday, November 01, 2011 4:27 PM
> > > > To: Myklebust, Trond
> > > > Cc: J. Bruce Fields; Myklebust, Trond; linux-nfs@vger.kernel.org
> > > > Subject: Re: [PATCH] nfs: open-associated setattr shouldn't invalidate
> > > own
> > > > cache
> > > > 
> > > > On Mon, Jul 18, 2011 at 08:09:15PM -0400, Myklebust, Trond wrote:
> > > > > We should already optimize away the unnecessary setting of the size.
> > > > 
> > > > Do you remember what commit fixed that?  (Was it an nfs change or a
> > > vfs
> > > > change?)
> > > 
> > > It predates the git repository. See the comment about "Optimization:" in
> > > nfs_setattr().
> > > 
> > > > > The problem is that truncate() still requires you to set the ctime,
> > > whereas
> > > > ftruncate() does not iirc.
> > > > 
> > > > Staring at the code....  I think you mean the opposite?  I notice
> > > > do_sys_ftruncate() calling
> > > > 
> > > > 	do_truncate(dentry, length, ATTR_MTIME|ATTR_CTIME, file);
> > > > 
> > > > and do_sys_truncate() calling
> > > > 
> > > > 	do_truncate(path.dentry, length, 0, NULL);
> > > > 
> > > > where the third argument is getting OR'd with ATTR_FILE to pass into
> > > > notify_change().
> > > 
> > > Sorry, yes. ftruncate() is the one that unconditionally sets the
> > > mtime/ctime on success according to the POSIX spec.
> > > 
> > 
> > Even when it's a noop? Blech.
> > 
> > > > Also even when a setattr does get through, I don't understand why it
> > > should
> > > > be invalidating our data cache.  Is there some reason it needs to, or
> > > is this just
> > > > a case that hasn't seemed worth fixing?
> > > 
> > > Is the problem perhaps that we should be clearing the
> > > NFS_INO_INVALID_DATA flag in nfs_vmtruncate() when the size gets set to
> > > zero?
> > > 
> > 
> > That was my thinking too. Whenever we truncate the i_size to 0, we
> > can safely assume that the pagecache is now valid, and should be able
> > to clear NFS_INO_INVALID_DATA no matter when it was set, right?
> 
> I don't understand why 0 is a special case: why should my setting the
> size ever mean that I have to go reread data from the server?
> 

If the server doesn't send pre-op attrs (and linux servers don't) then
you have no way to know whether someone raced in and did writes to the
remaining pages just prior to your truncate.

Size 0 is a special case because there are no remaining pages.

-- 
Jeff Layton <jlayton@redhat.com>
