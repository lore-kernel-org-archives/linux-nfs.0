From: Jon Forrest <jlforrest-TVLZxgkOlNX2fBVCVOL8/A@public.gmane.org>
Subject: To Automount or to Not Automount?
Date: Thu, 14 Jan 2010 12:00:48 -0800
Message-ID: <hint4t$gjt$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:42798 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757553Ab0ANUA6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Jan 2010 15:00:58 -0500
Received: from list by lo.gmane.org with local (Exim 4.50)
	id 1NVVsF-0001nM-Sq
	for linux-nfs@vger.kernel.org; Thu, 14 Jan 2010 21:00:55 +0100
Received: from nobozo.cchem.berkeley.edu ([128.32.50.5])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 14 Jan 2010 21:00:55 +0100
Received: from jlforrest by nobozo.cchem.berkeley.edu with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Thu, 14 Jan 2010 21:00:55 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I run several Beowulf-style compute clusters
using CentOS 5. The question has come up of
whether having the compute nodes automount
needed filesystems is really necessary.
Using the automounter complicates other
aspects of configuring the cluster, but
the cluster software designers believe
that the benefits of automounting outweigh
the negatives.

In a Beowulf-style cluster there is a private
usually >= 1Gb/sec ethernet that handles the
NFS traffic. There are no routers involved.
If the network has problems that would cause
NFS to misbehave then the cluster as a whole
is probably in trouble. So, you can assume
a properly configured and functioning network.

So, I'd like to ask the NFS experts on this
list whether in a CentOS 5 environment with
NFS3 mounts over a functional private network,
would using static mounts result in any negatives
as compared to automounts. I'm especially interested
in overhead on the NFS server.

Cordially,

-- 
Jon Forrest
Research Computing Support
College of Chemistry
173 Tan Hall
University of California Berkeley
Berkeley, CA
94720-1460
510-643-1032
jlforrest-TVLZxgkOlNX2fBVCVOL8/A@public.gmane.org

