From: Matthew Wilcox <willy@debian.org>
Subject: Re: [PATCH 1/4] Optimize NFS open() calls by means of 'intents'...
Date: Mon, 30 Jun 2003 16:14:26 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030630151426.GG31618@parcelfarce.linux.theplanet.co.uk>
References: <16128.19197.159225.698080@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux FSdevel <linux-fsdevel@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	NFS maillist <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <16128.19197.159225.698080@charged.uio.no>
List-ID: <nfs.lists.sourceforge.net>

On Mon, Jun 30, 2003 at 04:36:45PM +0200, Trond Myklebust wrote:
> +++ linux-2.5.73-04-lookupintent/include/linux/namei.h	2003-06-30 08:48:43.000000000 +0200
>  struct nameidata {
>  	struct dentry	*dentry;
>  	struct vfsmount *mnt;
>  	struct qstr	last;
>  	unsigned int	flags;
>  	int		last_type;
> +
> +	/* Intent data */
> +	union {
> +		struct open_intent open;
> +	} u;
> +
> +#if 0
> +	/* FS private data */
> +	void		*it_private;
> +	void (*it_release)(struct nameidata *, void *);
> +#endif

Can we call the union something descriptive (eg "intent") rather than "u"?
"u" only makes sense when you're working around not having anonymous
unions.

-- 
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodies.
Do you think I want to have an academic debate on this subject?" -- Robert Fisk
