From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH 0/21] nfsd41-for-2.6.30 review cleanup
Date: Thu, 2 Apr 2009 21:58:37 -0400
Message-ID: <20090403015837.GA30324@fieldses.org>
References: <49D53D44.4030102@panasas.com> <49D55C1E.2010704@panasas.com> <49D55D9A.9070504@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Adamson <andros@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:33342 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753136AbZDCB6m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 21:58:42 -0400
In-Reply-To: <49D55D9A.9070504@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 03, 2009 at 03:51:38AM +0300, Benny Halevy wrote:
> On Apr. 03, 2009, 3:45 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
> > On Apr. 03, 2009, 1:33 +0300, Benny Halevy <bhalevy@panasas.com> wrote:
> >> Bruce,
> >>
> >> The following patches fix non-DRC review comments.
> >> They are untested yet, but I wanted to send them out ASAP
> > 
> > Passed cthon tests over nfs4 so far from several clients:
> > same kernel, nfs41-for-2.6.30 from today, and from 2.6.27.19-78.2.30.fc9.x86_64.
> > The latter hit a single unreproducible failure in the bigfile test.
> > 
> > No pynfs regressions.
> 
> Oh, and I forgot to mention that I saw these suspicious messages
> on /var/log/messages a while after my last cthon test finished and the
> test server was essentially idle:
> 
> Apr  3 03:19:05 tl1 kernel: nfsd: non-standard errno: -9
> Apr  3 03:25:52 tl1 kernel: nfsd: inode locked twice during operation.
> Apr  3 03:25:54 tl1 kernel: RPC: multiple fragments per record not supported
> 
> I'm not what caused them and if they show up with the nfsd41 patches
> or not.

The last two look normal for pynfs runs.

The first I don't recall seeing before.  Hm, -9 is EBADF.  I'd be
curious where that's coming from.

Probably it's nothing serious--pynfs does weird stuff.

--b.
