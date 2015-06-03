Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57016 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753016AbbFCTrm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2015 15:47:42 -0400
Date: Wed, 3 Jun 2015 15:47:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 08/10] svcrdma: Add backward direction service for
 RPC/RDMA transport
Message-ID: <20150603194741.GC9627@fieldses.org>
References: <20150526174401.7061.43137.stgit@klimt.1015granger.net>
 <20150526174945.7061.58026.stgit@klimt.1015granger.net>
 <20150601202641.GD26972@fieldses.org>
 <C2428536-0784-4C42-B678-F2173C6CAB89@oracle.com>
 <20150602153054.GB32413@fieldses.org>
 <4939D8DF-4AD0-477F-B06C-0E27F015BBE0@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4939D8DF-4AD0-477F-B06C-0E27F015BBE0@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 03, 2015 at 03:49:13PM -0400, Chuck Lever wrote:
> 
> On Jun 2, 2015, at 11:30 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> > On Mon, Jun 01, 2015 at 04:45:26PM -0400, Chuck Lever wrote:
> >> 
> >> On Jun 1, 2015, at 4:26 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> 
> >>> On Tue, May 26, 2015 at 01:49:45PM -0400, Chuck Lever wrote:
> >>>> Introduce some pre-requisite infrastructure needed for handling
> >>>> RPC/RDMA bi-direction on the client side.
> >>>> 
> >>>> On NFSv4.1 mount points, the client uses this transport endpoint to
> >>>> receive backward direction calls and route replies back to the
> >>>> NFS server.
> >>> 
> >>> Am I missing something, or is this pretty much dead code for now?
> >>> 
> >>> In which case, I'd rather wait on it.
> >> 
> >> When I submit the client-side backchannel patches, should I submit
> >> this patch through Anna and request your Acked-by?
> > 
> > Sure, feel free to add my Acked-by.
> > 
> > Or I guess I won't worry too much about some dead code if the
> > client-side patches are coming soon.
> 
> There are more pre-requisites on the client than there are on the server.
> I anticipate it will be at least two more merge windows before the client
> will be ready to merge backchannel support.
> 
> I’ll add this patch back into the client backchannel series.

OK.--b.
