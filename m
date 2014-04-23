Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:54758 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932511AbaDWU6U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Apr 2014 16:58:20 -0400
Received: from davros.ocarinaproject (davros.ocarinaproject.vpn.netapp.com
 [10.63.233.168])	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP
 id s3NKwIMk001951	for <linux-nfs@vger.kernel.org>; Wed, 23 Apr 2014 13:58:18
 -0700 (PDT)
Message-ID: <53582969.3050708@netapp.com>
Date: Wed, 23 Apr 2014 16:58:17 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: "linux- >> \"linux-nfs@vger.kernel.org\"" <linux-nfs@vger.kernel.org>
Subject: NFS RDMA Git Tree
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi everybody!

I'm going to try to collect NFS RDMA patches into a single git tree that Trond can eventually pull from.  I've started one at linux-nfs.org based on 3.15-rc2 with Chuck's patches and a few others applied on top.  Please let me know if I've missed a patch or if I've applied something that shouldn't be there!  The tree is at: git://git.linux-nfs.org/projects/anna/nfs-rdma.git and I'll try to stay on top of things moving forward.

Thanks,
Anna
