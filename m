Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:36820 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752601AbbC3PhQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2015 11:37:16 -0400
Received: by qgf60 with SMTP id 60so173575453qgf.3
        for <linux-nfs@vger.kernel.org>; Mon, 30 Mar 2015 08:37:16 -0700 (PDT)
Date: Mon, 30 Mar 2015 11:37:12 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        jlayton@primarydata.com
Subject: Re: [PATCH] debugfs: debugfs_create_* shouldn't be checking
 permissions
Message-ID: <20150330113712.6c0ecbe2@tlielax.poochiereds.net>
In-Reply-To: <20150330152725.GC6901@fieldses.org>
References: <20150330142310.GB6901@fieldses.org>
	<20150330143823.GA10992@kroah.com>
	<20150330152725.GC6901@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 30 Mar 2015 11:27:25 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Mar 30, 2015 at 04:38:23PM +0200, Greg Kroah-Hartman wrote:
> > On Mon, Mar 30, 2015 at 10:23:10AM -0400, J. Bruce Fields wrote:
> > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > 
> > > Subject: [PATCH] debugfs: debugfs_create_* shouldn't be checking permissions
> > > 
> > > Debugfs files and and directories are created by kernel subsystems not
> > > directly by users, so we shouldn't be using lookup_one_len, which checks
> > > permissions.
> > > 
> > > This was causing krb5 mounts to fail to Fedora servers using gss-proxy
> > > if selinux was enabled, on kernels since 388f0c776781 "sunrpc: add a
> > > debugfs rpc_xprt directory with an info file in it", which creates a new
> > > debugfs directory for each new rpc client.
> > 
> > No kernel code should care / fail if a debugfs function fails, so please
> > fix up the sunrpc code first.
> 
> The sunrpc code is using debugfs to keep a list of all rpc clients
> together with some basic information about each one.
> 
> If the permissions issue is fixed then I think the only possible
> failures are lack of debugfs support and ENOMEM?
> 
> If there are situations where ENOMEM's actually possible, I'd worry a
> bit about this debugging information becoming unreliable after you go
> through some extreme memory shortage (possibly because that's what was
> necessary to reproduce the bug you're chasing).
> 
> But, I don't know, maybe I'm excessively paranoid; Jeff?
> 

The debugfs files are really just nice-to-have things. I don't think
you can read too much into it if they don't show up for some reason.
So, I'm fine with turning those into non-fatal errors.

> > > Reported-by: Anthony Messina <amessina@messinet.com>
> > > Reported-by: Jason Tibbits <tibbs@math.uh.edu>
> > > Cc: Jeff Layton <jlayton@primarydata.com>
> > > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > > ---
> > >  fs/debugfs/inode.c | 17 +++++++++++++----
> > >  1 file changed, 13 insertions(+), 4 deletions(-)
> > > 
> > > I swiped this code fragment from net/sunrpc/rpc_pipe.c, and it's gotten
> > > only minimal testing.  (It does fix krb5 mounts, though.)
> > > 
> > > diff --git a/fs/debugfs/inode.c b/fs/debugfs/inode.c
> > > index 96400ab42d13..75e5daa6a63f 100644
> > > --- a/fs/debugfs/inode.c
> > > +++ b/fs/debugfs/inode.c
> > > @@ -251,6 +251,7 @@ static struct dentry *start_creating(const char *name, struct dentry *parent)
> > >  {
> > >  	struct dentry *dentry;
> > >  	int error;
> > > +	struct qstr q = QSTR_INIT(name, strlen(name));
> > >  
> > >  	pr_debug("debugfs: creating file '%s'\n",name);
> > >  
> > > @@ -268,11 +269,19 @@ static struct dentry *start_creating(const char *name, struct dentry *parent)
> > >  		parent = debugfs_mount->mnt_root;
> > >  
> > >  	mutex_lock(&parent->d_inode->i_mutex);
> > > -	dentry = lookup_one_len(name, parent, strlen(name));
> > > -	if (!IS_ERR(dentry) && dentry->d_inode) {
> > > +	dentry = d_hash_and_lookup(parent, &q);
> > > +	if (!dentry) {
> > > +		dentry = d_alloc(parent, &q);
> > > +		if (!dentry) {
> > > +			dentry = ERR_PTR(-ENOMEM);
> > > +			goto out;
> > > +		}
> > > +	}
> > > +	if (dentry->d_inode) {
> > 
> > 
> > No, I'd rather not "open code" lookup_one_len() if at all possible
> > please.
> > 
> > What exactly is the problem here that the sunrpc code is failing from?
> 
> Sunrpc is creating a new rpc client (to talk to an rpc server).
> 
> Debugfs will fail to do that whenever the user doesn't have execute
> permissions on a debugfs directory.  The user in this case is whoever
> gss-proxy's running as, but I think it could just as well be someone
> doing an nfs mount, for example.
> 
> > Is it just interacting with selinux?  How is the debugfs code to blame
> > here?
> 
> As long as the debugfs directories permit "x" to everone, I guess you're
> only going to hit this with selinux (or some other security module).
> 
> We don't want to require updated selinux policies just because some
> subsystem started creating debugfs entries as a side-effect of some
> system call (which is what happened here).
> 
> --b.

Right.

-- 
Jeff Layton <jeff.layton@primarydata.com>
