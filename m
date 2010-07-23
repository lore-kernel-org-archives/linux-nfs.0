Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tango.0pointer.de ([85.214.72.216]:58116 "EHLO
	tango.0pointer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759726Ab0GWQ2Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jul 2010 12:28:16 -0400
Date: Fri, 23 Jul 2010 18:27:47 +0200
From: Lennart Poettering <lennart@poettering.net>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpcbind: add support for systemd socket activation
Message-ID: <20100723162746.GA4509@tango.0pointer.de>
References: <20100719021906.GA16939@tango.0pointer.de>
 <4C4734DC.9010106@oracle.com>
 <20100721215640.GA5648@tango.0pointer.de>
 <4C49B1AD.3060302@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C49B1AD.3060302@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 23.07.10 11:13, Chuck Lever (chuck.lever@oracle.com) wrote:

> >But for now, if people just add this tiny bit of code to their sources
> >this will be a feature that finds it way silently into the various
> >packages without requiring any new dependencies, and people will hence
> >have little reason to disable it.
> 
> The complexity or size of the systemd code is not the issue, it is
> how it will be maintained going forward.  Especially since these are
> all system daemons, you know that there will be security bug fixes.

In code that simply parses two environment variables with strtol(), how
likely is it to encounter a security issue in this?

> The least you could do is provide both the raw source files and a
> library implementation, and let daemon maintainers choose which they
> prefer.  The best solution would provide a clean versioned C
> language API via a shared library

Hmm, providing both is indeed an idea. However, we currently hide the
symbols sd-daemon.[ch] exports when linking for good reasons. Now, if we
supported both an .so and the drop-in code, then we'd have the same
symbols once exported and once not. That's a weird kind of namespace
clash...

But anyway, we'll think about this and most likely add this sooner or
later. However, if possible I'd very muhc prefer to use the drop-in code
for now, if that's ok? I promise I'll prepare the patch that moves
rpcbind to the the .so API as soon as we provide that ;-).

> Do you have some picture of systemd adoption outside of Fedora?

All bigger distributions have it (with one exception, see below). Some
smaller distros made it the default already. Some folks at Suse are
working on making it the default in their next release. Meego has folks
working on something like this too.

So basically, everybody who could adopt it has it at least packaged or
is already on the path to making it the default -- with one exception:
Ubuntu. The Upstart developer works for Canonical, so go figure. He was
vaguely interested in adopting socket-based activation in Upstart too,
but so far nothing has shown up. We have discussed with him whether he
then would be willing to adopt the same interface systemd uses for
socket activation. This petered out without result, but given that the
interface we came up with is really trivial and we tried our best to
keep this independent of systemd and already supported in quite a number
of software our hope is that eventually he'll adopt this scheme too.

Lennart

-- 
Lennart Poettering - Red Hat, Inc.
