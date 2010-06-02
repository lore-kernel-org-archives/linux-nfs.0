From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 0/2] mountd.nfs: Better error diagnostics for the mount command
Date: Wed,  2 Jun 2010 09:41:22 -0400
Message-ID: <1275486084-23899-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:46012 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752933Ab0FBOyo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jun 2010 10:54:44 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1OJoCC-0002bc-Cb
	for linux-nfs@vger.kernel.org; Wed, 02 Jun 2010 09:41:24 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following two patches add better error diagnostics when
invalid protocol version are given and when the network protocol
can not be determined. 

Steve Dickson (2):
  mount.nfs: silently fails with bad version arguments
  mount.nfs: silently fails when the network protocol is not found

 utils/mount/network.c |   21 +++++++++++++++++++--
 utils/mount/stropts.c |   16 +++++++++++-----
 2 files changed, 30 insertions(+), 7 deletions(-)

