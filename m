Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:52719 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751107AbbEGHxE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 03:53:04 -0400
Date: Thu, 7 May 2015 09:53:02 +0200
From: Christoph Hellwig <hch@lst.de>
To: Andreas =?iso-8859-1?Q?Gr=FCnbacher?=
	<andreas.gruenbacher@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: Disable NFSv2 timestamp workaround for NFSv3+
Message-ID: <20150507075302.GA23816@lst.de>
References: <1430895024-1403-1-git-send-email-andreas.gruenbacher@gmail.com> <20150506065651.GA22454@lst.de> <CAHpGcMJe1YyCev2mza=pOCvs1pcV6M2AnX-0hVa4gdppnXassA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <CAHpGcMJe1YyCev2mza=pOCvs1pcV6M2AnX-0hVa4gdppnXassA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 06, 2015 at 12:12:13PM +0200, Andreas Grünbacher wrote:
> 2015-05-06 8:56 GMT+02:00 Christoph Hellwig <hch@lst.de>:
> > How about moving the workaround into the NFSv2 specific code?
> 
> Not trivially, we would have to fh_verify() the file handle in
> nfsd_proc_setattr() first. Is that preferable?

Sounds better to me than making this workaround even more invasive
in the core.  Bruce, what do you think?
