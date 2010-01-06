From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/3] nfs-utils: add testing infrastructure to nfs-utils
 (try #3)
Date: Wed, 6 Jan 2010 14:42:47 -0500
Message-ID: <20100106144247.18dc10de@tlielax.poochiereds.net>
References: <1262706035-4929-1-git-send-email-jlayton@redhat.com>
	<20100106191706.GE6612@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: steved@redhat.com, chuck.lever@oracle.com,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25112 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756034Ab0AFTm6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 14:42:58 -0500
In-Reply-To: <20100106191706.GE6612@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 6 Jan 2010 14:17:06 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Tue, Jan 05, 2010 at 10:40:32AM -0500, Jeff Layton wrote:
> > This is an updated patchset for adding test infrastructure to nfs-utils.
> > The main differences from the last patchset are:
> > 
> > 1) renamed "statdtest" to "nsm_client", since that's a bit more
> > descriptive of its actual purpose.
> > 
> > 2) added a very simple "statdb_dump" program that dumps out the more
> > interesting fields of the of the NSM monitor DB. The inital mon/unmon
> > test now uses that program to verify the contents of the DB after the
> > MON call.
> > 
> > This patchset is intended as a starting point for an automated test
> > suite for nfs-utils. The idea here is to start simply and add a suite of
> > tests that we can run via "make check" -- the standard automake method
> > for running tests.
> > 
> > Clearly there are limits to what we can test without a multi-host test
> > harness.
> 
> This probably just shows I'm not reading carefully, but: are you
> requiring root, and messing with their existing nfs configuration at
> all?
> 
> For the export stuff it would also be great to have some tests that set
> up a few dummy exports (using tmpfs?) and tried to mount them (just over
> loopback), but I'd be afraid someone would try to run "make check" on
> their production server.  So I'm not sure where to put that kind of
> test.
> 

The script I have so far doesn't check for root privs, but it won't
work unless you have them since statd will fail to start. statd
currently requires root privs to start though it does drop them soon
afterward.

I'm open to suggestions on changing this as I'm not crazy about that
either.

-- 
Jeff Layton <jlayton@redhat.com>
