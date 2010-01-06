From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/3] nfs-utils: add testing infrastructure to nfs-utils
	(try #3)
Date: Wed, 6 Jan 2010 14:58:19 -0500
Message-ID: <20100106195819.GH6612@fieldses.org>
References: <1262706035-4929-1-git-send-email-jlayton@redhat.com> <20100106191706.GE6612@fieldses.org> <20100106144247.18dc10de@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steved@redhat.com, chuck.lever@oracle.com,
	linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49004 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755945Ab0AFT5m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 14:57:42 -0500
In-Reply-To: <20100106144247.18dc10de-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 06, 2010 at 02:42:47PM -0500, Jeff Layton wrote:
> On Wed, 6 Jan 2010 14:17:06 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > This probably just shows I'm not reading carefully, but: are you
> > requiring root, and messing with their existing nfs configuration at
> > all?
> > 
> > For the export stuff it would also be great to have some tests that set
> > up a few dummy exports (using tmpfs?) and tried to mount them (just over
> > loopback), but I'd be afraid someone would try to run "make check" on
> > their production server.  So I'm not sure where to put that kind of
> > test.
> > 
> 
> The script I have so far doesn't check for root privs, but it won't
> work unless you have them since statd will fail to start. statd
> currently requires root privs to start though it does drop them soon
> afterward.
> 
> I'm open to suggestions on changing this as I'm not crazy about that
> either.

My feeling is that it will be hard to find a realistic way to test
everything without having root and taking over the machine to some
degree.

Just so long as the user understands whether it needs to be run as root,
whether it's safe to be run on a host connected to the network, etc....
I don't know if 'make check' is the right ui for that.

--b.
