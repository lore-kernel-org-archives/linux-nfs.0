Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60432 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752700AbcHIQEh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Aug 2016 12:04:37 -0400
Date: Tue, 9 Aug 2016 12:04:35 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 0/2] Eliminate race between LOCK and FREE_STATEID
Message-ID: <20160809160435.GB15111@fieldses.org>
References: <20160808184711.11661.86427.stgit@klimt.1015granger.net>
 <20160808195948.GB6539@fieldses.org>
 <2A619A9B-7456-434E-9BD5-9731892DE8B3@oracle.com>
 <0B3D422E-5415-415F-BC59-3A65871152F0@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <0B3D422E-5415-415F-BC59-3A65871152F0@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 09, 2016 at 11:53:06AM -0400, Chuck Lever wrote:
> 
> > On Aug 8, 2016, at 4:06 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> > 
> >> 
> >> On Aug 8, 2016, at 3:59 PM, bfields@fieldses.org wrote:
> >> 
> >> On Mon, Aug 08, 2016 at 02:59:35PM -0400, Chuck Lever wrote:
> >>> This series passes light testing in my lab. If it looks good I will
> >>> pass it along to Alexey to confirm it closes the race.
> >>> 
> >>> To aid distributors and stable kernel maintainers, wondering if a
> >>> Fixes: tag should be added. Alexey first observed this issue in v4.1
> >>> kernels (UEK4). But looks like the race could have been introduced
> >>> as early as v3.17. Maybe this one?
> >> 
> >> The other reason we didn't see this till now might be client-side
> >> changes (maybe b4019c0e219b "NFSv4.1: Allow parallel LOCK/LOCKU
> >> calls"?).  (Not trying to dodge responsibility for a server-side bug
> >> here, but that might still be useful information for the changelog (not
> >> the Fixes: line) if it's correct.)
> > 
> > I asked Alexey to test as far back as v3.19, where I think the
> > LOCK parallelism was added. I need to get some clarification of
> > his test results; one set of test runs reproduced the race, and
> > a second set of test runs did not.
> 
> Alexey reports he tried reproducing this with an Oracle Linux UEK3
> client, which is roughly the same as v3.8 stable running on RHEL 6.
> He says he was not able to reproduce with that configuration.
> 
> However, he was able to reproduce with a stock RHEL 7.2 client, and
> with a v3.19 stable kernel running on a RHEL 7 client.

That "Allow parallel LOCK/LOCKU calls" patch wasn't in 3.19 (it went
into 4.0).  So, OK, I don't know, maybe we've got nothing to say about
that.

--b.
