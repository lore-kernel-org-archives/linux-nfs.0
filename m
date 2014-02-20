Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:42750 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751183AbaBTGih (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Feb 2014 01:38:37 -0500
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 20 Feb 2014 17:36:48 +1100
Subject: [nfs-utils RPC-PATCH 0/4] Add options to nfsd etc to avoid needing to write to /proc
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140220063616.6548.42556.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are a number of NFS-related setting that currently must be set
by writing to various files under /proc.
This is a bit clumsy, particularly for systemd unit files.

So this series adds options to a number of commands where relevant.

The first two (rdma, and  nfsv4{grace,lease}time) I am quite comfortable with.
The third (nlm grace time) I think is probably right but if someone can argue
 an alternate approach I'm unlikely to resist.
The fourth is .... uhm.  You better look yourself.

Part of me thinks that nlm port numbers should be set in /etc/sysctl.conf (or sysctl.d)
and /etc/modprobe.d should have something like

 install lockd  sysctl -p /etc/sysctl.d/lockd

but last time I tried that it broke "modprobe --show-depends".
Also it is awkward to get setting from /etc/sysconfig/nfs into /etc/sysctl.d/lockd

Thoughts?

Thanks,
NeilBrown


---

Neil Brown (4):
      nfsd: add -r and --rdma options to request rdma service.
      nfsd: alloc nfsv4leasetime and nfsv4gracetime to be set.
      nfsd: set nlm grace time to make NFSv4 grace time
      statd: add options to set port number of lockd.


 utils/nfsd/nfsd.c     |   52 +++++++++++++++++++++++++++++++++++++++----
 utils/nfsd/nfsd.man   |   21 +++++++++++++++++
 utils/nfsd/nfssvc.c   |   59 +++++++++++++++++++++++++++++++++++++++++++++++++
 utils/nfsd/nfssvc.h   |    2 ++
 utils/statd/statd.c   |   57 +++++++++++++++++++++++++++++++++++++++++++++--
 utils/statd/statd.man |   24 ++++++++++++++++++--
 6 files changed, 204 insertions(+), 11 deletions(-)

-- 
Signature

