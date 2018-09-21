Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cliff.cs.toronto.edu ([128.100.3.120]:52370 "EHLO
        cliff.cs.toronto.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2391089AbeIVByV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Sep 2018 21:54:21 -0400
From: Chris Siebenmann <cks@cs.toronto.edu>
To: linux-nfs@vger.kernel.org
cc: cks@cs.toronto.edu
Subject: nfsiostat has a confusion about XPRT-related stats for at least NFSv3
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 21 Sep 2018 16:03:55 -0400
Message-Id: <20180921200355.6A25C322B90@apps1.cs.toronto.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 The nfsiostat program from nfs-utils currently reports and uses
XPRT related statistics on a per-mountpoint basis (it uses them for the
sort order of -s and thus potentially for -l's limit). This is natural,
since /proc/self/mountstats reports them on a per-mountstat basis.

 Unfortunately this is not actually accurate or correct. An XPRT can be
shared between mount points from the same NFS server (at least for NFS
v3). On our Ubuntu NFS clients, we typically see a single XPRT being
shared by all NFS mounts from a single fileserver, which can be over a
hundred mounts. Naturally these NFS mounts usually have wildly varying
levels of activity. As a result, nfsiostat's use of XPRT-based stats
often presents a highly misleading picture of per-mount activity and
(for us) makes both -s and -l into useless options.

 I'm not sure that there's any simple fix for this for nfsiostat. This
assumption about what the per-XPRT stats means strikes me as deeply
embedded into the structure of the code and the information it presents.
Fixing it may well call for a rethink of the information that nfsiostat
presents and how it gets presented, especially since per-XPRT information
might be useful to have by itself (which would probably call for another
output mode). This doesn't look like a simple patch, it looks like a
significant rewrite of portions of the current code, one driven by a
vision of what people want and what the output should be.

	- cks
