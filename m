Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 178.141.211.66.inaddr.G4.NET ([66.211.141.178]:47120 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756315Ab1KWPYF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Nov 2011 10:24:05 -0500
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=tophat.home.4dicksons.org.home.4dicksons.org)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1RTEda-0003qX-By
	for linux-nfs@vger.kernel.org; Wed, 23 Nov 2011 10:21:26 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] nfsidmap: Allow admins to clean up id mappings that have (ver 3)
Date: Wed, 23 Nov 2011 10:24:00 -0500
Message-Id: <1322061842-1806-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In working with the new idmapper, it became very apparent that
keys created from bad id mapping were very persistent and were
not easy disposed of. Unlike with rpc.idmapd, to git rid 
of bad id mapping one just needed to restart the daemon. 

So I've added some functionality to the nfsidmap command
that will allow admins to:

    - remove all the keys on the keyring.
    - remove a particular key from the keying.

The intention is to allow admins a way to clean up the id
name space when name resolution mechanisms, like NIS or LDAP, 
fail and leave a large number (or small number) of id mapping 
pointing to nobody. 

Note, for the second patch to work, there need to be a small 
kernel patch that will change the per-key permissions to
allow root to revoke them.

Version 2:
- Added the fclose() calls as requested by the code review
Version 3:
- Confined the -c flag to only remove keys from the id_resolver keyring.

Steve Dickson (2):
  nfsidmap: Allow keys to be cleared from the keyring
  nfsidmap: Allow a particular key to be revoked.

 utils/nfsidmap/nfsidmap.c   |  148 +++++++++++++++++++++++++++++++++++++++++--
 utils/nfsidmap/nfsidmap.man |   25 +++++++-
 2 files changed, 167 insertions(+), 6 deletions(-)

-- 
1.7.7

