Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47948 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757262AbcK3PgX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 30 Nov 2016 10:36:23 -0500
From: Steve Dickson <SteveD@redhat.com>
Subject: ANNOUNCE: rpcbind-0.2.4 released.
To: libtirpc <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-ID: <a9771c20-690c-7358-b38f-c0812cd9d783@RedHat.com>
Date: Wed, 30 Nov 2016 10:36:22 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This release contains:
- Memory corruption fix
- Moved the default state directory to /var/run
   Note: a restart of the NFS daemons is required
         if the warm start feature is enabled.
- Systemd unit files were added. 

See the 0.2.4-ChangeLog for more details.  

Both the tarball and change log can be found at
  http://sourceforge.net/projects/rpcbind

The git tree was moved to:
   git://linux-nfs.org/~steved/rpcbind.git

Please send comments/bugs to linux-nfs@vger.kernel.org and/or
libtirpc-devel@lists.sourceforge.net

steved.
