Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36989 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756416Ab3AOU40 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2013 15:56:26 -0500
Date: Tue, 15 Jan 2013 15:56:25 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mark Lord <kernel@teksavvy.com>
Cc: linux-nfs@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921
Message-ID: <20130115205625.GH4940@fieldses.org>
References: <50F42F85.50907@teksavvy.com>
 <20130114203711.GA29982@fieldses.org>
 <50F4D800.5040703@teksavvy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50F4D800.5040703@teksavvy.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 14, 2013 at 11:16:00PM -0500, Mark Lord wrote:
> On 13-01-14 03:37 PM, J. Bruce Fields wrote:
> > Thanks for the report.
> > 
> > On Mon, Jan 14, 2013 at 11:17:09AM -0500, Mark Lord wrote:
> >> Since upgrading to 3.7, and now 3.7.2, my AMD-450E based server
> > 
> > It's acting as an NFS client, right?
> 
> Client and server, with other Linux boxes all running 3.something kernels.
> 
> > What did you upgrade from?
> 
> 3.4.something, I believe.
> 
> >> is getting these BUG complaints.  The .config file is gzip'd/attached.
> > 
> > Is this easy to reproduce?
> 
> So far, it seems to pop up within a day or so of any reboot.
> I normally only reboot that system for a kernel upgrade,
> but can do so a bit more often if there's useful info to collect.

So this means svc_delete_xprt was called on an xprt twice.

That could happen if server threads are still running (and calling
svc_recv) after we start shutting down the server: svc_shutdown_net
assumes that server threads are already shut down, but that isn't true
any more after the containerization work.

I thought that would only be a bug for users actually running multiple
containers, but looking at nfs_callback_down, I don't think that's
true--it seems to always shut down the thread last.

--b.
