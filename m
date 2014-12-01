Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52685 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932150AbaLAT4k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Dec 2014 14:56:40 -0500
Date: Mon, 1 Dec 2014 14:56:37 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/10] sunrpc: fixes and cleanups for svc creation and
 thread handling
Message-ID: <20141201195636.GC30001@fieldses.org>
References: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
 <20141119213758.GE14207@fieldses.org>
 <20141119165957.04e6e9c2@tlielax.poochiereds.net>
 <546DF808.1000905@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <546DF808.1000905@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 20, 2014 at 09:17:44AM -0500, Anna Schumaker wrote:
> On 11/19/2014 04:59 PM, Jeff Layton wrote:
> > On Wed, 19 Nov 2014 16:37:58 -0500
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> >
> >> On Wed, Nov 19, 2014 at 07:51:12AM -0500, Jeff Layton wrote:
> >>> Patch #1 in this series is a bugfix, but probably isn't worth sending to
> >>> stable. The rest are just cleanups in preparation for some other patches
> >>> that I have queued up. Can you consider these for 3.19?
> >> Sure, I've read through them, they look fine.
> >>
> >> When I tried to apply them to my for-3.19 there were rejects due to
> >> tracing stuff in include/trace/events/sunrpc.h.  I haven't tried to
> >> investigate yet.
> >>
> >> --b.
> >>
> > Ahh yeah. These are based on top of the tracepoint patches I sent to
> > Trond a couple of weeks ago. I think he's planning to merge those in
> > 3.19 too, but I don't think he's done that yet. Anna may have though...
> 
> I have them in a private tree on my laptop that I use for testing.  Want me to push them out somewhere?

That'd help me at least test, but we need something more than a
temporary testing branch to get ready for the merge window.  Choices
include:

	- Trond merges them all now, I pull that and apply these on top.
	- I merge them instead, or we divide the patches between us
	  somehow.  Worst case, it's probably even OK if there's a patch
	  or two that we both apply.

In any case we need to get that sorted out now-ish as the merge window's
probably starting next week.

--b.
