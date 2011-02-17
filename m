Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:41753 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753537Ab1BQXoT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Feb 2011 18:44:19 -0500
Date: Fri, 18 Feb 2011 00:44:18 +0100 (CET)
From: Jan Engelhardt <jengelh@medozas.de>
To: linux-nfs@vger.kernel.org
cc: kzak@redhat.com
Subject: umount.nfs4 is disturbed by /proc/mounts
Message-ID: <alpine.LNX.2.01.1102180041530.20379@obet.zrqbmnf.qr>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Recent distributions start to have /etc/mtab being a symlink to 
/proc/mounts with util-linux 2.19. Subsequently, this annoys umount.nfs4 
from nfs-client-1.2.3 and emits a warning:

jng-0:/ # grep nfs4 /proc/mounts
10.10.1.1:/home/ /home nfs4 rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=10.10.1.212,minorversion=0,local_lock=none,addr=10.10.1.1 0 0
jng-0:/ # umount /home
umount.nfs4: invalid value for 'port=' option


