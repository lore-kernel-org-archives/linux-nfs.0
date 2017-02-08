Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:48775 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751103AbdBHVvJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Feb 2017 16:51:09 -0500
Date: Wed, 8 Feb 2017 22:50:38 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: don't get =?utf-8?Q?writ?=
        =?utf-8?Q?e_access_tw=D1=96ce?= in nfsd_setattr
Message-ID: <20170208215038.GA21910@lst.de>
References: <20170207091244.GA14911@lst.de> <20170208214538.GB17622@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170208214538.GB17622@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 08, 2017 at 04:45:38PM -0500, J. Bruce Fields wrote:
> On Tue, Feb 07, 2017 at 10:12:44AM +0100, Christoph Hellwig wrote:
> > Turns out doing mnt_want_write twice for the same process makes
> > lockdep unhappy, so move the fh_want_write down to after calling
> > vfs_truncate in nfsd_setattr.  No changes to error handling required
> > as the want write state is automatically cleaned up by the caller
> > based on a flag in the svc_fh.
> > 
> > Fixes: 41f53350 ("nfsd: special case truncates some more")
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > Reported-by: Dave Jones <davej@codemonkey.org.uk>
> 
> Thanks, I'll see if I can squeeze this into 4.10.--b.

FYI, Chuck just reported another issue, let's wait for that for now.
