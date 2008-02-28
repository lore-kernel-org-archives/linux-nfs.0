From: Frans Pop <elendil@planet.nl>
Subject: [regression] nfs4: 30 second delay during umount of remote fs on system shutdown
Date: Thu, 28 Feb 2008 18:29:15 +0100
Message-ID: <200802281829.16343.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Cc: linux-kernel@vger.kernel.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760108AbYB1R32@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With 2.6.25-rc2 and -rc3 I noticed a pause of 30 seconds when my system 
(Debian unstable, x86_64) is being shutdown. The cause is the unmounting of 
an nfs4 remote file system.
The pause does not happen with 2.6.24. I'm unsure about 2.6.25-rc1 as I was 
concentrating on other issues when I was testing that.

I can reproduce the same pause on an active system by stopping portmap 
before doing an umount of the filesystem.

The shutdown sequence on my box includes:
K20nfs-common
[...]
S20sendsigs
[...]
S31umountnfs.sh
S32portmap

So it seems that things should be OK (S32portmap is after S31umountnfs.sh), 
but in fact portmap has already been killed during S20sendsigs!

I have verified that portmap is also not running during S31umountnfs.sh with 
2.6.24, so apparently there has been a change in the kernel that has made 
umount look for portmap and cause the 30 second delay if it is not running.

Is this a kernel regression?

Cheers,
FJP
