Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49524 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753839AbbCaPaH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2015 11:30:07 -0400
Date: Tue, 31 Mar 2015 11:30:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Jeff Layton <jlayton@poochiereds.net>, trond.myklebust@primarydata.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] sunrpc: make debugfs file creation failure non-fatal
Message-ID: <20150331153006.GK6901@fieldses.org>
References: <1427752698-32431-1-git-send-email-jeff.layton@primarydata.com>
 <20150330234753.GG6901@fieldses.org>
 <20150331140916.GJ6901@fieldses.org>
 <20150331142641.GA9961@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150331142641.GA9961@kroah.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 31, 2015 at 04:26:41PM +0200, Greg KH wrote:
> On Tue, Mar 31, 2015 at 10:09:16AM -0400, J. Bruce Fields wrote:
> > On Mon, Mar 30, 2015 at 07:47:53PM -0400, J. Bruce Fields wrote:
> > > ACK.--b.
> > 
> > But note the result after this is that the debugfs directories will
> > always miss gss-proxy clients on selinux-enforcing systems.  That could
> > be really confusing.
> 
> So, you shouldn't be relying on debugfs :)
>
> > So we should still fix debugfs's permission checking.  It doesn't make
> > sense to me as is.
> 
> I don't really understand what the problem is here.  Is selinux
> preventing some debugfs files to be created?

debugfs doesn't actually check permission on the create itself, it only
checks for permission to lookup in the directory.  But the effect is to
prevent some creates, yes.

> If so, great, it's allowed
> to do that, go fix up your selinux config files to not do that.
> Otherwise, to go around selinux/LSM seems like a bad idea for debugfs to
> be doing, don't you think?

As far as I can tell, other synthetic filesystems that allow kernel
subsystems to create files skip permissions checking (based on just a
quick look at proc, sysfs, and rpc_pipefs).  Even in the debugfs case
the permissions-checking appears to be an accident.

To take an extreme case, we wouldn't want fork() to check the caller's
permissions on /proc.

It's less crazy in this case, but I think it still violates the the
principle of least surprise.

If there's some real requirement for permissions checking here, then I'd
like to understand what that requirement is.  And then:

	- create should be checking for the correct permissions (not
	  just search/execute).

	- we should document that callers need to ignore errors from
	  debugfs_create_*, to avoid situations like this where adding
	  debugging files to some bit of kernel infrastructure causes
	  regressions.  ("You need to update your selinux policy to
	  access this new debugging feature" is maybe OK, but "You need
	  to update your selinux policy to fix a kernel regression"
	  definitely isn't.)

--b.
