Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43916 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751091AbcLHE1r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 23:27:47 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>
Date: Thu, 08 Dec 2016 15:27:24 +1100
Subject: [nfs-utils PATCH 0/10] More support for /etc/nfs.conf
Cc: linux-nfs@vger.kernel.org
Message-ID: <148117122602.31271.13586847542442809540.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Added some missing support for rpc.nfsd, rpc.gss, rpc.svcgssd.
Fixed a bug.

Added generic support for "debug="
This only applies to tools which use the xlog() infrastructure.
blkmapd used syslog directly and gssd has it's own shim.  I think
they should be converted to xlog rather than having separate debug=
support.

NeilBrown

---

NeilBrown (10):
      nfsd: move and improve test on valid port
      nfsd: remove pointless memory allocations.
      nfsd: add /etc/nfs.conf support for nfsd.port option.
      nfsd: add /etc/nfs.conf support for host=
      conffile: allow embedded spaces in values.
      conffile: fix striping of quotes from values.
      xlog: Add common support for "debug=??" in /etc/nfs.conf
      exportfs: allow debugging to be enabled in nfs.conf
      gssd: add /etc/nfs.conf support
      svcgssd: add /etc/nfs.conf support


 support/include/xlog.h          |    1 +
 support/nfs/conffile.c          |   24 ++++++++++-------
 support/nfs/xlog.c              |   14 ++++++++++
 systemd/nfs.conf.man            |   49 ++++++++++++++++++++++++++++++++++-
 utils/exportfs/exportfs.c       |    5 ++++
 utils/exportfs/exportfs.man     |    8 ++++++
 utils/gssd/gssd.c               |   29 +++++++++++++++++++++
 utils/gssd/gssd.man             |   54 +++++++++++++++++++++++++++++++++++++++
 utils/gssd/svcgssd.c            |   14 ++++++++++
 utils/gssd/svcgssd.man          |   17 ++++++++++++
 utils/mountd/mountd.c           |    1 +
 utils/nfsd/nfsd.c               |   48 +++++++++++++++++++++++------------
 utils/nfsd/nfsd.man             |   10 +++++++
 utils/nfsdcltrack/nfsdcltrack.c |    1 +
 utils/statd/sm-notify.c         |    1 +
 utils/statd/statd.c             |    1 +
 16 files changed, 249 insertions(+), 28 deletions(-)

--
Signature

