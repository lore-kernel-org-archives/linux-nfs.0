From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/3] NFS: SETCLIENTID truncates client ID and netid
Date: Thu, 25 Sep 2008 13:00:51 -0400
Message-ID: <20080925170051.GB31775@fieldses.org>
References: <20080925154814.8353.64762.stgit@manray.1015granger.net> <20080925155712.8353.47707.stgit@manray.1015granger.net> <1222359026.13388.8.camel@localhost> <20080925165821.GA31775@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45588 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752099AbYIYRAx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Sep 2008 13:00:53 -0400
In-Reply-To: <20080925165821.GA31775@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 25, 2008 at 12:58:21PM -0400, bfields wrote:
> On Thu, Sep 25, 2008 at 12:10:26PM -0400, Trond Myklebust wrote:
> > ACK. I'll take this patch, but should Bruce take the other 2? I believe
> > he should already have other changes to rpcb_clnt.c in his tree...
> 
> Yes I do; I'll take a look.  (My goal is to get through my backlog from
> Trond this afternoon....)

(err, I meant "Chuck" not "Trond" there.  You guys are so hard to tell
apart, ya know.)

--b.

> 
> I recall one remaining uncertainty about the patches already in my
> for-2.6.28: they allow building either a kernel that supports nfs/ipv6,
> or a kernel that works with older nfs-utils, but not both.
> 
> I'd prefer a stricter level of backwards compatibility.  The current
> approach may be confusing to distributors, early adopters, and testers.
> But I'm willing to settle for it and let it be a lesson to us if it
> turns out to cause more problems than expected.
> 
> Talking to Trond the other day he asked why we couldn't use
> PROG_MISMATCH (unsupported program version) error to fall back.  Chuck
> says in the changelog comment:
> 
> 	"I tried adding some automatic logic to fall back if registering
> 	with a v4 protocol request failed, but there are too many corner
> 	cases."
> 
> Which I can believe, though I haven't looked at it myself.
> 
> In any case I'd like Trond's ACK or NACK.
> 
> --b.
