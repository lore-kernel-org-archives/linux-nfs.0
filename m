Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:58268 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752978Ab0ESQO3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 May 2010 12:14:29 -0400
Date: Wed, 19 May 2010 17:14:19 +0100
From: Jamie Lokier <jamie@shareable.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Jeff Layton <jlayton@redhat.com>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>,
        NFSv3 list <linux-nfs@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
        ebiederm@xmission.com, adobriyan@gmail.com, viro@ZenIV.linux.org.uk
Subject: Re: [PATCH] VFS: Unlink should revoke all outstanding leases on file
Message-ID: <20100519161419.GB1693@shareable.org>
References: <4BED195F.3070504@cn.fujitsu.com> <20100514055844.109d2fdc@tlielax.poochiereds.net> <1273857471.4732.7.camel@localhost.localdomain> <20100514133819.5e383485@tlielax.poochiereds.net> <1273859968.4732.22.camel@localhost.localdomain> <1273861872.4732.34.camel@localhost.localdomain> <20100514192327.GA20192@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100514192327.GA20192@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:
> On Fri, May 14, 2010 at 02:31:12PM -0400, Trond Myklebust wrote:
> > On Fri, 2010-05-14 at 13:59 -0400, Trond Myklebust wrote: 
> > > Note that the server should also recall the delegation if someone
> > > attempts to violate the guarantees that are listed in section 9.4: Open
> > > Delegation
> > > 
> > >    When a client has a read open delegation, it may not make any changes
> > >    to the contents or attributes of the file but it is assured that no
> > >    other client may do so.  When a client has a write open delegation,
> > >    it may modify the file data since no other client will be accessing
> > >    the file's data.  The client holding a write delegation may only
> > >    affect file attributes which are intimately connected with the file
> > >    data:  size, time_modify, change.
> > > 
> > > IOW: even if you hold a write delegation you are not allowed to change
> > > the file mode bits, owner, group or acls...
> > 
> > ...or the nlink value. So technically, we should also recall the
> > delegation when someone creates or deletes a hard link. I think I need
> > to remind Tom that he should add that to the RFC3530bis draft...
> 
> Yep.  And fixing all these cases is required before our the server's
> NFSv4 server is ready for much of anything.
> 
> I'm not sure ading break_lease() to may_delete() is right, but maybe
> it's better than nothing.
> 
> One problem is that there's a race: nothing I can see stops anyone from
> getting another lease after may_delete() but before the delete happens.

Presumably the intent is that the NFSv4 REMOVE request _acquires_ the
lease, and releases it after the delete is done.

Same pattern with renames, attribute changes, etc.

Imho it would all be much tidier if leases had the same set of flag
bits as inotify/dnotify, to say what changes they block.  (Maybe the
flags would be slightly different - a detail).

All operations (read, write, open, link, rename, etc.) would follow a
pattern like this pseudo-code:

   do_write(file)
   {
       err = lease_acquire(file, IN_MODIFY);
       if (err < 0)
           return err;

       /* Do the modifying. */

       lease_release_and_inotify_event(file, IN_MODIFY);
   }

I think that would provide the semantics needed by NFS, Samba, also
fanotify for free, and more or less any kind of userspace caching,
coherent or not.  It's clean and orthogonal.  (Good value for money isn't it?)

The nlink value is missing from inotify (or "linked from" if you look
at it differently), but that's a problem needing to be fixed anyway.

-- Jamie
