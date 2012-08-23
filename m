Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49997 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758894Ab2HWOqG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Aug 2012 10:46:06 -0400
Date: Thu, 23 Aug 2012 10:46:05 -0400
To: Norbert Aschendorff <norbert.aschendorff@yahoo.de>
Cc: linux-nfs@vger.kernel.org, Rick Macklem <rmacklem@uoguelph.ca>
Subject: Re: NFSv4, Name (string) mapping vs. raw UID, idmapd and Kernels
 >= 3.3
Message-ID: <20120823144605.GA6923@fieldses.org>
References: <5035F619.80809@yahoo.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5035F619.80809@yahoo.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adding Rick to the cc:

On Thu, Aug 23, 2012 at 11:21:29AM +0200, Norbert Aschendorff wrote:
> I recently opened a thread on freebsd-stable about problems with the
> mapping of UIDs to user strings (user@domain form) in NFSv4 packets
> running newer kernels:
> [http://www.mail-archive.com/freebsd-stable@freebsd.org/index.html#122549]
> In
> [http://www.mail-archive.com/freebsd-stable@freebsd.org/msg122571.html],
> Rick says that the described issue may be related to the NFSv4/NFSv4.1
> RFCs which deny/allow sending "raw" numeric UIDs (1000 instead of
> "user@domain").
> The problem is that Linux kernels newer than 3.2 (the last working
> kernel, on both Debian and Fedora; I've tested 3.3, 3.4 and 3.5) send
> these numeric UIDs/GIDs [1] which, as it's described in the mentioned
> email, may be convenient when mounting NFSv4 filesystems as root
> filesystem (at a point where an idmapd/nfsuserd (on FreeBSD) isn't
> already running) and numeric UIDs/GIDs are required (because of the
> early stage)
> Now it could be that Kernels newer than 3.2 (>= 3.3) support this
> feature (which is said to appear in NFSv4.1) already - and FreeBSD 9.0
> does not (it shows 32767 as UID - due to that I discovered this issue; a
> Fedora 17/k3.5 system supports the numeric UIDs/GIDs without any problems).

Yes, newer linux servers by default do return numeric ID's (unless
kerberos is used).

> --> 1. Is this assumption correct? Or is it a bug as filed here:
> [https://bugzilla.novell.com/show_bug.cgi?id=756897]

That's slightly different, as it concerns a *client* sending numeric
id's to a server.  The client should in that case be falling back on the
old behavior, and if that's not working there's some other bug.

> --> 2. As Rick says finally in
> [http://www.mail-archive.com/freebsd-stable@freebsd.org/msg122572.html],
> it would be cool if this behavior was tunable. Is it tunable via options
> in /etc/exports? Or in idmapd.conf? (The man pages don't describe such
> directives (at least at the first look)).

It's tunable via the nfsd module's "nfs4_disable_idmapping" parameter.
So, for example,

	echo "N" > /sys/module/nfsd/parameters/nfs4_disable_idmapping

should return the server to its old behavior.

"Y" was made the default because even the old rfc 3530 language allowed
servers to return numeric ID's, so we assumed correct clients would need
to be prepared for them.

It may be the server-side default was too aggressive and needs to be
changed, but we'd also like to make sure that clients are fixed.

--b.
