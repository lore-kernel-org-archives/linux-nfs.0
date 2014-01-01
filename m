Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53248 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753929AbaAAMVP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Jan 2014 07:21:15 -0500
Date: Wed, 1 Jan 2014 07:21:10 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Simo Sorce <simo@redhat.com>, linux-nfs@vger.kernel.org, neilb@suse.de
Subject: Re: should we change how the kernel detects whether gssproxy is
 running?
Message-ID: <20140101072110.517c73ec@tlielax.poochiereds.net>
In-Reply-To: <20131231180123.GA12875@fieldses.org>
References: <20131231073300.0e0f220a@tlielax.poochiereds.net>
	<20131231180123.GA12875@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 31 Dec 2013 13:01:23 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Dec 31, 2013 at 07:33:00AM -0500, Jeff Layton wrote:
> > I'm a bit concerned with how /proc/net/rpc/use-gss-proxy works...
> > 
> > For one thing, when the kernel first boots any read against that file
> > hangs. That's going to be extremely problematic for certain tools that
> > scrape info out of /proc for troubleshooting purposes (e.g. Red Hat's
> > sosreport tool).
> 
> Is that the only file under /proc for which that's true?  (E.g. the rpc
> cache channel files probably do the same, don't they?)  I was assuming
> tools like sosreport need to work from lists of specific paths.
> 
> > Also, it seems like if gssproxy suddenly dies, then this switch stays
> > stuck in its position. There is no way switch back after enabling
> > gssproxy.
> 
> That's true.  I didn't think the ability to change on the fly was
> necessary (but I'll admit it's annoying when debugging at least.)
> 
> > All of that seems unnecessarily complicated. Is there some rationale
> > for it that I'm missing?
> > 
> > Would it instead make more sense to instead just have gssproxy
> > hold a file open under /proc? If the file is being held open, then
> > send upcalls to gssproxy. If not then use the legacy code.
> 
> The kernel code needs to know which way to handle an incoming packet at
> the time it arrives.  If it falls back on the legacy upcall that means
> failing large init_sec_context calls.  So a delayed gss-proxy start (or
> a crash and restart) would mean clients erroring out (with fatal errors
> I think, not just something that would be retried).
> 

Now that I look at the code, I'm not sure this is really doing what you
intend. The kernel upcall code immediately falls back on the legacy
code if gssproxy isn't up when the RPCs come in.

The only thing that seems to wait for that is reads from the
use-gss-proxy file, which doesn't make a lot of sense to me. AFAICT,
only gssproxy itself opens that file and all it does it write to it.

RFC patchset forthcoming. Probably best we continue the discussion there...

-- 
Jeff Layton <jlayton@redhat.com>
