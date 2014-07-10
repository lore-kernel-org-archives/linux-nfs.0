Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:42938 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbaGJH7V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 03:59:21 -0400
Date: Thu, 10 Jul 2014 00:59:20 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 011/100] nfsd: refactor nfs4_file_get_access and
 nfs4_file_put_access
Message-ID: <20140710075920.GA6226@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-12-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1404842668-22521-12-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +static void nfs4_file_get_access(struct nfs4_file *fp, u32 access)
>  {
> +	int oflag = nfs4_access_to_omode(access);
> +
> +	/* Note: relies on NFS4_SHARE_ACCESS_BOTH == READ|WRITE */
> +	access &= NFS4_SHARE_ACCESS_BOTH;
> +	if (access == 0)
> +		return;
> +
>  	if (oflag == O_RDWR) {

This fragment looks odd to me in several ways.

For one NFS4_SHARE_ACCESS_BOTH isn't == READ|WRITE, although reading it
again I suspect this supposed to mean
NFS4_SHARE_ACCESS_READ|NFS4_SHARE_ACCESS_WRITE.  Second why to the &=
on access if it's not used except for the test, or for that matter
why don't we do the check on the oflag?

I can see two sensible ways to do this:

a)

static void nfs4_file_get_access(struct nfs4_file *fp, u32 access)
{
	int oflag = nfs4_access_to_omode(access);

	if (oflag == O_RDWR) {
		__nfs4_file_get_access(fp, O_RDONLY);
		__nfs4_file_get_access(fp, O_WRONLY);
	} else if (oflag == O_RDONLY || oflag == O_RDONLY)
		__nfs4_file_get_access(fp, oflag);
	}
}

Or even better just avoid the nfs4_file_get_access call altogether:

static void nfs4_file_get_access(struct nfs4_file *fp, u32 access)
{
	WARN_ON_ONCE(access & ~NFS4_SHARE_ACCESS_BOTH);

	if (access & NFS4_SHARE_ACCESS_WRITE)
		__nfs4_file_get_access(fp, O_WRONLY);
	if (access & NFS4_SHARE_ACCESS_READ)
		__nfs4_file_get_access(fp, O_RDONLY);
}

Same for the put side.


Btw, what is the story about the third fd in fi_fds? Seems like
nfs4_get_vfs_file can put a file pointer in there, but
nfs4_file_get_access never grabs a reference to it.
