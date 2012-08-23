Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm32-vm4.bullet.mail.ne1.yahoo.com ([98.138.229.52]:39241 "HELO
	nm32-vm4.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758187Ab2HWJ2A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Aug 2012 05:28:00 -0400
Message-ID: <5035F619.80809@yahoo.de>
Date: Thu, 23 Aug 2012 11:21:29 +0200
From: Norbert Aschendorff <norbert.aschendorff@yahoo.de>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFSv4, Name (string) mapping vs. raw UID, idmapd and Kernels >= 3.3
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,
I recently opened a thread on freebsd-stable about problems with the
mapping of UIDs to user strings (user@domain form) in NFSv4 packets
running newer kernels:
[http://www.mail-archive.com/freebsd-stable@freebsd.org/index.html#122549]
In
[http://www.mail-archive.com/freebsd-stable@freebsd.org/msg122571.html],
Rick says that the described issue may be related to the NFSv4/NFSv4.1
RFCs which deny/allow sending "raw" numeric UIDs (1000 instead of
"user@domain").
The problem is that Linux kernels newer than 3.2 (the last working
kernel, on both Debian and Fedora; I've tested 3.3, 3.4 and 3.5) send
these numeric UIDs/GIDs [1] which, as it's described in the mentioned
email, may be convenient when mounting NFSv4 filesystems as root
filesystem (at a point where an idmapd/nfsuserd (on FreeBSD) isn't
already running) and numeric UIDs/GIDs are required (because of the
early stage)
Now it could be that Kernels newer than 3.2 (>= 3.3) support this
feature (which is said to appear in NFSv4.1) already - and FreeBSD 9.0
does not (it shows 32767 as UID - due to that I discovered this issue; a
Fedora 17/k3.5 system supports the numeric UIDs/GIDs without any problems).

--> 1. Is this assumption correct? Or is it a bug as filed here:
[https://bugzilla.novell.com/show_bug.cgi?id=756897]

--> 2. As Rick says finally in
[http://www.mail-archive.com/freebsd-stable@freebsd.org/msg122572.html],
it would be cool if this behavior was tunable. Is it tunable via options
in /etc/exports? Or in idmapd.conf? (The man pages don't describe such
directives (at least at the first look)).

regards,
Norbert

PS: Unfortunately, I do not have got any experience in kernel hacking (yet).

Refs:
[1] If no one has got an idea about what I talk about, here are some
NFSv4 packets with the mentioned numeric UIDs/GIDs:
[http://lbo.spheniscida.de/Files/nfs.pcap]
