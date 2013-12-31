Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55982 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753937Ab3LaSB3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Dec 2013 13:01:29 -0500
Date: Tue, 31 Dec 2013 13:01:23 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Simo Sorce <simo@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: should we change how the kernel detects whether gssproxy is
 running?
Message-ID: <20131231180123.GA12875@fieldses.org>
References: <20131231073300.0e0f220a@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131231073300.0e0f220a@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 31, 2013 at 07:33:00AM -0500, Jeff Layton wrote:
> I'm a bit concerned with how /proc/net/rpc/use-gss-proxy works...
> 
> For one thing, when the kernel first boots any read against that file
> hangs. That's going to be extremely problematic for certain tools that
> scrape info out of /proc for troubleshooting purposes (e.g. Red Hat's
> sosreport tool).

Is that the only file under /proc for which that's true?  (E.g. the rpc
cache channel files probably do the same, don't they?)  I was assuming
tools like sosreport need to work from lists of specific paths.

> Also, it seems like if gssproxy suddenly dies, then this switch stays
> stuck in its position. There is no way switch back after enabling
> gssproxy.

That's true.  I didn't think the ability to change on the fly was
necessary (but I'll admit it's annoying when debugging at least.)

> All of that seems unnecessarily complicated. Is there some rationale
> for it that I'm missing?
> 
> Would it instead make more sense to instead just have gssproxy
> hold a file open under /proc? If the file is being held open, then
> send upcalls to gssproxy. If not then use the legacy code.

The kernel code needs to know which way to handle an incoming packet at
the time it arrives.  If it falls back on the legacy upcall that means
failing large init_sec_context calls.  So a delayed gss-proxy start (or
a crash and restart) would mean clients erroring out (with fatal errors
I think, not just something that would be retried).

--b.

> That way the upcalls would truly be conditional on whether gssproxy is
> running...
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
