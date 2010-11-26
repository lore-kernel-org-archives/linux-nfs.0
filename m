Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.23]:47268 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754372Ab0KZMFq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Nov 2010 07:05:46 -0500
Date: Fri, 26 Nov 2010 13:05:41 +0100 (CET)
From: Guennadi Liakhovetski <g.liakhovetski@gmx.de>
To: linux-nfs@vger.kernel.org
cc: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Bryan Schumaker <bjschuma@netapp.com>, rees@umich.edu, sim@hostway.ca
Subject: [REGRESSION] git commit d1bacf9e "NFS: add readdir cache array" is
 bad
Message-ID: <Pine.LNX.4.64.1011261255260.16655@axis700.grange>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi all

I've bisected the problem, reported several times before:

http://www.spinics.net/lists/linux-nfs/msg17208.html
http://www.spinics.net/lists/linux-nfs/msg17298.html

(authors cc'ed) and also causing reproducibly problems on my sh7724 SuperH 
and sh7372 ARM Debian systems. Commit

commit d1bacf9eb2fd0e7ef870acf84b9e3b157dcfa7dc
Author: Bryan Schumaker <bjschuma@netapp.com>
Date:   Fri Sep 24 14:48:42 2010 -0400

    NFS: add readdir cache array

can be verified to be the culprit. Would be nice, if the other two 
reporters could also verify this commit. Or is there already a fix 
available?

Thanks
Guennadi
---
Guennadi Liakhovetski, Ph.D.
Freelance Open-Source Software Developer
http://www.open-technology.de/
