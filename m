Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55118 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752558AbdDFQbF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Apr 2017 12:31:05 -0400
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7EB373DBCA
        for <linux-nfs@vger.kernel.org>; Thu,  6 Apr 2017 16:31:05 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v3 0/4] add systemd generator for the rpc_pipefs mountpoint
Date: Thu,  6 Apr 2017 12:31:00 -0400
Message-Id: <20170406163104.28397-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Changes since v2: retained the name "general" for the global section of
the /etc/nfs.conf file.

These patches aim to make it a little easier to change the mountpoint.
Right now if you change the pipefs-directory in /etc/nfs.conf, you still
need to manually override the dependencies in the systemd unit files in
order for the change to actually work.

The first patch moves rpc.idmapd's (mostly) undocumented
pipefs-directory from /etc/idmapd.conf to /etc/nfs.conf.

The second patch adds a deprecation warning to  rpc.gssd if it reads its
pipefs-directory setting from the [gssd] section of /etc/nfs.conf
instead of from the [general] section.

The third patch allows blkmapd to read its pipefs-directory setting from
the [general] section of /etc/nfs.conf as well (previously it was
hard-coded).

The final patch adds a systemd generator that reads the
pipefs-directory configuration from /etc/nfs.conf, and if it differs
from the default it will automatically create a systemd mount unit
file for the pipefs mountpoint and it will override the dependencies on
the pipefs mountpoint via the rpc_pipefs.target unit file.

Scott Mayhew (4):
  idmapd: move the pipefs-directory config option to nfs.conf
  gssd: add a deprecation warning for pipefs-directory in gssd section
  blkmapd:  allow the rpc_pipefs mountpoint to be overridden
  systemd: add a generator for the rpc_pipefs mountpoint

 .gitignore                       |   1 +
 nfs.conf                         |   6 +-
 systemd/Makefile.am              |   5 +-
 systemd/nfs-blkmap.service       |   4 +-
 systemd/nfs-idmapd.service       |   4 +-
 systemd/nfs.conf.man             |  13 ++-
 systemd/rpc-gssd.service.in      |   4 +-
 systemd/rpc-pipefs-generator.c   | 216 +++++++++++++++++++++++++++++++++++++++
 systemd/rpc-svcgssd.service      |   3 +-
 systemd/rpc_pipefs.target        |   3 +
 utils/blkmapd/blkmapd.man        |  17 ++-
 utils/blkmapd/device-discovery.c |  47 +++++++--
 utils/gssd/gssd.c                |   4 +
 utils/gssd/gssd.man              |  12 ++-
 utils/idmapd/idmapd.c            |  36 +++++--
 utils/idmapd/idmapd.man          |  21 +++-
 16 files changed, 360 insertions(+), 36 deletions(-)
 create mode 100644 systemd/rpc-pipefs-generator.c
 create mode 100644 systemd/rpc_pipefs.target

-- 
2.9.3

