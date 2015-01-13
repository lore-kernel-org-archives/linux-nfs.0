Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45336 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751043AbbAMUhk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Jan 2015 15:37:40 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: [PATCH 0/3] Miscellaneous systemd changes 
Date: Tue, 13 Jan 2015 15:37:34 -0500
Message-Id: <1421181457-8159-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here are a few systemd changes that were suggested
by the systemd folks:

   * Bind the nfs-idmap service to the nfs server.
   * Correctly bind nfs-mountd service to the nfs server.
   * Used approved way to check if systemd is install and running

Steve Dickson (3):
  systemd: Bind rpc.idmapd to the nfs-server service
  systemd: Bind the nfs-mountd service to the nfs-server service
  start-statd: Use the canonical to check if systemd is running.

 systemd/nfs-idmapd.service | 2 +-
 systemd/nfs-mountd.service | 3 +--
 utils/statd/start-statd    | 2 +-
 3 files changed, 3 insertions(+), 4 deletions(-)

-- 
2.1.0

