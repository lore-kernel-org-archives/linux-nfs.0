From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] integrity: nfsd imbalance bug fix
Date: Wed, 27 May 2009 14:09:15 -0700
Message-ID: <20090527140915.26efc70b.akpm@linux-foundation.org>
References: <1243431112-7388-1-git-send-email-zohar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, hooanon05-/E1597aS9LR3+QwDJ9on6Q@public.gmane.org,
	"J. Bruce Fields" <bfields@fieldses.org>,
	James Morris <jmorris@namei.org>,
	David Safford <safford-aZOuKsOsJu3MbYB6QlFGEg@public.gmane.org>,
	linux-nfs@vger.kernel.org, Mimi Zohar <zohar@us.ibm.com>,
	Hugh Dickins <hugh.dickins-IWqWACnzNjwqdlJmJB21zg@public.gmane.org>
To: Mimi Zohar <zohar@linux.vnet.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36662 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750874AbZE0VJc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 May 2009 17:09:32 -0400
In-Reply-To: <1243431112-7388-1-git-send-email-zohar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org is about to vanish - please update your address book
to hugh.dickins-IWqWACnzNjxncZnQYuSK0A@public.gmane.org

On Wed, 27 May 2009 09:31:52 -0400
Mimi Zohar <zohar@linux.vnet.ibm.com> wrote:

> An nfsd exported file is opened/closed by the kernel causing the
> integrity imbalance message.
> 
> Before a file is opened, there normally is permission checking, which
> is done in inode_permission().  However, as integrity checking requires
> a dentry and mount point, which is not available in inode_permission(),
> the integrity (permission) checking must be called separately.
> 
> In order to detect any missing integrity checking calls, we keep track
> of file open/closes.  ima_path_check() increments these counts and
> does the integrity (permission) checking. As a result, the number of
> calls to ima_path_check()/ima_file_free() should be balanced.  An extra
> call to fput(), indicates the file could have been accessed without first
> calling ima_path_check().
> 
> In nfsv3 permission checking is done once, followed by multiple reads,
> which do an open/close for each read.  The integrity (permission) checking
> call should be in nfsd_permission() after the inode_permission() call, but
> as there is no correlation between the number of permission checking and
> open calls, the integrity checking call should not increment the counters,
> but defer it to when the file is actually opened.
> 
> This patch adds:
> - integrity (permission) checking for nfsd exported files in nfsd_permission().
> - a call to increment counts for files opened by nfsd.
> 
> This patch has been updated to return the nfs error types.

I have a note here that Hugh had some significant issues with the
previous version of this patch.

Were these problems addressed?  If so, how?

Thanks.
