Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48567 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750755AbbEGOIQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 10:08:16 -0400
Date: Thu, 7 May 2015 10:08:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andreas =?utf-8?Q?Gr=C3=BCnbacher?=
	<andreas.gruenbacher@gmail.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: Disable NFSv2 timestamp workaround for NFSv3+
Message-ID: <20150507140814.GF27106@fieldses.org>
References: <1430895024-1403-1-git-send-email-andreas.gruenbacher@gmail.com>
 <20150506065651.GA22454@lst.de>
 <CAHpGcMJe1YyCev2mza=pOCvs1pcV6M2AnX-0hVa4gdppnXassA@mail.gmail.com>
 <20150507075302.GA23816@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20150507075302.GA23816@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 07, 2015 at 09:53:02AM +0200, Christoph Hellwig wrote:
> On Wed, May 06, 2015 at 12:12:13PM +0200, Andreas Grünbacher wrote:
> > 2015-05-06 8:56 GMT+02:00 Christoph Hellwig <hch@lst.de>:
> > > How about moving the workaround into the NFSv2 specific code?
> > 
> > Not trivially, we would have to fh_verify() the file handle in
> > nfsd_proc_setattr() first. Is that preferable?
> 
> Sounds better to me than making this workaround even more invasive
> in the core.  Bruce, what do you think?

I haven't looked into it, but I certainly don't see a reason why an
extra call to nfsd_proc_setattr would be a problem.  And I agree that it
would be nice to have this in NFSv2-specific code.

--b.
