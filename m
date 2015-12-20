Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:49445 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709AbbLTPxW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Dec 2015 10:53:22 -0500
Date: Sun, 20 Dec 2015 07:53:21 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@primarydata.com,
        bfields@fieldses.org, hch@infradead.org
Subject: Re: [PATCH v2 3/3] NFS: Add COPY nfs operation
Message-ID: <20151220155321.GC18236@infradead.org>
References: <1450472727-19893-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1450472727-19893-4-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1450472727-19893-4-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +	if (res.write_res.committed != NFS_FILE_SYNC) {
> +		status = nfs42_proc_commit(dst, pos_dst, res.write_res.count);
> +		if (status)
> +			return status;
> +	}

Do we really expect data to be stabe on disk after a copy_file_range?
Seems like the page cache variant doesn't guarantee that, and it would
also be different from all other I/O syscalls.

Either way we will probably need to document the assumptions in the man
page.
