Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:35182 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605AbbCUSrg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Mar 2015 14:47:36 -0400
Date: Sat, 21 Mar 2015 14:47:32 -0400
From: Taesoo Kim <taesoo@gatech.edu>
To: Christoph Hellwig <hch@infradead.org>
Cc: Taesoo Kim <tsgatesv@gmail.com>, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, changwoo@gatech.edu, sanidhya@gatech.edu,
        blee@gatech.edu, csong84@gatech.edu,
        Byoungyoung Lee <lifeasageek@gmail.com>
Subject: Re: [PATCH] NFS: fix potential NULL deref in nfs_closedir()
Message-ID: <20150321184732.GA5170@taesoo.org>
References: <1426911678-25306-1-git-send-email-tsgatesv@gmail.com>
 <20150321180154.GA4916@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150321180154.GA4916@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ops. After reading nfs code, we also find out that nfs_opendir()
always allocates ctx obj (for private_data), unlike other fs allocate
private_data right before seeking dentries.

Sorry for the false alarm.

Taesoo

On 03/21/15 at 11:01am, Christoph Hellwig wrote:
> On Sat, Mar 21, 2015 at 12:21:18AM -0400, Taesoo Kim wrote:
> > From: Byoungyoung Lee <lifeasageek@gmail.com>
> > 
> > When filp->private_data is NULL, put_nfs_open_dir_context()
> > deferences its pointer (fi->list, fi->cred), similar to what
> > other file systems handle '.release' api (9p, cifs, btrfs, 
> > ext4, ocfs2).
> 
> Why woud filp->private_data ever be NULL here?
