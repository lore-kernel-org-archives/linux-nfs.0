From: Whoop Whouzer <tiredandnumb@gmail.com>
Subject: nfs client performance while server is down
Date: Sat, 23 Jan 2010 16:45:22 +0100
Message-ID: <d7f0b3a81001230745h18dbb14fi42f28adff0c45294@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:63015 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753044Ab0AWPwH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Jan 2010 10:52:07 -0500
Received: by ewy26 with SMTP id 26so408200ewy.28
        for <linux-nfs@vger.kernel.org>; Sat, 23 Jan 2010 07:52:03 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Howdy,

I was wondering why nfs is designed in such a way that the performance
of an nfs client machine gets very bad when the nfs server is offline?
This is even the case with a soft mount (either via mount or fstab).
Just about every application that requires disk access (not talking
about nfs share acces) gets really slow to unresponsive. For instance
nautilus becomes unresponsive when displaying the contents of any
folder on the local disk,
playing movie files (stored on local disk) let totem or vlc get stuck
on set intervals, even the terminal becomes unresponsive at times.

I could understand that these problems would occur while accessing the
nfs share directory while the server is offline, but why for totally
unrelated directories?

I have experienced this behaviour on various distro's, and also found
various bug reports on this issue, they don't seem to get solved as
this is viewed as nfs design.
I see this as a flaw because clients are totally dependent on the
server. This would be less of a deal if the entire home directory
would be stored on nfs (although I even think some sort of
synchronisation technology could and should be implemented in this
case). It is a bit odd that (technically) one machine serving some
"useless" files to a non-trivial directory on client machines can take
down these client machines.

For me the preferred functionality would be:
*If an nfs server gets offline the client's nfs share becomes
unaccessible, but local directories and applications (that only
require local disk access) stay responsive.
*If an nfs server gets online (after being offline while the client
has not been restarted) the nfs share becomes reconnected.

regards,
Whoop
