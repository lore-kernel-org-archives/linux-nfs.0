Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42558 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751133Ab2GaOTM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 10:19:12 -0400
Date: Tue, 31 Jul 2012 10:19:09 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v2 00/15] Lockd: grace period containerization
Message-ID: <20120731141909.GB27834@fieldses.org>
References: <20120725125258.24376.82525.stgit@localhost.localdomain>
 <20120727215431.GE6388@fieldses.org>
 <50165C0D.1070200@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <50165C0D.1070200@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 30, 2012 at 02:03:57PM +0400, Stanislav Kinsbursky wrote:
> 28.07.2012 01:54, J. Bruce Fields пишет:
> >On Wed, Jul 25, 2012 at 04:55:45PM +0400, Stanislav Kinsbursky wrote:
> >>Bruce, I feel this patch set is ready for inclusion.
> >>
> >>v2:
> >>1) Rebase on Bruce's "for-3.6" branch.
> >>
> >>This patch set makes grace period and hosts reclaiming network namespace
> >>aware.
> >
> >On a quick skim--yes, that looks reasonable to me.
> >
> >It doesn't help with active/active cluster exports, because in that case
> >we need some additional coordination between nfsd's.
> >
> >But it looks good enough to handle the case where each filesystem is
> >exported from at most one server at a time, which is more than we
> >currently handle.
> >
> >It's a little late for 3.6.  Also I get the impression Al Viro has some
> >lockd rework in progress, which we may want to wait for.
> >
> >So I'll likely look again into queueing this up for 3.7 once 3.6-rc1 is
> >out.
> 
> 
> Ok.
> Will Al Viro's lockd rework be a part of 3.6 kernel?

Actually I think it mostly won't be.

And this looks pretty safe, really.  I've gone ahead and merged it.

--b.
