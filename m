Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53883 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755433AbbICOBX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Sep 2015 10:01:23 -0400
Date: Thu, 3 Sep 2015 15:01:17 +0100
From: Mel Gorman <mgorman@suse.de>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: Mel Gorman <mgorman@techsingularity.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH] nfs: avoid swap-over-NFS deadlock
Message-ID: <20150903140117.GE25655@suse.de>
References: <1437552643-18774-1-git-send-email-jmarchan@redhat.com>
 <CAHQdGtRXhUi+=akuASUWo-tYy0YCWJtUts6fqGnA62fo1Jf5tA@mail.gmail.com>
 <55AF9EA8.6020102@redhat.com>
 <20150727105216.GD2660@techsingularity.net>
 <55B6153B.1070604@redhat.com>
 <20150820122359.GB12432@techsingularity.net>
 <55E5D0B6.10307@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
In-Reply-To: <55E5D0B6.10307@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 01, 2015 at 06:22:14PM +0200, Jerome Marchand wrote:
> > Thanks. Sorry for the long delay but I finally got back to the bug this
> > week. NFS can be modified to special case the swapfile but I was not happy
> > with the result for multiple reasons. It took me a while to see a way for
> > the core VM to deal with it. What do you think of the following
> > approach?
> 
> Seems sound to me.
> 
> > More importantly, does it work for you?
> 
> Yes.
> 

Sweet, thanks. It's the merge window now so it won't get fixed now and I
know there is already a collision with the mm merge. I'll rebase and
repost after 4.3-rc1 comes out.

-- 
Mel Gorman
SUSE Labs
