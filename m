Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63740 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754654AbaIZOFI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2014 10:05:08 -0400
Message-ID: <54257293.2060604@RedHat.com>
Date: Fri, 26 Sep 2014 10:05:07 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
CC: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: ANNOUNCE: nfs-utils-1.3.1 released.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

The major feature in this release is the addition 
of gssproxy support in the systemd scripts. 

When gssproxy is installed and and a key tab 
(/etc/krb5.keytab) exists, the gssproxy daemon 
will be started and the NFS server will use 
that daemon to manage the GSSAPI creds instead 
of rpc.svcgssd.

Rpc.svcgssd will continue to be used when gssproxy 
does not exist and a key tab does. 

One thing not addressed in this release is the tcp wrapper
changes to the mountd man page. I'm going to let distros
deal with that as they may.... I'm in favor of ripping 
all that code out, but I didn't want that to get in the 
way of this release.

The tarballs can be found in
  http://kernel.org/pub/linux/utils/nfs-utils/1.3.1/
or
  http://sourceforge.net/projects/nfs/files/nfs-utils/1.3.1

The change log is in
   http://kernel.org/pub/linux/utils/nfs-utils/1.3.1/1.3.1-ChangeLog
or
   http://sourceforge.net/projects/nfs/files/nfs-utils/1.3.1/

The git tree is at:
   git://linux-nfs.org/nfs-utils

Please send comments/bugs to linux-nfs@vger.kernel.org

steved.
