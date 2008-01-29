From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/3] NLM add resume procfs file
Date: Mon, 28 Jan 2008 21:29:43 -0500
Message-ID: <20080129022943.GG16785@fieldses.org>
References: <47997059.704@redhat.com> <20080129021910.GF16785@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:48976 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752534AbYA2C3o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 21:29:44 -0500
In-Reply-To: <20080129021910.GF16785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 09:19:10PM -0500, bfields wrote:
> On Fri, Jan 25, 2008 at 12:15:05AM -0500, Wendy Cheng wrote:
> > +static ssize_t failover_resume_ip(struct file *file, char *buf, size_t size)
> > +{
> > +	__be32 server_ip;
> > +	int len;
> > +
> > +	len = failover_parse_ip(file, buf, size, &server_ip);
> > +	if (len < 0)
> > +		return len;
> > +
> > +	return nlmsvc_failover_setgrace(&server_ip, len);
> 
> Does this really need to take a void *?  And the &server_ip makes it
> look like server_ip may be modified, which is slightly confusing.
> 
> Maybe the next patches will remind me why it's being done this way....

After another look--no, I'm assuming this is just left over from
previous versions that allowed per-path grace-period setting as well?
So we should just pass some kind of integer instead of a void *.

--b.

> 
> > +}
> > +
> >  static ssize_t failover_unlock_fs(struct file *file, char *buf, size_t size)
> >  {
> >  	struct nameidata nd;
> > @@ -711,6 +742,8 @@ static int nfsd_fill_super(struct super_
> >  					&transaction_ops, S_IWUSR|S_IRUSR},
> >  		[NFSD_FO_UnlockFS] = {"unlock_filesystem",
> >  					&transaction_ops, S_IWUSR|S_IRUSR},
> > +		[NFSD_FO_ResumeIP] = {"resume_ip",
> > +					&transaction_ops, S_IWUSR|S_IRUSR},
> >  		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
> >  		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
> >  		[NFSD_Pool_Threads] = {"pool_threads", &transaction_ops, S_IWUSR|S_IRUSR},
> > --- linux-1/fs/lockd/svcsubs.c	2008-01-22 10:36:24.000000000 -0500
> > +++ linux-2/fs/lockd/svcsubs.c	2008-01-22 11:45:44.000000000 -0500
> > @@ -422,3 +422,12 @@ nlmsvc_failover_ip(__be32 server_addr)
> >  			nlmsvc_failover_file_ok_ip);
> >  }
> >  EXPORT_SYMBOL_GPL(nlmsvc_failover_ip);
> > +
> > +int
> > +nlmsvc_failover_setgrace(void *server_ip, int ip_size)
> > +{
> > +	/* implemented by resume_002.patch */
> > +	return ENOSYS;
> 
> OK, terrifically trivial nit, but: that should be -ENOSYS?
> 
> --b.
> 
> > +}
> > +EXPORT_SYMBOL_GPL(nlmsvc_failover_setgrace);
> > +
> > --- linux-1/include/linux/lockd/lockd.h	2008-01-22 10:36:24.000000000 -0500
> > +++ linux-2/include/linux/lockd/lockd.h	2008-01-22 11:45:44.000000000 -0500
> > @@ -220,6 +220,7 @@ void		  nlmsvc_invalidate_all(void);
> >   */
> >  int           nlmsvc_failover_path(struct nameidata *nd);
> >  int           nlmsvc_failover_ip(__be32 server_addr);
> > +int           nlmsvc_failover_setgrace(void *server_ip, int ip_size);
> >  
> >  static __inline__ struct inode *
> >  nlmsvc_file_inode(struct nlm_file *file)
> 
