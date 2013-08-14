Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:38809 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932956Ab3HNTKX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Aug 2013 15:10:23 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1V9gSV-0003eK-V9
	for linux-nfs@vger.kernel.org; Wed, 14 Aug 2013 21:10:16 +0200
Received: from NORTHWEST-R.edge3.Denver1.Level3.net ([4.28.99.98])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 14 Aug 2013 21:10:15 +0200
Received: from orion by NORTHWEST-R.edge3.Denver1.Level3.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 14 Aug 2013 21:10:15 +0200
To: linux-nfs@vger.kernel.org
From: Orion Poplawski <orion@cora.nwra.com>
Subject: rpc.idmapd: =?utf-8?b?bnNzX2dldHB3bmFtOg==?= name '#' does not map into domain 
Date: Wed, 14 Aug 2013 19:09:56 +0000 (UTC)
Message-ID: <loom.20130814T210744-290@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On our EL6 nfs servers we see periodic messages like:

Aug 14 12:55:19 alexandria rpc.idmapd[19237]: nss_getpwnam: name '612' does
not map into domain 'cora.nwra.com'

I imagine that this is caused by a client actually passing the uid instead
of the username for some reason but I have no idea how to track down which.
 Any ideas?

