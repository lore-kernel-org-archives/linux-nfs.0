Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fifo99.com ([67.223.236.141]:38049 "EHLO fifo99.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752793Ab3J0PKA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 Oct 2013 11:10:00 -0400
Date: Sun, 27 Oct 2013 08:09:53 -0700
From: Daniel Walker <dwalker@fifo99.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2/3] fs: nfsd: remove calls to simple_strtoll
Message-ID: <20131027150952.GA4801@fifo99.com>
References: <1382754793-8827-2-git-send-email-dwalker@fifo99.com>
 <20131026184124.GA17487@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131026184124.GA17487@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 26, 2013 at 02:41:24PM -0400, J. Bruce Fields wrote:
> On Fri, Oct 25, 2013 at 07:33:12PM -0700, Daniel Walker wrote:
> > Signed-off-by: Daniel Walker <dwalker@fifo99.com>
> > ---
> >  fs/nfsd/fault_inject.c | 12 ++++++++----
> >  1 file changed, 8 insertions(+), 4 deletions(-)
> > 
> > diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
> > index d620e7f..41165f0 100644
> > --- a/fs/nfsd/fault_inject.c
> > +++ b/fs/nfsd/fault_inject.c
> > @@ -125,20 +125,24 @@ static ssize_t fault_inject_write(struct file *file, const char __user *buf,
> >  	size_t size = min(sizeof(write_buf) - 1, len);
> >  	struct net *net = current->nsproxy->net_ns;
> >  	struct sockaddr_storage sa;
> > +	int ret = -EFAULT;
> >  	u64 val;
> >  
> >  	if (copy_from_user(write_buf, buf, size))
> > -		return -EFAULT;
> > +		return ret;
> >  	write_buf[size] = '\0';
> >  
> >  	size = rpc_pton(net, write_buf, size, (struct sockaddr *)&sa, sizeof(sa));
> >  	if (size > 0)
> >  		nfsd_inject_set_client(file_inode(file)->i_private, &sa, size);
> 
> If we take this branch, don't we end up returning -EFAULT below?
> 


Looks like it .. I wasn't try to change that behavior, I'll update the
patch and resend.

Daniel
