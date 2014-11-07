Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46440 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229AbaKGQFZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Nov 2014 11:05:25 -0500
Date: Fri, 7 Nov 2014 11:05:24 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] sunrpc: new tracepoints for call/reply tracking
Message-ID: <20141107160524.GH22638@fieldses.org>
References: <1414520654-1606-1-git-send-email-jlayton@primarydata.com>
 <20141106202009.GE22638@fieldses.org>
 <20141106165834.27863d4c@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141106165834.27863d4c@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 06, 2014 at 04:58:34PM -0500, Jeff Layton wrote:
> On Thu, 6 Nov 2014 15:20:09 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Tue, Oct 28, 2014 at 02:24:11PM -0400, Jeff Layton wrote:
> > > These patches add some tracepoints that I recently used when tracking
> > > down the hang that Christoph reported recently. At this point, I still
> > > haven't followed the trail to completion, but I think the problem is
> > > not likely to be in the RPC code.
> > > 
> > > Please consider these for v3.19? Some of these are for client RPC and
> > > some for server-side. I'll assume that Trond will merge these, but
> > > review by others would be appreciated as well.
> > 
> > Looks fine to me, thanks, I'll assume Trond's applying all three unless
> > I hear otherwise.
> > 
> > (Separate issue: the server-side rpc dprintk's need review: they're much
> > too frequent to be useful, I think.)
> > 
> 
> Thanks.
> 
> Yeah. Probably best to just slowly phase those out in favor of
> tracepoints. Is there any way to do that that's less labor intensive?

No idea.

I'm hoping we can just get of some of them entirely, but I don't know, I
really haven't tried to look through them.

(I've just noticed that there's usually a ton of output, and recall it
interfering with testing in some cases--admittedly I might just be
remembering cases where someone was trying to use a slow serial
interface for logging.)

--b.
