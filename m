Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:51231 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752522AbdKJONN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Nov 2017 09:13:13 -0500
Received: by mail-it0-f65.google.com with SMTP id o135so1818393itb.0
        for <linux-nfs@vger.kernel.org>; Fri, 10 Nov 2017 06:13:13 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
Message-ID: <1510323191.2495.26.camel@gmail.com>
Subject: Re: [RFC 2/4] SUNRPC: Kill client tasks from debugfs
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>
Date: Fri, 10 Nov 2017 08:13:11 -0600
In-Reply-To: <87lgjeewgs.fsf@notabene.neil.brown.name>
References: <CAJdd5GZ-EMj8f3RaV_WUdeZs6aWbEAeC6xX8BadMD-aOFL3_jA@mail.gmail.com>
         <20171108145942.5127-1-JPEWhacker@gmail.com>
         <20171108145942.5127-3-JPEWhacker@gmail.com>
         <87lgjeewgs.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-11-10 at 12:47 +1100, NeilBrown wrote:
> On Wed, Nov 08 2017, Joshua Watt wrote:
> 
> > The "kill" client entry in debugfs can be used to kill client
> > tasks.
> > Writing "0" causes only the currently pending tasks to be killed,
> > while
> > writing "1" all currently pending, and any future pending tasks to
> > be
> > killed.
> > 
> > Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
> > ---
> >  net/sunrpc/debugfs.c | 48
> > ++++++++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 48 insertions(+)
> > 
> > diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
> > index e980d2a493de..a2f33d168873 100644
> > --- a/net/sunrpc/debugfs.c
> > +++ b/net/sunrpc/debugfs.c
> > @@ -118,6 +118,50 @@ static const struct file_operations tasks_fops
> > = {
> >  	.release	= tasks_release,
> >  };
> >  
> > +static int
> > +kill_set(void *data, u64 val)
> > +{
> > +	struct rpc_clnt *clnt = data;
> > +
> > +	rpc_killall_tasks(clnt, (int)val);
> > +	return 0;
> > +}
> > +
> > +static int
> > +kill_open(struct inode *inode, struct file *filp)
> > +{
> > +	int ret = simple_attr_open(inode, filp, NULL, kill_set,
> > "%i");
> > +
> > +	if (!ret) {
> > +		struct rpc_clnt *clnt = inode->i_private;
> > +
> > +		if (!atomic_inc_not_zero(&clnt->cl_count)) {
> > +			simple_attr_release(inode, filp);
> > +			ret = -EINVAL;
> > +		}
> > +	}
> > +
> > +	return ret;
> > +}
> > +
> > +static int
> > +kill_release(struct inode *inode, struct file *filp)
> > +{
> > +	struct rpc_clnt *clnt = inode->i_private;
> > +
> > +	rpc_release_client(clnt);
> > +
> > +	return simple_attr_release(inode, filp);
> > +}
> > +
> > +static const struct file_operations kill_fops = {
> > +	.owner	 = THIS_MODULE,
> > +	.open	 = kill_open,
> > +	.release = kill_release,
> > +	.write	 = debugfs_attr_write,
> > +	.llseek  = no_llseek,
> > +};
> > +
> >  void
> >  rpc_clnt_debugfs_register(struct rpc_clnt *clnt)
> >  {
> > @@ -160,6 +204,10 @@ rpc_clnt_debugfs_register(struct rpc_clnt
> > *clnt)
> >  	if (!debugfs_create_symlink("xprt", clnt->cl_debugfs,
> > name))
> >  		goto out_err;
> >  
> > +	if (!debugfs_create_file("kill", S_IFREG | 0200, clnt-
> > >cl_debugfs,
> > +				 clnt, &kill_fops))
> 
> S_IFREG is the default for debugfs_create_file, so it isn't needed.
> There are about 1085 calls to debugfs_create_file() in the kernel of
> which 85 specify S_IFREG.  Maybe we should fix them all...
> 
> And please use S_IWUSR rather than 0200.

Oddly enough, checkpatch.pl complains if you use S_IWUSR, stating that
you should use the octal instead:

  WARNING: Symbolic permissions 'S_IWUSR' are not preferred. Consider
using octal permissions '0200'.

I'm alright using S_IWUSR here since the rest of the file uses them
("when in Rome" and all that).

> 
> I don't know if we really need this functionality if debugfs, but I
> guess that is why we are putting it there - to see.

Yes, I purposely constructed this patch so it could be skipped if it is
unneeded/unwanted.

> 
> Thanks,
> NeilBrown
> 
> 
> > +		goto out_err;
> > +
> >  	return;
> >  out_err:
> >  	debugfs_remove_recursive(clnt->cl_debugfs);
> > -- 
> > 2.13.6
