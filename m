From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH  7/17] svcrdma: Fix error handling during listening
	endpoint creation
Date: Tue, 6 May 2008 17:22:49 -0400
Message-ID: <20080506212249.GN13484@fieldses.org>
References: <20080505224140.GI12814@fieldses.org> <C445D9D6.4AB49%tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:51780 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933293AbYEFVWu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 17:22:50 -0400
In-Reply-To: <C445D9D6.4AB49%tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 06, 2008 at 09:48:06AM -0500, Tom Tucker wrote:
> 
> 
> 
> On 5/5/08 5:41 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Fri, May 02, 2008 at 11:28:39AM -0500, Tom Tucker wrote:
> >> A listening endpoint isn't known to the generic transport switch until
> >> the svc_create_xprt function returns without error. Calling
> >> svc_xprt_put within the xpo_create function causes the module reference
> >> count to be erroneously decremented.
> > 
> > There's some redundant code in these three error paths; would the usual
> > kernel-style "goto cleanup" thing help?
> 
> I think code-size it's a wash, but it might look more familiar.

Yeah, we try to stick to the same idioms as used elsewhere when it's
easy to.

Doesn't have to be done now, though.

> BTW, I noticed that the error path above returns a positive errno :-\,
> so that needs to be fixed too.

Oops, didn't catch that.  I'll expect a patch?

--b.
