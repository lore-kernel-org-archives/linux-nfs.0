Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46300 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753318AbdBIPub (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Feb 2017 10:50:31 -0500
Date: Thu, 9 Feb 2017 10:43:07 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: don't get =?utf-8?Q?writ?=
 =?utf-8?Q?e_access_tw=D1=96ce?= in nfsd_setattr
Message-ID: <20170209154307.GD17622@fieldses.org>
References: <20170207091244.GA14911@lst.de>
 <20170208214538.GB17622@fieldses.org>
 <20170208215038.GA21910@lst.de>
 <20170208215101.GC17622@fieldses.org>
 <20170209132516.GA12528@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170209132516.GA12528@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 09, 2017 at 02:25:16PM +0100, Christoph Hellwig wrote:
> On Wed, Feb 08, 2017 at 04:51:01PM -0500, J. Bruce Fields wrote:
> > > FYI, Chuck just reported another issue, let's wait for that for now.
> 
> I can't really reproduce the issue Chuck reported.  So let's get this
> fixup in for now, especially as Linus replied to the thread it was
> reported in and asked for it.

I can't find that reply--am I missing a thread?

OK, so for 4.10 I have:

	nfsd: don't get write access twice in nfsd_setattr
	nfsd: restore owner override for truncate

--b.
