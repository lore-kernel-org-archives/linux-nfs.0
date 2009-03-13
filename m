From: Brian Wince <bwince-gvzKVTG1yJJBDgjK7y7TUQ@public.gmane.org>
Subject: issues with project quota over nfs
Date: Fri, 13 Mar 2009 09:59:26 -0700
Message-ID: <AD300F292705ED4089373955E129C1780491E77D@RBSJX.ad.redback.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mgate.redback.com ([155.53.3.41]:8107 "EHLO mgate.redback.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760713AbZCMRI5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Mar 2009 13:08:57 -0400
Received: from localhost (localhost [127.0.0.1])
	by prattle.redback.com (Postfix) with ESMTP id F04BD979EFA
	for <linux-nfs@vger.kernel.org>; Fri, 13 Mar 2009 09:59:27 -0700 (PDT)
Received: from prattle.redback.com ([127.0.0.1])
 by localhost (prattle [127.0.0.1]) (amavisd-new, port 10024) with ESMTP
 id 30181-09 for <linux-nfs@vger.kernel.org>;
 Fri, 13 Mar 2009 09:59:27 -0700 (PDT)
Received: from rbsjx.ad.redback.com (rbsjxh1.redback.com [155.53.14.105])
	by prattle.redback.com (Postfix) with ESMTP id DBF42979EF9
	for <linux-nfs@vger.kernel.org>; Fri, 13 Mar 2009 09:59:27 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All,
We have a Quad-core server running gentoo 2.6.27-r7 that is used as an nfs server for a xfs partition.
We are using project quota's on directories within this partition and exporting this.
When a client tries to untar in the dir with project quotas set and reaches the quota limit the load on the NFS server goes up dramatically and stays like this for a few minutes after the tar has gone through trying to write all of it files and failing due to quota limit exceeded.
 
Is this a known issue and if so is there anything that can be done to resolve this.
 
We do not see this issue if on the locally mounted partition. This only happens over NFS.
 
Please let me know if you need more information or if this should be addressed on a different list.
 
TIA,

Brian
