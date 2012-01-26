Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:11763 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751497Ab2AZThG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 14:37:06 -0500
Date: Thu, 26 Jan 2012 14:36:59 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 09/11] nfsdcld: reopen pipe if it's deleted and
 recreated
Message-ID: <20120126143659.74a9de30@tlielax.poochiereds.net>
In-Reply-To: <20120126185859.GA31531@fieldses.org>
References: <20120125140954.5312a80f@tlielax.poochiereds.net>
	<4F20587E.9070209@RedHat.com>
	<20120125152814.391ae064@tlielax.poochiereds.net>
	<4F207C7C.4090207@RedHat.com>
	<20120125183206.5efcd845@corrin.poochiereds.net>
	<4F214B77.8050300@RedHat.com>
	<20120126082830.23324255@corrin.poochiereds.net>
	<20120126093059.5c732d75@corrin.poochiereds.net>
	<4F2171B5.2030103@RedHat.com>
	<20120126104157.671a10c2@corrin.poochiereds.net>
	<20120126185859.GA31531@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 26 Jan 2012 13:58:59 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Jan 26, 2012 at 10:41:57AM -0500, Jeff Layton wrote:
> > Correct. When knfsd starts back up, a new pipe will be created. At that
> > point, the daemon will try to open the new one and will then close the
> > old if the open succeeds. It will only loop here if that open fails for
> > some reason.
> 
> I'm a little confused--how could this happen?
> 

Bugs?

> If it's because of something like knfsd stopping and restarting again
> (and the pipe diseappearing and reappering), then we should get another
> inotify event, and can handle the problem then.
> 

That's exactly what happens already. When the pipe is recreated, we get
an inotify event, and then attempt to reopen the pipe. I have that
attempt inside of a while loop so that if it fails, we'll reattempt
until it works.

It's highly unlikely that that would fail if the original open worked,
but it's best to account for the possibility and attempt to handle it
gracefully.

-- 
Jeff Layton <jlayton@redhat.com>
