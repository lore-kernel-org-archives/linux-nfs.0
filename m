Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:52361 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751921AbdBINdq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Feb 2017 08:33:46 -0500
Date: Thu, 9 Feb 2017 14:25:16 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: don't get =?utf-8?Q?writ?=
        =?utf-8?Q?e_access_tw=D1=96ce?= in nfsd_setattr
Message-ID: <20170209132516.GA12528@lst.de>
References: <20170207091244.GA14911@lst.de> <20170208214538.GB17622@fieldses.org> <20170208215038.GA21910@lst.de> <20170208215101.GC17622@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170208215101.GC17622@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 08, 2017 at 04:51:01PM -0500, J. Bruce Fields wrote:
> > FYI, Chuck just reported another issue, let's wait for that for now.

I can't really reproduce the issue Chuck reported.  So let's get this
fixup in for now, especially as Linus replied to the thread it was
reported in and asked for it.
