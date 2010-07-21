Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tango.0pointer.de ([85.214.72.216]:49817 "EHLO
	tango.0pointer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758788Ab0GUV5G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jul 2010 17:57:06 -0400
Date: Wed, 21 Jul 2010 23:56:40 +0200
From: Lennart Poettering <lennart@poettering.net>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpcbind: add support for systemd socket activation
Message-ID: <20100721215640.GA5648@tango.0pointer.de>
References: <20100719021906.GA16939@tango.0pointer.de>
 <4C4734DC.9010106@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C4734DC.9010106@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 21.07.10 13:56, Chuck Lever (chuck.lever@oracle.com) wrote:

> Why aren't sd-daemon.[ch] part of a systemd related library?  They
> seem pretty generic to me, and could be useful for other daemons.

Well, these two files are simply a reference implementation. The
algorithms are as trivial as they can get. For now we decided to simply
ask people to include the ref impl in their sources. Either the .c/.h
file or just the function needed. This is usually easier to get accepted
politically since this will then not add a new dependency to the
packages. Maybe one day when the number of APIs we provide are
substantial enough and the algorithms not trivial anymore we will add a
real library for this.

But for now, if people just add this tiny bit of code to their sources
this will be a feature that finds it way silently into the various
packages without requiring any new dependencies, and people will hence
have little reason to disable it.

> Plus, the newly introduced update-systemd Makefile target seems to
> suggest these won't be stable over time.  Wouldn't it be better to
> have a versioned library, external to rpcbind, with this code in it?

Well, the functions are trivial. I see little need to ever update them
unless sombody really wants new functionality.

Or to put this all in other words: the ABI/API that matters for the
socket activation are the execution semantics, and the two env vars
LISTEN_FDS and LISTEN_PID, it is not the C implementation we offer
people -- which does little more than parse those two env vars.

Or to put it in even other words: package maintainers are easily
convinced of merging support for this if we don't ask them to add an
additional dependency (which then would have to be ifdeffed) just for
the sake of parsing two env vars!

Lennart

-- 
Lennart Poettering - Red Hat, Inc.
