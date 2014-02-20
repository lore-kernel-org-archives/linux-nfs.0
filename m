Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:43383 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750703AbaBTG4K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Feb 2014 01:56:10 -0500
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 20 Feb 2014 17:55:30 +1100
Subject: [nfs-utils/systemd PATCH 0/6] Assorted fixes for systemd units
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140220065345.7320.49992.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These are a number of ad-hoc things I.  The nfs-utils_env.sh for SUSE
is primarily presented as an example.  I'm happy for it to get
applied, but I'm happy if it isn't applied too.

Thanks,
NeilBrown


---

Neil Brown (6):
      systemd units: remove reference to nfs-server.target from nfs-server.service.
      systemd units: create nfs-config.service as single location to process config.
      systemd: add nfs-utils_env.sh for SUSE.
      systemd: remove @localstatedir@ marking.
      systemd: nfs-client needs rpc-svcgssd too.
      systemd: add PIDFile directives where appropriate.


 systemd/README                   |    3 +-
 systemd/SUSE-nfs-utils_env.sh    |   62 ++++++++++++++++++++++++++++++++++++++
 systemd/nfs-blkmap.service       |    1 +
 systemd/nfs-client.target        |    5 ++-
 systemd/nfs-config.service       |    7 ++++
 systemd/nfs-idmapd.service       |    5 ++-
 systemd/nfs-mountd.service       |    5 ++-
 systemd/nfs-server.service       |    5 ++-
 systemd/rpc-gssd.service         |    4 ++
 systemd/rpc-statd-notify.service |    5 ++-
 systemd/rpc-statd.service        |    6 ++--
 systemd/rpc-svcgssd.service      |    7 ++--
 12 files changed, 97 insertions(+), 18 deletions(-)
 create mode 100644 systemd/SUSE-nfs-utils_env.sh
 create mode 100644 systemd/nfs-config.service

-- 
Signature

