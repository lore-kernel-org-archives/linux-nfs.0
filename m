From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch 10/14] sunrpc: Reorganise the queuing of cache upcalls.
Date: Fri, 9 Jan 2009 16:41:46 -0500
Message-ID: <20090109214146.GE5466@fieldses.org>
References: <20090108082510.050854000@sgi.com> <20090108082604.517918000@sgi.com> <20090108195747.GB19312@fieldses.org> <4966B92F.8060008@melbourne.sgi.com> <20090109212921.GC5466@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:36906 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324AbZAIVlr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Jan 2009 16:41:47 -0500
In-Reply-To: <20090109212921.GC5466@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 09, 2009 at 04:29:21PM -0500, bfields wrote:
> On Fri, Jan 09, 2009 at 01:40:47PM +1100, Greg Banks wrote:
> > A smaller issue is that you keep a single list and use the value of the
> > CACHE_PENDING bit to tell the difference between states.  I think this
> > could be made to work; however my technique of using two lists makes
> > most of the code even simpler at the small cost of having to do two list
> > searches in queue_loose().
> 
> OK.  When exactly do they get moved between lists?  I'll take a look at
> the code.

The one thing I'd be curious about here would be robustness in the face
of a userland daemon that was restarted: would requests marked as read
but not responded to be stuck there indefinitely at the time the daemon
went down?  That wouldn't be fatal, since if nothing else the client
will retry eventually, but it might lead to some unnecessary delays if
the admin needed to restart a daemon for some reason.

--b.
