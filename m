Return-Path: linux-nfs-owner@vger.kernel.org
Received: from whm03.asteroidpc.com ([204.191.218.7]:55439 "EHLO
	whm03.asteroidpc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754839AbaGIUPF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jul 2014 16:15:05 -0400
Received: from [207.228.103.62] (port=38941 helo=[10.10.1.156])
	by whm03.asteroidpc.com with esmtpsa (TLSv1:DHE-RSA-AES128-SHA:128)
	(Exim 4.82)
	(envelope-from <mail@nathanshearer.ca>)
	id 1X4yGe-0003hG-5o
	for linux-nfs@vger.kernel.org; Wed, 09 Jul 2014 14:15:04 -0600
Message-ID: <53BDA2C7.4030007@nathanshearer.ca>
Date: Wed, 09 Jul 2014 14:15:03 -0600
From: Nathan Shearer <mail@nathanshearer.ca>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: umount -f stalls forever
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When I have an nfs share that is mounted with the hard option (either
explicitly or implicitly since hard is on by default), and the nfs
server becomes unresponsive for any reason, it often causes the entire
OS to hang on many operations. In some cases I cannot even reboot a
server depending on what the nfs share was used for.

I relaize that this was probably done intentionally to prevent data
loss. However, when I am cleaning up a disaster and I actually do want
to "umount -f" a stalled nfs share and data loss es acceptable, then I
expect that command to return and the share to be unmounted. From a
usability perspective, stalling forever when I am explicitly forcing an
action is not right.

There is a workaround: and that is to assign the IP of the nfs server to
my system then issue umount -f, however that hardly the best way since I
am changing my network topology to unmount an offline filesystem. In
some situations adding an IP to an interface is not possilble, and if
the system is a remote system it could lead to more problems since it is
mostly unresponsive.

It would be greatly appreciated if a patch could be introduced that
allows "umount -f" to actually work without making any other changes to
a running system. The man page for umount even states that the -f
argument can be used to unmount an unreachable nfs share -- but it
almost never works.
