Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59296 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759034Ab0ENTXf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 May 2010 15:23:35 -0400
Date: Fri, 14 May 2010 15:23:27 -0400
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Jeff Layton <jlayton@redhat.com>, Mi Jinlong <mijinlong@cn.fujitsu.com>,
        NFSv3 list <linux-nfs@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
        ebiederm@xmission.com, adobriyan@gmail.com, viro@ZenIV.linux.org.uk,
        jamie@shareable.org
Subject: Re: [PATCH] VFS: Unlink should revoke all outstanding leases on
	file
Message-ID: <20100514192327.GA20192@fieldses.org>
References: <4BED195F.3070504@cn.fujitsu.com> <20100514055844.109d2fdc@tlielax.poochiereds.net> <1273857471.4732.7.camel@localhost.localdomain> <20100514133819.5e383485@tlielax.poochiereds.net> <1273859968.4732.22.camel@localhost.localdomain> <1273861872.4732.34.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1273861872.4732.34.camel@localhost.localdomain>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, May 14, 2010 at 02:31:12PM -0400, Trond Myklebust wrote:
> On Fri, 2010-05-14 at 13:59 -0400, Trond Myklebust wrote: 
> > Note that the server should also recall the delegation if someone
> > attempts to violate the guarantees that are listed in section 9.4: Open
> > Delegation
> > 
> >    When a client has a read open delegation, it may not make any changes
> >    to the contents or attributes of the file but it is assured that no
> >    other client may do so.  When a client has a write open delegation,
> >    it may modify the file data since no other client will be accessing
> >    the file's data.  The client holding a write delegation may only
> >    affect file attributes which are intimately connected with the file
> >    data:  size, time_modify, change.
> > 
> > IOW: even if you hold a write delegation you are not allowed to change
> > the file mode bits, owner, group or acls...
> 
> ...or the nlink value. So technically, we should also recall the
> delegation when someone creates or deletes a hard link. I think I need
> to remind Tom that he should add that to the RFC3530bis draft...

Yep.  And fixing all these cases is required before our the server's
NFSv4 server is ready for much of anything.

I'm not sure ading break_lease() to may_delete() is right, but maybe
it's better than nothing.

One problem is that there's a race: nothing I can see stops anyone from
getting another lease after may_delete() but before the delete happens.

--b.
