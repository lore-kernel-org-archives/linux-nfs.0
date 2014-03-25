Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hobo-dev.uvm.edu ([132.198.101.84]:58578 "EHLO hobo-dev.uvm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158AbaCYBZW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Mar 2014 21:25:22 -0400
Received: from hobo-dev.uvm.edu (localhost [127.0.0.1])
	by hobo-dev.uvm.edu (8.14.4/8.14.4) with ESMTP id s2P1PLJw051479
	for <linux-nfs@vger.kernel.org>; Mon, 24 Mar 2014 21:25:21 -0400
Message-Id: <cover.1395710586.git.root@hobo-dev.uvm.edu>
From: Benjamin Coddington <bcodding@uvm.edu>
To: linux-nfs@vger.kernel.org
Date: Mon, 24 Mar 2014 21:23:06 -0400
Subject: [PATCH 0/2] nfsidmap: a keyringer - 2nd try
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I took a second stab at this since it looks like fixing the keyrings is
probably the way to go.  This time through, the nfsidmap creates the
keyrings ad-hoc as they fill up instead of taking new command-line
parameters.  It also explicitly sets the permissions on the new keyrings, so
they should be able to be cleaned up in later kernels - though I haven't
tested that myself.

Ben

Benjamin Coddington (2):
  nfsidmap: Match names with kernel default keyring
  nfsidmap: Create id_resolver child keyrings

 utils/nfsidmap/nfsidmap.c |   76 ++++++++++++++++++++++++++++++++++++---------
 1 files changed, 61 insertions(+), 15 deletions(-)

