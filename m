Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:43250 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1729293AbeHOSkb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 15 Aug 2018 14:40:31 -0400
From: Steve Dickson <SteveD@RedHat.com>
Subject: ANNOUNCE: rpcbind-1.2.5 released.
To: libtirpc <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-ID: <8fa4531b-4cb2-fa11-5241-f396e8747271@RedHat.com>
Date: Wed, 15 Aug 2018 11:47:51 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This release contains:
- Remote calls are disabled by default
- Fixed a few memory issues
- Fixed a few build and autotools issue
- Fixed a few boot and systemd issues. 

See the 1.2.5-ChangeLog for more details.  

Both the tarball and change log can be found at
  http://sourceforge.net/projects/rpcbind

The git tree was moved to:
   git://linux-nfs.org/~steved/rpcbind.git

Please send comments/bugs to linux-nfs@vger.kernel.org and/or
libtirpc-devel@lists.sourceforge.net

steved.
