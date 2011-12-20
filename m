Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15505 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752002Ab1LTNlp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Dec 2011 08:41:45 -0500
Date: Tue, 20 Dec 2011 08:41:17 -0500
From: Josh Boyer <jwboyer@redhat.com>
To: Jan Kara <jack@suse.cz>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: Enclose hostname in brackets when needed in
 nfs_do_root_mount
Message-ID: <20111220134116.GB20167@zod.bos.redhat.com>
References: <1315004983-10271-1-git-send-email-jack@suse.cz>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AFD3952@SACMVEXC2-PRD.hq.netapp.com>
 <20110903002231.GI12182@quack.suse.cz>
 <20111108130608.GA16554@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111108130608.GA16554@quack.suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 08, 2011 at 02:06:08PM +0100, Jan Kara wrote:
> On Sat 03-09-11 02:22:31, Jan Kara wrote:
> > On Fri 02-09-11 16:23:43, Myklebust, Trond wrote:
> > > > -----Original Message-----
> > > > From: Jan Kara [mailto:jack@suse.cz]
> > > > Sent: Friday, September 02, 2011 7:10 PM
> > > > To: Myklebust, Trond
> > > > Cc: linux-nfs@vger.kernel.org; Jan Kara; Josh Boyer; Myklebust, Trond
> > > > Subject: [PATCH] nfs: Enclose hostname in brackets when needed in
> > > > nfs_do_root_mount
> > > > 
> > > > When hostname contains colon (e.g. when it is an IPv6 address) it
> > > needs
> > > > to be enclosed in brackets to make parsing of NFS device string
> > > > possible.
> > > > Fix nfs_do_root_mount() to enclose hostname properly when needed. NFS
> > > > code
> > > > actually does not need this as it does not parse the string passed by
> > > > nfs_do_root_mount() but the device string is exposed to userspace in
> > > > /proc/mounts.
> > > > 
> > > > CC: Josh Boyer <jwboyer@redhat.com>
> > > > CC: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > > Signed-off-by: Jan Kara <jack@suse.cz>
> > > > ---
> > > >  fs/nfs/super.c |    8 ++++++--
> > > >  1 files changed, 6 insertions(+), 2 deletions(-)
> > > > 
> > > > diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> > > > index b961cea..42b74f8 100644
> > > > --- a/fs/nfs/super.c
> > > > +++ b/fs/nfs/super.c
> > > > @@ -2694,11 +2694,15 @@ static struct vfsmount
> > > > *nfs_do_root_mount(struct file_system_type *fs_type,
> > > >  	char *root_devname;
> > > >  	size_t len;
> > > > 
> > > > -	len = strlen(hostname) + 3;
> > > > +	len = strlen(hostname) + 5;
> > > >  	root_devname = kmalloc(len, GFP_KERNEL);
> > > >  	if (root_devname == NULL)
> > > >  		return ERR_PTR(-ENOMEM);
> > > > -	snprintf(root_devname, len, "%s:/", hostname);
> > > > +	/* Does hostname needs to be enclosed in brackets? */
> > > > +	if (strchr(hostname, ':'))
> > > > +		snprintf(root_devname, len, "[%s]:/", hostname);
> > > > +	else
> > > > +		snprintf(root_devname, len, "%s:/", hostname);
> > > 
> > > What if the hostname is already enclosed in brackets, as is usually the
> > > case if I enter an IPv6 address instead of a DNS name? Won't this cause
> > > it to be bracketed twice?
> > > 
> > > IOW: If I try to
> > > 
> > > 	mount -t nfs [fe80::20c:29ff:fee9:83e6]:/export /mnt
> > > 
> > > won't the above end up returning a hostname of [[::20c:29ff:fee9:83e6]]?
> >   No it won't - I've actually verified my patch with experiment ;). The
> > hostname nfs_do_root_mount() gets is already without possible brackets
> > (these have been removed when we first parsed the string passed from
> > userspace by nfs_parse_devname() - yes, it took me some time to drill
> > through the NFS call stack during mount to actually find out who removes
> > the brackets from the passed hostname and who composes the device name back
> > without them).
>   Ping? Trond, will you merge the patch please? I guess it got somehow
> lost.

Did this patch ever get queued up?  I don't see it in Linus' tree or
linux-next so I'm guessing no.  Is there a reason why?

josh
