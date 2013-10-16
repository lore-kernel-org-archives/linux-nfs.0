Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:49006 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770Ab3JPHQt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Oct 2013 03:16:49 -0400
Date: Wed, 16 Oct 2013 00:16:48 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        Al Viro <viro@ZenIV.linux.org.uk>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/5] exportfs: move most of reconnect_path to helper
 function
Message-ID: <20131016071648.GA28671@infradead.org>
References: <1381869574-10662-1-git-send-email-bfields@redhat.com>
 <1381869574-10662-3-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1381869574-10662-3-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  /*
> + * Return the parent directory on success.
> + *
> + * Return NULL to keep trying.
> + *
> + * Otherwise return an error.
> + */
> +static int reconnect_one(struct vfsmount *mnt, struct dentry *pd, char *nbuf, int *noprogress)

Please keep the lines under 80 characters.

> +	struct dentry *ppd;
> +	struct dentry *npd;

Might as well use sensible names already when splitting it out instead
of renaming them later down the series?

Otherwise looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
