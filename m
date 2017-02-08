Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44916 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751307AbdBHVvJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Feb 2017 16:51:09 -0500
Date: Wed, 8 Feb 2017 16:51:01 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: don't get =?utf-8?Q?writ?=
 =?utf-8?Q?e_access_tw=D1=96ce?= in nfsd_setattr
Message-ID: <20170208215101.GC17622@fieldses.org>
References: <20170207091244.GA14911@lst.de>
 <20170208214538.GB17622@fieldses.org>
 <20170208215038.GA21910@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170208215038.GA21910@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 08, 2017 at 10:50:38PM +0100, Christoph Hellwig wrote:
> On Wed, Feb 08, 2017 at 04:45:38PM -0500, J. Bruce Fields wrote:
> > On Tue, Feb 07, 2017 at 10:12:44AM +0100, Christoph Hellwig wrote:
> > > Turns out doing mnt_want_write twice for the same process makes
> > > lockdep unhappy, so move the fh_want_write down to after calling
> > > vfs_truncate in nfsd_setattr.  No changes to error handling required
> > > as the want write state is automatically cleaned up by the caller
> > > based on a flag in the svc_fh.
> > > 
> > > Fixes: 41f53350 ("nfsd: special case truncates some more")
> > > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > > Reported-by: Dave Jones <davej@codemonkey.org.uk>
> > 
> > Thanks, I'll see if I can squeeze this into 4.10.--b.
> 
> FYI, Chuck just reported another issue, let's wait for that for now.

OK.--b.
