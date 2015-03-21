Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:43269 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637AbbCUSCD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Mar 2015 14:02:03 -0400
Date: Sat, 21 Mar 2015 11:01:54 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Taesoo Kim <tsgatesv@gmail.com>
Cc: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        taesoo@gatech.edu, changwoo@gatech.edu, sanidhya@gatech.edu,
        blee@gatech.edu, csong84@gatech.edu,
        Byoungyoung Lee <lifeasageek@gmail.com>
Subject: Re: [PATCH] NFS: fix potential NULL deref in nfs_closedir()
Message-ID: <20150321180154.GA4916@infradead.org>
References: <1426911678-25306-1-git-send-email-tsgatesv@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1426911678-25306-1-git-send-email-tsgatesv@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Mar 21, 2015 at 12:21:18AM -0400, Taesoo Kim wrote:
> From: Byoungyoung Lee <lifeasageek@gmail.com>
> 
> When filp->private_data is NULL, put_nfs_open_dir_context()
> deferences its pointer (fi->list, fi->cred), similar to what
> other file systems handle '.release' api (9p, cifs, btrfs, 
> ext4, ocfs2).

Why woud filp->private_data ever be NULL here?
