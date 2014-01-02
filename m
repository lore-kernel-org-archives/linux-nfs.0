Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40031 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752270AbaABSzW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Jan 2014 13:55:22 -0500
Date: Thu, 2 Jan 2014 13:55:19 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Jeff Layton <jlayton@redhat.com>, Simo Sorce <simo@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: should we change how the kernel detects whether gssproxy is
 running?
Message-ID: <20140102185519.GL25684@fieldses.org>
References: <20131231073300.0e0f220a@tlielax.poochiereds.net>
 <20131231180123.GA12875@fieldses.org>
 <20140101095620.0ab48051@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140101095620.0ab48051@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 01, 2014 at 09:56:20AM +1100, NeilBrown wrote:
> On Tue, 31 Dec 2013 13:01:23 -0500 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Tue, Dec 31, 2013 at 07:33:00AM -0500, Jeff Layton wrote:
> > > I'm a bit concerned with how /proc/net/rpc/use-gss-proxy works...
> > > 
> > > For one thing, when the kernel first boots any read against that file
> > > hangs. That's going to be extremely problematic for certain tools that
> > > scrape info out of /proc for troubleshooting purposes (e.g. Red Hat's
> > > sosreport tool).
> > 
> > Is that the only file under /proc for which that's true?  (E.g. the rpc
> > cache channel files probably do the same, don't they?)  I was assuming
> > tools like sosreport need to work from lists of specific paths.
> 
> The rpc cache channel files do not block on reads, so 'cat' works well on
> them.
> A process (like mountd) that wasn't to see new additions will use select (or
> poll) for an 'exception' condition, and then read.
> 
> I think that it is best of all files in /proc (or /sys) would support 'cat'.
> If I "tar" up "/proc" on my notebook it doesn't block ... though it does take
> quite a while on /proc/kcore :-)

Yes, trying that myself, I see the delay reading kcore, a bunch of "file
removed before we read it"/"file changed as we read it" errors (not too
surprising), EBUSY on /proc/acpi/event, and a few permission errors.

So yes letting a /proc read hang looks like a bug, my bad.

--b.
