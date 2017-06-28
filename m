Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49136 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751489AbdF1PWv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Jun 2017 11:22:51 -0400
Date: Wed, 28 Jun 2017 11:22:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <schumaker.anna@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, trond.myklebust@primarydata.com,
        jlayton@poochiereds.net, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] nfs4: add NFSv4 LOOKUPP handlers
Message-ID: <20170628152250.GF11295@fieldses.org>
References: <20170627154403.20944-1-hch@lst.de>
 <20170627154403.20944-4-hch@lst.de>
 <99a3d554-399f-3d02-2033-3962fc00afea@gmail.com>
 <20170628151316.GE11295@fieldses.org>
 <8598f3b1-d057-4ca8-325e-b1bd2eefb13f@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8598f3b1-d057-4ca8-325e-b1bd2eefb13f@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 28, 2017 at 11:17:41AM -0400, Anna Schumaker wrote:
> 
> 
> On 06/28/2017 11:13 AM, J. Bruce Fields wrote:
> > On Wed, Jun 28, 2017 at 10:55:35AM -0400, Anna Schumaker wrote:
> >> Hi Christoph,
> >>
> >> On 06/27/2017 11:44 AM, Christoph Hellwig wrote:
> >>> From: Jeff Layton <jeff.layton@primarydata.com>
> >>>
> >>> This will be needed in order to implement the get_parent export op
> >>> for nfsd.
> >>
> >> I think this patch conflicts with your constify and function pointer cleanups from a few weeks ago, and it may need to be updated.
> >>
> >> Just double checking:  Bruce, are you taking the constify series for 4.13?
> > 
> > Sorry, I haven't been paying attention--what constify series?
> 
> The one Christoph sent out in May that touched all of nfs, nfsd, and sunrpc.  I wasn't sure if we had come to a decision about who is sending that in or not :)

Gah, right, sorry.  I still intend to just pull his nfs-ops branch, but
I think I got distracted by test failures caused by an unrelated vm
networking issues.  I'll take a look....

--b.
