Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60092 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750820AbdALVSc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 12 Jan 2017 16:18:32 -0500
Date: Thu, 12 Jan 2017 16:18:31 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] NFSD: only support readonly export for !fsync and
 readonly filesystem
Message-ID: <20170112211831.GG10501@fieldses.org>
References: <960d206f-3cb5-b60e-5245-d7282dabf664@gmail.com>
 <20170108100715.GC25268@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170108100715.GC25268@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 08, 2017 at 02:07:15AM -0800, Christoph Hellwig wrote:
> On Sat, Dec 31, 2016 at 09:18:08PM +0800, Kinglong Mee wrote:
> > Commit fae5096ad217
> > "nfsd: assume writeable exportabled filesystems have f_sync"
> > have remove the checking of f_sync.
> > 
> > Christoph Hellwig suggests,
> > "Warn and refuse the writable export."
> > 
> > I think just covert to a readonly export for !fsync filesystem,
> > also, for a readonly filesystem is reasonable.
> 
> I don't like degrading the export.

Anything there other than an intuition?

> We should require an explicit ro option in this case.

Well, I can't tell if Kinglong's case is something people are actively
complaining about or more hypotethetical, and in any case it doesn't
seem like a big deal, so I'm ignoring this for now, I guess....

--b.
