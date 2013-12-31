Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44968 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754838Ab3LaUwH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Dec 2013 15:52:07 -0500
Subject: Re: should we change how the kernel detects whether gssproxy is
 running?
From: Simo Sorce <simo@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
In-Reply-To: <20131231180123.GA12875@fieldses.org>
References: <20131231073300.0e0f220a@tlielax.poochiereds.net>
	 <20131231180123.GA12875@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 31 Dec 2013 15:52:00 -0500
Message-ID: <1388523120.26102.9.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-12-31 at 13:01 -0500, J. Bruce Fields wrote:
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

Well if gss-proxy is not running it will fail anyway right ?
We have 90s before nfsd starts receiving incoming calls at startup
right ? Isn't that enough to guarantee whatever the admin configured to
start is started ? If gss-proxy is dead for whatever reason a failure
will happen anyway now, esp because rpc.gssd will most probably not be
running anyway if the admin configured gss-proxy instead ...

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

