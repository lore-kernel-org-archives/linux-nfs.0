Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39439 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753385AbaACWey (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Jan 2014 17:34:54 -0500
Date: Fri, 3 Jan 2014 17:34:51 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org, neilb@suse.de
Subject: Re: [RFC PATCH 1/5] sunrpc: don't wait for write before allowing
 reads from use-gss-proxy file
Message-ID: <20140103223451.GE5164@fieldses.org>
References: <1388579314-15255-1-git-send-email-jlayton@redhat.com>
 <1388579314-15255-2-git-send-email-jlayton@redhat.com>
 <20140102212149.GC28219@fieldses.org>
 <20140102172651.559eaa48@tlielax.poochiereds.net>
 <20140102224009.GF28219@fieldses.org>
 <20140102182746.547964c0@tlielax.poochiereds.net>
 <1388736843.26102.33.camel@willson.li.ssimo.org>
 <20140103162319.GK28219@fieldses.org>
 <1388786760.26102.65.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1388786760.26102.65.camel@willson.li.ssimo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 03, 2014 at 05:06:00PM -0500, Simo Sorce wrote:
> I'd like to use sd_notify, but preferred a more conservative approach
> for wider distribution portability.
> 
> Patch here waiting for review upstream:
> http://fedorapeople.org/cgit/simo/public_git/gss-proxy.git/commit/?h=usermode&id=ddc5eb950bbd2050dc76b4783f3d3383cd89bccf

Thanks.  If it's not too much verbage, it might be helpful to document
the reason for the ordering; something like:

	/*
	 * We need to tell nfsd gss-proxy is available before it starts,
	 * as nfsd may need to know this the moment it receives the
	 * first init_sec_context call.
	 *
	 * So now it is safe to tell the init system that we're done
	 * starting up and that it can continue with nfsd startup.
	 */

?

--b.
