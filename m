From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Should truncated READDIR replies return -EIO?
Date: Fri, 08 Feb 2008 11:13:07 -0500
Message-ID: <1202487187.10337.25.camel@heimdal.trondhjem.org>
References: <1202483082-5334-1-git-send-email-jlayton@redhat.com>
	 <1202483596.8914.13.camel@heimdal.trondhjem.org>
	 <20080208105659.3bfb8a6b@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:38939 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757419AbYBHQNL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Feb 2008 11:13:11 -0500
In-Reply-To: <20080208105659.3bfb8a6b-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Fri, 2008-02-08 at 10:56 -0500, Jeff Layton wrote:

> If it looks like the above, but EOF is 0, then we *do* "goto
> short_pkt", and that case would be affected by this. But in that case
> we currently reset EOF to 1. The client won't retry the request. I'm
> not sure that's what we want to do either...

That is to deal with the afore-mentioned broken server. I'm not
unwilling to change this (I _hate_ client side fixes for server bugs),
but it's important to note that there may be consequences if we do.

Cheers
  Trond

