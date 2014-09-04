Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43924 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754865AbaIDTyV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2014 15:54:21 -0400
Date: Thu, 4 Sep 2014 15:54:20 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 3/5] nfsd: add a v4_end_grace file to /proc/fs/nfsd
Message-ID: <20140904195420.GB14576@fieldses.org>
References: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
 <1408473509-14010-4-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1408473509-14010-4-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 19, 2014 at 02:38:27PM -0400, Jeff Layton wrote:
> Allow a privileged userland process to end the v4 grace period early.
> Any write to the file will cause the v4 grace period to be lifted.
> The basic idea with this will be to allow the userland client tracking
> program to lift the grace period once it knows that no more clients
> will be reclaiming state.
...
> +/**
> + * write_v4_end_grace - release grace period for nfsd's v4.x lock manager
> + *
> + * Input:
> + *			buf:		ignored
> + *			size:		zero
> + * OR
> + *
> + * Input:
> + * 			buf:		any value
> + *			size:		non-zero length of C string in @buf
> + * Output:
> + *			passed-in buffer filled with "Y" or "N" with a newline
> + *			and NULL-terminated C string. This indicates whether
> + *			the grace period has ended in the current net
> + *			namespace. Return code is the size in bytes of the
> + *			string. Writing to the file will end the grace period
> + *			for nfsd's v4 lock manager.
> + */
> +static ssize_t write_v4_end_grace(struct file *file, char *buf, size_t size)
> +{
> +	struct net *net = file->f_dentry->d_sb->s_fs_info;
> +	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
> +
> +	if (size > 0)
> +		nfsd4_end_grace(nn);

Ditto for this one.

Do we really need separate files for nlm and nfsd?

I think the separate nlm and nfsd grace periods may just be a historical
mistake.

--b.
