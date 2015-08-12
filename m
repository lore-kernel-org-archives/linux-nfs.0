Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33351 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755118AbbHLNxq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Aug 2015 09:53:46 -0400
Date: Wed, 12 Aug 2015 09:53:45 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] svcrdma: Change maximum server payload back to
 RPCSVC_MAXPAYLOAD
Message-ID: <20150812135345.GA26656@fieldses.org>
References: <20150807205325.1887.53743.stgit@klimt.1015granger.net>
 <20150810210557.GC10455@fieldses.org>
 <4E4E8EA4-AF06-4BB6-ABAB-5D9B5BF6FEB6@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E4E8EA4-AF06-4BB6-ABAB-5D9B5BF6FEB6@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 10, 2015 at 05:27:18PM -0400, Chuck Lever wrote:
> 
> On Aug 10, 2015, at 5:05 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> > On Fri, Aug 07, 2015 at 04:55:46PM -0400, Chuck Lever wrote:
> >> Both commit 0380a3f375 ("svcrdma: Add a separate "max data segs"
> >> macro for svcrdma") and commit 7e5be28827bf ("svcrdma: advertise
> >> the correct max payload") are incorrect. This commit reverts both
> >> changes, restoring the server's maximum payload size to 1MB.
> >> 
> >> Commit 7e5be28827bf based the server's maximum payload on the
> >> _client's_ RPCRDMA_MAX_DATA_SEGS value. That was wrong.
> >> 
> >> Commit 0380a3f375 tried to fix this so that the client maximum
> >> payload size could be raised without affecting the server, but
> >> managed to confuse matters more on the server side.
> >> 
> >> More importantly, limiting the advertised maximum payload size was
> >> meant to be a workaround, not the actual fix. We need to revisit
> >> 
> >>  https://bugzilla.linux-nfs.org/show_bug.cgi?id=270
> >> 
> >> A Linux client on a platform with 64KB pages can overrun and crash
> >> an x86_64 NFS/RDMA server when the r/wsize is 1MB. An x86/64 Linux
> >> client seems to work fine using 1MB reads and writes when the Linux
> >> server's maximum payload size is restored to 1MB.
> >> 
> >> BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=270
> >> Fixes: 0380a3f375 ("svcrdma: Add a separate "max data segs" macro")
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >> 
> >> Hi Bruce-
> >> 
> >> I notice you still have "svcrdma: Boost NFS READ/WRITE payload
> >> size maximum" in both your nfsd-next and for-4.3 branches. Can
> >> you please replace that patch with this one? This patch uses
> >> the approach we agreed on several weeks ago.
> >> 
> >> Thanks!
> > 
> > Gah, I don't like rebasing those for-XXX branches, but OK, done.  In the
> > future I'd prefer incremental patches against those branches if at all
> > possible.
> 
> Thanks for taking the update!
> 
> I thought you were going to wait for v2 of that series.
> 
> http://marc.info/?l=linux-nfs&m=143680563000597&w=2

Yeah, that was probably my screwup.

--b.
