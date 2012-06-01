Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:40006 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964937Ab2FAPxO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jun 2012 11:53:14 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1SaUA3-00047b-46
	for linux-nfs@vger.kernel.org; Fri, 01 Jun 2012 17:53:11 +0200
Received: from NORTHWEST-R.edge3.Denver1.Level3.net ([4.28.99.98])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 01 Jun 2012 17:53:11 +0200
Received: from orion by NORTHWEST-R.edge3.Denver1.Level3.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 01 Jun 2012 17:53:11 +0200
To: linux-nfs@vger.kernel.org
From: Orion Poplawski <orion@cora.nwra.com>
Subject: Spurious rpc.idmapd =?utf-8?b?bnNzX2dldHB3bmFtOg==?= name 'nobody' does not map into domain messages
Date: Fri, 1 Jun 2012 15:53:02 +0000 (UTC)
Message-ID: <loom.20120601T174414-583@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm seeing a fair number of these messages on our file server:

Jun  1 09:37:58 alexandria rpc.idmapd[28890]: nss_getpwnam: name 'nobody' does
not map into domain 'cora.nwra.com'

I think they are coming from accessing files on another file server that are
owned by an unknown uid (user left and was removed from the user database). 
These files end up owned by "nobody" (as expected) on the remote system:

drwxr-xr-x.  7 nobody nwra 4096 Mar 15  2010 analysis_data

Now, this seems like a perfectly normal operation and so shouldn't generate a
system log message.  First two possible fixes I can think of:

- Should the remote system send the username as "nobody@cora.nwra.com" instead
of just "nobody"?

                            recc_attr: FATTR4_OWNER (36)
                                fattr4_owner: nobody
                                    length: 6
                                    contents: nobody
                                    fill bytes: opaque data
                            recc_attr: FATTR4_OWNER_GROUP (37)
                                fattr4_owner_group: nwra@cora.nwra.com
                                    length: 18
                                    contents: nwra@cora.nwra.com
                                    fill bytes: opaque data

- Don't log if the username is "nobody"?  Although since this is independently
configurable on the different machines this seems like a bad idea.  Maybe don't
log if there is no domain part at all?

This is on EL6 with nfs-utils-1.2.3-15.el6_2.1

Orion Poplawski

