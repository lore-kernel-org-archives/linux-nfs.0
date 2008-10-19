From: Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
Subject: mount.nfs should support arbitrary option order
Date: Sat, 18 Oct 2008 20:46:53 -0400 (EDT)
Message-ID: <alpine.LNX.1.10.0810182045380.17929@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:59065 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbYJSAq5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 18 Oct 2008 20:46:57 -0400
Received: from localhost (localhost [127.0.0.1])
	by sovereign.computergmbh.de (Postfix) with ESMTP id 2D2FA1C0989E2
	for <linux-nfs@vger.kernel.org>; Sat, 18 Oct 2008 20:46:54 -0400 (EDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,


currently it seems that mount.nfs only accepts -o as the last portion:


# mount.nfs -o foo a:/ /
usage: mount.nfs remotetarget dir [-rvVwfnsih] [-o nfsoptions]
options:
        -r              Mount file system readonly
        -v              Verbose
        -V              Print version
        -w              Mount file system read-write
        -f              Fake mount, do not actually mount
        -n              Do not update /etc/mtab
        -s              Tolerate sloppy mount options rather than fail
        -h              Print this help
        nfsoptions      Refer to mount.nfs(8) or nfs(5)

# mount.nfs  a:/ / -o foo
mount.nfs: an incorrect mount option was specified


It would be nice if options can be specified anywhere. Especially
hard POSIX puts options first.
